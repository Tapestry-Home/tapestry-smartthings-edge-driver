local capabilities = require "st.capabilities"
local zcl_clusters = require "st.zigbee.zcl.clusters"
local ZigbeeDriver = require "st.zigbee"
local constants = require "st.zigbee.constants"
local defaults = require "st.zigbee.defaults"
local contact_sensor_defaults = require "st.zigbee.defaults.contactSensor_defaults"
local data_types = require "st.zigbee.data_types"
local common = require("common")

-- local function added(driver, device) 
--     --Add the manufacturer-specific attributes to generate their configure reporting and bind requests
--     for capability_id, configs in pairs(common.get_cluster_configurations(device:get_manufacturer())) do
--         if device:supports_capability_by_id(capability_id) then
--             for _, config in pairs(configs) do
--                 device:add_configured_attribute(config)
--                 device:add_monitored_attribute(config)
--             end
--         end
--     end
-- end

----------------------Driver configuration----------------------
local handlers = {
    global = {},
    cluster = {},
    attr = {},
    zdo = {}
}

local thpz1_driver_template = {
    supported_capabilities = {
        capabilities.temperatureMeasurement,
        capabilities.relativeHumidityMeasurement,
        capabilities.occupancySensor
    },
    zigbee_handlers = handlers,
    lifecycle_handlers = {
        -- added = added
    },
}

--Run driver
defaults.register_for_default_handlers(thpz1_driver_template, thpz1_driver_template.supported_capabilities)
local thpz1_driver = ZigbeeDriver("thpz1Driver", thpz1_driver_template)
thpz1_driver:run()