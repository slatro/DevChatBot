local json = require("json")

DevChat = {}

DevChat.Colors = {
    red = "\27[31m",
    green = "\27[32m",
    blue = "\27[34m",
    yellow = "\27[33m",
    magenta = "\27[35m",
    cyan = "\27[36m",
    reset = "\27[0m",
    gray = "\27[90m"
}

DevChat.Router = "xnkv_QpWqICyt8NpVMbfsUQciZ4wlm5DigLrfXRm8fY"
DevChat.InitRoom = "isImEFj7zii8ALzRirQ2nqUUXecCkdFSh10xB_hbBJ0"
DevChat.LastSend = DevChat.LastSend or DevChat.InitRoom

DevChat.LastReceive = {
    Room = DevChat.InitRoom,
    Sender = nil
}

DevChat.InitRooms = { [DevChat.InitRoom] = "DevChat-Main" }
DevChat.Rooms = DevChat.Rooms or DevChat.InitRooms

DevChat.Confirmations = DevChat.Confirmations or true

DevChat.findRoom = function(target)
    for address, name in pairs(DevChat.Rooms) do
        if target == name then
            return address
        end
    end
end

DevChat.add = function(...)
    local arg = {...}
    ao.send({
        Target = DevChat.Router,
        Action = "Register",
        Name = arg[1] or Name,
        Address = arg[2] or ao.id
    })
end

List = function()
    ao.send({ Target = DevChat.Router, Action = "Get-List" })
    return(DevChat.Colors.gray .. "DevChat dizininden oda listesi alınıyor..." .. DevChat.Colors.reset)
end

Join = function(id, ...)
    local arg = {...}
    local addr = DevChat.findRoom(id) or id
    local nick = arg[1] or ao.id
    ao.send({ Target = addr, Action = "Register", Nickname = nick })
    return(
        DevChat.Colors.gray ..
        "Odaya kayıt yapılıyor " ..
        DevChat.Colors.blue .. id .. 
        DevChat.Colors.gray .. "..." .. DevChat.Colors.reset)
end

Say = function(text, ...)
    local arg = {...}
    local id = arg[1]
    if id ~= nil then
        DevChat.LastSend = DevChat.findRoom(id) or id
    end
    local name = DevChat.Rooms[DevChat.LastSend] or id
    ao.send({ Target = DevChat.LastSend, Action = "Say", Data = text })
    if DevChat.Confirmations then
        return(DevChat.Colors.gray .. "Mesaj gönderiliyor " .. DevChat.Colors.blue ..
            name .. DevChat.Colors.gray .. "..." .. DevChat.Colors.reset)
    else
        return ""
    end
end

Tip = function(...) -- Alıcı, Hedef, Miktar
    local arg = {...}
    local room = arg[2] or DevChat.LastReceive.Room
    local roomName = DevChat.Rooms[room] or room
    local qty = tostring(arg[3] or 1)
    local recipient = arg[1] or DevChat.LastReceive.Sender
    ao.send({
        Action = "Transfer",
        Target = room,
        Recipient = recipient,
        Quantity = qty
    })
    return(DevChat.Colors.gray .. "Bahşiş gönderildi " ..
        DevChat.Colors.green .. qty .. DevChat.Colors.gray ..
        " alıcıya " .. DevChat.Colors.red .. recipient .. DevChat.Colors.gray ..
        " odada " .. DevChat.Colors.blue .. roomName .. DevChat.Colors.gray ..
        "."
    )
end

Replay = function(...) -- Derinlik, oda
    local arg = {...}
    local room = nil
    if arg[2] then
        room = DevChat.findRoom(arg[2]) or arg[2]
    else
        room = DevChat.LastReceive.Room
    end
    local roomName = DevChat.Rooms[room] or room
    local depth = arg[1] or 3

    ao.send({
        Target = room,
        Action = "Replay",
        Depth = tostring(depth)
    })
    return(
        DevChat.Colors.gray ..
        "Son " ..
        DevChat.Colors.green .. depth .. 
        DevChat.Colors.gray .. " mesajların tekrarı istendi " .. DevChat.Colors.blue ..
        roomName .. DevChat.Colors.reset .. ".")
end

Leave = function(id)
    local addr = DevChat.findRoom(id) or id
    ao.send({ Target = addr, Action = "Unregister" })
    return(
        DevChat.Colors.gray ..
        "Odayı terk ediyor " ..
        DevChat.Colors.blue .. id ..
        DevChat.Colors.gray .. "..." .. DevChat.Colors.reset)
end

Handlers.add(
    "DevChat-Broadcasted",
    Handlers.utils.hasMatchingTag("Action", "Broadcasted"),
    function (m)
        local shortRoom = DevChat.Rooms[m.From] or string.sub(m.From, 1, 6)
        if m.Broadcaster == ao.id then
            if DevChat.Confirmations == true then
                print(
                    DevChat.Colors.gray .. "[Yayınınızın onayı alındı "
                    .. DevChat.Colors.blue .. shortRoom .. DevChat.Colors.gray .. ".]"
                    .. DevChat.Colors.reset)
            end
        else
            local nick = string.sub(m.Nickname, 1, 10)
            if m.Broadcaster ~= m.Nickname then
                nick = nick .. DevChat.Colors.gray .. "#" .. string.sub(m.Broadcaster, 1, 3)
            end
            print(
                "[" .. DevChat.Colors.red .. nick .. DevChat.Colors.reset
                .. "@" .. DevChat.Colors.blue .. shortRoom .. DevChat.Colors.reset
                .. "]> " .. DevChat.Colors.green .. m.Data .. DevChat.Colors.reset)

            DevChat.LastReceive.Room = m.From
            DevChat.LastReceive.Sender = m.Broadcaster
        end
    end
)

Handlers.add(
    "DevChat-List",
    function(m)
        if m.Action == "Room-List" and m.From == DevChat.Router then
            return true
        end
        return false
    end,
    function(m)
        local intro = "?? DevChat'te şu anda mevcut olan odalar:\n\n"
        local rows = ""
        DevChat.Rooms = DevChat.InitRooms

        for i = 1, #m.TagArray do
            local filterPrefix = "Room-" -- Bütün oda etiketleri bununla başlar
            local tagPrefix = string.sub(m.TagArray[i].name, 1, #filterPrefix)
            local name = string.sub(m.TagArray[i].name, #filterPrefix + 1, #m.TagArray[i].name)
            local address = m.TagArray[i].value

            if tagPrefix == filterPrefix then
                rows = rows .. DevChat.Colors.blue .. "        " .. name .. DevChat.Colors.reset .. "\n"
                DevChat.Rooms[address] = name
            end
        end

        print(
            intro .. rows .. "\nBir odaya katılmak için `Join(\"chatName\"[, \"yourNickname\"])` komutunu çalıştırabilirsiniz! Odalardan çıkmak için `Leave(\"name\")` komutunu kullanabilirsiniz.")
    end
)

Handlers.add(
    "TransferToDevChat",
    Handlers.utils.hasMatchingTag("Action", "TransferToDevChat"),
    function(m)
        local msgContent = m.Data or "Mesaj içeriği yok"
        local senderName = m.Sender or "Bilinmeyen gönderen" -- Mesajdan gelen gönderici adını kontrol edin

        -- Mesajı DevChat konsolunda göster
        print(DevChat.Colors.green .. "[" .. senderName .. "]: " .. DevChat.Colors.reset .. msgContent)
    end
)

if DevChatRegistered == nil then
    DevChatRegistered = true
    Join(DevChat.InitRoom)
end

return(
    DevChat.Colors.blue .. "\n\nDevChat v0.1'e hoş geldiniz!\n\n" .. DevChat.Colors.reset ..
    "DevChat, ao topluluğunun yeni bilgisayarımızı inşa ederken iletişim kurmasına yardımcı olan basit bir hizmettir.\n" ..
    "Arayüz basittir. Çalıştırın...\n\n" ..
    DevChat.Colors.green .. "\t\t`List()`" .. DevChat.Colors.reset .. " mevcut odaları görmek için.\n" .. 
    DevChat.Colors.green .. "\t\t`Join(\"RoomName\")`" .. DevChat.Colors.reset .. " bir odaya katılmak için.\n" .. 
    DevChat.Colors.green .. "\t\t`Say(\"Msg\"[, \"RoomName\"])`" .. DevChat.Colors.reset .. " bir odaya mesaj göndermek için (bir sonraki seferde son seçiminizi hatırlayarak).\n" ..
    DevChat.Colors.green .. "\t\t`Replay([\"Count\"])`" .. DevChat.Colors.reset .. " bir sohbetteki en son mesajları yeniden yazdırmak için.\n" ..
    DevChat.Colors.green .. "\t\t`Leave(\"RoomName\")`" .. DevChat.Colors.reset .. " istediğiniz zaman bir sohbetten çıkmak için.\n" ..
    DevChat.Colors.green .. "\t\t`Tip([\"Recipient\"])`" .. DevChat.Colors.reset .. " sohbet odasından son mesajın göndericisine bir token göndermek için.\n\n" ..
    "Zaten " .. DevChat.Colors.blue .. DevChat.Rooms[DevChat.InitRoom] .. DevChat.Colors.reset .. " odasına kayıtlısınız.\n" ..
    "AO: Paralel İşlemleri Birleştirerek Merkezi Olmayan Bir Ekosisteme Dönüştürüyoruz, Discord DevChat ile Sorunsuz Bağlanıyor.")
