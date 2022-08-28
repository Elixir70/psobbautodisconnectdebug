local core_mainmenu = require("core_mainmenu")

local showWindow = false
local _PSOBBScene = 0x00aab384

local function CurrentScene()
    return pso.read_u32(_PSOBBScene)
end

local function GetAutoDisconnectTimeout()
    local myIdx = pso.read_u32(0xA9C4F4)
    local A95DF8 = pso.read_u32(0xA95DF8)
    if A95DF8 == 0 then
        return 0
    end
    
    local mask = bit.band(pso.read_u32(A95DF8 + 0x10), 0x1C00)
    local mask2 = bit.rshift(mask, 10)
    
    return pso.read_u32(0x97E4DC + mask2 * 4)
end

local function DisplayDebugStats()
    if CurrentScene() ~= 0xB then
        imgui.Text("Not logged in.")
        return
    end

    local shipConnectionManagerPtr = pso.read_u32(0xAAB284)
    if shipConnectionManagerPtr == 0 then
        imgui.Text("Not logged in.")
        return
    end

    local idleObjPtr = pso.read_u32(shipConnectionManagerPtr + 0x10)
    if idleObjPtr == 0 then
        imgui.Text("No auto disconnect object.")
        return
    end

    local timeCurr = pso.read_u32(idleObjPtr + 0x1C)
    local timePrev = pso.read_u32(idleObjPtr + 0x20)
    local timeout = pso.read_u32(idleObjPtr + 0x24)
    local autoDisconnectTimeout = GetAutoDisconnectTimeout()
    imgui.Text(string.format("SYS: %u", os.time()))
    imgui.Text(string.format("Idle times: %u, %u", timeCurr, timePrev))
    imgui.Text(string.format("Timeouts: %u, %u", timeout, autoDisconnectTimeout))
end

local function present()
    if not showWindow then
        return
    end
    if imgui.Begin("Auto Disconnect Debug") then
        DisplayDebugStats()
    end
end

local function init()
    local function mainMenuButtonHandler()
        showWindow = not showWindow
    end

    core_mainmenu.add_button("Auto Disconnect Debug", mainMenuButtonHandler)

    return
    {
        name = "Auto Disconnect Debug",
        version = "0.1.0",
        author = "Ender",
        present = present
    }
end

return {
    __addon =
    {
        init = init,
    },
}
