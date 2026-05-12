-- juha_heart | Juha (CraftPlay777)
-- /heart: vidas invisibles mostradas en HUD lateral

local S = minetest.get_translator("juha_heart")

local huds    = {}
local hp_inv  = {}
local storage = minetest.get_mod_storage()

local POS     = {x = 0.5, y = 1.0}
local OFF_BG  = {x = -230, y = -100}
local OFF_TXT = {x = -229, y = -100}
local COLOR   = 0x111111

local function crear_hud(player)
    local name = player:get_player_name()
    if huds[name] then return end

    local bg = player:hud_add({
        hud_elem_type = "image",
        position      = POS,
        offset        = OFF_BG,
        text          = "[fill:120x27:#FFFFFF",
        scale         = {x = 1, y = 1},
        alignment     = {x = 1, y = 0},
        z_index       = 10,
    })

    local txt = player:hud_add({
        hud_elem_type = "text",
        position      = POS,
        offset        = OFF_TXT,
        text          = "",
        number        = COLOR,
        alignment     = {x = 1, y = 0},
        z_index       = 11,
    })

    huds[name] = {bg = bg, txt = txt}
end

local function actualizar_hud(player)
    local name = player:get_player_name()
    local hp   = hp_inv[name] or 0

    if hp <= 0 then
        if huds[name] then
            player:hud_remove(huds[name].bg)
            player:hud_remove(huds[name].txt)
            huds[name] = nil
        end
        return
    end

    crear_hud(player)
    player:hud_change(huds[name].txt, "text", S("@1 vidas invisibles", hp))
end

-- intercepta daño
minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if hp_change >= 0 then return hp_change end -- solo daño

    local name  = player:get_player_name()
    local inv   = hp_inv[name] or 0
    if inv <= 0 then return hp_change end

    local dano  = -hp_change -- positivo
    local resto = inv - dano

    if resto >= 0 then
        hp_inv[name] = resto
        storage:set_int(name, resto)
        actualizar_hud(player)
        return 0
    else
        hp_inv[name] = 0
        storage:set_int(name, 0)
        actualizar_hud(player)
        return resto
    end
end, true)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    hp_inv[name] = storage:get_int(name) or 0
    actualizar_hud(player)
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    storage:set_int(name, hp_inv[name] or 0)
    huds[name]   = nil
    hp_inv[name] = nil
end)

-- priv
minetest.register_privilege("heart", {
    description      = S("Puede usar /heart"),
    give_to_singleplayer = false,
})

minetest.register_chatcommand("heart", {
    params      = S("<hp> [jugador] | quit <hp> [jugador]"),
    description = S("Asigna o quita vidas invisibles"),
    privs       = {heart = true},
    func = function(caller, param)
        local args = {}
        for w in param:gmatch("%S+") do args[#args + 1] = w end

        local quitar   = args[1] == "quit"
        local idx      = quitar and 2 or 1
        local cantidad = tonumber(args[idx])
        local objetivo = args[idx + 1] or caller

        if not cantidad or cantidad < 0 then
            return false, S("Uso: /heart <hp> [jugador]  |  /heart quit <hp> [jugador]")
        end

        local player = minetest.get_player_by_name(objetivo)
        if not player then
            return false, S("Jugador no encontrado: @1", objetivo)
        end

        if quitar then
            hp_inv[objetivo] = math.max(0, (hp_inv[objetivo] or 0) - cantidad)
        else
            hp_inv[objetivo] = cantidad
        end

        storage:set_int(objetivo, hp_inv[objetivo])
        actualizar_hud(player)

        local accion = quitar
            and S("Quitadas @1 vidas invisibles a @2", cantidad, objetivo)
            or  S("Asignadas @1 vidas invisibles a @2", cantidad, objetivo)
        return true, accion
    end,
})