pfUI:RegisterModule("castbar", function ()

  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.unitframes ~= "-1" then
    default_border = pfUI_config.appearance.border.unitframes
  end

  pfUI.castbar = CreateFrame("Frame", "pfCastBar", UIParent)

  -- hide blizzard
  if pfUI_config.castbar.player.hide_blizz == "1" then
    CastingBarFrame:UnregisterAllEvents()
    CastingBarFrame:Hide()
  end

  -- [[ pfPlayerCastbar ]] --
  pfUI.castbar.player = CreateFrame("Frame", "pfPlayerCastbar", UIParent)
  pfUI.castbar.player:SetFrameStrata("HIGH")
  pfUI.api:CreateBackdrop(pfUI.castbar.player, default_border)
  pfUI.castbar.player:SetHeight(pfUI_config.global.font_size + default_border)

  if pfUI.uf.player then
    pfUI.castbar.player:SetPoint("TOPLEFT",pfUI.uf.player,"BOTTOMLEFT",0,-default_border*2)
    pfUI.castbar.player:SetWidth(pfUI.uf.player:GetWidth())
  else
    pfUI.castbar.player:SetPoint("CENTER", 0, -200)
    pfUI.castbar.player:SetWidth(200)
  end

  pfUI.api:UpdateMovable(pfUI.castbar.player)
  pfUI.castbar.player:Hide()
  pfUI.castbar.player.delay = 0

  -- statusbar
  pfUI.castbar.player.bar = CreateFrame("StatusBar", nil, pfUI.castbar.player)
  pfUI.castbar.player.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.castbar.player.bar:ClearAllPoints()
  pfUI.castbar.player.bar:SetAllPoints(pfUI.castbar.player)
  pfUI.castbar.player.bar:SetMinMaxValues(0, 100)
  pfUI.castbar.player.bar:SetValue(20)
  local r,g,b,a = pfUI.api.strsplit(",", pfUI_config.appearance.castbar.castbarcolor)
  pfUI.castbar.player.bar:SetStatusBarColor(r,g,b,a)

  -- text left
  pfUI.castbar.player.bar.left = pfUI.castbar.player.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.castbar.player.bar.left:ClearAllPoints()
  pfUI.castbar.player.bar.left:SetPoint("TOPLEFT", pfUI.castbar.player.bar, "TOPLEFT", 3, 0)
  pfUI.castbar.player.bar.left:SetPoint("BOTTOMRIGHT", pfUI.castbar.player.bar, "BOTTOMRIGHT", -3, 0)
  pfUI.castbar.player.bar.left:SetNonSpaceWrap(false)
  pfUI.castbar.player.bar.left:SetFontObject(GameFontWhite)
  pfUI.castbar.player.bar.left:SetTextColor(1,1,1,1)
  pfUI.castbar.player.bar.left:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.castbar.player.bar.left:SetText("left")
  pfUI.castbar.player.bar.left:SetJustifyH("left")

  -- text right
  pfUI.castbar.player.bar.right = pfUI.castbar.player.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.castbar.player.bar.right:ClearAllPoints()
  pfUI.castbar.player.bar.right:SetPoint("TOPLEFT", pfUI.castbar.player.bar, "TOPLEFT", 3, 0)
  pfUI.castbar.player.bar.right:SetPoint("BOTTOMRIGHT", pfUI.castbar.player.bar, "BOTTOMRIGHT", -3, 0)
  pfUI.castbar.player.bar.right:SetNonSpaceWrap(false)
  pfUI.castbar.player.bar.right:SetFontObject(GameFontWhite)
  pfUI.castbar.player.bar.right:SetTextColor(1,1,1,1)
  pfUI.castbar.player.bar.right:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.castbar.player.bar.right:SetText("right")
  pfUI.castbar.player.bar.right:SetJustifyH("right")

  -- events
  pfUI.castbar.player:RegisterEvent("SPELLCAST_START")
  pfUI.castbar.player:RegisterEvent("SPELLCAST_STOP")
  pfUI.castbar.player:RegisterEvent("SPELLCAST_DELAYED")
  pfUI.castbar.player:RegisterEvent("SPELLCAST_CHANNEL_START")
  pfUI.castbar.player:RegisterEvent("SPELLCAST_CHANNEL_STOP")
  pfUI.castbar.player:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
  pfUI.castbar.player:RegisterEvent("SPELLCAST_FAILED")
  pfUI.castbar.player:RegisterEvent("SPELLCAST_INTERRUPTED")

  pfUI.castbar.player:SetScript("OnEvent", function ()
    if ( event == "SPELLCAST_START" ) then
      pfUI.castbar.player.delay = 0
      pfUI.castbar.player.spell = arg1
      pfUI.castbar.player.bar.left:SetText(arg1)
      local r,g,b,a = pfUI.api.strsplit(",", pfUI_config.appearance.castbar.castbarcolor)
      pfUI.castbar.player.bar:SetStatusBarColor(r,g,b,a)
      pfUI.castbar.player.startTime = GetTime()
      pfUI.castbar.player.maxValue = arg2 / 1000
      pfUI.castbar.player.endTime = nil
      pfUI.castbar.player.bar:SetMinMaxValues(0, pfUI.castbar.player.maxValue)
      pfUI.castbar.player.bar:SetValue(pfUI.castbar.player.startTime)
      pfUI.castbar.player.holdTime = 0
      pfUI.castbar.player.casting = 1
      pfUI.castbar.player.channeling = nil
      pfUI.castbar.player.mode = "casting"
      pfUI.castbar.player.fadeout = nil
      pfUI.castbar.player:SetAlpha(1)
      pfUI.castbar.player:Show()

    elseif ( event == "SPELLCAST_CHANNEL_START" ) then
      pfUI.castbar.player.delay = 0
      pfUI.castbar.player.spell = arg2
      pfUI.castbar.player.bar.left:SetText(arg2)
      local r,g,b,a = pfUI.api.strsplit(",", pfUI_config.appearance.castbar.channelcolor)
      pfUI.castbar.player.bar:SetStatusBarColor(r,g,b,a)
      pfUI.castbar.player.maxValue = nil
      pfUI.castbar.player.startTime = GetTime()
      pfUI.castbar.player.endTime = pfUI.castbar.player.startTime + (arg1 / 1000)
      pfUI.castbar.player.duration = arg1 / 1000
      pfUI.castbar.player.bar:SetMinMaxValues(pfUI.castbar.player.startTime, pfUI.castbar.player.endTime)
      pfUI.castbar.player.bar:SetValue(pfUI.castbar.player.endTime)
      pfUI.castbar.player.holdTime = 0
      pfUI.castbar.player.casting = nil
      pfUI.castbar.player.channeling = 1
      pfUI.castbar.player.fadeout = nil
      pfUI.castbar.player:SetAlpha(1)
      pfUI.castbar.player:Show()

    elseif event == "SPELLCAST_STOP" then
      if pfUI.castbar.player.casting then
        pfUI.castbar.player.fadeout = 1
        pfUI.castbar.player.casting = nil
        pfUI.castbar.player.bar:SetMinMaxValues(1,pfUI.castbar.player.bar:GetValue())
      end

    elseif event == "SPELLCAST_CHANNEL_STOP" then
      if pfUI.castbar.player.channeling then
        pfUI.castbar.player.fadeout = 1
        pfUI.castbar.player.channeling = nil

        if GetTime() + 0.3 < pfUI.castbar.player.endTime then
          pfUI.castbar.player.bar:SetStatusBarColor(1,.5,.5,1)
          pfUI.castbar.player.bar:SetMinMaxValues(1,100)
          pfUI.castbar.player.bar:SetValue(100)
        end
      end

    elseif event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then
      if pfUI.castbar.player.casting then
        pfUI.castbar.player.fadeout = 1
        pfUI.castbar.player.casting = nil

        pfUI.castbar.player.bar:SetStatusBarColor(1,.5,.5,1)
        pfUI.castbar.player.bar:SetMinMaxValues(1,100)
        pfUI.castbar.player.bar:SetValue(100)
      end

    elseif ( event == "SPELLCAST_DELAYED" ) then
      if( pfUI.castbar.player:IsShown() ) then
        pfUI.castbar.player.delay = pfUI.castbar.player.delay + arg1/1000
      end

    elseif ( event == "SPELLCAST_CHANNEL_UPDATE" ) then
      if ( pfUI.castbar.player:IsShown() ) then
        pfUI.castbar.player.delay = pfUI.castbar.player.delay + arg1/1000
        local origDuration = pfUI.castbar.player.endTime - pfUI.castbar.player.startTime
        pfUI.castbar.player.endTime = GetTime() + (arg1 / 1000)
        pfUI.castbar.player.startTime = pfUI.castbar.player.endTime - origDuration
        pfUI.castbar.player.bar:SetMinMaxValues(pfUI.castbar.player.startTime, pfUI.castbar.player.endTime)
      end
    end
  end)

  pfUI.castbar.player:SetScript("OnUpdate", function ()
    if pfUI_config.castbar.player.hide_pfui == "1" then pfUI.castbar.player:Hide() return end

    -- cast
    if pfUI.castbar.player.casting then
      local cur = GetTime() - pfUI.castbar.player.startTime - pfUI.castbar.player.delay
      local max = pfUI.castbar.player.maxValue
      local delay = pfUI.castbar.player.delay

      pfUI.castbar.player.bar:SetValue(cur)

      if cur > max then cur = max end

      if delay > 0 then
        delay = "|cffffaaaa+" .. pfUI.api.round(delay,1) .. " |r "
        pfUI.castbar.player.bar.right:SetText(delay .. pfUI.api.round(cur,1) .. " / " .. pfUI.api.round(max,1))
      else
        pfUI.castbar.player.bar.right:SetText(pfUI.api.round(cur,1) .. " / " .. pfUI.api.round(max,1))
      end

      return

    -- channel
    elseif pfUI.castbar.player.channeling then
      local time = GetTime()
      local barValue = pfUI.castbar.player.startTime + (pfUI.castbar.player.endTime - time)

      pfUI.castbar.player.bar:SetValue( barValue )

      local cur = pfUI.castbar.player.endTime - GetTime()
      local max = pfUI.castbar.player.endTime - pfUI.castbar.player.startTime
      local delay = pfUI.castbar.player.delay
      if cur > max then cur = max end
      if ( time > pfUI.castbar.player.endTime ) then
        time = pfUI.castbar.player.endTime
      end
      if ( time >= pfUI.castbar.player.endTime ) then
        pfUI.castbar.player.channeling = nil
        pfUI.castbar.player.fadeout = 1
        return
      end
      if delay > 0 then
        delay = "|cffffaaaa-" .. pfUI.api.round(delay,1) .. " |r "
        pfUI.castbar.player.bar.right:SetText(delay .. pfUI.api.round(cur,1))
      else
        pfUI.castbar.player.bar.right:SetText(pfUI.api.round(cur,1))
      end

      return

    -- fadeout
    elseif pfUI.castbar.player.fadeout and pfUI.castbar.player:GetAlpha() > 0 then
      pfUI.castbar.player:SetAlpha(pfUI.castbar.player:GetAlpha()-0.025)
      if pfUI.castbar.player:GetAlpha() == 0 then
        pfUI.castbar.player:Hide()
        pfUI.castbar.player.fadeout = nil
      end
    end
  end)

  -- [[ pfTargetCastbar ]] --
  pfUI.castbar.target = CreateFrame("Frame", "pfTargetCastbar", UIParent)
  pfUI.castbar.target:SetFrameStrata("HIGH")
  pfUI.api:CreateBackdrop(pfUI.castbar.target, default_border)
  pfUI.castbar.target:SetHeight(pfUI_config.global.font_size + default_border)

  if pfUI.uf.target then
    pfUI.castbar.target:SetPoint("TOPLEFT",pfUI.uf.target,"BOTTOMLEFT",0,-default_border*2)
    pfUI.castbar.target:SetWidth(pfUI.uf.target:GetWidth())
  else
    pfUI.castbar.target:SetPoint("CENTER", 0, -225)
    pfUI.castbar.target:SetWidth(200)
  end

  pfUI.api:UpdateMovable(pfUI.castbar.target)
  pfUI.castbar.target:Hide()


  -- statusbar
  pfUI.castbar.target.bar = CreateFrame("StatusBar", nil, pfUI.castbar.target)
  pfUI.castbar.target.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.castbar.target.bar:ClearAllPoints()
  pfUI.castbar.target.bar:SetAllPoints(pfUI.castbar.target)
  pfUI.castbar.target.bar:SetMinMaxValues(0, 100)
  pfUI.castbar.target.bar:SetValue(20)
  local r,g,b,a = pfUI.api.strsplit(",", pfUI_config.appearance.castbar.castbarcolor)
  pfUI.castbar.target.bar:SetStatusBarColor(r,g,b,a)

  -- text left
  pfUI.castbar.target.bar.left = pfUI.castbar.target.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.castbar.target.bar.left:ClearAllPoints()
  pfUI.castbar.target.bar.left:SetPoint("TOPLEFT", pfUI.castbar.target.bar, "TOPLEFT", 3, 0)
  pfUI.castbar.target.bar.left:SetPoint("BOTTOMRIGHT", pfUI.castbar.target.bar, "BOTTOMRIGHT", -3, 0)
  pfUI.castbar.target.bar.left:SetNonSpaceWrap(false)
  pfUI.castbar.target.bar.left:SetFontObject(GameFontWhite)
  pfUI.castbar.target.bar.left:SetTextColor(1,1,1,1)
  pfUI.castbar.target.bar.left:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.castbar.target.bar.left:SetText("left")
  pfUI.castbar.target.bar.left:SetJustifyH("left")

  -- text right
  pfUI.castbar.target.bar.right = pfUI.castbar.target.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
  pfUI.castbar.target.bar.right:ClearAllPoints()
  pfUI.castbar.target.bar.right:SetPoint("TOPLEFT", pfUI.castbar.target.bar, "TOPLEFT", 3, 0)
  pfUI.castbar.target.bar.right:SetPoint("BOTTOMRIGHT", pfUI.castbar.target.bar, "BOTTOMRIGHT", -3, 0)
  pfUI.castbar.target.bar.right:SetNonSpaceWrap(false)
  pfUI.castbar.target.bar.right:SetFontObject(GameFontWhite)
  pfUI.castbar.target.bar.right:SetTextColor(1,1,1,1)
  pfUI.castbar.target.bar.right:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.castbar.target.bar.right:SetText("right")
  pfUI.castbar.target.bar.right:SetJustifyH("right")

  pfUI.castbar.target.bar:SetScript("OnUpdate", function()
    if pfUI.castbar.target.drag and pfUI.castbar.target.drag:IsShown() then this:Show() return end
    if UnitExists("target") and pfUI.castbar.target.casterDB[UnitName("target")] then
      local spellname = pfUI.castbar.target.casterDB[UnitName("target")].cast or 0
      local starttime = pfUI.castbar.target.casterDB[UnitName("target")].starttime or 0
      local casttime = pfUI.castbar.target.casterDB[UnitName("target")].casttime or 0

      if starttime + casttime > GetTime() then
        if pfUI.castbar.target.bar then
          pfUI.castbar.target.bar:SetMinMaxValues(0, casttime)
          pfUI.castbar.target.bar:SetValue(GetTime() - starttime)
          pfUI.castbar.target.bar.left:SetText(spellname)
          pfUI.castbar.target.bar.right:SetText(pfUI.api.round(GetTime() - starttime,1) .. " / " .. casttime)
        end
      else
        pfUI.castbar.target.casterDB[UnitName("target")] = nil
        pfUI.castbar.target:Hide()
      end
    else
      pfUI.castbar.target:Hide()
    end
  end)

  -- Parse localized combatlog strings available in globalstrings.lua:
  -- SPELL_CAST:          (.+) begins to cast (.+).
  -- SPELL_PERFORM:       (.+) begins to perform (.+).
  -- SPELL_GAINS:         (.+) gains (.+).
  -- SPELL_AFFLICTED:     (.+) %a+ afflicted by (.+).
  -- SPELL_HIT:           Your (.+) %a hits (.+) for %d+\.
  -- SPELL_CRIT:          Your (.+) %a crits (.+) for %d+\.
  -- OTHER_SPELL_HIT:     %a+'s (.+) %a hits (.+) for %d+\.
  -- OTHER_SPELL_CRIT:    %a+'s (.+) %a crits (.+) for %d+\.
  pfUI.castbar.target.SPELL_CAST = string.gsub(string.gsub(SPELLCASTOTHERSTART,"%d%$",""), "%%s", "(.+)")
  pfUI.castbar.target.SPELL_PERFORM = string.gsub(string.gsub(SPELLPERFORMOTHERSTART,"%d%$",""), "%%s", "(.+)")
  pfUI.castbar.target.SPELL_GAINS = string.gsub(string.gsub(AURAADDEDOTHERHELPFUL,"%d%$",""), "%%s", "(.+)")
  pfUI.castbar.target.SPELL_AFFLICTED = string.gsub(string.gsub(AURAADDEDOTHERHARMFUL,"%d%$",""), "%%s", "(.+)")
  pfUI.castbar.target.SPELL_HIT = string.gsub(string.gsub(string.gsub(SPELLLOGSELFOTHER,"%d%$",""),"%%d","%%d+"),"%%s","(.+)")
  pfUI.castbar.target.SPELL_CRIT = string.gsub(string.gsub(string.gsub(SPELLLOGCRITSELFOTHER,"%d%$",""),"%%d","%%d+"),"%%s","(.+)")
  pfUI.castbar.target.OTHER_SPELL_HIT = string.gsub(string.gsub(string.gsub(SPELLLOGOTHEROTHER,"%d%$",""), "%%s", "(.+)"), "%%d", "%%d+")
  pfUI.castbar.target.OTHER_SPELL_CRIT = string.gsub(string.gsub(string.gsub(SPELLLOGOTHEROTHER,"%d%$",""), "%%s", "(.+)"), "%%d", "%%d+")

  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PARTY_BUFF")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
  pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
  pfUI.castbar.target:RegisterEvent("PLAYER_TARGET_CHANGED")

  pfUI.castbar.target.casterDB = {}

  pfUI.castbar.target:SetScript("OnEvent", function()
    if (arg1 ~= nil) then
      -- cast action
      for mob, spell in string.gfind(arg1, pfUI.castbar.target.SPELL_CAST) do
        pfUI.castbar.target:Action(mob, spell)
        return
      end
      for mob, spell in string.gfind(arg1, pfUI.castbar.target.SPELL_PERFORM) do
        pfUI.castbar.target:Action(mob, spell)
        return
      end

      -- interrupt action
      for mob, spell in string.gfind(arg1, pfUI.castbar.target.SPELL_GAINS) do
        pfUI.castbar.target:StopAction(mob, spell)
        return
      end
      for mob, spell in string.gfind(arg1, pfUI.castbar.target.SPELL_AFFLICTED) do
        pfUI.castbar.target:StopAction(mob, spell)
        return
      end
      for spell, mob in string.gfind(arg1, pfUI.castbar.target.SPELL_HIT) do
        pfUI.castbar.target:StopAction(mob, spell)
        return
      end
      for spell, mob in string.gfind(arg1, pfUI.castbar.target.SPELL_CRIT) do
        pfUI.castbar.target:StopAction(mob, spell)
        return
      end
      for spell, mob in string.gfind(arg1, pfUI.castbar.target.OTHER_SPELL_HIT) do
        pfUI.castbar.target:StopAction(mob, spell)
        return
      end
      for spell, mob in string.gfind(arg1, pfUI.castbar.target.OTHER_SPELL_CRIT) do
        pfUI.castbar.target:StopAction(mob, spell)
        return
      end
    end

    if UnitExists("target") and pfUI.castbar.target.casterDB[UnitName("target")] then
      local starttime = pfUI.castbar.target.casterDB[UnitName("target")].starttime or 0
      local casttime = pfUI.castbar.target.casterDB[UnitName("target")].casttime or 0
      if starttime + casttime > GetTime() then
        if pfUI_config.castbar.target.hide_pfui == "1" then
          pfUI.castbar.target:Hide()
        else
          pfUI.castbar.target:Show()
        end
      elseif pfUI.castbar.target.drag and not pfUI.castbar.target.drag:IsShown() then
        pfUI.castbar.target.casterDB[UnitName("target")] = nil
        pfUI.castbar.target:Hide()
      end
    end
  end)

  function pfUI.castbar.target:Action(mob, spell)
    if pfLocaleSpells[pfUI.cache["locale"]][spell] ~= nil then
      local casttime = pfLocaleSpells[pfUI.cache["locale"]][spell].t / 1000
      local icon = pfLocaleSpells[pfUI.cache["locale"]][spell].icon
      pfUI.castbar.target.casterDB[mob] = {cast = spell, starttime = GetTime(), casttime = casttime, icon = icon}
      if UnitExists("target") and pfUI.castbar.target.casterDB[UnitName("target")] then
        if pfUI_config.castbar.target.hide_pfui == "1" then
          pfUI.castbar.target:Hide()
        else
          pfUI.castbar.target:Show()
        end
      elseif pfUI.castbar.target.drag and not pfUI.castbar.target.drag:IsShown() then
        pfUI.castbar.target:Hide()
      end
    end
  end

  function pfUI.castbar.target:StopAction(mob, spell)
    if pfUI.castbar.target.casterDB[mob] and pfLocaleSpellInterrupts[pfUI.cache["locale"]][spell] ~= nil then
      pfUI.castbar.target.casterDB[mob] = nil
    end
  end
end)
