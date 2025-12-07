-- PickPocketCounter for Turtle WoW (Vanilla 1.12)
-- Version 2.1 - Con widget visual, milestones y estadisticas de items

local _, playerClass = UnitClass("player")
if playerClass ~= "ROGUE" then
    return
end

local DEBUG = false
local isPickPocketing = false
local moneyBeforePickPocket = 0
local pickPocketTime = 0
local waitingForMoney = false
local waitFrames = 0

-- Saved variables
PPC_Total = PPC_Total or 0
PPC_Session = 0
PPC_Count = PPC_Count or 0
PPC_Items = PPC_Items or 0
PPC_Attempts = PPC_Attempts or 0
PPC_AttemptsSession = 0
PPC_ItemStats = PPC_ItemStats or {}
PPC_Milestones = PPC_Milestones or {}
PPC_WidgetPos = PPC_WidgetPos or {x = 0, y = -150}
PPC_WidgetLocked = PPC_WidgetLocked or false
PPC_WidgetVisible = PPC_WidgetVisible or true

local frame = CreateFrame("Frame", "PickPocketCounterFrame", UIParent)

-- ============================================================
-- SISTEMA DE MILESTONES
-- ============================================================
local Milestones = {
    -- Milestones de intentos
    {type = "attempts", value = 1, title = "Primer Intento", msg = "Has intentado tu primer robo!", sound = "Sound\\interface\\iCreateCharacterA.wav"},
    {type = "attempts", value = 10, title = "Manos Inquietas", msg = "10 intentos! Tus manos piden mas.", sound = "Sound\\interface\\iQuestUpdate.wav"},
    {type = "attempts", value = 50, title = "Aprendiz de Ladron", msg = "50 intentos! Vas aprendiendo...", sound = "Sound\\interface\\iQuestUpdate.wav"},
    {type = "attempts", value = 100, title = "Carterista Novato", msg = "100 intentos de robo!", sound = "Sound\\interface\\iQuestUpdate.wav"},
    {type = "attempts", value = 250, title = "Dedos Agiles", msg = "250 intentos! Tus dedos son rapidos.", sound = "Sound\\interface\\iQuestUpdate.wav"},
    {type = "attempts", value = 500, title = "Ladron Callejero", msg = "500 intentos! La calle es tu hogar.", sound = "Sound\\interface\\iQuestComplete.wav"},
    {type = "attempts", value = 1000, title = "Ladron Profesional", msg = "1,000 intentos! Eres un profesional.", sound = "Sound\\interface\\iQuestComplete.wav"},
    {type = "attempts", value = 2500, title = "Sombra Silenciosa", msg = "2,500 intentos! Nadie te ve venir.", sound = "Sound\\interface\\iQuestComplete.wav"},
    {type = "attempts", value = 5000, title = "Maestro del Hurto", msg = "5,000 intentos! Leyenda viviente.", sound = "Sound\\interface\\iLevelUp.wav"},
    {type = "attempts", value = 7500, title = "Fantasma de Bolsillos", msg = "7,500 intentos! Eres un mito.", sound = "Sound\\interface\\iLevelUp.wav"},
    {type = "attempts", value = 10000, title = "Gran Maestro Ladron", msg = "10,000 intentos! Los bolsillos tiemblan.", sound = "Sound\\interface\\iLevelUp.wav"},
    {type = "attempts", value = 25000, title = "Leyenda del Hampa", msg = "25,000 intentos! Tu nombre es temido.", sound = "Sound\\interface\\iLevelUp.wav"},
    {type = "attempts", value = 50000, title = "El Inmaterial", msg = "50,000 intentos! Ni saben que existes.", sound = "Sound\\interface\\iLevelUp.wav"},
    {type = "attempts", value = 100000, title = "Dios de los Ladrones", msg = "100,000 intentos! Eres inmortal.", sound = "Sound\\interface\\iLevelUp.wav"},
    
    -- Milestones de dinero (en copper) - 100c = 1s, 10000c = 1g
    {type = "money", value = 100, title = "Primeras Monedas", msg = "Tu primera plata robada!", sound = "Sound\\interface\\iQuestUpdate.wav"},
    {type = "money", value = 500, title = "Monedero Ligero", msg = "5 plata robada!", sound = "Sound\\interface\\iQuestUpdate.wav"},
    {type = "money", value = 1000, title = "Bolsillo Caliente", msg = "10 plata robada!", sound = "Sound\\interface\\iQuestUpdate.wav"},
    {type = "money", value = 5000, title = "Plata Facil", msg = "50 plata robada!", sound = "Sound\\interface\\iQuestUpdate.wav"},
    {type = "money", value = 10000, title = "Primer Oro", msg = "1 oro robado!", sound = "Sound\\interface\\iQuestComplete.wav"},
    {type = "money", value = 50000, title = "Ladron de Oro", msg = "5 oro robados!", sound = "Sound\\interface\\iQuestComplete.wav"},
    {type = "money", value = 100000, title = "Bolsillos de Oro", msg = "10 oro robados!", sound = "Sound\\interface\\iQuestComplete.wav"},
    {type = "money", value = 250000, title = "Manos de Oro", msg = "25 oro robados!", sound = "Sound\\interface\\iQuestComplete.wav"},
    {type = "money", value = 500000, title = "Fortuna Robada", msg = "50 oro robados!", sound = "Sound\\interface\\iLevelUp.wav"},
    {type = "money", value = 1000000, title = "Baron del Crimen", msg = "100 oro robados!", sound = "Sound\\interface\\iLevelUp.wav"},
    {type = "money", value = 2500000, title = "Magnate Sombrio", msg = "250 oro robados!", sound = "Sound\\interface\\iLevelUp.wav"},
    {type = "money", value = 5000000, title = "Rey del Bajo Mundo", msg = "500 oro robados!", sound = "Sound\\interface\\iLevelUp.wav"},
    {type = "money", value = 10000000, title = "Emperador de las Sombras", msg = "1,000 oro robados! Eres leyenda.", sound = "Sound\\interface\\iLevelUp.wav"},
    {type = "money", value = 50000000, title = "El Intocable", msg = "5,000 oro robados! Imposible.", sound = "Sound\\interface\\iLevelUp.wav"},
    {type = "money", value = 100000000, title = "Dios de la Fortuna", msg = "10,000 oro robados! Eres un mito.", sound = "Sound\\interface\\iLevelUp.wav"},
    
    -- Milestones de items
    {type = "items", value = 1, title = "Primer Botin", msg = "Tu primer item robado!", sound = "Sound\\interface\\iQuestUpdate.wav"},
    {type = "items", value = 25, title = "Coleccionista Novato", msg = "25 items robados!", sound = "Sound\\interface\\iQuestUpdate.wav"},
    {type = "items", value = 50, title = "Coleccionista", msg = "50 items robados!", sound = "Sound\\interface\\iQuestUpdate.wav"},
    {type = "items", value = 100, title = "Acumulador", msg = "100 items robados!", sound = "Sound\\interface\\iQuestComplete.wav"},
    {type = "items", value = 250, title = "Almacen Ambulante", msg = "250 items robados!", sound = "Sound\\interface\\iQuestComplete.wav"},
    {type = "items", value = 500, title = "Almacen Andante", msg = "500 items robados!", sound = "Sound\\interface\\iQuestComplete.wav"},
    {type = "items", value = 1000, title = "Rey de los Items", msg = "1,000 items robados!", sound = "Sound\\interface\\iLevelUp.wav"},
    {type = "items", value = 2500, title = "Museo del Robo", msg = "2,500 items robados!", sound = "Sound\\interface\\iLevelUp.wav"},
    {type = "items", value = 5000, title = "Boveda Personal", msg = "5,000 items robados!", sound = "Sound\\interface\\iLevelUp.wav"},
    {type = "items", value = 10000, title = "Tesoro Nacional", msg = "10,000 items robados!", sound = "Sound\\interface\\iLevelUp.wav"},
}

local function CheckMilestones()
    for i, milestone in ipairs(Milestones) do
        local key = milestone.type .. "_" .. milestone.value
        
        if PPC_Milestones[key] then
            -- skip
        else
            local currentValue = 0
            if milestone.type == "attempts" then
                currentValue = PPC_Attempts
            elseif milestone.type == "money" then
                currentValue = PPC_Total
            elseif milestone.type == "items" then
                currentValue = PPC_Items
            end
            
            if currentValue >= milestone.value then
                PPC_Milestones[key] = true
                
                DEFAULT_CHAT_FRAME:AddMessage("|cffFFD700======================================|r")
                DEFAULT_CHAT_FRAME:AddMessage("|cffFFD700  MILESTONE: |cff00FF00" .. milestone.title .. "|r")
                DEFAULT_CHAT_FRAME:AddMessage("|cffFFFF00  " .. milestone.msg .. "|r")
                DEFAULT_CHAT_FRAME:AddMessage("|cffFFD700======================================|r")
                
                if milestone.sound then
                    PlaySoundFile(milestone.sound)
                end
            end
        end
    end
end

-- ============================================================
-- FUNCIONES AUXILIARES
-- ============================================================
local function DebugPrint(msg)
    if DEBUG then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF00FF[PPC]|r " .. tostring(msg))
    end
end

local function FormatMoney(copper)
    if not copper then copper = 0 end
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper - (gold * 10000)) / 100)
    local cop = copper - (gold * 10000) - (silver * 100)
    return "|cffFFD700" .. gold .. "g|r |cffC0C0C0" .. silver .. "s|r |cffB87333" .. cop .. "c|r"
end

local function FormatMoneyShort(copper)
    if not copper then copper = 0 end
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper - (gold * 10000)) / 100)
    local cop = copper - (gold * 10000) - (silver * 100)
    if gold > 0 then
        return gold .. "g " .. silver .. "s"
    elseif silver > 0 then
        return silver .. "s " .. cop .. "c"
    else
        return cop .. "c"
    end
end

local function ParseItemFromLoot(msg)
    if not msg then return nil end
    local _, _, itemName = string.find(msg, "%[(.+)%]")
    return itemName
end

local function AddItemStat(itemName)
    if not itemName then return end
    if not PPC_ItemStats[itemName] then
        PPC_ItemStats[itemName] = 0
    end
    PPC_ItemStats[itemName] = PPC_ItemStats[itemName] + 1
end

-- Tooltip para escanear
local tooltip = CreateFrame("GameTooltip", "PickPocketCounterTooltip", UIParent, "GameTooltipTemplate")
tooltip:SetOwner(UIParent, "ANCHOR_NONE")

-- ============================================================
-- WIDGET VISUAL
-- ============================================================
local widget = CreateFrame("Button", "PPCWidget", UIParent)
widget:SetWidth(140)
widget:SetHeight(50)
widget:SetPoint("CENTER", UIParent, "CENTER", PPC_WidgetPos.x, PPC_WidgetPos.y)
widget:SetMovable(true)
widget:EnableMouse(true)
widget:SetClampedToScreen(true)
widget:RegisterForClicks("LeftButtonUp", "RightButtonUp")

-- Fondo del widget
widget:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
widget:SetBackdropColor(0, 0, 0, 0.8)
widget:SetBackdropBorderColor(0.6, 0.6, 0.1, 1)

-- Titulo
local widgetTitle = widget:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
widgetTitle:SetPoint("TOP", widget, "TOP", 0, -5)
widgetTitle:SetText("|cffFFD700Pick Pocket|r")

-- Texto de dinero
local widgetMoney = widget:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
widgetMoney:SetPoint("TOP", widgetTitle, "BOTTOM", 0, -2)
widgetMoney:SetText("0g 0s 0c")

-- Texto de intentos
local widgetAttempts = widget:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
widgetAttempts:SetPoint("TOP", widgetMoney, "BOTTOM", 0, -1)
widgetAttempts:SetText("Intentos: 0")

-- Icono de candado
local lockIcon = widget:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
lockIcon:SetPoint("TOPRIGHT", widget, "TOPRIGHT", -4, -4)
lockIcon:SetText("")

local function UpdateLockIcon()
    if PPC_WidgetLocked then
        lockIcon:SetText("|cffFF0000x|r")
    else
        lockIcon:SetText("|cff00FF00o|r")
    end
end

local function UpdateWidget()
    widgetMoney:SetText(FormatMoneyShort(PPC_Total))
    widgetAttempts:SetText("Intentos: " .. PPC_Attempts .. " | Items: " .. PPC_Items)
    UpdateLockIcon()
end

-- Variables para drag
local isDragging = false

widget:SetScript("OnMouseDown", function()
    if arg1 == "LeftButton" and not PPC_WidgetLocked then
        widget:StartMoving()
        isDragging = true
    end
end)

widget:SetScript("OnMouseUp", function()
    if isDragging then
        widget:StopMovingOrSizing()
        isDragging = false
        -- Guardar posicion
        local _, _, _, x, y = widget:GetPoint()
        PPC_WidgetPos.x = x
        PPC_WidgetPos.y = y
    end
end)

widget:SetScript("OnClick", function()
    if arg1 == "LeftButton" then
        -- Click izquierdo: mostrar detalles
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00=== PickPocketCounter ===|r")
        DEFAULT_CHAT_FRAME:AddMessage("Sesion: " .. FormatMoney(PPC_Session))
        DEFAULT_CHAT_FRAME:AddMessage("Total: " .. FormatMoney(PPC_Total))
        DEFAULT_CHAT_FRAME:AddMessage("Intentos (sesion/total): " .. PPC_AttemptsSession .. "/" .. PPC_Attempts)
        DEFAULT_CHAT_FRAME:AddMessage("Robos con dinero: " .. PPC_Count)
        DEFAULT_CHAT_FRAME:AddMessage("Items robados: " .. PPC_Items)
    elseif arg1 == "RightButton" then
        -- Click derecho: toggle lock
        PPC_WidgetLocked = not PPC_WidgetLocked
        UpdateLockIcon()
        if PPC_WidgetLocked then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PPC]|r Widget |cffFF0000bloqueado|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PPC]|r Widget |cff00FF00desbloqueado|r - arrastra para mover")
        end
    end
end)

-- Tooltip del widget
widget:SetScript("OnEnter", function()
    GameTooltip:SetOwner(widget, "ANCHOR_RIGHT")
    GameTooltip:AddLine("PickPocketCounter", 1, 0.82, 0)
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Sesion:", FormatMoneyShort(PPC_Session), 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine("Total:", FormatMoneyShort(PPC_Total), 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine("Intentos:", PPC_AttemptsSession .. " / " .. PPC_Attempts, 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine("Items:", PPC_Items, 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine("Robos con dinero:", PPC_Count, 1, 1, 1, 1, 1, 1)
    
    -- Mostrar milestones alcanzados
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cffFFD700Milestones:|r", 1, 0.82, 0)
    
    local achieved = 0
    local total = 0
    local shown = 0
    local maxShow = 8
    
    -- Contar total y mostrar los alcanzados (ultimos primero)
    for i = table.getn(Milestones), 1, -1 do
        local milestone = Milestones[i]
        total = total + 1
        local key = milestone.type .. "_" .. milestone.value
        if PPC_Milestones[key] then
            achieved = achieved + 1
            if shown < maxShow then
                GameTooltip:AddLine("  |cff00FF00[X]|r " .. milestone.title, 0.7, 0.7, 0.7)
                shown = shown + 1
            end
        end
    end
    
    if achieved == 0 then
        GameTooltip:AddLine("  |cff888888Ninguno aun...|r", 0.5, 0.5, 0.5)
    elseif achieved > maxShow then
        GameTooltip:AddLine("  |cff888888... y " .. (achieved - maxShow) .. " mas|r", 0.5, 0.5, 0.5)
    end
    
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Progreso:", achieved .. "/" .. total, 0.6, 0.6, 0.6, 1, 1, 0)
    
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cff00FF00Click izq:|r Ver detalles en chat", 0.5, 0.5, 0.5)
    GameTooltip:AddLine("|cff00FF00Click der:|r Bloquear/Desbloquear", 0.5, 0.5, 0.5)
    GameTooltip:Show()
end)

widget:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- ============================================================
-- MONITOREO DE DINERO
-- ============================================================
local function StartMoneyWatch()
    waitingForMoney = true
    waitFrames = 0
    frame:SetScript("OnUpdate", function()
        waitFrames = waitFrames + 1
        local currentMoney = GetMoney()
        
        if currentMoney ~= moneyBeforePickPocket then
            local diff = currentMoney - moneyBeforePickPocket
            DebugPrint("Frame " .. waitFrames .. ": Dinero cambio! diff=" .. diff)
            
            if diff > 0 then
                PPC_Total = PPC_Total + diff
                PPC_Session = PPC_Session + diff
                PPC_Count = PPC_Count + 1
                DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PPC]|r +" .. FormatMoney(diff) .. " | Total: " .. FormatMoney(PPC_Total))
                CheckMilestones()
                UpdateWidget()
            end
            
            waitingForMoney = false
            isPickPocketing = false
            frame:SetScript("OnUpdate", nil)
        elseif waitFrames > 60 then
            DebugPrint("Timeout - no hubo cambio de dinero")
            waitingForMoney = false
            isPickPocketing = false
            frame:SetScript("OnUpdate", nil)
        end
    end)
end

-- ============================================================
-- HOOKS
-- ============================================================
local originalUseAction = UseAction
UseAction = function(slot, checkCursor, onSelf)
    if HasAction(slot) then
        PickPocketCounterTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        PickPocketCounterTooltip:ClearLines()
        PickPocketCounterTooltip:SetAction(slot)
        local text = PickPocketCounterTooltipTextLeft1:GetText()
        if text then
            local textLower = string.lower(text)
            if string.find(textLower, "robar") or string.find(textLower, "pick pocket") then
                moneyBeforePickPocket = GetMoney()
                isPickPocketing = true
                pickPocketTime = GetTime()
                PPC_Attempts = PPC_Attempts + 1
                PPC_AttemptsSession = PPC_AttemptsSession + 1
                DebugPrint("ROBAR! Intento #" .. PPC_Attempts)
                CheckMilestones()
                UpdateWidget()
            end
        end
        PickPocketCounterTooltip:Hide()
    end
    return originalUseAction(slot, checkCursor, onSelf)
end

local originalCastSpellByName = CastSpellByName
CastSpellByName = function(spell, onSelf)
    if spell then
        local spellLower = string.lower(spell)
        if string.find(spellLower, "robar") or string.find(spellLower, "pick pocket") then
            moneyBeforePickPocket = GetMoney()
            isPickPocketing = true
            pickPocketTime = GetTime()
            PPC_Attempts = PPC_Attempts + 1
            PPC_AttemptsSession = PPC_AttemptsSession + 1
            DebugPrint("ROBAR (spell)! Intento #" .. PPC_Attempts)
            CheckMilestones()
            UpdateWidget()
        end
    end
    return originalCastSpellByName(spell, onSelf)
end

-- ============================================================
-- EVENT HANDLER
-- ============================================================
local function OnEvent()
    local e = event
    local a1 = arg1
    
    if e == "PLAYER_LOGIN" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00PickPocketCounter v2.1|r cargado! /ppc para comandos")
        UpdateWidget()
        if PPC_WidgetVisible then
            widget:Show()
        else
            widget:Hide()
        end
        
    elseif e == "LOOT_OPENED" then
        DebugPrint("LOOT_OPENED")
        
    elseif e == "LOOT_CLOSED" then
        DebugPrint("LOOT_CLOSED - isPickPocketing: " .. tostring(isPickPocketing))
        if isPickPocketing and not waitingForMoney then
            StartMoneyWatch()
        end
        
    elseif e == "CHAT_MSG_LOOT" then
        if (isPickPocketing or waitingForMoney) and a1 then
            if string.find(a1, "Recibes") or string.find(a1, "You receive") then
                PPC_Items = PPC_Items + 1
                
                local itemName = ParseItemFromLoot(a1)
                if itemName then
                    AddItemStat(itemName)
                    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PPC]|r Item: [" .. itemName .. "] | Total items: " .. PPC_Items)
                else
                    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PPC]|r Item robado! Total: " .. PPC_Items)
                end
                
                CheckMilestones()
                UpdateWidget()
            end
        end
        
    elseif e == "UI_ERROR_MESSAGE" then
        if a1 then
            DebugPrint("UI_ERROR: " .. a1)
            isPickPocketing = false
            waitingForMoney = false
            frame:SetScript("OnUpdate", nil)
        end
        
    elseif e == "SPELLCAST_FAILED" or e == "SPELLCAST_INTERRUPTED" then
        DebugPrint(e)
        isPickPocketing = false
        waitingForMoney = false
        frame:SetScript("OnUpdate", nil)
    end
end

frame:SetScript("OnEvent", OnEvent)
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("LOOT_OPENED")
frame:RegisterEvent("LOOT_CLOSED")
frame:RegisterEvent("CHAT_MSG_LOOT")
frame:RegisterEvent("UI_ERROR_MESSAGE")
frame:RegisterEvent("SPELLCAST_FAILED")
frame:RegisterEvent("SPELLCAST_INTERRUPTED")

-- ============================================================
-- SLASH COMMANDS
-- ============================================================
SLASH_PPC1 = "/ppc"
local confirmClear = false

SlashCmdList["PPC"] = function(msg)
    msg = string.lower(msg or "")
    
    if msg == "debug" then
        DEBUG = not DEBUG
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PPC]|r Debug " .. (DEBUG and "|cff00FF00ON|r" or "|cffFF0000OFF|r"))
        
    elseif msg == "" or msg == "total" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00=== PickPocketCounter ===|r")
        DEFAULT_CHAT_FRAME:AddMessage("Sesion: " .. FormatMoney(PPC_Session))
        DEFAULT_CHAT_FRAME:AddMessage("Total: " .. FormatMoney(PPC_Total))
        DEFAULT_CHAT_FRAME:AddMessage("Intentos (sesion/total): " .. PPC_AttemptsSession .. "/" .. PPC_Attempts)
        DEFAULT_CHAT_FRAME:AddMessage("Robos con dinero: " .. PPC_Count)
        DEFAULT_CHAT_FRAME:AddMessage("Items robados: " .. PPC_Items)
        confirmClear = false
        
    elseif msg == "items" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00=== Items Robados ===|r")
        local count = 0
        for itemName, qty in pairs(PPC_ItemStats) do
            DEFAULT_CHAT_FRAME:AddMessage("  [" .. itemName .. "] x" .. qty)
            count = count + 1
        end
        if count == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("  No has robado items aun.")
        end
        
    elseif msg == "milestones" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00=== Milestones Alcanzados ===|r")
        local achieved = 0
        for i, milestone in ipairs(Milestones) do
            local key = milestone.type .. "_" .. milestone.value
            if PPC_Milestones[key] then
                achieved = achieved + 1
                DEFAULT_CHAT_FRAME:AddMessage("  |cff00FF00[X]|r " .. milestone.title)
            end
        end
        if achieved == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("  Aun no has alcanzado ningun milestone.")
        end
        DEFAULT_CHAT_FRAME:AddMessage("Progreso: " .. achieved .. "/" .. table.getn(Milestones))
        
    elseif msg == "show" then
        widget:Show()
        PPC_WidgetVisible = true
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PPC]|r Widget visible")
        
    elseif msg == "hide" then
        widget:Hide()
        PPC_WidgetVisible = false
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PPC]|r Widget oculto")
        
    elseif msg == "lock" then
        PPC_WidgetLocked = true
        UpdateLockIcon()
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PPC]|r Widget |cffFF0000bloqueado|r")
        
    elseif msg == "unlock" then
        PPC_WidgetLocked = false
        UpdateLockIcon()
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PPC]|r Widget |cff00FF00desbloqueado|r")
        
    elseif msg == "reset" then
        widget:ClearAllPoints()
        widget:SetPoint("CENTER", UIParent, "CENTER", 0, -150)
        PPC_WidgetPos.x = 0
        PPC_WidgetPos.y = -150
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PPC]|r Posicion del widget reseteada")
        
    elseif msg == "clear" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000[PPC]|r Seguro? /ppc yes (esto borra TODO)")
        confirmClear = true
        
    elseif msg == "yes" and confirmClear then
        PPC_Total = 0
        PPC_Session = 0
        PPC_Count = 0
        PPC_Items = 0
        PPC_Attempts = 0
        PPC_AttemptsSession = 0
        PPC_ItemStats = {}
        PPC_Milestones = {}
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PPC]|r Todo limpiado!")
        UpdateWidget()
        confirmClear = false
        
    elseif msg == "help" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PPC] Comandos:|r")
        DEFAULT_CHAT_FRAME:AddMessage("  /ppc - Ver estadisticas")
        DEFAULT_CHAT_FRAME:AddMessage("  /ppc items - Ver items robados")
        DEFAULT_CHAT_FRAME:AddMessage("  /ppc milestones - Ver logros")
        DEFAULT_CHAT_FRAME:AddMessage("  /ppc show - Mostrar widget")
        DEFAULT_CHAT_FRAME:AddMessage("  /ppc hide - Ocultar widget")
        DEFAULT_CHAT_FRAME:AddMessage("  /ppc lock - Bloquear widget")
        DEFAULT_CHAT_FRAME:AddMessage("  /ppc unlock - Desbloquear widget")
        DEFAULT_CHAT_FRAME:AddMessage("  /ppc reset - Resetear posicion widget")
        DEFAULT_CHAT_FRAME:AddMessage("  /ppc debug - Modo debug")
        DEFAULT_CHAT_FRAME:AddMessage("  /ppc clear - Limpiar todo")
        
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PPC]|r Comando desconocido. Usa /ppc help")
    end
end

DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00PickPocketCounter v2.1|r listo.")
