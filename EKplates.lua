local iconcastbar = "Interface\\AddOns\\EKplates\\media\\dM3"
local raidicon = "Interface\\AddOns\\EKplates\\media\\raidicons"
local redarrow = "Interface\\AddOns\\EKplates\\media\\NeonRedArrow"
local numberstylefont = "Interface\\AddOns\\EKplates\\media\\Infinity Gears.ttf"
local numFont = "Interface\\AddOns\\EKplates\\media\\number.ttf" --number font/名字字體
local norFont = STANDARD_TEXT_FONT  --name font/數字字體/GameFontHighlight:GetFont()
local ufbar = "Interface\\AddOns\\EKplates\\media\\ufbar"
local fontsize = 16  --name font size/名字字體大小(normal font*1.75=number font)
local fontflag = "OUTLINE"  --"OUTLINE" or none
local blank = "Interface\\Buttons\\WHITE8x8"
local glow = "Interface\\AddOns\\EKplates\\media\\glow"
local myClass = select(2, UnitClass("player"))

--[[ Config ]]-- 
local WhiteList = {
	--[11426]  = true, --寒冰護體(測試用魔法)
	--[196741] = true, --連珠狂拳(測試用)
	--[147732] = true, --冰封攻擊(測試用)	
	
	--BUFF
	--[209859] = true, -- 挑戰激勵
	
	--DEBUFF
	[25046]  = true, --奧流之術
	
	[118] = true, -- 變形術
	[51514] = true, -- 妖術
	[217832] = true, -- 禁錮
	[605] = true, -- 心控
	[710] = true, -- 放逐
	[2094] = true, -- 致盲
	[6770] = true, -- 悶棍
	[9484] = true, -- 束縛不死生物
	[20066] = true, -- 懺悔
	[115078] = true, --點穴
	
	[339] = true, -- 小d綁
	[102359] = true, -- 群纏
	[3355] = true, -- 冰凍陷阱
	[64695] = true, -- 地縛圖騰
	
	[5211] = true, -- 蠻力猛擊
	[853] = true, -- 制裁(聖騎)
	[221562] = true, -- 窒息(dk)
	
	[118905] = true, -- 電容(薩滿)
	[132168] = true, -- 震懾波(戰士)
	[179057] = true, -- 混沌新星(dh)
	[30283] = true, -- 暗影之怒(術士)
 	[207171] = true, -- 凜冬將至(dk)
	[117405] = true, -- 束縛射擊(獵人)
	[119381] = true, -- 掃葉腿(武僧)
	[127797] = true, -- 厄索克之旋(小德)
	[205369] = true, --  精神炸彈 
	[81261] = true, -- 日光(小德)
}

local BlackList = {
	--[11426]  = true, --寒冰護體(測試用魔法)
	--[196741] = true, --連珠狂拳(測試用)	
	[166646] = true, --御風而行
	[15407] = true, -- 精神鞭笞
}

local Config = {

	numberstyle = true, --數字樣式/infinity plates's number style
	
	CVAR = true,  -- do a cvar setting to turn nameplate work like WOD, can also slove fps drop.
	
	--blizzard default setting will scale nameplate to 0.8 when it's 10 yards outside,
	--but scale nameplate by range will get fps drop if both range scale and outline working, 
	--so if you get fps drop, should enable CVAR or disable font flag (font flag can be change at line 9),
	--I suggest to use this config, outline is goodlook for nameplates.
	--暴雪預設姓名板在10碼外會自動縮放，但這個功能和姓名板字體描邊同時存在時會引起fps drop
	--描邊提供了姓名板美觀與易讀性，所以如果碰到了這個問題，建議啟用cvar設定來解決
	
	auranum = 5,
	auraiconsize = 25,
	friendlyCR = true, --友方職業顏色/friendly class color
	enemyCR = true, --敵方職業顏色/enemy class color
	threatcolor = true, --名字仇恨染色/change name color by threat(note at line 686)
	cbtext = false,  --施法條法術名稱/show castbar text(number style only)
	cbshield = false,  --施法條不可打斷圖示/show castbar un-interrupt shield icon
	--threattext = true,  --">"mark when ur on threat(not yet)
	level = false, --show level
	
	myfiltertype = "blacklist", --自身施放/show aura cast by player
	otherfiltertype = "whitelist",  --他人施放/show aura cast by other
	--"whitelist": show only list/白名單：只顯示列表中
	--"blacklist": show only unlist/黑名單：只顯示列表外
	--"none": do not show anything/不顯示任何光環
	
	playerplate = false,  
	classresource_show = false,  
	classresource = "player", --"player", "target"  
	plateaura = false, 
	
	Guarm_mod = false,  --Mythic Guarm mod/傳奇模式加爾姆提示模塊
}
--[[ 為特定目標自定義姓名板顏色/custom colored plates ]]--
local Customcoloredplates = {
	[1] = {
		name = "ekk",
		color = {r = 1, g = 1, b = 1},
	},
	[2] = {
		name = "ek",
		color = {r = 1, g = 0, b = 1},
	},
}

--[[ Functions ]]-- 
colorspower = {}
for power, color in next, PowerBarColor do
	if (type(power) == "string") then
		colorspower[power] = {color.r, color.g, color.b}
	end
end

local Ccolors = {}
if(IsAddOnLoaded'!ClassColors' and CUSTOM_CLASS_COLORS) then
	Ccolors = CUSTOM_CLASS_COLORS
else
	Ccolors = RAID_CLASS_COLORS
end

local createnumber = function(f, layer, fontsize, flag, justifyh)
	local text = f:CreateFontString(nil, layer)
	text:SetFont(numFont, fontsize, flag)
	text:SetJustifyH(justifyh)
	return text
end

local createtext = function(f, layer, fontsize, flag, justifyh)
	local text = f:CreateFontString(nil, layer)
	text:SetFont(norFont, fontsize, flag)
	text:SetJustifyH(justifyh)
	return text
end

local CreateBD = function(f, a)
	f:SetBackdrop({
		bgFile = blank,
		edgeFile = blank,
		edgeSize = 1,
	})
	f:SetBackdropColor(0, 0, 0, a or 1)
	f:SetBackdropBorderColor(0, 0, 0)
end

local CreateThinSD = function(parent, size, r, g, b, alpha, offset)
	local sd = CreateFrame("Frame", nil, parent)
	sd.size = size or 1
	sd.offset = offset or 0
	sd:SetBackdrop({
		bgFile = blank,
		edgeFile = blank,
		edgeSize = sd.size,
	})
	sd:SetPoint("TOPLEFT", parent, -sd.size - 1 - sd.offset, sd.size + 1 + sd.offset)
	sd:SetPoint("BOTTOMRIGHT", parent, sd.size + 1 + sd.offset, -sd.size - 1 - sd.offset)
	sd:SetBackdropBorderColor(r or 0, g or 0, b or 0)
	sd:SetBackdropColor(r or 0, g or 0, b or 0, alpha or 0)
	
	return sd
end

local CreateBDFrame = function(f, a)
	local frame
	if f:GetObjectType() == "Texture" then
		frame = f:GetParent()
	else
		frame = f
	end

	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetPoint("TOPLEFT", f, -1, 1)
	bg:SetPoint("BOTTOMRIGHT", f, 1, -1)
	bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)

	CreateBD(bg, a or .5)

	return bg
end

local CreateBG = function(frame)
	local f = frame
	if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", frame, -1, 1)
	bg:SetPoint("BOTTOMRIGHT", frame, 1, -1)
	bg:SetTexture(blank)
	bg:SetVertexColor(0, 0, 0)

	return bg
end

local frameBD = {
    edgeFile = glow, edgeSize = 3,
    bgFile = blank,
    insets = {left = 3, right = 3, top = 3, bottom = 3}
}

local createBackdrop = function(parent, anchor, a)
    local frame = CreateFrame("Frame", nil, parent)

	local flvl = parent:GetFrameLevel()
	if flvl - 1 >= 0 then frame:SetFrameLevel(flvl-1) end

	frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", -3, 3)
    frame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 3, -3)

    frame:SetBackdrop(frameBD)
	if a then
		frame:SetBackdropColor(.15, .15, .15, a)
		frame:SetBackdropBorderColor(0, 0, 0)
	end

    return frame
end
--[[ Auras ]]-- 

local day, hour, minute = 86400, 3600, 60
local function FormatTime(s)
    if s >= day then
        return format("%dd", floor(s/day + 0.5))
    elseif s >= hour then
        return format("%dh", floor(s/hour + 0.5))
    elseif s >= minute then
        return format("%dm", floor(s/minute + 0.5))
    end

    return format("%d", math.fmod(s, minute))
end

local function CreateAuraIcon(parent)
	local button = CreateFrame("Frame",nil,parent)
	button:SetSize(Config.auraiconsize, Config.auraiconsize)
	
	button.icon = button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.icon:SetPoint("TOPLEFT",button,"TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-1, 1)
	button.icon:SetTexCoord(.08, .92, 0.08, 0.92)
	
	button.overlay = button:CreateTexture(nil, "ARTWORK", nil, 7)
	button.overlay:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.overlay:SetAllPoints(button)	
	
	button.bd = button:CreateTexture(nil, "ARTWORK", nil, 6)
	button.bd:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.bd:SetVertexColor(0, 0, 0)
	button.bd:SetPoint("TOPLEFT",button,"TOPLEFT", -1, 1)
	button.bd:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT", 1, -1)
	
	button.text = createnumber(button, "OVERLAY", Config.auraiconsize-11, fontflag, "CENTER")
    button.text:SetPoint("BOTTOM", button, "BOTTOM", 0, -2)
	button.text:SetTextColor(1, 1, 0)
	
	button.count = createnumber(button, "OVERLAY", Config.auraiconsize-13, fontflag, "RIGHT")
	button.count:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1, 2)
	button.count:SetTextColor(.4, .95, 1)
	
	return button
end

local function UpdateAuraIcon(button, unit, index, filter)
	local name, _, icon, count, debuffType, duration, expirationTime, _, _, _, spellID = UnitAura(unit, index, filter)

	button.icon:SetTexture(icon)
	button.expirationTime = expirationTime
	button.duration = duration
	button.spellID = spellID
	
	local color = DebuffTypeColor[debuffType] or DebuffTypeColor.none
	button.overlay:SetVertexColor(color.r, color.g, color.b)

	if count and count > 1 then
		button.count:SetText(count)
	else
		button.count:SetText("")
	end
	
	button:SetScript("OnUpdate", function(self, elapsed)
		if not self.duration then return end
		
		self.elapsed = (self.elapsed or 0) + elapsed

		if self.elapsed < .2 then return end
		self.elapsed = 0

		local timeLeft = self.expirationTime - GetTime()
		if timeLeft <= 0 then
			self.text:SetText(nil)
		else
			self.text:SetText(FormatTime(timeLeft))
		end
	end)
	
	button:Show()
end

local function UnitDebuffID(unit, spell_id)
	local debuff_name = GetSpellInfo(spell_id)
	if UnitDebuff(unit, debuff_name) then
		local id = select(11, UnitDebuff(unit, debuff_name))
		if id == spell_id then
			return true
		end
	end
end

local function AuraFilter(caster, spellid, unit)
	if Config.Guarm_mod then
		if spellid == 228818 or spellid == 228810 or spellid == 228744 then
			return true
		elseif spellid == 228769 and UnitDebuffID("player", 228818) then -- 紫色
			return true
		elseif spellid == 228768 and UnitDebuffID("player", 228810) then -- 藍色
			return true
		elseif spellid == 228758 and UnitDebuffID("player", 228744) then -- 紅色
			return true
		end
	end
	
	if caster == "player" then
		if Config["myfiltertype"] == "none" then
			return false
		elseif Config.Guarm_mod and UnitIsPlayer(unit) and UnitReaction(unit, 'player') >= 5 then
			return false
		elseif Config["myfiltertype"] == "whitelist" and WhiteList[spellid] then
			return true
		elseif Config["myfiltertype"] == "blacklist" and not BlackList[spellid] then
			return true
		end
	else
		if Config["otherfiltertype"] == "none" then
			return false
		elseif Config.Guarm_mod and UnitIsPlayer(unit) and UnitReaction(unit, 'player') >= 5 then
			return false
		elseif Config["otherfiltertype"] == "whitelist" and WhiteList[spellid] then
			return true
		end
	end
end

local function UpdateBuffs(unitFrame)
	if not unitFrame.icons or not unitFrame.displayedUnit then return end
	if not Config.plateaura and UnitIsUnit(unitFrame.displayedUnit, "player") then return end
	local unit = unitFrame.displayedUnit
	local i = 1

	for index = 1, 15 do
		if i <= Config.auranum then
			local bname, _, _, _, _, bduration, _, bcaster, _, _, bspellid = UnitAura(unit, index, 'HELPFUL')
			local matchbuff = AuraFilter(bcaster, bspellid, unit)
			if bname and matchbuff then
				if not unitFrame.icons[i] then
					unitFrame.icons[i] = CreateAuraIcon(unitFrame)
				end
				UpdateAuraIcon(unitFrame.icons[i], unit, index, 'HELPFUL')
				if i ~= 1 then
					unitFrame.icons[i]:SetPoint("LEFT", unitFrame.icons[i-1], "RIGHT", 4, 0)
				end
				i = i + 1
			end
		end
	end

	for index = 1, 20 do
		if i <= Config.auranum then
			local dname, _, _, _, _, dduration, _, dcaster, _, _, dspellid = UnitAura(unit, index, 'HARMFUL')
			local matchdebuff = AuraFilter(dcaster, dspellid, unit)
			
			if dname and matchdebuff then
				if not unitFrame.icons[i] then
					unitFrame.icons[i] = CreateAuraIcon(unitFrame)
				end
				UpdateAuraIcon(unitFrame.icons[i], unit, index, 'HARMFUL')
				if i ~= 1 then
					unitFrame.icons[i]:SetPoint("LEFT", unitFrame.icons[i-1], "RIGHT", 4, 0)
				end
				i = i + 1
			end
		end
	end
	
	unitFrame.iconnumber = i - 1
	
	if i > 1 then
		unitFrame.icons[1]:SetPoint("LEFT", unitFrame.icons, "CENTER", -((Config.auraiconsize+4)*(unitFrame.iconnumber)-4)/2,0)
	end
	for index = i, #unitFrame.icons do unitFrame.icons[index]:Hide() end
end

--[[ Player Power ]]-- 
 
if Config.playerplate then  
	local PowerFrame = CreateFrame("Frame", "EKNamePlatePowerFrame")  
	  
	PowerFrame.powerBar = CreateFrame("StatusBar", nil, PowerFrame)  
	PowerFrame.powerBar:SetHeight(3)  
	PowerFrame.powerBar:SetStatusBarTexture(ufbar)  
	PowerFrame.powerBar:SetMinMaxValues(0, 1)  
	  
	PowerFrame.powerBar.bd = createBackdrop(PowerFrame.powerBar, PowerFrame.powerBar, 1)  
	  
	PowerFrame.powerperc = PowerFrame:CreateFontString(nil, "OVERLAY")  
	PowerFrame.powerperc:SetFont(numberstylefont, fontsize, fontflag)  
	PowerFrame.powerperc:SetShadowColor(0, 0, 0, 0.4)  
	PowerFrame.powerperc:SetShadowOffset(1, -1)  
	  
	PowerFrame:SetScript("OnEvent", function(self, event, unit)  
		if event == "PLAYER_ENTERING_WORLD" or (event == "UNIT_POWER_FREQUENT" and unit == "player") then  
			local minPower, maxPower, _, powertype = UnitPower("player"), UnitPowerMax("player"), UnitPowerType("player")  
			local perc  
			  
			if maxPower ~= 0 then  
				perc = minPower/maxPower  
			else  
				perc = 0  
			end  
			local perc_text = string.format("%d", math.floor(perc*100))  
			  
			if not Config.numberstyle then  
				PowerFrame.powerBar:SetValue(perc)  
			else  
				if minPower ~= maxPower then  
					PowerFrame.powerperc:SetText(perc_text)  
				else  
					PowerFrame.powerperc:SetText("")  
				end  
			end  
		  
			local r, g, b = unpack(colorspower[powertype])  
  
			if ( r ~= PowerFrame.r or g ~= PowerFrame.g or b ~= PowerFrame.b ) then  
				if not Config.numberstyle then  
					PowerFrame.powerBar:SetStatusBarColor(r, g, b)  
				else  
					PowerFrame.powerperc:SetTextColor(r, g, b)  
				end  
				PowerFrame.r, PowerFrame.g, PowerFrame.b = r, g, b  
			end  
		elseif event == "NAME_PLATE_UNIT_ADDED" and UnitIsUnit(unit, "player") then  
			local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player")  
			if namePlatePlayer then  
				PowerFrame:Show()  
				PowerFrame:SetParent(namePlatePlayer)  
				if not Config.numberstyle then  
					PowerFrame.powerBar:ClearAllPoints()  
					PowerFrame.powerBar:SetPoint("TOPLEFT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMLEFT", 0, -3)  
					PowerFrame.powerBar:SetPoint("TOPRIGHT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMRIGHT", 0, -3)  
				else  
					PowerFrame.powerperc:ClearAllPoints()  
					PowerFrame.powerperc:SetPoint("BOTTOMLEFT", namePlatePlayer.UnitFrame.healthperc, "BOTTOMRIGHT", 0, 0)  
				end  
			end  
		elseif event == "NAME_PLATE_UNIT_REMOVED" and UnitIsUnit(unit, "player") then  
			PowerFrame:Hide()  
		end  
	end)  
	PowerFrame:RegisterEvent("UNIT_POWER_FREQUENT")  
	PowerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")  
	PowerFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")  
	PowerFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")  
end  
  
--[[ Class bar stuff ]]--  
if Config.classresource_show then  
	local function multicheck(check, ...)  
		for i=1, select("#", ...) do  
			if check == select(i, ...) then return true end  
		end  
		return false  
	end  
  
	local ClassPowerID, ClassPowerType, RequireSpec  
	local classicon_colors = { --monk/paladin/preist  
		{.6, 0, .1},  
		{.9, .1, .2},  
		{1, .2, .3},  
		{1, .3, .4},  
		{1, .4, .5},  
		{1, .5, .6},  
	}  
	  
	local cpoints_colors = { -- combat points  
		{1, 0, 0},  
		{1, 1, 0},  
	}  
	  
	if(myClass == 'MONK') then  
		ClassPowerID = SPELL_POWER_CHI  
		ClassPowerType = "CHI"  
		RequireSpec = SPEC_MONK_WINDWALKER  
	elseif(myClass == 'PALADIN') then  
		ClassPowerID = SPELL_POWER_HOLY_POWER  
		ClassPowerType = "HOLY_POWER"  
		RequireSpec = SPEC_PALADIN_RETRIBUTION  
	elseif(myClass == 'MAGE') then  
		ClassPowerID = SPELL_POWER_ARCANE_CHARGES  
		ClassPowerType = "ARCANE_CHARGES"  
		RequireSpec = SPEC_MAGE_ARCANE  
	elseif(myClass == 'WARLOCK') then  
		ClassPowerID = SPELL_POWER_SOUL_SHARDS  
		ClassPowerType = "SOUL_SHARDS"  
	elseif(myClass == 'ROGUE' or myClass == 'DRUID') then  
		ClassPowerID = SPELL_POWER_COMBO_POINTS  
		ClassPowerType = "COMBO_POINTS"  
	end  
  
	local Resourcebar = CreateFrame("Frame", "EKplateresource", UIParent)  
	Resourcebar:SetWidth(100)--(10+3)*6 - 3  
	Resourcebar:SetHeight(3)  
	Resourcebar.maxbar = 6  
	  
	for i = 1, 6 do  
		Resourcebar[i] = CreateFrame("Frame", "EKplateresource"..i, Resourcebar)  
		Resourcebar[i]:SetFrameLevel(1)  
		Resourcebar[i]:SetSize(15, 3)  
		Resourcebar[i].bd = createBackdrop(Resourcebar[i], Resourcebar[i], 1)  
		Resourcebar[i].tex = Resourcebar[i]:CreateTexture(nil, "OVERLAY")  
		Resourcebar[i].tex:SetAllPoints(Resourcebar[i])  
		if myClass == "DEATHKNIGHT" then  
			Resourcebar[i].value = createtext(Resourcebar[i], "OVERLAY", fontsize-2, fontflag, "CENTER")  
			Resourcebar[i].value:SetPoint("CENTER")  
			Resourcebar[i].tex:SetColorTexture(.7, .7, 1)  
		end  
		  
		if i == 1 then  
			Resourcebar[i]:SetPoint("BOTTOMLEFT", Resourcebar, "BOTTOMLEFT")  
		else  
			Resourcebar[i]:SetPoint("LEFT", Resourcebar[i-1], "RIGHT", 2, 0)  
		end  
  
	end  
	  
	Resourcebar:SetScript("OnEvent", function(self, event, unit, powerType)  
		if event == "PLAYER_TALENT_UPDATE" then  
			if multicheck(myClass, "WARLOCK", "PALADIN", "MONK", "MAGE", "ROGUE", "DRUID", "DEATHKNIGHT") and not RequireSpec or RequireSpec == GetSpecialization() then -- 啟用  
				self:RegisterEvent("UNIT_POWER_FREQUENT")  
				self:RegisterEvent("PLAYER_ENTERING_WORLD")  
				self:RegisterEvent("NAME_PLATE_UNIT_ADDED")  
				self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")  
				self:RegisterEvent("PLAYER_TARGET_CHANGED")  
				self:RegisterEvent("RUNE_POWER_UPDATE")  
				self:Show()  
			else  
				self:UnregisterEvent("UNIT_POWER_FREQUENT")  
				self:UnregisterEvent("PLAYER_ENTERING_WORLD")  
				self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")  
				self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")  
				self:UnregisterEvent("PLAYER_TARGET_CHANGED")  
				self:UnregisterEvent("RUNE_POWER_UPDATE")  
				self:Hide()  
			end  
		elseif event == "PLAYER_ENTERING_WORLD" or (event == "UNIT_POWER_FREQUENT" and unit == "player" and powerType == ClassPowerType) then  
			if multicheck(myClass, "WARLOCK", "PALADIN", "MONK", "MAGE", "ROGUE", "DRUID") then  
				local cur, max, oldMax  
				  
				cur = UnitPower('player', ClassPowerID)  
				max = UnitPowerMax('player', ClassPowerID)  
				  
				if multicheck(myClass, "WARLOCK", "PALADIN", "MONK", "MAGE") then  
					for i = 1, max do  
						if(i <= cur) then  
							self[i]:Show()  
						else  
							self[i]:Hide()  
						end  
						if cur == max then  
							self[i].tex:SetColorTexture(unpack(classicon_colors[max]))  
						else  
							self[i].tex:SetColorTexture(unpack(classicon_colors[i]))  
						end  
					end  
					  
					oldMax = self.maxbar  
					if(max ~= oldMax) then  
						if(max < oldMax) then  
							for i = max + 1, oldMax do  
								self[i]:Hide()  
							end  
						end  
						for i = 1, 6 do  
							self[i]:SetWidth(102/max-2)  
						end  
						self.maxbar = max  
					end  
				else -- 連擊點  
					if max <= 6 then  
						for i = 1, max do  
							if(i <= cur) then  
								self[i]:Show()  
							else  
								self[i]:Hide()  
							end  
							self[i].tex:SetColorTexture(unpack(cpoints_colors[1]))  
						end  
					else  
						if cur <= 5 then  
							for i = 1, 5 do  
								if(i <= cur) then  
									self[i]:Show()  
								else  
									self[i]:Hide()  
								end  
								self[i].tex:SetColorTexture(unpack(cpoints_colors[1]))  
							end  
						else  
							for i = 1, 5 do  
								self[i]:Show()  
							end  
							for i = 1, cur - 5 do  
								self[i].tex:SetColorTexture(unpack(cpoints_colors[2]))  
							end  
							for i = cur - 4, 5 do  
								self[i].tex:SetColorTexture(unpack(cpoints_colors[1]))  
							end  
						end  
					end  
  
					oldMax = self.maxbar  
					if(max ~= oldMax) then  
						if max == 5 or max == 8 then  
							self[6]:Hide()  
							for i = 1, 6 do  
								self[i]:SetWidth(102/5-2)  
							end  
						else  
							for i = 1, 6 do  
								self[i]:SetWidth(102/max-2)  
								if i > max then  
									self[i]:Hide()  
								end  
							end  
						end  
						self.maxbar = max  
					end  
				end  
			end  
		elseif myClass == "DEATHKNIGHT" and event == "RUNE_POWER_UPDATE" then  
			local rid = unit  
			local start, duration, runeReady = GetRuneCooldown(rid)  
			if runeReady then  
				self[rid]:SetAlpha(1)  
				self[rid].tex:SetColorTexture(.7, .7, 1)  
				self[rid]:SetScript("OnUpdate", nil)  
				self[rid].value:SetText("")  
			elseif start then  
				self[rid]:SetAlpha(.7)  
				self[rid].tex:SetColorTexture(.3, .3, .3)  
				self[rid].max = duration  
				self[rid].duration = GetTime() - start  
				self[rid]:SetScript("OnUpdate", function(self, elapsed)  
					self.duration = self.duration + elapsed  
					if self.duration >= self.max or self.duration <= 0 then  
						self.value:SetText("")  
					else  
						self.value:SetText(FormatTime(self.max - self.duration))  
					end  
				end)  
			end  
		elseif Config.classresource == "player" then  
			if event == "NAME_PLATE_UNIT_ADDED" and UnitIsUnit(unit, "player") then  
				local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player")  
				if namePlatePlayer then  
					self:SetParent(namePlatePlayer)  
					self:ClearAllPoints()  
					self:Show()  
					if Config.numberstyle then  
						self:SetPoint("TOP", namePlatePlayer.UnitFrame.name, "TOP", 0, 0) -- 玩家數字  
					else  
						self:SetPoint("BOTTOM", namePlatePlayer.UnitFrame.healthBar, "TOP", 0, 3) -- 玩家條  
					end  
				end  
			elseif event == "NAME_PLATE_UNIT_REMOVED" and UnitIsUnit(unit, "player") then  
				self:Hide()  
			end  
		elseif Config.classresource == "target" and (event == "PLAYER_TARGET_CHANGED" or event == "NAME_PLATE_UNIT_ADDED") then  
			local namePlateTarget = C_NamePlate.GetNamePlateForUnit("target")  
			if namePlateTarget and UnitCanAttack("player", namePlateTarget.UnitFrame.displayedUnit) then  
				self:SetParent(namePlateTarget)  
				self:ClearAllPoints()  
				if Config.numberstyle then  
					self:SetPoint("TOP", namePlateTarget.UnitFrame.name, "BOTTOM", 0, -2) -- 目標數字  
				else  
					self:SetPoint("TOP", namePlateTarget.UnitFrame.healthBar, "BOTTOM", 0, -2) -- 目標條
				end  
				self:Show()  
			else  
				self:Hide()  
			end  
		end  
	end)  
	  
	Resourcebar:RegisterEvent("PLAYER_TALENT_UPDATE")  
end  

 
--[[ Unit frame ]]--
local function UpdateName(unitFrame)
	local name = GetUnitName(unitFrame.displayedUnit, false) or UNKNOWN
	local level = UnitLevel(unitFrame.unit)
	local hexColor
		
	if name then
	
	if Config.level then
		if UnitIsUnit(unitFrame.displayedUnit, "player") then  
			unitFrame.name:SetText("")  
		else  
	
		if level >= UnitLevel("player")+5 then
			hexColor = "ff0000"
		elseif level >= UnitLevel("player")+3 then
			hexColor = "ff6600"
		elseif level <= UnitLevel("player")-3 then
			hexColor = "00ff00"
		elseif level <= UnitLevel("player")-5 then
			hexColor = "808080"
		else
			hexColor = "ffff00"
		end
		
		if level == -1 then 
		unitFrame.name:SetText("|cffff0000??|r "..name)
		else
		unitFrame.name:SetText("|cff"..hexColor..""..level.."|r "..name)
		end

		end  
	else	
		if UnitIsUnit(unitFrame.displayedUnit, "player") then  
			unitFrame.name:SetText("")  
		else  
			unitFrame.name:SetText(name)  
		end 
end		
	end
end

local function UpdateHealth(unitFrame)
	local unit = unitFrame.displayedUnit
	local minHealth, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	local perc = minHealth/maxHealth
	local perc_text = string.format("%d", math.floor(perc*100))
	
	if not Config.numberstyle then
		unitFrame.healthBar:SetValue(perc)
		if minHealth ~= maxHealth then 
			unitFrame.healthBar.value:SetText(perc_text)
		else
			unitFrame.healthBar.value:SetText("")
		end
		
		if perc < .25 then
			unitFrame.healthBar.value:SetTextColor(0.8, 0.05, 0)
		elseif perc < .3 then
			unitFrame.healthBar.value:SetTextColor(0.95, 0.7, 0.25)
		else
			unitFrame.healthBar.value:SetTextColor(1, 1, 1)
		end
	else
		if minHealth ~= maxHealth then
			unitFrame.healthperc:SetText(perc_text)
		else
			unitFrame.healthperc:SetText("")
		end
		
		if perc < .25 then
			unitFrame.healthperc:SetTextColor(0.8, 0.05, 0)
		elseif perc < .3 then
			unitFrame.healthperc:SetTextColor(0.95, 0.7, 0.25)
		else
			unitFrame.healthperc:SetTextColor(1, 1, 1)
		end
	end
end

local function IsOnThreatList(unit)
	local _, threatStatus = UnitDetailedThreatSituation("player", unit)
	if threatStatus == 3 then  --穩定仇恨/當前坦克/securely tanking, highest threat
		return .9, .1, .4  --紅色/red
	elseif threatStatus == 2 then  --非當前仇恨/當前坦克/insecurely tanking, another unit have higher threat but not tanking.
		return .9, .1, .9  --粉色/pink
	elseif threatStatus == 1 then  --當前仇恨/非當前坦克(遠程ot)/not tanking, higher threat than tank.
		return .4, .1, .9  --紫色/purple
	elseif threatStatus == 0 then  --低仇恨/安全/not tanking, lower threat than tank.
		return .1, .7, .9  --藍色/blue
	end
end

local function IsTapDenied(unitFrame)
	return UnitIsTapDenied(unitFrame.unit) and not UnitPlayerControlled(unitFrame.unit)
end

local function UpdateHealthColor(unitFrame)
	local unit = unitFrame.displayedUnit
	local r, g, b
	
	if ( not UnitIsConnected(unit) ) then
		r, g, b = 0.7, 0.7, 0.7
	else
		local iscustomed = false
		for index, info in pairs(Customcoloredplates) do
			if GetUnitName(unit, false) == info.name then
				r, g, b= info.color.r, info.color.g, info.color.b
				iscustomed = true
				break
			end
		end
		
		if not iscustomed then
			local _, englishClass = UnitClass(unit)
			local classColor = Ccolors[englishClass]
			if UnitIsPlayer(unit) and classColor and Config.friendlyCR and UnitReaction(unit, 'player') >= 5 then
				r, g, b = classColor.r, classColor.g, classColor.b
			elseif UnitIsPlayer(unit) and classColor and Config.enemyCR and UnitReaction(unit, 'player') <= 4 then
				r, g, b = classColor.r, classColor.g, classColor.b
			elseif ( IsTapDenied(unitFrame) ) then
				r, g, b = 0.3, 0.3, 0.3
			else
				if Config.threatcolor and IsOnThreatList(unitFrame.displayedUnit) then
					r, g, b = IsOnThreatList(unitFrame.displayedUnit)
				else
					r, g, b = UnitSelectionColor(unit, true)
				end
			end
		end
	end
	
	if ( r ~= unitFrame.r or g ~= unitFrame.g or b ~= unitFrame.b ) then
		if not Config.numberstyle then
			unitFrame.healthBar:SetStatusBarColor(r, g, b)  
			unitFrame.healthBar.bd:SetBackdropColor(r/3, g/3, b/3)
		else
			unitFrame.name:SetTextColor(r, g, b)
		end
		unitFrame.r, unitFrame.g, unitFrame.b = r, g, b
	end
end

local function UpdateCastBar(unitFrame)
	local castBar = unitFrame.castBar
	castBar.startCastColor = CreateColor(0.6, 0.6, 0.6)
	castBar.startChannelColor = CreateColor(0.6, 0.6, 0.6)
	castBar.finishedCastColor = CreateColor(0.6, 0.6, 0.6)
	castBar.failedCastColor = CreateColor(0.5, 0.2, 0.2)
	castBar.nonInterruptibleColor = CreateColor(0.9, 0, 1)
	CastingBarFrame_AddWidgetForFade(castBar, castBar.BorderShield)
	if UnitIsUnit("player", unitFrame.displayedUnit) then return end
	if Config.Guarm_mod and UnitIsPlayer(unitFrame.unit) and UnitReaction(unitFrame.unit, "player") >= 5 then return end
	if Config.cbshield then
		CastingBarFrame_SetUnit(castBar, unitFrame.unit, false, true)
	else
		CastingBarFrame_SetUnit(castBar, unitFrame.unit, false, false)
	end
end

local function UpdateSelectionHighlight(unitFrame)
	local unit = unitFrame.unit
	if UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "player") then
		unitFrame.redarrow:Show()
	else
		unitFrame.redarrow:Hide()
	end
	
	if not Config.numberstyle then
		if unitFrame.iconnumber and unitFrame.iconnumber > 0 then
			unitFrame.redarrow:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, Config.auraiconsize+3)
		else
			unitFrame.redarrow:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, 0)
		end
	else
		if unitFrame.iconnumber and unitFrame.iconnumber > 0 then -- 有圖標
			unitFrame.redarrow:SetPoint("BOTTOM", unitFrame.healthperc, "TOP", 0, Config.auraiconsize)
		elseif UnitHealth(unit) and UnitHealthMax(unit) and UnitHealth(unit) ~= UnitHealthMax(unit) then -- 非滿血
			unitFrame.redarrow:SetPoint("BOTTOM", unitFrame.healthperc, "TOP", 0, 0)
		else -- 只有名字
			unitFrame.redarrow:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, 0)
		end
	end
end

local function UpdateRaidTarget(unitFrame)
	local icon = unitFrame.RaidTargetFrame.RaidTargetIcon
	local index = GetRaidTargetIndex(unitFrame.displayedUnit)
	if ( index ) then
		SetRaidTargetIconTexture(icon, index)
		icon:Show()
	else
		icon:Hide()
	end
end

local function UpdateInVehicle(unitFrame)
	if ( UnitHasVehicleUI(unitFrame.unit) ) then
		if ( not unitFrame.inVehicle ) then
			unitFrame.inVehicle = true
			local prefix, id, suffix = string.match(unitFrame.unit, "([^%d]+)([%d]*)(.*)")
			unitFrame.displayedUnit = prefix.."pet"..id..suffix
			UpdateNamePlateEvents(unitFrame)
		end
	else
		if ( unitFrame.inVehicle ) then
			unitFrame.inVehicle = false
			unitFrame.displayedUnit = unitFrame.unit
			UpdateNamePlateEvents(unitFrame)
		end
	end
end

local function UpdateforGuarm(unitFrame)
	if not Config.Guarm_mod then return end
	local unit = unitFrame.displayedUnit
	if UnitIsPlayer(unit) and UnitReaction(unit, 'player') >= 5 then
		if Config.numberstyle then
			unitFrame.healthperc:Hide()
		else
			unitFrame.healthBar:Hide()
		end
		unitFrame.name:Hide()
		unitFrame.castBar:UnregisterAllEvents()
	else
		if Config.numberstyle then
			unitFrame.healthperc:Show()
		else
			unitFrame.healthBar:Show()
		end
		unitFrame.name:Show()		
	end
end

local function UpdateAll(unitFrame)
	UpdateInVehicle(unitFrame)
	if ( UnitExists(unitFrame.displayedUnit) ) then
		UpdateName(unitFrame)
		UpdateHealthColor(unitFrame)
		UpdateHealth(unitFrame)
		UpdateCastBar(unitFrame)
		UpdateSelectionHighlight(unitFrame)
		UpdateBuffs(unitFrame)
		UpdateRaidTarget(unitFrame)
		UpdateforGuarm(unitFrame)
		
		if UnitIsUnit("player", unitFrame.displayedUnit) then  
			unitFrame.castBar:UnregisterAllEvents()  
			if not Config.numberstyle then  
				unitFrame.healthBar.value:Hide()  
			end  
		else  
			if not Config.numberstyle then  
				unitFrame.healthBar.value:Show()  
			end  
		end
	end
end

local function NamePlate_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4 = ...
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		UpdateName(self)
		UpdateSelectionHighlight(self)
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		UpdateAll(self)
	elseif ( arg1 == self.unit or arg1 == self.displayedUnit ) then
		if ( event == "UNIT_HEALTH_FREQUENT" ) then
			UpdateHealth(self)
			UpdateSelectionHighlight(self)
		elseif ( event == "UNIT_AURA" ) then
			UpdateBuffs(self)
			UpdateSelectionHighlight(self)
		elseif ( event == "UNIT_THREAT_LIST_UPDATE" ) then
			UpdateHealthColor(self)
		elseif ( event == "UNIT_NAME_UPDATE" ) then
			UpdateName(self)
			UpdateforGuarm(self)
		elseif ( event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_PET" ) then
			UpdateAll(self)
		end
	end
end

local function UpdateNamePlateEvents(unitFrame)
	-- These are events affected if unit is in a vehicle
	local unit = unitFrame.unit
	local displayedUnit
	if ( unit ~= unitFrame.displayedUnit ) then
		displayedUnit = unitFrame.displayedUnit
	end
	unitFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit, displayedUnit)
	unitFrame:RegisterUnitEvent("UNIT_AURA", unit, displayedUnit)
	unitFrame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit, displayedUnit)
end

local function RegisterNamePlateEvents(unitFrame)
	unitFrame:RegisterEvent("UNIT_NAME_UPDATE")
	unitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	unitFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	unitFrame:RegisterEvent("UNIT_PET")
	unitFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
	unitFrame:RegisterEvent("UNIT_EXITED_VEHICLE")
	UpdateNamePlateEvents(unitFrame)
	unitFrame:SetScript("OnEvent", NamePlate_OnEvent)
end

local function UnregisterNamePlateEvents(unitFrame)
	unitFrame:UnregisterAllEvents()
	unitFrame:SetScript("OnEvent", nil)
end

local function SetUnit(unitFrame, unit)
	unitFrame.unit = unit
	unitFrame.displayedUnit = unit	 -- For vehicles
	unitFrame.inVehicle = false
	if ( unit ) then
		RegisterNamePlateEvents(unitFrame)
	else
		UnregisterNamePlateEvents(unitFrame)
	end
end


--[[ Driver frame ]]--

local function HideBlizzard()
	NamePlateDriverFrame:UnregisterAllEvents()
	NamePlateDriverFrame.SetupClassNameplateBars = function() end
	ClassNameplateManaBarFrame:Hide()
  
	hooksecurefunc(NamePlateDriverFrame, "SetupClassNameplateBar", function()  
		NamePlateTargetResourceFrame:Hide()  
		NamePlatePlayerResourceFrame:Hide()	  
	end)  

	local checkBox = InterfaceOptionsNamesPanelUnitNameplatesMakeLarger
	function checkBox.setFunc(value)
		if value == "1" then
			SetCVar("NamePlateHorizontalScale", checkBox.largeHorizontalScale)
			SetCVar("NamePlateVerticalScale", checkBox.largeVerticalScale)
		else
			SetCVar("NamePlateHorizontalScale", checkBox.normalHorizontalScale)
			SetCVar("NamePlateVerticalScale", checkBox.normalVerticalScale)
		end
		NamePlates_UpdateNamePlateOptions()
	end
end

local function OnUnitFactionChanged(unit)
	-- This would make more sense as a unitFrame:RegisterUnitEvent
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	if (namePlate) then
		UpdateName(namePlate.UnitFrame)
		UpdateHealthColor(namePlate.UnitFrame)
		UpdateforGuarm(namePlate.UnitFrame)
	end
end

local function OnRaidTargetUpdate()
	for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
		UpdateRaidTarget(namePlate.UnitFrame)
	end
end

function NamePlates_UpdateNamePlateOptions()
	-- Called at VARIABLES_LOADED and by "Larger Nameplates" interface options checkbox
	local baseNamePlateWidth = 100
	local baseNamePlateHeight = 45
	local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"))
	C_NamePlate.SetNamePlateFriendlySize(baseNamePlateWidth * horizontalScale, baseNamePlateHeight)
	C_NamePlate.SetNamePlateEnemySize(baseNamePlateWidth, baseNamePlateHeight)

	for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
		local unitFrame = namePlate.UnitFrame
		UpdateAll(unitFrame)
	end
end

local function OnNamePlateCreated(namePlate)

	namePlate.UnitFrame = CreateFrame("Button", "$parentUnitFrame", namePlate)
	namePlate.UnitFrame:SetAllPoints(namePlate)
	namePlate.UnitFrame:SetFrameLevel(namePlate:GetFrameLevel())
			
	if Config.numberstyle then -- 數字樣式
		namePlate.UnitFrame.healthperc = namePlate.UnitFrame:CreateFontString(nil, "OVERLAY")
		namePlate.UnitFrame.healthperc:SetFont(numberstylefont, fontsize*1.75, fontflag)
		namePlate.UnitFrame.healthperc:SetPoint("CENTER")
		namePlate.UnitFrame.healthperc:SetTextColor(1,1,1)
		namePlate.UnitFrame.healthperc:SetShadowColor(0, 0, 0, 0.4)
		namePlate.UnitFrame.healthperc:SetShadowOffset(1, -1)
		namePlate.UnitFrame.healthperc:SetText("92")
		
		namePlate.UnitFrame.name = createtext(namePlate.UnitFrame, "ARTWORK", fontsize, fontflag, "CENTER")
		namePlate.UnitFrame.name:SetPoint("TOP", namePlate.UnitFrame.healthperc, "BOTTOM", 0, -3)
		namePlate.UnitFrame.name:SetTextColor(1,1,1)
		namePlate.UnitFrame.name:SetText("Name")
		
		-- threattext
		--[[namePlate.UnitFrame.HLthreat = namePlate.UnitFrame:CreateFontString(nil, "OVERLAY")
		namePlate.UnitFrame.HLthreat:SetFont(numberstylefont, fontsize*1.75, fontflag)
		namePlate.UnitFrame.HLthreat:SetPoint("RIGHT", namePlate.UnitFrame.healthperc, "LEFT", -2, 0)
		namePlate.UnitFrame.HLthreat:SetShadowOffset(1, -1)]]--
		
		namePlate.UnitFrame.castBar = CreateFrame("StatusBar", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.castBar:Hide()
		namePlate.UnitFrame.castBar.iconWhenNoninterruptible = false
		namePlate.UnitFrame.castBar:SetSize(38,38)
		if Config.classresource_show and Config.classresource == "target" then  
			namePlate.UnitFrame.castBar:SetPoint("TOP", namePlate.UnitFrame.name, "BOTTOM", 0, -7)  
		else  
			namePlate.UnitFrame.castBar:SetPoint("TOP", namePlate.UnitFrame.name, "BOTTOM", 0, -3)  
		end 

		namePlate.UnitFrame.castBar:SetStatusBarTexture(iconcastbar)
		namePlate.UnitFrame.castBar:SetStatusBarColor(0.5, 0.5, 0.5)
		
		namePlate.UnitFrame.castBar.border = CreateBDFrame(namePlate.UnitFrame.castBar, 0)
		CreateThinSD(namePlate.UnitFrame.castBar.border, 1, 0, 0, 0, 1, -2)
		
		namePlate.UnitFrame.castBar.bg = namePlate.UnitFrame.castBar:CreateTexture(nil, 'BORDER')
		namePlate.UnitFrame.castBar.bg:SetAllPoints(namePlate.UnitFrame.castBar)
		namePlate.UnitFrame.castBar.bg:SetTexture(1/3, 1/3, 1/3, .5)

		namePlate.UnitFrame.castBar.Icon = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY", 1)
		namePlate.UnitFrame.castBar.Icon:SetPoint("CENTER")
		namePlate.UnitFrame.castBar.Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
		namePlate.UnitFrame.castBar.Icon:SetSize(32, 32)
		namePlate.UnitFrame.castBar.iconborder = CreateBG(namePlate.UnitFrame.castBar.Icon)
		namePlate.UnitFrame.castBar.iconborder:SetDrawLayer("OVERLAY",-1)
		
		if Config.cbtext then
		namePlate.UnitFrame.castBar.Text = createtext(namePlate.UnitFrame.castBar, "OVERLAY", fontsize-4, fontflag, "CENTER")
		namePlate.UnitFrame.castBar.Text:SetPoint("CENTER")
		end

		namePlate.UnitFrame.castBar.BorderShield = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY", 1)
		namePlate.UnitFrame.castBar.BorderShield:SetAtlas("nameplates-InterruptShield")
		namePlate.UnitFrame.castBar.BorderShield:SetSize(15, 15)
		namePlate.UnitFrame.castBar.BorderShield:SetPoint("CENTER", namePlate.UnitFrame.castBar, "BOTTOMLEFT")  
		namePlate.UnitFrame.castBar.BorderShield:SetDrawLayer("OVERLAY",2)  

		
		namePlate.UnitFrame.castBar.Spark = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY")
		namePlate.UnitFrame.castBar.Spark:SetSize(38, 76)
		namePlate.UnitFrame.castBar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		namePlate.UnitFrame.castBar.Spark:SetBlendMode("ADD")
		namePlate.UnitFrame.castBar.Spark:SetPoint("CENTER", 0, -3)
		namePlate.UnitFrame.castBar.Spark:SetAlpha(0) --Disable this spark
		
		namePlate.UnitFrame.castBar.Flash = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY")
		namePlate.UnitFrame.castBar.Flash:SetAllPoints()
		namePlate.UnitFrame.castBar.Flash:SetTexture(ufbar)
		namePlate.UnitFrame.castBar.Flash:SetBlendMode("ADD")
		
		CastingBarFrame_OnLoad(namePlate.UnitFrame.castBar, nil, false, true)
		namePlate.UnitFrame.castBar:SetScript("OnEvent", CastingBarFrame_OnEvent)
		namePlate.UnitFrame.castBar:SetScript("OnUpdate", CastingBarFrame_OnUpdate)
		namePlate.UnitFrame.castBar:SetScript("OnShow", CastingBarFrame_OnShow)

		namePlate.UnitFrame.RaidTargetFrame = CreateFrame("Frame", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.RaidTargetFrame:SetSize(30, 30)
		if Config.Guarm_mod then
			namePlate.UnitFrame.RaidTargetFrame:SetPoint("TOP", namePlate.UnitFrame.healthperc, "BOTTOM", 0, 0)
		else
			namePlate.UnitFrame.RaidTargetFrame:SetPoint("RIGHT", namePlate.UnitFrame.name, "LEFT")
		end
		
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon = namePlate.UnitFrame.RaidTargetFrame:CreateTexture(nil, "OVERLAY")
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:SetTexture(raidicon)
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:SetAllPoints()
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:Hide()
		
		namePlate.UnitFrame.redarrow = namePlate.UnitFrame:CreateTexture(nil, 'OVERLAY')
		namePlate.UnitFrame.redarrow:SetSize(50, 50)
		namePlate.UnitFrame.redarrow:SetTexture(redarrow)
		namePlate.UnitFrame.redarrow:Hide()
		
		namePlate.UnitFrame.icons = CreateFrame("Frame", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.icons:SetPoint("BOTTOM", namePlate.UnitFrame.healthperc, "TOP", 0, 0)
		namePlate.UnitFrame.icons:SetWidth(140)
		namePlate.UnitFrame.icons:SetHeight(25)
		namePlate.UnitFrame.icons:SetFrameLevel(namePlate.UnitFrame:GetFrameLevel() + 2)
	else -- 條形樣式
		namePlate.UnitFrame.healthBar = CreateFrame("StatusBar", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.healthBar:SetHeight(8)
		namePlate.UnitFrame.healthBar:SetPoint("LEFT", 0, 0)
		namePlate.UnitFrame.healthBar:SetPoint("RIGHT", 0, 0)
		namePlate.UnitFrame.healthBar:SetStatusBarTexture(ufbar)
		namePlate.UnitFrame.healthBar:SetMinMaxValues(0, 1)
		
		namePlate.UnitFrame.healthBar.bd = createBackdrop(namePlate.UnitFrame.healthBar, namePlate.UnitFrame.healthBar, 1) 
		
		namePlate.UnitFrame.healthBar.value = createtext(namePlate.UnitFrame.healthBar, "OVERLAY", fontsize-4, fontflag, "CENTER")
		namePlate.UnitFrame.healthBar.value:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame.healthBar, "TOPRIGHT", 0, -fontsize/3)
		namePlate.UnitFrame.healthBar.value:SetTextColor(1,1,1)
		namePlate.UnitFrame.healthBar.value:SetText("Value")
		
		namePlate.UnitFrame.name = createtext(namePlate.UnitFrame, "OVERLAY", fontsize-4, fontflag, "CENTER")
		namePlate.UnitFrame.name:SetPoint("TOPLEFT", namePlate.UnitFrame, "TOPLEFT", 5, -5)
		namePlate.UnitFrame.name:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame, "TOPRIGHT", -5, -15)
		namePlate.UnitFrame.name:SetIndentedWordWrap(false)
		namePlate.UnitFrame.name:SetTextColor(1,1,1)
		namePlate.UnitFrame.name:SetText("Name")
		
		namePlate.UnitFrame.castBar = CreateFrame("StatusBar", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.castBar:Hide()
		namePlate.UnitFrame.castBar.iconWhenNoninterruptible = false
		namePlate.UnitFrame.castBar:SetHeight(8)
		if Config.classresource_show and Config.classresource == "target" then  
			namePlate.UnitFrame.castBar:SetPoint("TOPLEFT", namePlate.UnitFrame.healthBar, "BOTTOMLEFT", 0, -7)  
			namePlate.UnitFrame.castBar:SetPoint("TOPRIGHT", namePlate.UnitFrame.healthBar, "BOTTOMRIGHT", 0, -7)  
		else  
			namePlate.UnitFrame.castBar:SetPoint("TOPLEFT", namePlate.UnitFrame.healthBar, "BOTTOMLEFT", 0, -3)  
			namePlate.UnitFrame.castBar:SetPoint("TOPRIGHT", namePlate.UnitFrame.healthBar, "BOTTOMRIGHT", 0, -3)  
		end  

		namePlate.UnitFrame.castBar:SetStatusBarTexture(ufbar)
		namePlate.UnitFrame.castBar:SetStatusBarColor(0.5, 0.5, 0.5)
		createBackdrop(namePlate.UnitFrame.castBar, namePlate.UnitFrame.castBar, 1) 
			
		namePlate.UnitFrame.castBar.Text = createtext(namePlate.UnitFrame.castBar, "OVERLAY", fontsize-4, fontflag, "CENTER")
		namePlate.UnitFrame.castBar.Text:SetPoint("TOPLEFT", namePlate.UnitFrame.castBar, "BOTTOMLEFT", -5, 5)
		namePlate.UnitFrame.castBar.Text:SetPoint("TOPRIGHT", namePlate.UnitFrame.castBar, "BOTTOMRIGHT", 5, -5)
		namePlate.UnitFrame.castBar.Text:SetText("Spell Name")
		
		namePlate.UnitFrame.castBar.Icon = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY", 1)
		namePlate.UnitFrame.castBar.Icon:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame.castBar, "BOTTOMLEFT", -4, -1)
		namePlate.UnitFrame.castBar.Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
		if Config.classresource_show and Config.classresource == "target" then  
			namePlate.UnitFrame.castBar.Icon:SetSize(25, 25)  
		else  
			namePlate.UnitFrame.castBar.Icon:SetSize(21, 21)  
		end  

		namePlate.UnitFrame.castBar.Icon.iconborder = CreateBG(namePlate.UnitFrame.castBar.Icon)
		namePlate.UnitFrame.castBar.Icon.iconborder:SetDrawLayer("OVERLAY", -1)
		
		namePlate.UnitFrame.castBar.BorderShield = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY", 1)
		namePlate.UnitFrame.castBar.BorderShield:SetAtlas("nameplates-InterruptShield")
		namePlate.UnitFrame.castBar.BorderShield:SetSize(15, 15)
		namePlate.UnitFrame.castBar.BorderShield:SetPoint("LEFT", namePlate.UnitFrame.castBar, "LEFT", 5, -5)

		namePlate.UnitFrame.castBar.Spark = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY")
		namePlate.UnitFrame.castBar.Spark:SetSize(30, 25)
		namePlate.UnitFrame.castBar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		namePlate.UnitFrame.castBar.Spark:SetBlendMode("ADD")
		namePlate.UnitFrame.castBar.Spark:SetPoint("CENTER", 0, 3)
		
		namePlate.UnitFrame.castBar.Flash = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY")
		namePlate.UnitFrame.castBar.Flash:SetAllPoints()
		namePlate.UnitFrame.castBar.Flash:SetTexture(ufbar)
		namePlate.UnitFrame.castBar.Flash:SetBlendMode("ADD")
		
		CastingBarFrame_OnLoad(namePlate.UnitFrame.castBar, nil, false, true)
		namePlate.UnitFrame.castBar:SetScript("OnEvent", CastingBarFrame_OnEvent)
		namePlate.UnitFrame.castBar:SetScript("OnUpdate", CastingBarFrame_OnUpdate)
		namePlate.UnitFrame.castBar:SetScript("OnShow", CastingBarFrame_OnShow)

		namePlate.UnitFrame.RaidTargetFrame = CreateFrame("Frame", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.RaidTargetFrame:SetSize(30, 30)
		
		if Config.Guarm_mod then
			namePlate.UnitFrame.RaidTargetFrame:SetPoint("TOP", namePlate.UnitFrame, "BOTTOM", 0, 30)
		else
			namePlate.UnitFrame.RaidTargetFrame:SetPoint("RIGHT", namePlate.UnitFrame.name, "LEFT")
		end
		
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon = namePlate.UnitFrame.RaidTargetFrame:CreateTexture(nil, "OVERLAY")
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:SetTexture(raidicon)
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:SetAllPoints()
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:Hide()
		
		namePlate.UnitFrame.redarrow = namePlate.UnitFrame:CreateTexture("$parent_Arrow", 'OVERLAY')
		namePlate.UnitFrame.redarrow:SetSize(50, 50)
		namePlate.UnitFrame.redarrow:SetTexture(redarrow)
		namePlate.UnitFrame.redarrow:SetPoint("CENTER")
		namePlate.UnitFrame.redarrow:Hide()
		
		namePlate.UnitFrame.icons = CreateFrame("Frame", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.icons:SetPoint("BOTTOM", namePlate.UnitFrame, "TOP", 0, 0)
		namePlate.UnitFrame.icons:SetWidth(140)
		namePlate.UnitFrame.icons:SetHeight(25)
		namePlate.UnitFrame.icons:SetFrameLevel(namePlate.UnitFrame:GetFrameLevel() + 2)
	end
	
	namePlate.UnitFrame:EnableMouse(false)
end
			
local function OnNamePlateAdded(unit)
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	local unitFrame = namePlate.UnitFrame
	SetUnit(unitFrame, unit)
	UpdateAll(unitFrame)
end

local function OnNamePlateRemoved(unit)
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	SetUnit(namePlate.UnitFrame, nil)
	CastingBarFrame_SetUnit(namePlate.UnitFrame.castBar, nil, false, true)
end

--加一段cvar代碼
local function defaultcvar() 
	if Config.CVAR then	
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
		SetCVar("namePlateMinScale", 1)
		SetCVar("namePlateMaxScale", 1)
		SetCVar("nameplateMaxDistance", 45)
	else
		SetCVar("nameplateOtherTopInset", 0.08)
		SetCVar("nameplateOtherBottomInset", 0.1)
		SetCVar("namePlateMinScale", 0.8)
		SetCVar("namePlateMaxScale", 1)
		SetCVar("nameplateMaxDistance", 60)	
	end
end 
	
local function NamePlates_OnEvent(self, event, ...)
	local arg1 = ...
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		defaultcvar()
	end
	if ( event == "VARIABLES_LOADED" ) then
		HideBlizzard()
		if Config.playerplate then  
			SetCVar("nameplateShowSelf", 1)  
		else  
			SetCVar("nameplateShowSelf", 0)  
		end  

		NamePlates_UpdateNamePlateOptions()
	elseif ( event == "NAME_PLATE_CREATED" ) then
		local namePlate = ...
		OnNamePlateCreated(namePlate)
	elseif ( event == "NAME_PLATE_UNIT_ADDED" ) then 
		local unit = ...
		OnNamePlateAdded(unit)
	elseif ( event == "NAME_PLATE_UNIT_REMOVED" ) then 
		local unit = ...
		OnNamePlateRemoved(unit)
	elseif event == "RAID_TARGET_UPDATE" then
		OnRaidTargetUpdate()
	elseif event == "DISPLAY_SIZE_CHANGED" then
		NamePlates_UpdateNamePlateOptions()
	elseif ( event == "UNIT_FACTION" ) then
		OnUnitFactionChanged(...)
	elseif Config.Guarm_mod and event == "UNIT_AURA" and arg1 == "player" then
		for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
			UpdateBuffs(namePlate.UnitFrame)
		end
	end
end

local NamePlatesFrame = CreateFrame("Frame", "NamePlatesFrame", UIParent) 
NamePlatesFrame:SetScript("OnEvent", NamePlates_OnEvent)
NamePlatesFrame:RegisterEvent("VARIABLES_LOADED")
NamePlatesFrame:RegisterEvent("NAME_PLATE_CREATED")
NamePlatesFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
NamePlatesFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
NamePlatesFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")
NamePlatesFrame:RegisterEvent("RAID_TARGET_UPDATE")
NamePlatesFrame:RegisterEvent("UNIT_FACTION")
NamePlatesFrame:RegisterEvent("UNIT_AURA")
NamePlatesFrame:RegisterEvent("PLAYER_ENTERING_WORLD")