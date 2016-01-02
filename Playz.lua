
gColors = {}
gColors["PLAYZ"] = {255, 128, 128}
gColors["ERR"]   = {255,  64,  64}
gColors["WARN"]  = {255, 255,   0}
gColors["LINE"]  = {  0,   0, 192}

local function c(t, r, g, b)
    return format("|cff%2.2x%2.2x%2.2x%s|r", r, g, b, t)
end

local function ct(t, n)
    return format("|cff%2.2x%2.2x%2.2x%s|r", gColors[n][1], gColors[n][2], gColors[n][3], t)
end

local function playzLog(msg)
    print(ct("Playz: " .. msg, "PLAYZ"))
end

local function playzHorizontalLine()
    playzLog(ct("---------------------------------------------", "LINE"))
end

local function playzError(msg)
    print(ct("Playz Error: " .. msg, "ERR")) -- Errors are always local
end

local function askForPlayed()
    playzLog("Asking for /played ...")

    local editbox=ChatEdit_ChooseBoxForSend(DEFAULT_CHAT_FRAME);--  Get an editbox
    ChatEdit_ActivateChat(editbox);--   Show the editbox
    editbox:SetText("/played");-- Command goes here
    ChatEdit_OnEnterPressed(editbox);
end

local function getCompletedDate(id)
    id, name, points, completed, month, day, year = GetAchievementInfo(id)
    d = "--"
    if completed then
        d = year .. "/" .. month .. "/" .. day
    end
    return d
end

local function recordCharacter(totalPlayed, playedThisLevel)
    playzLog("Recording character...")

    local info = {}
    info.level = UnitLevel("player")
    info.class = UnitClass("player")
    info.totalPlayed = totalPlayed
    info.playedThisLevel = playedThisLevel
    info.level10  = getCompletedDate(6)
    info.level20  = getCompletedDate(7)
    info.level30  = getCompletedDate(8)
    info.level40  = getCompletedDate(9)
    info.level50  = getCompletedDate(10)
    info.level60  = getCompletedDate(11)
    info.level70  = getCompletedDate(12)
    info.level80  = getCompletedDate(13)
    info.level85  = getCompletedDate(4826)
    info.level90  = getCompletedDate(6193)
    info.level100 = getCompletedDate(9060)

    local realm = GetRealmName()
    local name = UnitName("player")
    if PlayzData[realm] == nil then
        PlayzData[realm] = {}
    end

    PlayzData[realm][name] = info
    playzLog("recorded character: " .. realm .. "-" .. name)
end

local frame = CreateFrame("FRAME", "PlayzAddonFrame");
frame:RegisterEvent("TIME_PLAYED_MSG");
frame:RegisterEvent("ADDON_LOADED");

local function eventHandler(self, event, a, b)
    --print("GOT EVENT: " .. event)
    if (event == "ADDON_LOADED") and (a == "Playz") then
        playzLog("Loaded")
        if PlayzData == nil then
            playzLog("Resetting data (fresh, first usage?)")
            PlayzData = {}
        end
        askForPlayed()
    end
    if event == "TIME_PLAYED_MSG" then
        recordCharacter(a, b)
    end
end
frame:SetScript("OnEvent", eventHandler);

function prettyPrintTime(t)
    text = ""

    secondsInMinute = 60
    secondsInHour = secondsInMinute * 60
    secondsInDay = secondsInHour * 24
    secondsInWeek = secondsInDay * 7
    secondsInYear = secondsInDay * 365 -- roughly

    -- if t > secondsInYear then
    --     v = floor(t / secondsInYear)
    --     t = t - (v * secondsInYear)
    --     text = text .. v .. " years, "
    -- end

    if t > secondsInDay then
        v = floor(t / secondsInDay)
        t = t - (v * secondsInDay)
        text = text .. v .. " days, "
    end

    if t > secondsInHour then
        v = floor(t / secondsInHour)
        t = t - (v * secondsInHour)
        text = text .. v .. " hours, "
    end

    if t > secondsInMinute then
        v = floor(t / secondsInMinute)
        t = t - (v * secondsInMinute)
        text = text .. v .. " minutes, "
    end

    text = text .. t .. " seconds"
    return text
end

function Playz_Command(msg)
    playzLog("Heard playz command.")

    total = 0
    realmTotals = {}

    for realm, chars in pairs(PlayzData) do
        if realmTotals[realm] == nil then
            realmTotals[realm] = 0
        end
        for name, info in pairs(PlayzData[realm]) do
            playzLog("Char: " .. name .. "-" .. realm .. ": " .. prettyPrintTime(info.totalPlayed))
            realmTotals[realm] = realmTotals[realm] + info.totalPlayed
            total = total + info.totalPlayed
        end
    end

    for realm, realmTotal in pairs(realmTotals) do
        playzLog("Realm: " .. realm .. " " .. prettyPrintTime(realmTotal))
    end
    playzLog("Total (all realms): " .. prettyPrintTime(total))
end

SLASH_PLAYZ1 = "/playz";
SlashCmdList["PLAYZ"] = Playz_Command
