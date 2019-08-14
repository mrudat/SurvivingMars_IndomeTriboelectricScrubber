local orig_print = print
if Mods.mrudat_TestingMods then
  print = orig_print
else
  print = empty_func
end

local CurrentModId = rawget(_G, 'CurrentModId') or rawget(_G, 'CurrentModId_X')
local CurrentModDef = rawget(_G, 'CurrentModDef') or rawget(_G, 'CurrentModDef_X')
if not CurrentModId then

  -- copied shamelessly from Expanded Cheat Menu
  local Mods, rawset = Mods, rawset
  for id, mod in pairs(Mods) do
    rawset(mod.env, "CurrentModId_X", id)
    rawset(mod.env, "CurrentModDef_X", mod)
  end

  CurrentModId = CurrentModId_X
  CurrentModDef = CurrentModDef_X
end

orig_print("loading", CurrentModId, "-", CurrentModDef.title)

-- unforbid TriboelectricScrubbers from being built inside.
mrudat_AllowBuildingInDome.forbidden_template_classes.TriboelectricScrubber = nil

local wrap_method = mrudat_AllowBuildingInDome.wrap_method

mrudat_AllowBuildingInDome.DomePosOrMyPos('TriboelectricScrubber')

wrap_method('TriboelectricScrubber','CleanBuildings', function(self, orig_method)
  local dome = self.parent_dome
  if not dome or dome.open_air then
    orig_method(self)
    return
  end

  MapForEach(dome, "hex", HexShapeRadius(dome:GetInteriorShape()), "DroneBase", function(drone)
    if IsUnitInDome(drone) == dome then
      drone:AddDust(-self.dust_clean)
    end
  end)

  for _, dirty in ipairs(dome.labels.Building) do
    if dirty ~= self then
      if dirty:IsKindOf("DustGridElement") then
        dirty:AddDust(-self.dust_clean)
      else
        dirty:AccumulateMaintenancePoints(-self.dust_clean)
      end
    end
  end
end)

wrap_method('TriboelectricScrubber','OnPostChangeRange', function(self, orig_method)
  local range = self.UIRange

  local prop_meta = self:GetPropertyMetadata("UIRange")
  self.UIRange = Max(Min(range, prop_meta.max), prop_meta.min)

  return orig_method(self)
end)

wrap_method('TriboelectricScrubber','UpdateElectricityConsumption', function(self, orig_method)
  local dome = self.parent_dome
  if not dome then
    return orig_method(self)
  end

  local range = self.UIRange

  local base_range = self:GetPropertyMetadata("UIRange").base

  if base_range == nil then
    print("Argh!")
  end

  local template = ClassTemplates.Building[self.template_name]
  self:SetBase("electricity_consumption", MulDivRound(range * range, template.electricity_consumption, base_range * base_range))
end)

local prop_cache = {}

wrap_method('TriboelectricScrubber','GetPropertyMetadata', function(self, orig_method, prop_name)
  if prop_name ~= "UIRange" then
    return orig_method(self, prop_name)
  end

  local dome = self.parent_dome
  if not dome then
    return orig_method(self, prop_name)
  end

  local prop = prop_cache[dome]

  if prop then return prop end

  prop = orig_method(self, prop_name)
  prop = table.copy(prop)

  local dome_radius = HexShapeRadius(dome:GetInteriorShape())

  prop.base = prop.min
  prop.default = dome_radius
  prop.min = dome_radius
  prop.max = dome_radius

  prop_cache[dome] = prop
  print(prop)
  return prop
end)

if OpenAirBuilding and OpenAirBuilding.ChangeOpenAirState then
  wrap_method('Dome', 'ChangeOpenAirState', function(self, orig_func, open)
    orig_func(self, open)

    for _, scrubber in ipairs(self.labels.TriboelectricScrubber or empty_table) do
      -- recalculate neighbour penalty, now that we're running in the open air (or not)
      scrubber:OnPostChangeRange()
    end
  end)
end

orig_print("loaded", CurrentModId, "-", CurrentModDef.title)
