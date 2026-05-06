local _, DCT = ...

DCT.QUESTS = {
    { id = 93372, step = 1,  name = "Shadow Enclave",       zoneKey = "EV", zone = "Eversong Woods",     mapID = 2395, x = 45.4,  y = 86.0 },
    { id = 93384, step = 2,  name = "Collegiate Calamity",  zoneKey = "SM", zone = "Silvermoon City",    mapID = 2393, x = 40.76, y = 54.06 },
    { id = 93385, step = 3,  name = "The Darkway",          zoneKey = "SM", zone = "Silvermoon City",    mapID = 2393, x = 39.3,  y = 32.1 },
    { id = 93386, step = 4,  name = "Parhelion Plaza",      zoneKey = "QD", zone = "Isle of Quel'Danas", mapID = 2424, x = 47.74, y = 41.58 },
    { id = 93409, step = 5,  name = "Atal'Aman",            zoneKey = "ZA", zone = "Zul'Aman",           mapID = 2437, x = 24.8,  y = 53.0 },
    { id = 93410, step = 6,  name = "Twilight Crypts",      zoneKey = "ZA", zone = "Zul'Aman",           mapID = 2437, x = 25.4,  y = 84.3 },
    { id = 93416, step = 7,  name = "The Gulf of Memory",   zoneKey = "HA", zone = "Harandar",           mapID = 2413, x = 36.3,  y = 49.2 },
    { id = 93421, step = 8,  name = "The Grudge Pit",       zoneKey = "HA", zone = "Harandar",           mapID = 2413, x = 70.5,  y = 64.9 },
    { id = 93427, step = 9,  name = "Sunkiller Sanctum",    zoneKey = "VS", zone = "Voidstorm",          mapID = 2405, x = 54.8,  y = 47.0 },
    { id = 93428, step = 10, name = "Shadowguard Point",    zoneKey = "VS", zone = "Voidstorm",          mapID = 2405, x = 37.38, y = 47.7 },
}

DCT.TURN_IN_POINTS = {
    [93372] = { mapID = 2393, x = 52.6, y = 78.0 }, -- Naleidea Rivergleam
    [93384] = { mapID = 2393, x = 52.6, y = 78.0 }, -- Naleidea Rivergleam
    [93409] = { mapID = 2437, x = 45.4, y = 65.0 }, -- Tavikko
    [93410] = { mapID = 2437, x = 45.4, y = 65.0 }, -- Tavikko
    [93416] = { mapID = 2413, x = 54.2, y = 53.0 }, -- Zur'ashar Kassameh
    [93421] = { mapID = 2413, x = 71.8, y = 64.0 }, -- Boletus
    [93427] = { mapID = 2405, x = 51.4, y = 67.6 }, -- Perodius
    [93428] = { mapID = 2405, x = 51.4, y = 67.6 }, -- Perodius
}

DCT.SILVERMOON_MAP_ID = 2393

DCT.ROUTE_ZONE_BY_MAP_ID = {
    [2393] = "SM",
    [2395] = "SM",
    [2424] = "QD",
    [2413] = "HA",
    [2523] = "HA",
    [2405] = "VS",
    [2527] = "VS",
}

DCT.COMMON_ROUTE_STEPS = {
    SilvermoonToQuelDanas = { mapID = DCT.SILVERMOON_MAP_ID, x = 50.97, y = 71.25, descKey = "ROUTE_SILVERMOON_TO_QUELDANAS" },
    QuelDanasToSilvermoon = { mapID = 2424, x = 57.55, y = 33.85, descKey = "ROUTE_QUELDANAS_TO_SILVERMOON" },
    SilvermoonToHarandar = { mapID = DCT.SILVERMOON_MAP_ID, x = 36.96, y = 67.99, descKey = "ROUTE_SILVERMOON_TO_HARANDAR" },
    HarandarToSilvermoon = { mapID = 2413, x = 53.36, y = 55.42, descKey = "ROUTE_HARANDAR_TO_SILVERMOON" },
    SilvermoonToVoidstorm = { mapID = DCT.SILVERMOON_MAP_ID, x = 35.28, y = 66.18, descKey = "ROUTE_VOIDSTORM_PORTAL" },
    VoidstormToSilvermoon = { mapID = 2405, x = 51.56, y = 70.29, descKey = "ROUTE_VOIDSTORM_TO_SILVERMOON" },
}

DCT.ROUTE_FROM_SILVERMOON = {
    QD = DCT.COMMON_ROUTE_STEPS.SilvermoonToQuelDanas,
    HA = DCT.COMMON_ROUTE_STEPS.SilvermoonToHarandar,
    VS = DCT.COMMON_ROUTE_STEPS.SilvermoonToVoidstorm,
}

DCT.ROUTE_TO_SILVERMOON = {
    QD = DCT.COMMON_ROUTE_STEPS.QuelDanasToSilvermoon,
    HA = DCT.COMMON_ROUTE_STEPS.HarandarToSilvermoon,
    VS = DCT.COMMON_ROUTE_STEPS.VoidstormToSilvermoon,
}

DCT.DEFAULT_CONFIG = {
    language = "auto",
    ui = {
        fontSize = 12,
        width = 460,
        rowHeight = 34,
        scale = 1,
        activeTabKey = "not_started",
        hideInCombat = false,
        autohide = false,
        colors = {
            pending = "FFFF8000",
            active = "FF00B7FF",
            ready = "FFAA66FF",
            completed = "FF7CFF4D",
        },
    },
}

DCT.STATUS = {
    NOT_STARTED = 0,
    IN_PROGRESS = 1,
    READY = 2,
    COMPLETED = 3,
}

DCT.STATUS_COLOR_KEY = {
    [DCT.STATUS.NOT_STARTED] = "pending",
    [DCT.STATUS.IN_PROGRESS] = "active",
    [DCT.STATUS.READY] = "ready",
    [DCT.STATUS.COMPLETED] = "completed",
}

DCT.TABS = {
    { key = "not_started", labelKey = "TAB_NOT_STARTED", descriptionKey = "TAB_NOT_STARTED_DESC", statuses = { [DCT.STATUS.NOT_STARTED] = true } },
    { key = "progress", labelKey = "TAB_PROGRESS", descriptionKey = "TAB_PROGRESS_DESC", statuses = { [DCT.STATUS.IN_PROGRESS] = true } },
    { key = "ready", labelKey = "TAB_READY", descriptionKey = "TAB_READY_DESC", statuses = { [DCT.STATUS.READY] = true } },
    { key = "completed", labelKey = "TAB_COMPLETED", descriptionKey = "TAB_COMPLETED_DESC", statuses = { [DCT.STATUS.COMPLETED] = true } },
}

DCT.GOLD = { 0.90, 0.74, 0.00 }
DCT.PANEL_PADDING = 14
DCT.MIN_FRAME_HEIGHT = 150
