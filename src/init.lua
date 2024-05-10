local capabilities = require "st.capabilities"
local zcl_clusters = require "st.zigbee.zcl.clusters"
local ZigbeeDriver = require "st.zigbee"
local defaults = require "st.zigbee.defaults"

-- preferences update values
local function do_preferences(self, device, event, args)

    for id, value in pairs(device.preferences) do
        local oldPreferenceValue = args.old_st_store.preferences[id]
        local newParameterValue = device.preferences[id]
        if oldPreferenceValue ~= newParameterValue and newParameterValue ~= nil then
            if  id == "tempMaxTime" or id == "tempChangeRep" then
                local maxTime = device.preferences.tempMaxTime * 60
                local changeRep = device.preferences.tempChangeRep * 100
                print ("Temp maxTime:", maxTime "changeRep:", changeRep)
                device:send(zcl_clusters.TemperatureMeasurement.attributes.MeasuredValue:configure_reporting(device, 30, maxTime, changeRep))
                local config ={
                    cluster = zcl_clusters.TemperatureMeasurement.ID,
                    attribute = zcl_clusters.TemperatureMeasurement.attributes.MeasuredValue.ID,
                    minimum_interval = 30,
                    maximum_interval = maxTime,
                    data_type = zcl_clusters.TemperatureMeasurement.attributes.MeasuredValue.base_type,
                    reportable_change = changeRep
                }
                device:add_monitored_attribute(config)

            elseif id == "humMaxTime" or id == "humChangeRep" then
                local maxTime = device.preferences.humMaxTime * 60
                local changeRep = device.preferences.humChangeRep * 100
                print ("Humidity maxTime:", maxTime, "changeRep:", changeRep)
                device:send(zcl_clusters.RelativeHumidity.attributes.MeasuredValue:configure_reporting(device, 30, maxTime, changeRep))
                local config ={
                cluster = zcl_clusters.RelativeHumidity.ID,
                attribute = zcl_clusters.RelativeHumidity.attributes.MeasuredValue.ID,
                minimum_interval = 30,
                maximum_interval = maxTime,
                data_type = zcl_clusters.RelativeHumidity.attributes.MeasuredValue.base_type,
                reportable_change = changeRep
                }
                device:add_monitored_attribute(config)
            end
        end
    end
end

--- device perform do configure 
local function do_configure(self,device)

    ----configure temperature reports
    local maxTime = device.preferences.tempMaxTime * 60
    local changeRep = device.preferences.tempChangeRep * 100
    print ("Temp maxTime:", maxTime, "changeRep:", changeRep)

    local config ={
        cluster = zcl_clusters.TemperatureMeasurement.ID,
        attribute = zcl_clusters.TemperatureMeasurement.attributes.MeasuredValue.ID,
        minimum_interval = 30,
        maximum_interval = maxTime,
        data_type = zcl_clusters.TemperatureMeasurement.attributes.MeasuredValue.base_type,
        reportable_change = changeRep
    }
    device:add_configured_attribute(config)
    device:add_monitored_attribute(config)

    -- configure Humidity reports
    maxTime = device.preferences.humMaxTime * 60
    changeRep = device.preferences.humChangeRep * 100
    print ("Humidity maxTime:", maxTime, "changeRep:", changeRep)

    config ={
        cluster = zcl_clusters.RelativeHumidity.ID,
        attribute = zcl_clusters.RelativeHumidity.attributes.MeasuredValue.ID,
        minimum_interval = 30,
        maximum_interval = maxTime,
        data_type = zcl_clusters.RelativeHumidity.attributes.MeasuredValue.base_type,
        reportable_change = changeRep
    }
    device:add_configured_attribute(config)
    device:add_monitored_attribute(config)

    device:configure()
end

---- driver_switched function to perfirm device configure
local function driver_switched(self,device)
    device.thread:call_with_delay(5, function() 
      do_configure(self,device)
    end)
end

-- Initialize capabilities
local function added(driver, device) 
    device:refresh()
end

----------------------Driver configuration----------------------
local thpz1_driver_template = {
    supported_capabilities = {
        capabilities.temperatureMeasurement,
        capabilities.relativeHumidityMeasurement,
        capabilities.occupancySensor
    },

    lifecycle_handlers = {
        added = added,
        doConfigure = do_configure,
        infoChanged = do_preferences,
        driverSwitched = driver_switched
    },
}

--Run driver
defaults.register_for_default_handlers(thpz1_driver_template, thpz1_driver_template.supported_capabilities)
local thpz1_driver = ZigbeeDriver("thpz1Driver", thpz1_driver_template)
thpz1_driver:run()