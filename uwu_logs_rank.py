import requests
import os
import json
import subprocess
import asyncio
import aiohttp
from datetime import datetime

TOP_POINTS_URL = "https://uwu-logs.xyz/top_points"
REALM = "Icecrown"
OUTPUT_DIR = "UwULogsData"

MAX_PLAYERS = 1000
MAX_CONCURRENT_REQUESTS = 20

GITHUB_TOKEN = "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"
GITHUB_REPO_URL = "https://github.com/Bomo2/UwULogsTooltip.git"

classes_and_specs = {
    0: {"Blood": 1, "Frost": 2, "Unholy": 3},
    1: {"Balance": 1, "Feral Combat": 2, "Restoration": 3},
    2: {"Beast Mastery": 1, "Marksmanship": 2, "Survival": 3},
    3: {"Arcane": 1, "Fire": 2, "Frost": 3},
    4: {"Holy": 1, "Protection": 2, "Retribution": 3},
    5: {"Discipline": 1, "Holy": 2, "Shadow": 3},
    6: {"Assassination": 1, "Combat": 2, "Subtlety": 3},
    7: {"Elemental": 1, "Enhancement": 2, "Restoration": 3},
    8: {"Affliction": 1, "Demonology": 2, "Destruction": 3},
    9: {"Arms": 1, "Fury": 2, "Protection": 3},
}

HEADERS = {
    "Content-Type": "application/json",
    "Origin": "https://uwu-logs.xyz",
    "Referer": "https://uwu-logs.xyz/top",
    "User-Agent": "Mozilla/5.0"
}

os.makedirs(OUTPUT_DIR, exist_ok=True)

def lua_escape(s):
    return s.replace("\\", "\\\\").replace("\"", "\\\"")

def to_lua_table_string(data, indent=0):
    lua_lines = []
    prefix = "  " * indent

    if isinstance(data, dict):
        lua_lines.append("{")
        for k, v in data.items():
            key_str = f"[\"{lua_escape(str(k))}\"]" if isinstance(k, str) else f"[{k}]"
            value_str = to_lua_table_string(v, indent+1)
            lua_lines.append(f"{prefix}  {key_str} = {value_str},")
        lua_lines.append(f"{prefix}}}")
    elif isinstance(data, list):
        lua_lines.append("{")
        for v in data:
            value_str = to_lua_table_string(v, indent+1)
            lua_lines.append(f"{prefix}  {value_str},")
        lua_lines.append(f"{prefix}}}")
    elif isinstance(data, str):
        lua_lines.append(f"\"{lua_escape(data)}\"")
    elif data is None:
        lua_lines.append("nil")
    else:
        lua_lines.append(str(data))

    return "\n".join(lua_lines)

async def fetch_top_players(session, class_i, spec_i, semaphore):
    payload = {
        "class_i": class_i,
        "spec_i": spec_i,
        "server": REALM,
        "raid": "Points",
        "boss": "Points",
        "size": 25,
        "mode": 0,
        "best": 1,
        "limit": MAX_PLAYERS
    }

    async with semaphore:
        try:
            async with session.post(TOP_POINTS_URL, headers=HEADERS, json=payload) as resp:
                if resp.status == 200:
                    return await resp.json()
                else:
                    print(f"Erreur {resp.status} pour class {class_i} spec {spec_i}")
                    return []
        except Exception as e:
            print(f"Exception pour class {class_i} spec {spec_i}: {e}")
            return []

async def fetch_player_detail(session, player_name, spec_i, semaphore):
    url = f"https://uwu-logs.xyz/character/{REALM}/{player_name}/{spec_i}"

    async with semaphore:
        try:
            async with session.get(url) as resp:
                if resp.status == 200:
                    return await resp.json()
                else:
                    print(f"Erreur {resp.status} pour {player_name}")
                    return None
        except Exception as e:
            print(f"Exception pour {player_name}: {e}")
            return None

async def process_spec(class_i, spec_str):
    spec_i = classes_and_specs[class_i][spec_str]
    print(f"Processing class {class_i} spec {spec_i} ({spec_str})...")

    lua_table = {}
    semaphore = asyncio.Semaphore(MAX_CONCURRENT_REQUESTS)

    async with aiohttp.ClientSession() as session:
        top_players = await fetch_top_players(session, class_i, spec_i, semaphore)

        tasks = []
        player_infos = []

        for player_data in top_players[:MAX_PLAYERS]:
            if isinstance(player_data, list) and len(player_data) >= 3:
                player_name, percentile, total = player_data
                player_infos.append((player_name, percentile, total))
                tasks.append(fetch_player_detail(session, player_name, spec_i, semaphore))

        responses = await asyncio.gather(*tasks)

    for i, details in enumerate(responses):
        if not details:
            continue

        player_name, percentile, total = player_infos[i]

        player_entry = {
            "percentile": percentile,
            "server": details.get("server"),
            "overall_rank": details.get("overall_rank"),
            "bosses": {}
        }

        for boss_name, boss_data in details.get("bosses", {}).items():
            player_entry["bosses"][boss_name] = {
                "rank_raids": boss_data.get("rank_raids"),
                "dps_max": boss_data.get("dps_max"),
                "points": boss_data.get("points")
            }

        lua_table[player_name] = player_entry

    out_file = os.path.join(OUTPUT_DIR, f"class_{class_i}_spec_{spec_i}.lua")
    with open(out_file, "w", encoding="utf-8") as f_out:
        lua_content = f"UWULogsData = UWULogsData or {{}}\nUWULogsData[{class_i}] = UWULogsData[{class_i}] or {{}}\nUWULogsData[{class_i}][{spec_i}] = {to_lua_table_string(lua_table)}\n"
        f_out.write(lua_content)

    print(f"✅ Saved LUA: class_{class_i}_spec_{spec_i}.lua")

def push_to_github():
    print("=== UwULogs: Pushing updated LUA files to GitHub ===")
    repo_dir = os.path.abspath(os.path.dirname(__file__))

    subprocess.run(["git", "config", "user.name", "UwULogsBot"], cwd=repo_dir)
    subprocess.run(["git", "config", "user.email", "bot@uwulogs.local"], cwd=repo_dir)

    subprocess.run(["git", "add", "--all", "UwULogsData/"], cwd=repo_dir)

    commit_msg = f"UwULogsData auto update - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
    subprocess.run(["git", "commit", "-m", commit_msg], cwd=repo_dir, check=False)

    remote_with_token = GITHUB_REPO_URL.replace("https://", f"https://{GITHUB_TOKEN}@")
    subprocess.run(["git", "remote", "set-url", "origin", remote_with_token], cwd=repo_dir)

    subprocess.run(["git", "pull", "--rebase", "origin", "main"], cwd=repo_dir)
    subprocess.run(["git", "push", "origin", "main"], cwd=repo_dir)

    print("✅ UwULogs: Data pushed successfully to GitHub.")

def main():
    asyncio.run(run_all())

async def run_all():
    for class_i, specs in classes_and_specs.items():
        for spec_name in specs.keys():
            await process_spec(class_i, spec_name)

    push_to_github()

if __name__ == "__main__":
    main()