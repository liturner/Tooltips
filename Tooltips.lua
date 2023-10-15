local name, Tooltips = ...

Tooltips.MainFrame = CreateFrame('FRAME', nil, UIParent)

function Tooltips.OnEvent(self, event, ...) 
	if event == "ADDON_LOADED" and ... == "Tooltips" then		
		Tooltips.ExtendContainerMetadata()		
		self:UnregisterEvent("ADDON_LOADED")
	end
end

-- brief:	adds the bagID parameter, and GetSlot() function to the container frames 
function Tooltips.ExtendContainerMetadata()
    for b = 1, 5 do
        for s = 1, 32 do -- using 32 as a max bag size and therefore a max count for button frame creations, could be an issue, need to know if all bag slot buttons are created on game start and just hidden OR are they created per bag equipped ?
            -- get global name
            if _G['ContainerFrame'..b..'Item'..s] then
                _G['ContainerFrame'..b..'Item'..s].bagID = b - 1
                _G['ContainerFrame'..b..'Item'..s].getSlot = function(self)
                    return C_Container.GetContainerNumSlots(b - 1) - (s - 1)
                end
            end		
        end
    end
end

function Tooltips.OnTooltipSetItem(tooltip, ...)
	local tooltipItemName, tooltipItemLink = tooltip:GetItem()
	local tooltipOwner = tooltip:GetOwner()

	if not tooltipItemLink then 
		return 
	end

	-- texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bagID, slot);

	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(tooltipItemLink)
	local itemId = GetItemInfoInstant(tooltipItemLink)

	if not Tooltips.tooltipLineAdded then
		
		if itemType == 'Armor' or itemType == 'Weapon' or itemType == 'Projectile' then
			tooltip:AddLine('Item Level '..itemLevel)
		end

		if itemSellPrice and itemSellPrice ~= 0 then
			if tooltipOwner.bagID == nil then
				tooltip:AddDoubleLine('Sell Price: ', GetCoinTextureString(itemSellPrice))
			end
		end

		Tooltips.tooltipLineAdded = true
	end
end

function Tooltips.OnTooltipCleared(tooltip, ...)
   Tooltips.tooltipLineAdded = false
end

Tooltips.MainFrame:RegisterEvent('ADDON_LOADED')
Tooltips.MainFrame:SetScript('OnEvent', Tooltips.OnEvent)
GameTooltip:HookScript("OnTooltipSetItem", Tooltips.OnTooltipSetItem)
GameTooltip:HookScript("OnTooltipCleared", Tooltips.OnTooltipCleared)
