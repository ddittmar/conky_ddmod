--==============================================================================
--                            ddmod_rings.lua
--
--  Author  : Dirk Dittmar
--  License : Distributed under the terms of GNU GPL version 2 or later
--
--==============================================================================

require 'cairo'


--------------------------------------------------------------------------------
--                                                                    gauge DATA
gauge = {
    {
        name='cpu',                    arg='cpu1',
        x=70,                          y=130,
        graph_radius=54,               graph_thickness=5,
    },
    {
        name='cpu',                    arg='cpu2',
        x=70,                          y=130,
        graph_radius=48,               graph_thickness=5,
    },
    {
        name='cpu',                    arg='cpu3',
        x=70,                          y=130,
        graph_radius=42,               graph_thickness=5,
    },
    {
        name='cpu',                    arg='cpu4',
        x=70,                          y=130,
        graph_radius=36,               graph_thickness=5,
    },
    {
        name='cpu',                    arg='cpu5',
        x=70,                          y=130,
        graph_radius=30,               graph_thickness=5,
    },
    {
        name='cpu',                    arg='cpu6',
        x=70,                          y=130,
        graph_radius=24,               graph_thickness=5,
    },
    {
        name='cpu',                    arg='cpu7',
        x=70,                          y=130,
        graph_radius=18,               graph_thickness=5,
    },
    {
        name='cpu',                    arg='cpu8',
        x=70,                          y=130,
        graph_radius=12,               graph_thickness=5,
    },
    {
        name='memperc',                arg='',
        x=70,                          y=300,
        graph_radius=54,               graph_thickness=10,
    },
    {
        name='fs_used_perc',           arg='/',
        x=70,                          y=470,
        graph_radius=54,               graph_thickness=6,
        caption='root',                caption_size=10.0,
    },
    {
        name='swapperc',               arg='',
        x=70,                          y=470,
        graph_radius=44,               graph_thickness=6,
        caption='swap',                caption_size=10.0,
    }
} -- gauge

--------------------------------------------------------------------------------
--                                                          gauge DATA (special)
gauge_special = {
    {   -- show mem plus caches 
        name='mem_caches',             arg='',
        x=70,                          y=300,
        graph_radius=40,               graph_thickness=7,
    },
    {
        name='mounts',                 arg='',
        x=70,                          y=470,
        graph_radius=34,               graph_thickness=6,
        caption='',                    caption_size=10.0,
    }, 
} -- gauge2

--------------------------------------------------------------------------------
--                                                                  default DATA
default = {
    max_value=100,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xFFFFFF,      graph_bg_alpha=0.1,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.3,
    caption='',
    caption_weight=1,              caption_size=12.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
} -- default

-------------------------------------------------------------------------------
--                                                                 rgb_to_r_g_b
-- converts color in hexa to decimal
--
function rgb_to_r_g_b(colour, alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end -- rgb_to_r_g_b

-------------------------------------------------------------------------------
--                                                            angle_to_position
-- convert degree to rad and rotate (0 degree is top/north)
--
function angle_to_position(start_angle, current_angle)
    local pos = current_angle + start_angle
    return ( ( pos * (2 * math.pi / 360) ) - (math.pi / 2) )
end -- angle_to_position


-------------------------------------------------------------------------------
--                                                              draw_gauge_ring
-- displays gauges
--
function draw_gauge_ring(display, data, value)
    local max_value = data['max_value'] and data['max_value'] or default['max_value']
    local x, y = data['x'], data['y']
    local graph_radius = data['graph_radius']
    local graph_thickness = data['graph_thickness'] and data['graph_thickness'] or default['graph_thickness']
    local graph_unit_thickness = data['graph_unit_thickness'] and data['graph_unit_thickness'] or default['graph_unit_thickness']
    local graph_start_angle = data['graph_start_angle'] and data['graph_start_angle'] or default['graph_start_angle']
    local graph_unit_angle = data['graph_unit_angle'] and data['graph_unit_angle'] or default['graph_unit_angle']
    local graph_bg_colour = data['graph_bg_colour'] and data['graph_bg_colour'] or default['graph_bg_colour']
    local graph_bg_alpha = data['graph_bg_alpha'] and data['graph_bg_alpha'] or default['graph_bg_alpha']
    local graph_fg_colour = data['graph_fg_colour'] and data['graph_fg_colour'] or default['graph_fg_colour']
    local graph_fg_alpha = data['graph_fg_alpha'] and data['graph_fg_alpha'] or default['graph_fg_alpha']
    local graph_end_angle = (max_value * graph_unit_angle) % 360

    -- background ring
    cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, 0), angle_to_position(graph_start_angle, graph_end_angle))
    cairo_set_source_rgba(display, rgb_to_r_g_b(graph_bg_colour, graph_bg_alpha))
    cairo_set_line_width(display, graph_thickness)
    cairo_stroke(display)

    -- arc of value
    local val = value % (max_value + 1)
    local start_arc = 0
    local stop_arc = 0
    local i = 1
    while i <= val do
        start_arc = (graph_unit_angle * i) - graph_unit_thickness
        stop_arc = (graph_unit_angle * i)
        cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
        cairo_set_source_rgba(display, rgb_to_r_g_b(graph_fg_colour, graph_fg_alpha))
        cairo_stroke(display)
        i = i + 1
    end
    local angle = start_arc

    -- caption
    local caption = data['caption'] and data['caption'] or default['caption']
    local caption_weight = data['caption_weight'] and data['caption_weight'] or default['caption_weight']
    local caption_size = data['caption_size'] and data['caption_size'] or default['caption_size']
    local caption_fg_colour = data['caption_fg_colour'] and data['caption_fg_colour'] or default['caption_fg_colour']
    local caption_fg_alpha = data['caption_fg_alpha'] and data['caption_fg_alpha'] or default['caption_fg_alpha']
    local tox = graph_radius * (math.cos((graph_start_angle * 2 * math.pi / 360)-(math.pi/2)))
    local toy = graph_radius * (math.sin((graph_start_angle * 2 * math.pi / 360)-(math.pi/2)))
    cairo_select_font_face (display, "ubuntu", CAIRO_FONT_SLANT_NORMAL, caption_weight);
    cairo_set_font_size (display, caption_size)
    cairo_set_source_rgba (display, rgb_to_r_g_b(caption_fg_colour, caption_fg_alpha))
    cairo_move_to (display, x + tox + 5, y + toy + 3)
    -- bad hack but not enough time !
    if graph_start_angle < 105 then
        cairo_move_to (display, x + tox - 30, y + toy + 3)
    end
    cairo_show_text (display, caption)
    cairo_stroke (display)
end -- draw_gauge_ring


-------------------------------------------------------------------------------
--                                                           string:starts_with
-- checks if a string starts with another string
--
function string:starts_with(starts_with)
    return self.sub(self, 1, string.len(starts_with)) == starts_with
end -- string:starts_with


-------------------------------------------------------------------------------
--                                                           string:split
-- splits the String by 'inSplitPattern' and (optional) append the results to
-- 'outResults'
--
function string:split(inSplitPattern, outResults)
    if not outResults then
        outResults = { }
    end
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    while theSplitStart do
        table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
        theStart = theSplitEnd + 1
        theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    end
    table.insert( outResults, string.sub( self, theStart ) )
    return outResults
end


-------------------------------------------------------------------------------
--                                                            table.shallowcopy
-- does a shallow copy of orig
--
function table.shallowcopy(orig)
    local copy = {}
    for orig_key, orig_value in pairs(orig) do
        copy[orig_key] = orig_value
    end
    return copy
end -- table.shallowcopy


-------------------------------------------------------------------------------
--                                                                 get_mem_info
-- loads /proc/meminfo into a table
--
function get_mem_info()
    local meminfo={}
    for Line in io.lines("/proc/meminfo") do
        local k,v = Line:match("(.-): *(%d+)")
        if (k~=nil and v~=nil) then
            meminfo[k]=tonumber(v)
        end
    end
    return meminfo
end -- get_mem_info


-------------------------------------------------------------------------------
--                                                             get_media_mounts
-- loads /proc/mounts startng with /media into a table
--
function get_media_mounts()
    local mounts={}
    for Line in io.lines("/proc/mounts") do
        local mount = Line:match(".- (.-) .*")
        if (mount~=nil and mount:starts_with('/media')) then
            table.insert(mounts, mount)
        end
    end
    return mounts
end -- get_media_mounts


-------------------------------------------------------------------------------
--                                                       go_special_gauge_rings
-- loads data and displays gauges (to show special values)
--
function go_special_gauge_rings(display, refresh) 
    if (not meminfo or refresh) then
        meminfo = get_mem_info() -- global var!
    end
    if (not mounts or refresh) then
        mounts = get_media_mounts() -- global var!
    end

    for i in pairs(gauge_special) do
        -- special handling by name
        local data = gauge_special[i]
        local name = data['name']
        -- draw mem_caches
        if (name == "mem_caches") then
            local value = (meminfo['MemTotal'] - meminfo['MemFree']) * 100.0 / meminfo['MemTotal']
            draw_gauge_ring(display, data, value)
        end
        -- draw dynamich mounts
        if (name == "mounts") then
            local copy = table.shallowcopy(data)
            for i in pairs(mounts) do
                local mnt = mounts[i]
                local split = mnt:split('/')
                local n = table.getn(split)
                copy['caption'] = split[n]
                local value = tonumber(conky_parse(string.format('${fs_used_perc %s}', mnt)))
                draw_gauge_ring(display, copy, value)
            end
        end
    end

end -- go_special_gauge_rings


-------------------------------------------------------------------------------
--                                                               go_gauge_rings
-- loads data and displays gauges
--
function go_gauge_rings(display)
    local function load_gauge_rings(display, data)
        local str, value = '', 0
        str = string.format('${%s %s}', data['name'], data['arg'])
        str = conky_parse(str)
        value = tonumber(str)
        draw_gauge_ring(display, data, value)
    end
    
    for i in pairs(gauge) do
        load_gauge_rings(display, gauge[i])
    end
end -- go_gauge_rings


-------------------------------------------------------------------------------
--                                                                         MAIN
function conky_main()
    if conky_window == nil then 
        return
    end

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local display = cairo_create(cs)
    
    local updates = conky_parse('${updates}')
    local update_num = tonumber(updates)
    
    -- setup a 'timer'
    local interval = 2
    local timer = (update_num % interval)

    if update_num > 5 then
        go_gauge_rings(display) -- display normal rings

        -- display special rings
        if timer == 0 then
            go_special_gauge_rings(display, true) -- refresh the values
        else
            go_special_gauge_rings(display) -- no refresh needed
        end
    end

    cairo_surface_destroy(cs)
    cairo_destroy(display)

end --conky_main
