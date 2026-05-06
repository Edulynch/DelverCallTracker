local _, DCT = ...

DCT.LOCALES = {
    en = {
        ADDON_TITLE = "Delver Call Tracker",
        HEADER = "Delver's Call - Midnight",
        TAB_CREATOR = "Creator",
        ENTRY = "Entry",
        MAP_ID = "Map ID",
        QUEST_ID = "Quest ID",
        READY_COUNT = "Ready/turned in: %d/%d",
        TAB_NOT_STARTED = "Not Taken",
        TAB_PROGRESS = "In Progress",
        TAB_READY = "Completed",
        TAB_COMPLETED = "Turned In",
        EMPTY_TAB = "No quests in this tab.",
        FILTER_LABEL = "Filter: %s (%d)",
        FILTER_TOOLTIP = "Click to change the filter.",
        TAB_NOT_STARTED_DESC = "Mission not taken. This mission can be picked up inside its respective delve.",
        TAB_PROGRESS_DESC = "Mission in progress. Click a delve to mark its entrance by zone.",
        TAB_READY_DESC = "Mission completed. Click the respective delve by zone to find where to turn in the mission.",
        TAB_COMPLETED_DESC = "Mission already turned in. These entries are kept here as completed tracking.",
        STATUS_PENDING = "MISSING",
        STATUS_ACTIVE = "ACTIVE",
        STATUS_READY = "READY",
        STATUS_DONE = "TURNED IN",
        TOOLTIP_ENTRY = "Delve entrance",
        TOOLTIP_CLICK = "Click to create the waypoint directly.",
        TOOLTIP_CLICK_READY = "Click to mark the turn-in location when available.",
        WAYPOINT_TOMTOM = "TomTom waypoint created: %s (%d %.2f %.2f)",
        WAYPOINT_NATIVE = "Game waypoint created: %s (%d %.2f %.2f)",
        WAYPOINT_FAILED = "Could not create waypoint. Enable TomTom or use a current Retail client.",
        ROUTE_STARTED = "Route started: %s",
        ROUTE_NEXT = "Route step: %s",
        ROUTE_SILVERMOON_TO_QUELDANAS = "Use the Silvermoon flight master to reach Isle of Quel'Danas",
        ROUTE_QUELDANAS_TO_SILVERMOON = "Use the Terrace of the Sun flight master to return to Silvermoon City",
        ROUTE_SILVERMOON_TO_HARANDAR = "Use the Rootway to Harandar in Silvermoon City",
        ROUTE_HARANDAR_TO_SILVERMOON = "Use the Eversong Rootway in Harandar to return to Silvermoon City",
        ROUTE_VOIDSTORM_PORTAL = "Take the Voidstorm portal in Silvermoon City",
        ROUTE_VOIDSTORM_TO_SILVERMOON = "Use the Silvermoon portal in Voidstorm",
        ROUTE_FINAL = "Fly to the delve entrance",
        ROUTE_TURNIN = "Turn in the quest",
        TURNIN_TITLE = "Turn in: %s",
        LOADED = "loaded. Use /dcall, /dct or /delverscall.",
        CLOSE_MESSAGE = "Panel closed. Use /dcall, /dct, /delverscall or /delvercalltracker to open it again. Use /dcall help to see all commands.",
        HELP_HEADER = "Delver Call Tracker commands:",
        HELP_OPEN = "/dcall, /dct, /delverscall - open the tracker",
        HELP_SETTINGS = "/dcall settings - open addon settings",
        HELP_COMBAT = "/dcall combat enable|disable - hide/show the tracker during combat",
        HELP_AUTOHIDE = "/dcall autohide enable|disable - only show the tracker on mouseover",
        HELP_SHOW = "/dcall show|hide|toggle - control the tracker panel",
        SETTINGS_OPENED = "Opening addon settings.",
        COMBAT_ENABLED = "Hide in combat enabled.",
        COMBAT_DISABLED = "Hide in combat disabled.",
        AUTOHIDE = "Autohide",
        AUTOHIDE_TIP = "Only shows the tracker while your mouse is over it.",
        AUTOHIDE_ENABLED = "Autohide enabled.",
        AUTOHIDE_DISABLED = "Autohide disabled.",
        SETTINGS_GENERAL = "General",
        SETTINGS_APPEARANCE = "Appearance",
        SETTINGS_COLORS = "Colors",
        SETTINGS_LANGUAGE = "Language",
        SETTINGS_LANGUAGE_TIP = "Overrides the addon language. Auto follows the game client locale.",
        FONT_SIZE = "Font size",
        FONT_SIZE_TIP = "Changes text size live.",
        PANEL_WIDTH = "Width",
        PANEL_WIDTH_TIP = "Changes the tracker width live.",
        ROW_HEIGHT = "Row height",
        ROW_HEIGHT_TIP = "Changes quest row height live.",
        UI_SCALE = "Scale",
        UI_SCALE_TIP = "Scales the tracker window live.",
        HIDE_IN_COMBAT = "Hide in combat",
        HIDE_IN_COMBAT_TIP = "Hides the tracker while you are in combat.",
        COLOR_PENDING = "Missing color",
        COLOR_ACTIVE = "Active color",
        COLOR_READY = "Ready color",
        COLOR_COMPLETED = "Turned in color",
        COLOR_TIP = "Changes row status and waypoint pin color live.",
        LANG_AUTO = "Auto",
        LANG_EN = "English",
        LANG_ES = "Spanish",
        CREATOR_TITLE = "Created by Edulynch",
        CREATOR_BODY = "Tracks Delver's Call - Midnight completion and creates mapID waypoints for every delve entrance.",
        CREATOR_CREDITS = "UI style inspired by Myu's Knowledge Points Tracker.",
        CREATOR_COMMANDS = "Commands: /dcall, /dct, /delverscall, /delvercalltracker",
        HOW_TO_USE = "How to use",
        CLOSE = "Close",
    },
    es = {
        ADDON_TITLE = "Delver Call Tracker",
        HEADER = "Delver's Call - Midnight",
        TAB_CREATOR = "Creador",
        ENTRY = "Entrada",
        MAP_ID = "Map ID",
        QUEST_ID = "Quest ID",
        READY_COUNT = "Listas/entregadas: %d/%d",
        TAB_NOT_STARTED = "Sin tomar",
        TAB_PROGRESS = "En progreso",
        TAB_READY = "Completadas",
        TAB_COMPLETED = "Entregadas",
        EMPTY_TAB = "No hay quests en esta pestana.",
        FILTER_LABEL = "Filtro: %s (%d)",
        FILTER_TOOLTIP = "Click para cambiar el filtro.",
        TAB_NOT_STARTED_DESC = "Mision sin tomar. Esta mision puede ser tomada dentro del respectivo delve.",
        TAB_PROGRESS_DESC = "Mision en progreso. Haz clic en el delve para marcar su entrada por zona.",
        TAB_READY_DESC = "Mision completada. Haz clic en el respectivo delve por zona para saber donde entregar la mision.",
        TAB_COMPLETED_DESC = "Mision ya entregada. Estas entradas quedan aqui como registro completado.",
        STATUS_PENDING = "PENDIENTE",
        STATUS_ACTIVE = "ACTIVA",
        STATUS_READY = "LISTA",
        STATUS_DONE = "ENTREGADA",
        TOOLTIP_ENTRY = "Entrada del delve",
        TOOLTIP_CLICK = "Click para crear el waypoint directamente.",
        TOOLTIP_CLICK_READY = "Click para marcar la entrega cuando este disponible.",
        WAYPOINT_TOMTOM = "Waypoint TomTom creado: %s (%d %.2f %.2f)",
        WAYPOINT_NATIVE = "Waypoint del juego creado: %s (%d %.2f %.2f)",
        WAYPOINT_FAILED = "No se pudo crear waypoint. Activa TomTom o usa un cliente Retail actual.",
        ROUTE_STARTED = "Ruta iniciada: %s",
        ROUTE_NEXT = "Paso de ruta: %s",
        ROUTE_SILVERMOON_TO_QUELDANAS = "Usa el maestro de vuelo de Lunargenta para ir a Isla de Quel'Danas",
        ROUTE_QUELDANAS_TO_SILVERMOON = "Usa el maestro de vuelo del Bancal del Sol para volver a Ciudad de Lunargenta",
        ROUTE_SILVERMOON_TO_HARANDAR = "Usa el Rootway a Harandar en Ciudad de Lunargenta",
        ROUTE_HARANDAR_TO_SILVERMOON = "Usa el Rootway a Bosque Cancion Eterna en Harandar para volver a Ciudad de Lunargenta",
        ROUTE_VOIDSTORM_PORTAL = "Toma el portal a Tormenta del Vacio en Ciudad de Lunargenta",
        ROUTE_VOIDSTORM_TO_SILVERMOON = "Usa el portal a Ciudad de Lunargenta en Tormenta del Vacio",
        ROUTE_FINAL = "Vuela a la entrada del delve",
        ROUTE_TURNIN = "Entrega la quest",
        TURNIN_TITLE = "Entregar: %s",
        LOADED = "cargado. Usa /dcall, /dct o /delverscall.",
        CLOSE_MESSAGE = "Panel cerrado. Usa /dcall, /dct, /delverscall o /delvercalltracker para abrirlo otra vez. Usa /dcall help para ver todos los comandos.",
        HELP_HEADER = "Comandos de Delver Call Tracker:",
        HELP_OPEN = "/dcall, /dct, /delverscall - abrir el tracker",
        HELP_SETTINGS = "/dcall settings - abrir opciones del addon",
        HELP_COMBAT = "/dcall combat enable|disable - ocultar/mostrar el tracker en combate",
        HELP_AUTOHIDE = "/dcall autohide enable|disable - mostrar el tracker solo con mouseover",
        HELP_SHOW = "/dcall show|hide|toggle - controlar el panel del tracker",
        SETTINGS_OPENED = "Abriendo opciones del addon.",
        COMBAT_ENABLED = "Ocultar en combate activado.",
        COMBAT_DISABLED = "Ocultar en combate desactivado.",
        AUTOHIDE = "Autohide",
        AUTOHIDE_TIP = "Solo muestra el tracker mientras el mouse esta encima.",
        AUTOHIDE_ENABLED = "Autohide activado.",
        AUTOHIDE_DISABLED = "Autohide desactivado.",
        SETTINGS_GENERAL = "General",
        SETTINGS_APPEARANCE = "Apariencia",
        SETTINGS_COLORS = "Colores",
        SETTINGS_LANGUAGE = "Idioma",
        SETTINGS_LANGUAGE_TIP = "Sobrescribe el idioma del addon. Auto usa el idioma del juego.",
        FONT_SIZE = "Tamano de letra",
        FONT_SIZE_TIP = "Cambia el tamano del texto en vivo.",
        PANEL_WIDTH = "Ancho",
        PANEL_WIDTH_TIP = "Cambia el ancho del tracker en vivo.",
        ROW_HEIGHT = "Alto de fila",
        ROW_HEIGHT_TIP = "Cambia el alto de cada quest en vivo.",
        UI_SCALE = "Escala",
        UI_SCALE_TIP = "Cambia la escala de la ventana en vivo.",
        HIDE_IN_COMBAT = "Ocultar en combate",
        HIDE_IN_COMBAT_TIP = "Oculta el tracker mientras estas en combate.",
        COLOR_PENDING = "Color pendiente",
        COLOR_ACTIVE = "Color activa",
        COLOR_READY = "Color lista",
        COLOR_COMPLETED = "Color entregada",
        COLOR_TIP = "Cambia el color del estado y del pin de waypoint en vivo.",
        LANG_AUTO = "Auto",
        LANG_EN = "Ingles",
        LANG_ES = "Espanol",
        CREATOR_TITLE = "Creado por Edulynch",
        CREATOR_BODY = "Trackea el completismo de Delver's Call - Midnight y crea waypoints por mapID para cada entrada de delve.",
        CREATOR_CREDITS = "Estilo de UI inspirado en Myu's Knowledge Points Tracker.",
        CREATOR_COMMANDS = "Comandos: /dcall, /dct, /delverscall, /delvercalltracker",
        HOW_TO_USE = "Como usar",
        CLOSE = "Cerrar",
    },
}

DCT.ZONE_LABELS = {
    en = {
        EV = "Eversong Woods",
        SM = "Silvermoon City",
        QD = "Isle of Quel'Danas",
        ZA = "Zul'Aman",
        HA = "Harandar",
        VS = "Voidstorm",
    },
    es = {
        EV = "Bosque Cancion Eterna",
        SM = "Ciudad de Lunargenta",
        QD = "Isla de Quel'Danas",
        ZA = "Zul'Aman",
        HA = "Harandar",
        VS = "Tormenta del Vacio",
    },
}

local function GetClientLanguage()
    local locale = GetLocale and GetLocale() or "enUS"
    if locale == "esES" or locale == "esMX" then
        return "es"
    end
    return "en"
end

function DCT.GetConfig()
    DelverCallTrackerDB = DelverCallTrackerDB or DCT_Config or {}
    DCT_Config = nil
    DelverCallTrackerDB.language = DelverCallTrackerDB.language or DCT.DEFAULT_CONFIG.language
    DelverCallTrackerDB.ui = DelverCallTrackerDB.ui or {}

    for key, value in pairs(DCT.DEFAULT_CONFIG.ui) do
        if type(value) == "table" then
            DelverCallTrackerDB.ui[key] = DelverCallTrackerDB.ui[key] or {}
            for nestedKey, nestedValue in pairs(value) do
                if DelverCallTrackerDB.ui[key][nestedKey] == nil then
                    DelverCallTrackerDB.ui[key][nestedKey] = nestedValue
                end
            end
        elseif DelverCallTrackerDB.ui[key] == nil then
            DelverCallTrackerDB.ui[key] = value
        end
    end

    return DelverCallTrackerDB
end

function DCT.GetUiConfig()
    return DCT.GetConfig().ui
end

function DCT.GetLanguage()
    local language = DCT.GetConfig().language
    if language == "es" or language == "en" then
        return language
    end
    return GetClientLanguage()
end

function DCT.L(key)
    local lang = DCT.GetLanguage()
    return (DCT.LOCALES[lang] and DCT.LOCALES[lang][key]) or DCT.LOCALES.en[key] or key
end

local function HexToRGB(hex)
    hex = hex or "FFFFFFFF"
    if #hex == 8 then
        hex = hex:sub(3)
    end

    local r = tonumber(hex:sub(1, 2), 16) or 255
    local g = tonumber(hex:sub(3, 4), 16) or 255
    local b = tonumber(hex:sub(5, 6), 16) or 255
    return { r / 255, g / 255, b / 255 }
end

function DCT.GetStatusColor(status)
    local key = DCT.STATUS_COLOR_KEY[status]
    return HexToRGB(DCT.GetUiConfig().colors[key])
end
