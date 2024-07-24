local ConfigSystem = {}

local CONFIG_FILE_PATH = "flux_script_config.json"

-- Helper function to serialize tables to JSON
local function serializeTable(tbl)
    local json = game:GetService("HttpService"):JSONEncode(tbl)
    return json
end

-- Helper function to deserialize JSON to tables
local function deserializeTable(json)
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(json)
    end)
    return success and result or {}
end

-- Save config to file
function ConfigSystem.saveConfig(config)
    local serializedConfig = serializeTable(config)
    writefile(CONFIG_FILE_PATH, serializedConfig)
end

-- Load config from file
function ConfigSystem.loadConfig()
    if not isfile(CONFIG_FILE_PATH) then
        return {}
    end
    local content = readfile(CONFIG_FILE_PATH)
    return deserializeTable(content)
end

-- Update UI elements based on loaded config
function ConfigSystem.updateUI(config, uiElements)
    for elementId, value in pairs(config) do
        local element = uiElements[elementId]
        if element then
            if element.UpdateState then  -- For checkboxes
                element:UpdateState(value, true)
            elseif element.Update then  -- For dropdowns
                element:Update({value}, true)
            end
        end
    end
end

-- Autoload function
function ConfigSystem.autoload(uiElements, state)
    local loadedConfig = ConfigSystem.loadConfig()
    
    -- Update UI elements
    ConfigSystem.updateUI(loadedConfig, uiElements)
    
    -- Update state
    for key, value in pairs(loadedConfig) do
        if state[key] ~= nil then
            state[key] = value
        end
    end
    
    -- Toggle autoFeatures based on loaded config
    for feature, enabled in pairs(loadedConfig) do
        if autoFeatures.functions[feature] then
            autoFeatures:toggle(feature, enabled)
        end
    end
end

return ConfigSystem
