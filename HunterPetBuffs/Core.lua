-- Create a new frame to hold the buttons
local buffFrame = CreateFrame("Frame", "HunterPetBuffFrame", UIParent)
buffFrame:SetSize(64, 32) -- Adjust size as needed
buffFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -100) -- Adjust position as needed
buffFrame:SetMovable(true)

-- Spell IDs (might need verification on your specific server)
local MEND_PET_SPELL_ID = 27046 -- Mend Pet
local FEED_PET_SPELL_ID = 1539 -- Feed Pet

local ACTIVE_ALPHA = 1
local INACTIVE_ALPHA = 0.25

local MEND_PET_DURATION = 15
local FEED_PET_DURATION = 20

-- Function to create a buff button
local function CreateBuffButton(parent, name, size, xOffset, texture, spellID)
	local button = CreateFrame("Frame", name, parent)
	button:SetSize(size, size)
	button:SetPoint("LEFT", parent, "LEFT", xOffset, 0)
	--button:SetMovable(true)
	button:EnableMouse(true)
	button:RegisterForDrag("LeftButton")
	button:SetScript("OnDragStart", function(self) self:GetParent():StartMoving() end)
	button:SetScript("OnDragStop", function(self) self:GetParent():StopMovingOrSizing() end)
	button:SetAlpha(INACTIVE_ALPHA)
	button.spellID = spellID

	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetSize(size-4, size-4)
	button.icon:SetPoint("CENTER", button, "CENTER", 0, 0)
	button.icon:SetTexture(texture)

	-- Cooldown Text (optional, for displaying remaining time)
	button.cooldownText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
	button.cooldownText:SetPoint("CENTER", button, "CENTER", 0, 0)
	button.cooldownText:SetJustifyH("CENTER")
	button.cooldownText:SetTextColor(0, 1, 0, 1)
	button.cooldownText:SetText("") -- Initially empty

	return button
end

local mendPetButton = CreateBuffButton(buffFrame, "MendPetButton", 64, 0, "Interface\\Icons\\Ability_Hunter_MendPet", 27046)
local feedPetButton = CreateBuffButton(buffFrame, "FeedPetButton", 64, 64, "Interface\\Icons\\Ability_Hunter_BeastTraining", 1539)

buffFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, subEvent, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName = ...

		if srcGUID == UnitGUID("player") and dstGUID == UnitGUID("pet") then
			if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" then
				if spellID == MEND_PET_SPELL_ID then
					mendPetButton:SetAlpha(ACTIVE_ALPHA)
					mendPetButton.startTime = GetTime()
					mendPetButton.endTime = mendPetButton.startTime + MEND_PET_DURATION
				elseif spellID == FEED_PET_SPELL_ID then
					feedPetButton:SetAlpha(ACTIVE_ALPHA)
					feedPetButton.startTime = GetTime()
					feedPetButton.endTime = feedPetButton.startTime + FEED_PET_DURATION
				end
			elseif subEvent == "SPELL_AURA_REMOVED" then
				if spellID == MEND_PET_SPELL_ID then
					mendPetButton:SetAlpha(INACTIVE_ALPHA)
					mendPetButton.startTime = nil
					mendPetButton.endTime = nil
				elseif spellID == FEED_PET_SPELL_ID then
					feedPetButton:SetAlpha(INACTIVE_ALPHA)
					feedPetButton.startTime = nil
					feedPetButton.endTime = nil
				end
			end
		end
	end
end)

buffFrame:SetScript("OnUpdate", function(self, elapsed)
	self.timer = (self.timer or 0) + elapsed

	if self.timer >= 0.2 then
		if MendPetButton.startTime ~= nil and MendPetButton.endTime ~= nil then
			local duration = MendPetButton.endTime - GetTime()

			MendPetButton.cooldownText:SetText(("%.1f"):format(duration))
		else
			MendPetButton.cooldownText:SetText("")
		end

		if FeedPetButton.startTime ~= nil and FeedPetButton.endTime ~= nil then
			local duration = FeedPetButton.endTime - GetTime()

			FeedPetButton.cooldownText:SetText(("%.1f"):format(duration))
		else
			FeedPetButton.cooldownText:SetText("")
		end

		self.timer = 0
	end
end)

if UnitClass("player") == "Hunter" then
    buffFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    buffFrame:Show()
else
    buffFrame:Hide()
end
