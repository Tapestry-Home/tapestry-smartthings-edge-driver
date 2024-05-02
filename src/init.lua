local capabilities = require "st.capabilities"
local zcl_clusters = require "st.zigbee.zcl.clusters"
local ZigbeeDriver = require "st.zigbee"
local constants = require "st.zigbee.constants"
local defaults = require "st.zigbee.defaults"
local data_types = require "st.zigbee.data_types"

local function added(driver, device) 
    device:refresh()
end

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
        added = added
    },
}

--Run driver
defaults.register_for_default_handlers(thpz1_driver_template, thpz1_driver_template.supported_capabilities)
local thpz1_driver = ZigbeeDriver("thpz1Driver", thpz1_driver_template)
thpz1_driver:run()