--[[
Made by:
alek#4521
Holy#9756
luigistyle#0420
fml#1332

Credits to:
Jesus_Is_Cap#6666: Help with improvements.
.ilana#1273: Informed us about the 2.1B sale, which inspired us to create a loop.
ICYPhoenix#0725: Creating MusinessBanager, whose code we used for some functions.
ᴹᶦʳʳᵒʳ#2800: Creating Musiness Banager, whose code we used for some functions.
IceDoomfist#0001: Creating Heist Control, whose code we used for some functions.
All of our Space Monkeys: Testing the loop <3
]]

util.require_natives(1660775568)

util.toast("When you no longer see any pending transactions, click cap stock. You can now begin the loop :)")

local Int_PTR = memory.alloc_int()

local function getMPX()
    return 'MP'.. util.get_char_slot() ..'_'
end

local function STAT_GET_INT(Stat)
    STATS.STAT_GET_INT(util.joaat(getMPX() .. Stat), Int_PTR, -1)
    return memory.read_int(Int_PTR)
end

local function isScriptActive(script)
    return SCRIPT._GET_NUMBER_OF_REFERENCES_OF_SCRIPT_WITH_NAME_HASH(util.joaat(script)) >= 1
end

function GET_INT_GLOBAL(Global)
	return memory.read_int(memory.script_global(Global))
end

function SET_INT_GLOBAL(Global, Value)
	memory.write_int(memory.script_global(Global), Value)
end

function SET_INT_LOCAL(Script, Local, Value)
	if memory.script_local(Script, Local) ~= 0 then
		memory.write_int(memory.script_local(Script, Local), Value)
	end
end

local function startScript(script)
    SCRIPT.REQUEST_SCRIPT(script)
    while not SCRIPT.HAS_SCRIPT_LOADED(script)  do 
        util.yield()
    end

    if SCRIPT.HAS_SCRIPT_LOADED(script) then
        SYSTEM.START_NEW_SCRIPT(script, 4592)
        SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(script)
    end
end

local function getBusinessIndex(index)
    return 1853348 + 1 + (PLAYER.PLAYER_ID()*888) + 267 + 191 + 1 + (index*13)
end

local function simulateMouseClick()
    PAD._SET_CONTROL_NORMAL(2, 237, 1);
    util.yield()
    PAD._SET_CONTROL_NORMAL(2, 237, 0);
end

local clickspeed = 100

local function simulatePlayerInput()
    PAD._SET_CURSOR_LOCATION(0.5, 0.6)
    simulateMouseClick()
    util.yield(clickspeed)
    PAD._SET_CURSOR_LOCATION(0.2, 0.6)
    simulateMouseClick()
    util.yield(clickspeed)
    PAD._SET_CURSOR_LOCATION(0.5, 0.6)
    util.yield(2*clickspeed)
    simulateMouseClick()
    util.yield(clickspeed)
    simulateMouseClick()
    util.yield()
    PAD._SET_CURSOR_LOCATION(0.55, 0.55)
    util.yield()
    simulateMouseClick()
end

util.create_thread(function()
    while true do
        if GET_INT_GLOBAL(getBusinessIndex(5) + 2) < 40 then
            SET_INT_GLOBAL(1640642+1+5, 1)
        end
        SET_INT_GLOBAL(262145+21576, 0)
        SET_INT_GLOBAL(262145+21577, 0)
        SET_INT_GLOBAL(262145+21578, 0)
        SET_INT_GLOBAL(getBusinessIndex(5) + 9, 0) -- Production speed.
        util.yield(200)
    end
end)

local function IsInSession()
    return util.is_session_started() and not util.is_session_transition_active()
end

function kill_appbunkerbusiness()
    util.spoof_script("appbunkerbusiness", SCRIPT.TERMINATE_THIS_THREAD)
    PLAYER.SET_PLAYER_CONTROL(players.user(), true, 0)
    PAD.ENABLE_ALL_CONTROL_ACTIONS(0)
    PAD.ENABLE_CONTROL_ACTION(2, 1, true)
    PAD.ENABLE_CONTROL_ACTION(2, 2, true)
    PAD.ENABLE_CONTROL_ACTION(2, 187, true)
    PAD.ENABLE_CONTROL_ACTION(2, 188, true)
    PAD.ENABLE_CONTROL_ACTION(2, 189, true)
    PAD.ENABLE_CONTROL_ACTION(2, 190, true)
    PAD.ENABLE_CONTROL_ACTION(2, 199, true)
    PAD.ENABLE_CONTROL_ACTION(2, 200, true)
end

menu.action(menu.my_root(), "Cap Stock", { "capstock" }, "Cap bunker stock to 1. This is crucial before starting the loop!", function()
    if IsInSession() then
        SET_INT_GLOBAL(262145+21575, 1)
        util.toast("Capped bunker stock at 1")
    end
end)

local settings_root = menu.list(menu.my_root(), 'Loop Settings', {}, '')

-- loop delay
local loop_delay = 2000
menu.slider(settings_root,"Delay", {"bunkerloopdelay"}, "How long the script waits before starting the next loop (in milliseconds). \n\nIncrease this if you are having issues with the loop.", 0, 10000, 1000, 50, function(delay)
    loop_delay = delay
end)

menu.slider(settings_root,"Click Speed", {"clickspeed"}, "Change the amount of time (in milliseconds) between clicks on the bunker screen.", 0, 1000, 50, 5, function(clickdelay)
    clickspeed = clickdelay
end)

sell_amount = 2147481333
menu.slider(settings_root,"Sell Amount", {"sellamount"}, "Change the amount you sell your bunker stock for.", 0, 2147481333, 2147481333, 50, function(amount)
    sell_amount = amount
end)

function format_int(number)
    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

local totalearnings = 0

local earnings_settings = menu.list(menu.my_root(), 'Draw Earnings Settings', {}, '')

local directx_colour = {
	["r"] = 0.4,
	["g"] = 0.0,
	["b"] = 0.0,
	["a"] = 1.0
}

drawtext = off
menu.toggle(earnings_settings, "Draw Earnings", { "" }, "", function(on)
    drawtext = on
end)

local c = menu.colour(earnings_settings, "Change Colour", {"earningscolour"}, "", directx_colour, true, function(colour)
	directx_colour = colour
end)
menu.rainbow(c)

xpos = 50.0
menu.slider(earnings_settings,"Change X Pos", {"setxpos"}, "Change the x positioning of displaying earnings.", 0, 100, 50, 1, function(setxpos)
    xpos = setxpos / 100
end)

ypos = 80.0
menu.slider(earnings_settings,"Change Y Pos", {"setypos"}, "Change the y positioning of displaying earnings.", 0, 100, 80, 1, function(setypos)
    ypos = setypos / 100
end)

earningText = "Earnings: $"
menu.text_input(earnings_settings, "Change Earnings Text", { "earningText" }, "Allows you the text for displaying earnings.", function(moneyText)
    earningText = moneyText
end)

util.create_tick_handler(function()
	if drawtext then
        directx.draw_text(xpos,ypos, earningText .. format_int(totalearnings),ALIGN_TOP_LEFT,1.0,directx_colour,false)
    end
	return true
end)

local bcsalesattempted = STAT_GET_INT("LIFETIME_BKR_SEL_UNDERTABC5")
util.create_thread(function()
    while true do
        if STAT_GET_INT("LIFETIME_BKR_SEL_UNDERTABC5") == bcsalesattempted + 1 then
            totalearnings = totalearnings + sell_amount
            bcsalesattempted = bcsalesattempted + 1
        end
    util.yield(500)
    end
end)

bunkerloopftw = menu.toggle_loop(menu.my_root(), "Start Loop", {"bunkerloop"}, "This is all you ever need :)", function()
    start = true
    PAD.ENABLE_CONTROL_ACTION(2, 237, true);
    SET_INT_GLOBAL(283726, sell_amount)
    if isScriptActive("gb_gunrunning") then
        SET_INT_LOCAL(util.joaat("gb_gunrunning"), 1977, 0)
        MISC.TERMINATE_ALL_SCRIPTS_WITH_THIS_NAME("appbunkerbusiness"); -- Otherwise it stays running.
        util.yield(loop_delay)
    else
        startScript("appbunkerbusiness");
        if start then
            simulatePlayerInput()
            start = false
        end
    end
end)

-- Restarts loop after the error
local is_my_loop_breaking = 0
util.create_tick_handler(function()
   while menu.get_value(bunkerloopftw) do
        local n = STAT_GET_INT("BUNKER_UNITS_MANUFAC")
        util.yield(2200)
        if n == STAT_GET_INT("BUNKER_UNITS_MANUFAC") then
            is_my_loop_breaking = is_my_loop_breaking + 1
            if is_my_loop_breaking >= 3 then
                menu.trigger_commands("bunkerloop off")
                util.yield(200)
                menu.trigger_commands("bunkerloop on")
                util.toast("Restarted the loop after it died")
                is_my_loop_breaking = 0
            end
        else
            is_my_loop_breaking = 1
        end
    end
end)

function TELEPORT(X, Y, Z)
	local Handle = PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) and PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) or players.user_ped()
	ENTITY.SET_ENTITY_COORDS(Handle, X, Y, Z)
end
function tpfps()
	TELEPORT(-6969.69, -6969.69, 2668.69)
end
function tpnorm()
	TELEPORT(178.93, -3301.40, 6.00)
end
Opti = menu.toggle(menu.my_root(), "Optimize Loop", {"optiloop"}, "Will maximise your FPS by reducing how much the game has to render.", function()
	if menu.get_value(Opti) then
	tpfps()
	menu.trigger_commands("levitate on")
	menu.trigger_commands("potatomode on")
	menu.trigger_commands("nosky on")
	menu.trigger_commands("lodscale 0")
	menu.trigger_commands("fovfponfoot 0")
	menu.trigger_commands("fovtponfoot 0")
	util.yield(150) GRAPHICS.TOGGLE_PAUSED_RENDERPHASES(on)
	end
	if not menu.get_value(Opti) then
	tpnorm()
	menu.trigger_commands("levitate off")
	menu.trigger_commands("potatomode off")
	menu.trigger_commands("nosky off")
	menu.trigger_commands("lodscale 1")
	menu.trigger_commands("fovfponfoot -5")
	menu.trigger_commands("fovtponfoot -5")
	GRAPHICS.TOGGLE_PAUSED_RENDERPHASES(not on)
	end
end)

local misc = menu.list(menu.my_root(), 'Misc', {}, '')

menu.action(misc, "Open Bunker App", {"openbunker"}, "Use this to enter the bunker screen if needed.", function()
    startScript("appbunkerbusiness");
end)

menu.action(misc, "Kill Bunker App", {"unstuckbunker"}, "Use this to go out of the bunker screen if you get stuck on it.", function()
	kill_appbunkerbusiness()
end)

menu.action(misc, "Bunker Bandaid", {"bandaidbunker"}, "This will TP you inside the bunker interior, which sometimes can fix bunker sell prices or the stock not updating.", function()
    ENTITY.SET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), 909.2901, -3206.9666, -97.187904, false, false, false, false)
end)

menu.action(misc, "Escape Interior", {"escapeinterior"}, "TPs you to the closest ground to escape the current interior you are in.", function()
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    local accurate
    local counter = 0
    repeat
        accurate, pos.z = util.get_ground_z(pos.x, pos.y)
        counter = counter + 1
        util.yield_once()
    until accurate or counter >= 2000
    ENTITY.SET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), pos.x, pos.y, pos.z, false, false, false, false)
end)

menu.action(misc, "Create Spoofed Session", {"spoofedsession"}, "Create a spoofed session so that you are left alone while looping. \n\nAlso automatically registers you as a CEO once you are in the spoofed session.", function()
    menu.trigger_commands("gosolop")
    waitUntilInSession = true
    while checkIfSession do
        if IsInSession() then
            menu.trigger_commands("startceo")
            menu.trigger_commands("spoofsession storymode")
            util.toast("Have fun!")
            waitUntilInSession = false
        end
        util.yield()
    end
end)

menu.action(misc, "Start CEO", {"startceo"}, "Press to start CEO", function()
    menu.trigger_commands("startceo")
end)

util.keep_running()