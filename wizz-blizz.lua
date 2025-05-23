-- some wizz blizz

---@diagnostic disable: undefined-global, lowercase-global, duplicate-set-field

SCRIPT_NAME = "wizz-blizz"
local _grid = include 'lib/_grid'
local _blooper = include 'lib/blooper'
local _mood = include 'lib/mood'
local _dm = include 'device_manager/lib/_device_manager' -- install from https://github.com/illges/device_manager
local _pacifist = include 'pacifist_dev/lib/_pacifist' -- install from https://github.com/illges/pacifist_dev

engine.name = 'PolyPerc'

message_count = 0

function init()
    message = SCRIPT_NAME
    dm = _dm.new({adv=false, debug=false})
    mood=_mood.new({dm=dm})
    blooper=_blooper.new({dm=dm})
    mft = _pacifist:new({
        devices=dm.devices, debug=false, colors={mood.color,mood.color,mood.color,0,mood.color,mood.color,mood.color,0,0,blooper.color,blooper.color,blooper.color,0,blooper.color,blooper.color,blooper.color},
        ind={mood.knobs[1],mood.knobs[2],mood.knobs[3],0,mood.knobs[4],mood.knobs[5],mood.knobs[6],0,0,blooper.knobs[1],blooper.knobs[2],blooper.knobs[3],0,blooper.knobs[4],blooper.knobs[5],blooper.knobs[6]}
    })
    g=_grid:new()

    screen_dirty = true
    grid_dirty = true
    screen_redraw_clock()
    grid_redraw_clock()
end

function screen_redraw_clock()
    screen_drawing=metro.init()
    screen_drawing.time=0.1
    screen_drawing.count=-1
    screen_drawing.event=function()
        if message_count>0 then
            message_count=message_count-1
        else
            mood.message = ""
            blooper.message = ""
            screen_dirty = true
        end
        if screen_dirty == true then
            redraw()
            screen_dirty = false
        end
    end
    screen_drawing:start()
end

function set_message(msg, count)
    message = msg
    message_count = count and count or 8
    screen_dirty = true
end

function grid_redraw_clock()
    grid_drawing=metro.init()
    grid_drawing.time=0.1
    grid_drawing.count=-1
    grid_drawing.event=function()
        mft:activity_countdown()
        if grid_dirty == true then
            g:grid_redraw()
            redraw_mft()
            grid_dirty = false
        end
    end
    grid_drawing:start()
end

function enc(e, d)
    if e == 1 then turn(e, d) end
    if e == 2 then turn(e, d) end
    if e == 3 then turn(e, d) end
    screen_dirty = true
end

function turn(e, d)
    --set_message("encoder " .. e .. ", delta " .. d)
end

function key(k, z)
    if z == 0 then return end
    if k == 2 then press_down(2) end
    if k == 3 then press_down(3) end
    screen_dirty = true
end

function press_down(i)
    --set_message("press down " .. i)
end

function redraw()
    screen.clear()
    screen.aa(1)
    screen.font_face(1)
    screen.font_size(8)
    screen.level(15)
    screen.move(0, 32)
    screen.line(127,32)
    screen.stroke()

    screen.move(0, 5)
    screen.text(mood.name.."-".. mood.mode )
    screen.move(0, 15)
    screen.text(mood.message)

    screen.move(127, 62)
    screen.text_right(blooper.mode.."-"..blooper.name)
    screen.move(127, 52)
    screen.text_right(blooper.message)

    screen.fill()
    screen.update()
end

function redraw_mft()
    --mft:all(0)
    for i=1,16 do
        mft:led(i, mft.color[i]) --color is optional
        mft:send(i, mft.ind[i])
    end
end

function mft_enc(n,d)
    mft.last_turned = n
    mft.enc_activity_count = 15
    mft.activity_count = 15
    --mft:delta_color(n,d)
    if (n>=1 and n<=3) or (n>=5 and n<=7) then
        mood:delta_knob(n,d)
    elseif (n>=10 and n<=12) or (n>=14 and n<=16) then
        blooper:delta_knob(n,d)
    end
    screen_dirty = true
    grid_dirty=true
end

function mft_key(n,z)
    local on = z==1
    mft.momentary[n] = on and 1 or 0
    if on then
        --set_message("mft key "..n.." pressed")
        mft.last_pressed = n
        mft.key_activity_count = 15
        mft.activity_count = 15
        if (n>=1 and n<=3) or (n>=5 and n<=7) then
            mood:toggle_lfo(n)
        elseif (n>=10 and n<=12) or (n>=14 and n<=16) then
            blooper:toggle_lfo(n)
        elseif n==17 then
            mood:delta_mode()
        elseif n==18 then
        elseif n==19 then
            dm:device_out():program_change(1, mood.channel)
        elseif n==20 then
            blooper:delta_mode()
        elseif n==21 then
        elseif n==22 then
            dm:device_out():program_change(1, blooper.channel)
        end
    else
        if (n>=1 and n<=3) or (n>=5 and n<=7) then
            
        elseif (n>=10 and n<=12) or (n>=14 and n<=16) then

        end
    end
    screen_dirty = true
    grid_dirty=true
end

function midi_event_note_on(d)
    --set_message(d.note)
end

function midi_event_note_off(d) end

function midi_event_start(d) end

function midi_event_stop(d) end

function midi_event_cc(d) end

function r() ----------------------------- execute r() in the repl to quickly rerun this script
    norns.script.load(norns.state.script) -- https://github.com/monome/norns/blob/main/lua/core/state.lua
end

function cleanup() --------------- cleanup() is automatically called on script close

end