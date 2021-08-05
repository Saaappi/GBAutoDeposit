local addonName, addonTable = ...
local e = CreateFrame("Frame")
local gold, silver, copper

local function ShowTooltip(self, text)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(text)
	GameTooltip:Show()
end

local function HideTooltip(self)
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide()
	end
end

SLASH_GBAutoDeposit1 = "/gbad"
SlashCmdList["GBAutoDeposit"] = function(message, editbox)
	if (GBAutoDepositFrame:IsVisible()) then
		GBAutoDepositFrame:Hide()
    else
		GBAutoDepositFrame:Show()
		GBAutoDepositGoldBox:SetText(GBAutoDepositAmount)

		GBAutoDepositFrameCloseButton:SetScript("OnClick", function(self)
			self:GetParent():Hide()
		end)

		GBAutoDepositGoldBox:SetScript("OnEnter", function(self)
			ShowTooltip(self, "The value to keep on hand after deposits.\nPlease enter a value between |cffFFFFFF1|r and |cffFFFFFF9999|r.\nThis value applies to all characters on the account.\n\n"
				.. "|cffFFFFFFCurrent|r: " .. GetCoinTextureString(GBAutoDepositAmount))
		end)

		GBAutoDepositGoldBox:SetScript("OnLeave", function(self)
			HideTooltip(self)
		end)

		GBAutoDepositGoldBox:SetScript("OnEnterPressed", function(self)
			GBAutoDepositAmount = (self:GetText()) * 10000
			GBAutoDepositGoldBox:SetText("")
			GBAutoDepositFrame:Hide()
		end)
	end
end

e:RegisterEvent("ADDON_LOADED")
e:RegisterEvent("GUILDBANKFRAME_OPENED")
e:SetScript("OnEvent", function(self, event, ...)
	if (event == "ADDON_LOADED") then
		if (GBAutoDepositAmount == nil) then
			-- If the value hasn't been set, then default to 50 gold.
			GBAutoDepositAmount = 500000
		end
	end
	if (event == "GUILDBANKFRAME_OPENED") then
		local money = GetMoney()
		if (money > GBAutoDepositAmount) then
			-- This is the non-configurable version of the addon. Let's deposit everything except 50 gold.
			money = money-GBAutoDepositAmount
			
			-- Let's get the length of the string and split it. Copper is the last 2 digits. Silver is the next 2. Gold is the rest.
			local length = string.len(money)
			gold = string.sub(money, 0, length-4)
			silver = string.sub(money, length-3, length-2)
			copper = string.sub(money, length-1, length-0)
			
			-- Click the Deposit button in the Guild Bank UI.
			GuildBankFrameDepositButton:Click()
			
			if (StaticPopup1:IsVisible()) then
				-- Let's make sure the popup appeared before we try to fill in the fields.
				-- Let's also place it on a timer in case Blizzard gets mad about the hastiness of the automation.
				C_Timer.After(0, function()
					C_Timer.After(1, function()
						StaticPopup1MoneyInputFrameGold:SetText(gold)
						StaticPopup1MoneyInputFrameSilver:SetText(silver)
						StaticPopup1MoneyInputFrameCopper:SetText(copper)
						StaticPopup1Button1:Click()
					end)
				end)
			end
		end
	end
end)
