--[[----------------------------------------------------------------------------
BASICS
----------------------------------------------------------------------------]]--
local AddonName, r2r = ...
local data = CopyTable(R2R.data)
data.keyword = "anchoring"
--------------------------------------------------------------------------------
-- OPTIONS PANEL CREATION
--------------------------------------------------------------------------------
R2R.Anchoring = R2R.Anchoring or {
  fields = {},
}
local _posXname,_posYname,_parentName,_sizeName,_strataName

function R2R:FillAnchoringPanel(panel, container, anchorline)
  local namingPrefix = "SettingsPanel"
  if panel == R2R.ConfigDialog then
    r2r.windowWidth = ceil(container:GetWidth() - 20)
    namingPrefix = "ConfigPanel"
  else
    r2r.windowWidth = SettingsPanel.Container:GetWidth()
  end
  r2r.columnWidth = r2r.windowWidth / r2r.columns - 20

  _posXname = format("%s_%sEditBox_parent_pos_x", data.prefix, namingPrefix )
  _posYname = format("%s_%sEditBox_parent_pos_y", data.prefix, namingPrefix )
  _parentName = format("%s_%sEditBox_parent_frame", data.prefix, namingPrefix )
  _sizeName = format("%s_%sSlider_button_size", data.prefix, namingPrefix)
  _strataName = format("%s_%sDropdown_button_strata", data.prefix, namingPrefix)
  
  local function BuildAnchorGrid(wrapper, cols, option)
    for i,value in ipairs(READI.Anchors) do
      local parent = wrapper
      local p_anchor = READI.ANCHOR_TOPLEFT
      local x = 0
      local y = 0

      if i == 1 then
        x = 32
      elseif i == 2 then
        p_anchor = READI.ANCHOR_TOP
        x = -32
      elseif i == cols then
        p_anchor = READI.ANCHOR_TOPRIGHT
        x = -96
      else
        local parentName = format("%s_%sRadioButton_%s_%s", data.prefix, namingPrefix, option, READI.Anchors[i - cols])
        parent = R2R.Anchoring.fields[parentName]
        p_anchor = READI.ANCHOR_BOTTOMLEFT
      end
      local btnName = format("%s_%sRadioButton_%s_%s", data.prefix, namingPrefix, option ,value)
      local textures = {
        normal = READI.T.rdl100001,
        highlight = READI.T.rdl100002,
        active = READI.T.rdl100003,
      }
      R2R.Anchoring.fields[btnName] = READI:RadioButton(data, {
        name = btnName,
        option = option,
        value = value,
        region = container,
        textures = textures,
        parent = parent,
        p_anchor = p_anchor,
        offsetX = x,
        offsetY = y,
        condition = R2R.db.anchoring[option] == value,
        onClick = function()
          local rb = R2R.Anchoring.fields[btnName]
          for i, val in ipairs(READI.Anchors) do
            local btnName = format("%s_%sRadioButton_%s_%s", data.prefix, namingPrefix, option, val)
            local btn = R2R.Anchoring.fields[btnName]
            if btn.value ~= rb.value then
              btn:SetChecked(false)
              btn.tex:SetTexture(textures.normal)
            end
          end
          rb:SetChecked(true)
          rb.tex:SetTexture(textures.active)
          R2R.db.anchoring[option] = rb.value
          R2R.SkyButton:SetPosition()
        end,
        onReset = function()
          local rb = R2R.Anchoring.fields[btnName]
          if R2R.defaults.anchoring[option] == rb.value and not rb:GetChecked() then rb:Click() end
        end
      })
    end
  end

  local cols = 3
  for _,val in pairs({"button", "parent"}) do
    local offsetX = 20
    if val == "parent" then
      offsetX = r2r.columnWidth + 20
    end

    local title = container:CreateFontString("ARTWORK", nil, "GameFontHighlightLarge")
    title:SetPoint(READI.ANCHOR_TOPLEFT, anchorline, offsetX, -20)
    title:SetText(READI.Helper.color:Get("r2r", R2R.Colors, R2R.L[READI.Helper.string:Capitalize(val) .. " Anchor"]))

    local subTitle = container:CreateFontString("ARTWORK", nil, "GameFontHighlight")
    subTitle:SetPoint(READI.ANCHOR_TOPLEFT, title, READI.ANCHOR_BOTTOMLEFT, 0, -5)
    subTitle:SetJustifyH("LEFT")
    subTitle:SetJustifyV(READI.ANCHOR_TOP)
    subTitle:SetWordWrap(true)
    subTitle:SetSpacing(3)
    subTitle:SetTextScale(1.2)
    subTitle:SetWidth(r2r.columnWidth)
    if val == "button" then
      subTitle:SetText(
        READI.Helper.color:Get("white", nil, format(R2R.L["Select the anchor point of the %s that should be aligned to its parent frame."], READI.Helper.color:Get("r2r", R2R.Colors, R2R.L["SkyridingButton"])))
      )
    else
      subTitle:SetText(
        READI.Helper.color:Get("white", nil, format(R2R.L["Select the parent frame's anchor point that the %s should be aligned to."], READI.Helper.color:Get("r2r", R2R.Colors, R2R.L["SkyridingButton"])))
      )
    end
  
    local wrapper = CreateFrame("Frame", format("%s_%s%s_anchorWrapper", data.prefix, namingPrefix, val))
    wrapper:SetPoint(READI.ANCHOR_TOPLEFT, subTitle, READI.ANCHOR_BOTTOMLEFT, 0, -10)
    wrapper:SetPoint(READI.ANCHOR_BOTTOMRIGHT, subTitle, READI.ANCHOR_BOTTOMRIGHT, 0, -80)

    -- create the anchor position radios
    BuildAnchorGrid(wrapper, cols, format("%s_anchor", val))

  end

  local position_sectionTitle = container:CreateFontString("ARTWORK", nil, "GameFontHighlightLarge")
  position_sectionTitle:SetPoint(READI.ANCHOR_TOPLEFT, _G[data.prefix .. "_".. namingPrefix .. "button_anchorWrapper"], READI.ANCHOR_BOTTOMLEFT, 0, -20)
  position_sectionTitle:SetText(READI.Helper.color:Get("r2r", R2R.Colors, R2R.L["Position offset"]))

  local position_cols = 2
  local posColWidth = r2r.columnWidth / position_cols - 20

  local positionX_sectionTitle = container:CreateFontString("ARTWORK", nil, "GameFontHighlight")
  positionX_sectionTitle:SetPoint(READI.ANCHOR_TOPLEFT, position_sectionTitle, READI.ANCHOR_BOTTOMLEFT, 0, -5)
  positionX_sectionTitle:SetText(READI.Helper.color:Get("white", nil, R2R.L["X-Offset"]))
  positionX_sectionTitle:SetSpacing(3)
  positionX_sectionTitle:SetTextScale(1.2)

  R2R.Anchoring.fields[_posXname] = READI:EditBox(data, {
    name = _posXname,
    region = container,
    type = "number",
    step = 0.25,
    value = R2R.db.anchoring.position_x or R2R.defaults.anchoring.position_x,
    width = posColWidth,
    parent = positionX_sectionTitle,
    showButtons = true,
    okayForNumber = false,
    onChange = function()
      R2R.db.anchoring.position_x = R2R.Anchoring.fields[_posXname]:GetText()
      R2R.SkyButton:SetPosition()
    end,
    onReset = function()
      R2R.Anchoring.fields[_posXname]:SetText(R2R.defaults.anchoring.position_x)
      EventRegistry:TriggerEvent(format("%s.%s.%s", data.prefix, data.keyword, "OnChange"))
    end
  })

  local positionY_sectionTitle = container:CreateFontString("ARTWORK", nil, "GameFontHighlight")
  positionY_sectionTitle:SetPoint(READI.ANCHOR_TOPLEFT, position_sectionTitle, READI.ANCHOR_BOTTOMLEFT, posColWidth + 20, -5)
  positionY_sectionTitle:SetText(READI.Helper.color:Get("white", nil, R2R.L["Y-Offset"]))
  positionY_sectionTitle:SetSpacing(3)
  positionY_sectionTitle:SetTextScale(1.2)

  R2R.Anchoring.fields[_posYname] = READI:EditBox(data, {
    name = _posYname,
    region = container,
    type = "number",
    step = 0.25,
    value = R2R.db.anchoring.position_y or R2R.defaults.anchoring.position_y,
    width = posColWidth,
    parent = positionY_sectionTitle,
    showButtons = true,
    okayForNumber = false,
    onChange = function()
      R2R.db.anchoring.position_y = R2R.Anchoring.fields[_posYname]:GetText()
      R2R.SkyButton:SetPosition()
    end,
    onReset = function()
      R2R.Anchoring.fields[_posYname]:SetText(R2R.defaults.anchoring.position_y)
      EventRegistry:TriggerEvent(format("%s.%s.%s", data.prefix, data.keyword, "OnChange"))
    end
  })

  -- define the parent related fields
  local parentFrame_sectionTitle = container:CreateFontString("ARTWORK", nil, "GameFontHighlightLarge")
  parentFrame_sectionTitle:SetPoint(READI.ANCHOR_TOPLEFT, _G[data.prefix.."_"..namingPrefix.."parent_anchorWrapper"], READI.ANCHOR_BOTTOMLEFT, 0, -20)
  parentFrame_sectionTitle:SetText(READI.Helper.color:Get("r2r", R2R.Colors, R2R.L["Parent Frame"]))

  local parentFrame_nameTitle = container:CreateFontString("ARTWORK", nil, "GameFontHighlight")
  parentFrame_nameTitle:SetPoint(READI.ANCHOR_TOPLEFT, parentFrame_sectionTitle, READI.ANCHOR_BOTTOMLEFT, 0, -5)
  parentFrame_nameTitle:SetText(READI.Helper.color:Get("white", nil, R2R.L["Enter the name of the parent frame"]))
  parentFrame_nameTitle:SetSpacing(3)
  parentFrame_nameTitle:SetTextScale(1.2)

  R2R.Anchoring.fields[_parentName] = READI:EditBox(data, {
    name = _parentName,
    region = container,
    type = "text",
    value = R2R.db.anchoring.frame or R2R.defaults.anchoring.frame,
    width = r2r.columnWidth,
    parent = parentFrame_nameTitle,
    showButtons = true,
    onChange = function()
      R2R.db.anchoring.frame = R2R.Anchoring.fields[_parentName]:GetText()
      R2R.SkyButton:SetPosition()
    end,
    onReset = function()
      R2R.Anchoring.fields[_parentName]:SetText(R2R.defaults.anchoring.frame)
      EventRegistry:TriggerEvent(format("%s.%s.%s", data.prefix, data.keyword, "OnChange"))
    end
  })
  R2R.Anchoring.fields[AddonName.."FrameSelectorButton"] = READI:Button(data, {
    name = data.prefix..namingPrefix.."FrameSelectorButton",
    region = container,
    label = "",
    tooltip = READI:l10n("general.tooltips.buttons.frameSelector"),
    width = 22,
    height = 22,
    anchor = "LEFT",
    parent = R2R.Anchoring.fields[_parentName],
    p_anchor = "RIGHT",
    offsetX = 5,
    onClick = function(self)
      local field = R2R.Anchoring.fields[_parentName]
      data.frameName = field:GetText()
      READI:StartFrameSelector(data, R2R.db.anchoring.frame, field)
    end,
  })
  R2R.Anchoring.fields[AddonName.."FrameSelectorButton"].symbol = READI:Icon(data, {
    name = data.prefix..namingPrefix.."FrameSelectorButtonSymbol",
    region = R2R.Anchoring.fields[AddonName.."FrameSelectorButton"],
    texture = READI.T.rdl120001,
    width = 14,
    height = 14
  })
  R2R.Anchoring.fields[AddonName.."FrameSelectorButton"].symbol:SetPoint("CENTER", R2R.Anchoring.fields[AddonName.."FrameSelectorButton"], "CENTER", 0, 0)
  R2R.Anchoring.fields[_parentName]:SetWidth(r2r.columnWidth - R2R.Anchoring.fields[AddonName.."FrameSelectorButton"]:GetWidth() - 10)

  local buttonSizeTitle = container:CreateFontString("ARTWORK", nil, "GameFontHighlightLarge")
  buttonSizeTitle:SetPoint(READI.ANCHOR_TOPLEFT, R2R.Anchoring.fields[_posXname], READI.ANCHOR_BOTTOMLEFT, 0, -20)

  R2R.Anchoring.fields[_sizeName] = READI:Slider(data, {
    region = container,
    name = _sizeName,
    min = 16,
    max = 64,
    step = 8,
    value = R2R.db.anchoring.button_size or R2R.defaults.anchoring.button_size,
    width = r2r.columnWidth - 20,
    anchor = READI.ANCHOR_TOPLEFT,
    parent = buttonSizeTitle,
    p_anchor = READI.ANCHOR_BOTTOMLEFT,
    offsetX = 0,
    offsetY = -20,
    onChange = function ()
      local slider = R2R.Anchoring.fields[_sizeName]
      R2R.db.anchoring.button_size = slider:GetValue()
      _G[slider.name.."Text"]:SetText(slider:GetValue())
        R2R.SkyButton:ScaleButton()
    end,
    onReset = function ()
      R2R.Anchoring.fields[_sizeName]:SetValue(R2R.defaults.anchoring.button_size)
    end
  })

  local buttonStrataTitle = container:CreateFontString("ARTWORK", nil, "GameFontHighlightLarge")
  buttonStrataTitle:SetPoint(READI.ANCHOR_TOPLEFT, R2R.Anchoring.fields[_parentName], READI.ANCHOR_BOTTOMLEFT, 0, -20)

  R2R.Anchoring.fields[_strataName] = READI:DropDown(data, {
    values = READI.Strata,
    storage = "R2R.db.anchoring",
    option = "button_strata",
    name = _strataName,
    region = container,
    width = r2r.columnWidth - 20,
    parent = buttonStrataTitle,
    offsetX = -20,
    offsetY = -15,
    onReset = function()
      R2R.db.anchoring.button_strata = R2R.defaults.anchoring.button_strata
      UIDropDownMenu_SetText(R2R.Anchoring.fields[_strataName], R2R.defaults.anchoring.button_strata)
      CloseDropDownMenus()    
    end,
    onChange = function () R2R.SkyButton:SetStrata() end
  })

  local btnRegion
  if panel == R2R.ConfigDialog then
    btnRegion = container
  else
    btnRegion = panel
  end

  local btn_Reset = READI:Button(data,
    {
      name = data.prefix..namingPrefix..READI.Helper.string:Capitalize(data.keyword).."ResetButton",
      region = btnRegion,
      label = READI:l10n("general.labels.buttons.reset"),
      anchor = READI.ANCHOR_BOTTOMLEFT,
      parent = btnRegion,
      offsetX = 10,
      offsetY = 10,
      onClick = function()
        R2R.db[data.keyword] = CopyTable(R2R.defaults[data.keyword])
        EventRegistry:TriggerEvent(format("%s_%s_RESET", data.prefix, string.upper(data.keyword)))
        R2R[READI.Helper.string:Capitalize(data.keyword)]:Update()
    end
    }
  )
end
function R2R.Anchoring:Update()
  R2R.Anchoring.fields[_posXname]:SetText( R2R.db.anchoring.position_x)
  R2R.Anchoring.fields[_posYname]:SetText( R2R.db.anchoring.position_y)
  R2R.Anchoring.fields[_parentName]:SetText( R2R.db.anchoring.frame)
  R2R.Anchoring.fields[_sizeName]:SetValue( R2R.db.anchoring.button_size)
  R2R.Anchoring.fields[_strataName]:SetValue( R2R.db.anchoring.button_strata)

  for _,val in pairs({"button", "parent"}) do
    for i, anchor in pairs(READI.Anchors) do
      local rb = R2R.Anchoring.fields[format("%s%sRadioButton_%s_%s", data.prefix, namingPrefix, format("%s_anchor", val), anchor)]
      if rb.value == R2R.db.anchoring[format("%s%s%s_anchor", data.prefix, namingPrefix, val)] then
        rb:Click()
        break;
      end
    end
  end
end
