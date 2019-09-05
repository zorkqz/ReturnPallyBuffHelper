ReturnPallyBuffHelper = CreateFrame("Frame")
local events = {}

local elapsedTime = 0

local PallyBuffs = {
	Kings = { small = "Blessing of Kings", big = "Greater Blessing of Kings",
		classes = {"WARRIOR", "ROGUE", "HUNTER", "WARLOCK", "PRIEST", "PALADIN", "DRUID", "MAGE"} },
	Wisdom = { small = "Blessing of Wisdom", big = "Greater Blessing of Wisdom",
		classes = {"HUNTER", "WARLOCK", "PRIEST", "PALADIN", "DRUID", "MAGE"} },
	Might = { small = "Blessing of Might", big = "Greater Blessing of Might",
		classes = {"WARRIOR", "ROGUE"} },
	Salvation = { small = "Blessing of Salvation", big = "Greater Blessing of Salvation",
		classes = {"WARRIOR", "ROGUE", "HUNTER", "WARLOCK", "PRIEST", "PALADIN", "DRUID", "MAGE"} },
	Light = { small = "Blessing of Light", big = "Greater Blessing of Light",
		classes = {"WARRIOR"} }
}

local ClassNames = {
	WARRIOR = "Warrior",
	ROGUE = "Rogue",
	HUNTER = "Hunter",
	WARLOCK = "Warlock",
	PRIEST = "Priest",
	PALADIN = "Paladin",
	DRUID = "Druid",
	MAGE = "Mage"
}

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function CheckUnitBuff(unit, class, buff)
	
	if not has_value(buff.classes, class) then
		return true
	end

	for i = 1,40 do
		b = UnitBuff(unit, i);
		if b == buff.small or b == buff.big then
			return true
		end
	end
	
	return false
end

local function Check(buff)
	withoutBuff = {}
	for i = 1,40 do
        _, _, _, _, _, class = GetRaidRosterInfo(i)
        if class and not CheckUnitBuff("raid" .. i, class, buff) then 
			withoutBuff[class] = class
        end
    end
	s = ""
	for c in pairs(withoutBuff) do
		s = s .. ClassNames[c] .. " "
	end
	return s
end

local function OnUpdate(self)
	
	ReturnPallyBuffHelper.UI.Kings:SetText("Kings: " .. Check(PallyBuffs.Kings))	
	ReturnPallyBuffHelper.UI.Wisdom:SetText("Wisdom: " .. Check(PallyBuffs.Wisdom))
	ReturnPallyBuffHelper.UI.Might:SetText("Might: " .. Check(PallyBuffs.Might))
	ReturnPallyBuffHelper.UI.Salvation:SetText("Salvation: " .. Check(PallyBuffs.Salvation))
	ReturnPallyBuffHelper.UI.Light:SetText("Light: " .. Check(PallyBuffs.Light))

end

local function CreateTextFrame(parent, pos, name)
	parent[name] = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	parent[name]:SetPoint("TOPLEFT", theFrame, "TOPLEFT", 4, pos)
	parent[name]:SetText(name .. ":")
end

local function CreateUI()

	theFrame = CreateFrame("Frame", "ReturnPallyBuffHelperUI", UIParent)
	
	theFrame:SetWidth(64)
	theFrame:SetHeight(64)
	theFrame:SetFrameStrata("DIALOG")
	
	if ReturnPallyBuffHelperDBPerChar then
		theFrame:SetPoint("BOTTOMLEFT", ReturnPallyBuffHelperDBPerChar.x, ReturnPallyBuffHelperDBPerChar.y)
	else
		theFrame:SetPoint("CENTER", 0, 0)
	end
	
		
	CreateTextFrame(theFrame,   0, "Kings")
	CreateTextFrame(theFrame, -12, "Wisdom")
	CreateTextFrame(theFrame, -24, "Might")
	CreateTextFrame(theFrame, -36, "Salvation")
	CreateTextFrame(theFrame, -48, "Light")
		
	theFrame:EnableMouse(true)
	theFrame:SetMovable(true)
	theFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    theFrame:SetScript("OnMouseUp", function(self)
		self:StopMovingOrSizing()
		if not ReturnPallyBuffHelperDBPerChar then
			ReturnPallyBuffHelperDBPerChar = {}
		end
		ReturnPallyBuffHelperDBPerChar.x = theFrame:GetLeft()
		ReturnPallyBuffHelperDBPerChar.y = theFrame:GetBottom()
	end)
		
	return theFrame
end


ReturnPallyBuffHelper:SetScript("OnUpdate", function(self, elapsed)

	if not ReturnPallyBuffHelper.UI then
		ReturnPallyBuffHelper.UI = CreateUI()	
		return
	end

	elapsedTime = elapsedTime + elapsed
	if elapsedTime < 1 then
		return
	end
	elapsedTime = 0

	if not ReturnPallyBuffHelper.UI:IsVisible() then
		ReturnPallyBuffHelper.UI:Show()
	end

	OnUpdate(this)
end)

ReturnPallyBuffHelper:SetScript("OnEvent", function(self, event, ...)
	events[event](event, ...)
end)

for k, v in pairs(events) do
 ReturnPallyBuffHelper:RegisterEvent(k)
end

function print(text)
  	if (DEFAULT_CHAT_FRAME) then 
		DEFAULT_CHAT_FRAME:AddMessage(text or "", 1.0, 0.5, 0.25);
	end
end