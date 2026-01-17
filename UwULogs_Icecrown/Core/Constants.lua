local _, Private = ...

-- specID used for LibGroupTalents
Private.UWULogsSpecMapping = {
    WARRIOR = { ["Arms"] = 1, ["Fury"] = 2, ["Protection"] = 3 },
    PALADIN = { ["Holy"] = 1, ["Protection"] = 2, ["Retribution"] = 3 },
    HUNTER = { ["Beast Mastery"] = 1, ["Marksmanship"] = 2, ["Survival"] = 3 },
    ROGUE = { ["Assassination"] = 1, ["Combat"] = 2, ["Subtlety"] = 3 },
    PRIEST = { ["Discipline"] = 1, ["Holy"] = 2, ["Shadow"] = 3 },
    DEATHKNIGHT = { ["Blood"] = 1, ["Frost"] = 2, ["Unholy"] = 3 },
    SHAMAN = { ["Elemental"] = 1, ["Enhancement"] = 2, ["Restoration"] = 3 },
    MAGE = { ["Arcane"] = 1, ["Fire"] = 2, ["Frost"] = 3 },
    WARLOCK = { ["Affliction"] = 1, ["Demonology"] = 2, ["Destruction"] = 3 },
    DRUID = { ["Balance"] = 1, ["Feral Combat"] = 2, ["Restoration"] = 3 },
}

-- Icon Spec
Private.SPEC_ICONS = {
    DEATHKNIGHT = {
        "Interface\\Icons\\Spell_Deathknight_BloodPresence",
        "Interface\\Icons\\Spell_Deathknight_FrostPresence",
        "Interface\\Icons\\Spell_Deathknight_UnholyPresence"
    },
    DRUID = {
        "Interface\\Icons\\Spell_Nature_Starfall",
        "Interface\\Icons\\Ability_Druid_CatForm",
        "Interface\\Icons\\Spell_Nature_HealingTouch"
    },
    HUNTER = {
        "Interface\\Icons\\Ability_Hunter_BeastTaming",
        "Interface\\Icons\\Ability_Hunter_Focusedaim",
        "Interface\\Icons\\Ability_Hunter_Swiftstrike"
    },
    MAGE = {
        "Interface\\Icons\\Spell_Holy_ArcaneIntellect",
        "Interface\\Icons\\Spell_Fire_FireBolt02",
        "Interface\\Icons\\Spell_Frost_FrostBolt02"
    },
    PALADIN = {
        "Interface\\Icons\\Spell_Holy_HolyBolt",
        "Interface\\Icons\\Spell_Holy_Devotionaura",
        "Interface\\Icons\\Spell_Holy_AuraOfLight"
    },
    PRIEST = {
        "Interface\\Icons\\Spell_Holy_PowerWordShield",
        "Interface\\Icons\\Spell_Holy_GuardianSpirit",
        "Interface\\Icons\\Spell_Shadow_ShadowWordPain"
    },
    ROGUE = {
        "Interface\\Icons\\Ability_Rogue_Eviscerate",
        "Interface\\Icons\\Ability_BackStab",
        "Interface\\Icons\\Ability_Stealth"
    },
    SHAMAN = {
        "Interface\\Icons\\Spell_Nature_Lightning",
        "Interface\\Icons\\Spell_Nature_Lightningshield",
        "Interface\\Icons\\Spell_Nature_MagicImmunity"
    },
    WARLOCK = {
        "Interface\\Icons\\Spell_Shadow_DeathCoil",
        "Interface\\Icons\\Spell_Shadow_Metamorphosis",
        "Interface\\Icons\\Spell_Shadow_RainOfFire"
    },
    WARRIOR = {
        "Interface\\Icons\\Ability_Warrior_SavageBlow",
        "Interface\\Icons\\Ability_Warrior_InnerRage",
        "Interface\\Icons\\Ability_Warrior_DefensiveStance"
    },
}

-- Class Color
Private.CLASS_COLORS = {
    WARRIOR     = "|cFFC79C6E",
    PALADIN     = "|cFFF58CBA",
    PRIEST      = "|cFFFFFFFF",
    MAGE        = "|cFF40C7EB",
    ROGUE       = "|cFFFFF569",
    HUNTER      = "|cFFABD473",
    SHAMAN      = "|cFF0070DE",
    WARLOCK     = "|cFF8788EE",
    DEATHKNIGHT = "|cFFC41F3B",
    DRUID       = "|cFFFF7D0A",
}

-- Class ID
Private.classFile_to_id = {
    DEATHKNIGHT = 0,
    DRUID       = 1,
    HUNTER      = 2,
    MAGE        = 3,
    PALADIN     = 4,
    PRIEST      = 5,
    ROGUE       = 6,
    SHAMAN      = 7,
    WARLOCK     = 8,
    WARRIOR     = 9,
}

-- Bosses key
Private.BossNameLookup = {
    bql = "Blood-Queen Lana'thel",
    pp  = "Professor Putricide",
    lm  = "Lord Marrowgar",
    ldw = "Lady Deathwhisper",
    ds  = "Deathbringer Saurfang",
    fg  = "Festergut",
    rf  = "Rotface",
    bpc = "Blood Prince Council",
    sg  = "Sindragosa",
    lk  = "The Lich King",
}

-- Boss Order Display
Private.BossOrder = { "lm", "ldw", "ds", "fg", "rf", "pp", "bpc", "bql", "sg", "lk" }