import json
import os

INPUT_DIR = "specs_json"
OUTPUT_FILE = "UWULogsData.lua"

def lua_safe_string(s):
    return s.replace("\\", "\\\\").replace('"', '\\"')

output = ["UWULogsData = {}"]

for filename in os.listdir(INPUT_DIR):
    if filename.endswith(".json"):
        path = os.path.join(INPUT_DIR, filename)
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        
        class_i = data.get("class_i")
        spec_i = data.get("spec_i")
        players = data.get("players", [])

        output.append(f"UWULogsData[{class_i}] = UWULogsData[{class_i}] or {{}}")
        output.append(f"UWULogsData[{class_i}][{spec_i}] = {{}}")

        for player in players:
            name = lua_safe_string(player.get("name", ""))
            percentile = player.get("percentile", 0)
            details = player.get("details")

            if not details:
                continue  # Skip si pas de détails

            server = lua_safe_string(details.get("server", ""))
            overall_rank = details.get("overall_rank", 0)
            bosses_data = details.get("bosses", {})

            output.append(f"UWULogsData[{class_i}][{spec_i}][\"{name}\"] = {{")
            output.append(f'  percentile = {percentile},')
            output.append(f'  server = "{server}",')
            output.append(f'  overall_rank = {overall_rank},')
            output.append('  bosses = {')

            for boss_name, boss_info in bosses_data.items():
                boss_name_lua = lua_safe_string(boss_name)
                rank_raids = boss_info.get("rank_raids", 0)
                dps_max = boss_info.get("dps_max", 0)
                points = boss_info.get("points", 0)

                output.append(f'    ["{boss_name_lua}"] = {{ rank_raids = {rank_raids}, dps_max = {dps_max}, points = {points} }},')

            output.append('  }')
            output.append('}')

output_str = "\n".join(output)
with open(OUTPUT_FILE, "w", encoding="utf-8") as f_out:
    f_out.write(output_str)

print(f"✅ Exported to {OUTPUT_FILE}")