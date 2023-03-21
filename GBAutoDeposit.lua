local addonName, addonTable = ...
local e = CreateFrame("Frame")
local gold, silver, copper
local coloredDash = "|cffFFD100-|r "

GBAutoDeposit = LibStub("AceAddon-3.0"):NewAddon("GBAutoDeposit", "AceConsole-3.0")

local options = {
	name = addonName,
	handler = GBAutoDeposit,
	type = "group",
	args = {
		enable = {
			name = "Enable",
			order = 0,
			desc = "Toggle the addon's functionality on or off.",
			type = "toggle",
			get = function() return GBAutoDepositOptions.Enabled end,
			set = function(_, val) GBAutoDepositOptions.Enabled = val end,
		},
		optionsHeader = {
			name = "Options",
			order = 1,
			type = "header",
		},
		amount = {
			name = "Amount",
			order = 2,
			usage = "Enter an amount of gold the addon should keep in your possession. The remainder will be deposited to the guild vault.",
			type = "input",
			get = function() return GBAutoDepositOptions.Amount end,
			set = function(_, val) GBAutoDepositOptions.Amount = tonumber(val*10000) end,
			validate = function(self, val)
				if tonumber(val) then
					return true
				end
				return "Please enter a numeric value from 1 to 9,999,999 (commas should not be used)."
			end,
		},
		changesHeader = {
			name = "Changes",
			order = 10,
			type = "header",
		},
		updatedText = {
			name = coloredDash .. "Updated the TOC to support Patch 10.0.7.",
			order = 21,
			type = "description",
			fontSize = "medium",
		},
	},
}

function GBAutoDeposit:OnInitialize()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("GBAutoDeposit_Main", options)
	self.mainOptions = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GBAutoDeposit_Main", addonName)
	self:RegisterChatCommand("gbad", "SlashCommandHandler")
	
	-- Default Options
	if GBAutoDepositOptions == nil then
		GBAutoDepositOptions = {}
		GBAutoDepositOptions.Enabled = false
		GBAutoDepositOptions.Amount = 500000
	end
end

function GBAutoDeposit:SlashCommandHandler(cmd)
	if not cmd or cmd == "" then
		Settings.OpenToCategory(addonName)
	elseif cmd == "amount" then
		print("Current Amount: " .. GetCoinTextureString(GBAutoDepositOptions.Amount))
	end
end

e:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
e:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
		local type = ...
		if type == 10 then
			local money = GetMoney()
			if (money > GBAutoDepositOptions.Amount) then
				money = money-GBAutoDepositOptions.Amount
				-- Let's get the length of the string and split it.
				-- Copper is the last 2 digits. Silver is the next 2.
				-- Gold is the rest.
				local length = string.len(money)
				gold = string.sub(money, 0, length-4)
				silver = string.sub(money, length-3, length-2)
				copper = string.sub(money, length-1, length-0)
				-- Click the Deposit button in the
				-- Guild Bank UI.
				if GBAutoDepositOptions.Enabled then
					GuildBankFrame.DepositButton:Click("LeftButton")
					if (StaticPopup1:IsVisible()) then
						-- Let's make sure the popup appeared before we
						-- try to fill in the fields. Let's also place it
						-- on a timer in case Blizzard gets mad about
						-- the hastiness of the automation.
						C_Timer.After(0, function()
							C_Timer.After(1, function()
								StaticPopup1MoneyInputFrameGold:SetText(gold)
								StaticPopup1MoneyInputFrameSilver:SetText(silver)
								StaticPopup1MoneyInputFrameCopper:SetText(copper)
								StaticPopup1Button1:Click()
								print("Money deposited: " .. GetCoinTextureString(money))
							end)
						end)
					end
				end
			end
		end
	end
end)
