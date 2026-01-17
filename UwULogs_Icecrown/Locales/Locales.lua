local AddonName, Private = ...

Private.L = {}
local L = Private.L

local locale = GetLocale()

if locale == "frFR" then
    L["UwULogs Tooltip"] = "UwULogs Tooltip"
    L["Enable UwULogs Tooltip display"] = "Activer l'affichage UwULogs"
    L["Please enter a name to see if it is in the top 1000 :"] = "Veuillez entrez un nom pour voir s'il est dans le top 1000 :"

elseif locale == "deDE" then
    L["UwULogs Tooltip"] = "UwULogs Tooltip"
    L["Enable UwULogs Tooltip display"] = "UwULogs Tooltip aktivieren"
    L["Please enter a name to see if it is in the top 1000 :"] = "Bitte geben Sie einen Namen ein, um zu sehen, ob er zu den Top 1000 gehört :"

elseif locale == "esES" or locale == "esMX" then
    L["UwULogs Tooltip"] = "UwULogs Tooltip"
    L["Enable UwULogs Tooltip display"] = "Activar UwULogs Tooltip"
    L["Please enter a name to see if it is in the top 1000 :"] = "Introduzca un nombre para ver si está entre los 1000 primeros :"

else
    L["UwULogs Tooltip"] = "UwULogs Tooltip"
    L["Enable UwULogs Tooltip display"] = "Enable UwULogs Tooltip display"
    L["Please enter a name to see if it is in the top 1000 :"] = "Please enter a name to see if it is in the top 1000 :"
end


if locale == "frFR" then
    L["Changes require UI reload."] = "Les changements nécessitent un rechargement de l'interface."
    L["Accept"] = "Valider"
    L["Cancel"] = "Annuler"
    
elseif locale == "deDE" then
    L["Changes require UI reload."] = "Änderungen erfordern ein Neuladen des Interfaces."
    L["Accept"] = "Akzeptieren"
    L["Cancel"] = "Abbrechen"
    
elseif locale == "esES" or locale == "esMX" then
    L["Changes require UI reload."] = "Los cambios requieren recargar la interfaz."
    L["Accept"] = "Aceptar"
    L["Cancel"] = "Cancelar"
    
else
    L["Changes require UI reload."] = "Changes require UI reload."
    L["Accept"] = "Accept"
    L["Cancel"] = "Cancel"
end


-- Make missing translations available
setmetatable(Private.L, {__index = function(self, key)
  self[key] = (key or "")
  return key
end})