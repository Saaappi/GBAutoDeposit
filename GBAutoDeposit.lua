local addonName, addonTable = ...
local e = CreateFrame("Frame")
local gold, silver, copper

e:RegisterEvent("GUILDBANKFRAME_OPENED")
e:SetScript("OnEvent", function(self, event, ...)
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
