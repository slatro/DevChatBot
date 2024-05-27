-- ao değişkenini tanımlayın
ao = {
    id = "ao-id-example",
    send = function(message)
        -- Bu işlev, mesajları göndermek için kullanılır
        if message.Action == "Broadcast" then
            local usernameColor = DevChat.getColorForUsername(message.Username)
            print(usernameColor .. message.Username .. DevChat.Colors.reset .. ": " .. message.Data)
            io.write("::discord::" .. message.Username .. ": " .. message.Data .. "\n") -- Bu satır Discord'a iletilecek mesajı işaretler
        else
            print("Unknown action: " .. message.Action)
        end
    end
}

-- Handlers değişkenini tanımlayın ve başlatın
Handlers = Handlers or {}

-- Handler yardımcı işlevlerini ekleyin
Handlers.utils = {
    hasMatchingTag = function(tagKey, tagValue)
        return function(message)
            return message[tagKey] == tagValue
        end
    end
}

-- Örnek bir Handler ekleyin
Handlers.add = function(action, condition, callback)
    if not Handlers[action] then
        Handlers[action] = {}
    end
    table.insert(Handlers[action], { condition = condition, callback = callback })
end

-- Say fonksiyonunu tanımlayın
function Say(message, username)
    if not message then
        print("Error: No message provided.")
        return
    end
    if not username then
        print("Error: No username provided.")
        return
    end
    local formattedMessage = "Message from \"" .. username .. "\": " .. message
    print(formattedMessage) -- Bu satır terminale yazdırmak için eklendi
    ao.send({
        Action = "Broadcast",
        Data = message,
        Username = username,
        Target = "I6c7tto7uXzZROotNxb8F1m86ORv4DeG1PzqXoXfQ4U" -- chatroom.lua process ID
    })
end

-- DevChat betiği burada başlar
DevChat = {}

DevChat.Colors = {
    cyan = "\27[36m",        -- Cyan
    magenta = "\27[35m",     -- Magenta
    yellow = "\27[33m",      -- Yellow
    brightRed = "\27[91m",   -- Bright Red
    brightGreen = "\27[92m", -- Bright Green
    brightBlue = "\27[94m",  -- Bright Blue
    brightYellow = "\27[93m",-- Bright Yellow
    brightMagenta = "\27[95m",-- Bright Magenta
    brightCyan = "\27[96m",  -- Bright Cyan
    reset = "\27[0m",        -- Reset
    brightGray = "\27[97m"   -- Bright Gray
}

-- Kullanıcı adlarına renk atamak için fonksiyon
DevChat.getColorForUsername = function(username)
    local colors = {
        DevChat.Colors.brightRed,
        DevChat.Colors.brightGreen,
        DevChat.Colors.brightBlue,
        DevChat.Colors.brightYellow,
        DevChat.Colors.brightMagenta,
        DevChat.Colors.brightCyan
    }
    local sum = 0
    for i = 1, #username do
        sum = sum + username:byte(i)
    end
    return colors[(sum % #colors) + 1]
end

DevChat.Router = "Vm_gxd6H_Fp09RkX1CAItb1fya_e4qdCJycwK-2kE1Y"
DevChat.InitRoom = "I6c7tto7uXzZROotNxb8F1m86ORv4DeG1PzqXoXfQ4U"
DevChat.LastSend = DevChat.LastSend or DevChat.InitRoom

DevChat.LastReceive = {
    Room = DevChat.InitRoom,
    Sender = nil
}

DevChat.InitRooms = { [DevChat.InitRoom] = "DevChat-Main" }
DevChat.Rooms = DevChat.Rooms or DevChat.InitRooms

DevChat.Confirmations = DevChat.Confirmations or true

-- Helper function to go from roomName => address
DevChat.findRoom = function(target)
    for address, name in pairs(DevChat.Rooms) do
        if target == name then
            return address
        end
    end
end

List = function()
    ao.send({ Target = DevChat.Router, Action = "Get-List" })
    return(DevChat.Colors.brightGray .. "Getting the room list from the DevChat index..." .. DevChat.Colors.reset)
end

Tip = function(...)
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
    return(DevChat.Colors.brightGray .. "Sent tip of " ..
        DevChat.Colors.brightGreen .. qty .. DevChat.Colors.brightGray ..
        " to " .. DevChat.Colors.brightRed .. recipient .. DevChat.Colors.brightGray ..
        " in room " .. DevChat.Colors.brightBlue .. roomName .. DevChat.Colors.brightGray ..
        "."
    )
end

Replay = function(...)
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
        DevChat.Colors.brightGray ..
         "Requested replay of the last " ..
        DevChat.Colors.brightGreen .. depth .. 
        DevChat.Colors.brightGray .. " messages from " .. DevChat.Colors.brightBlue ..
        roomName .. DevChat.Colors.reset .. ".")
end

Leave = function(id)
    local addr = DevChat.findRoom(id) or id
    ao.send({ Target = addr, Action = "Unregister" })
    return(
        DevChat.Colors.brightGray ..
         "Leaving room " ..
        DevChat.Colors.brightBlue .. id ..
        DevChat.Colors.brightGray .. "..." .. DevChat.Colors.reset)
end

-- Handler'ları ekleyin
Handlers.add(
    "DevChat-Broadcasted",
    Handlers.utils.hasMatchingTag("Action", "Broadcasted"),
    function (m)
        local shortRoom = DevChat.Rooms[m.From] or string.sub(m.From, 1, 6)
        if m.Broadcaster == ao.id then
            if DevChat.Confirmations == true then
                io.write(
                    DevChat.Colors.brightGray .. "[Received confirmation of your broadcast in "
                    .. DevChat.Colors.brightBlue .. shortRoom .. DevChat.Colors.brightGray .. ".]"
                    .. DevChat.Colors.reset .. "\n")
            end
        else
            local nick = string.sub(m.Nickname, 1, 10)
            if m.Broadcaster ~= m.Nickname then
                nick = nick .. DevChat.Colors.brightGray .. "#" .. string.sub(m.Broadcaster, 1, 3)
            end
            io.write(
                "[" .. DevChat.Colors.brightRed .. nick .. DevChat.Colors.reset
                .. "@" .. DevChat.Colors.brightBlue .. shortRoom .. DevChat.Colors.reset
                .. "]> " .. DevChat.Colors.brightGreen .. m.Data .. DevChat.Colors.reset .. "\n")

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
        local intro = "👋 The following rooms are currently available on DevChat:\n\n"
        local rows = ""
        DevChat.Rooms = DevChat.InitRooms

        for i = 1, #m.TagArray do
            local filterPrefix = "Room-" -- All of our room tags start with this
            local tagPrefix = string.sub(m.TagArray[i].name, 1, #filterPrefix)
            local name = string.sub(m.TagArray[i].name, #filterPrefix + 1, #m.TagArray[i].name)
            local address = m.TagArray[i].value

            if tagPrefix == filterPrefix then
                rows = rows .. DevChat.Colors.brightBlue .. "        " .. name .. DevChat.Colors.reset .. "\n"
                DevChat.Rooms[address] = name
            end
        end

        io.write(
            intro .. rows .. "\nJoin a chat by running `Join(\"chatName\"[, \"yourNickname\"])`! You can leave chats with `Leave(\"name\")`.\n")
    end
)

if DevChatRegistered == nil then
    DevChatRegistered = true
end

return(
    DevChat.Colors.brightBlue .. "\n\nWelcome to ao DevChat v0.1!\n\n" .. DevChat.Colors.reset ..
    "DevChat is a simple service that helps the ao community communicate as we build our new computer.\n" ..
    "The interface is simple. Run...\n\n" ..
    DevChat.Colors.brightGreen .. "\t\t`List()`" .. DevChat.Colors.reset .. " to see which rooms are available.\n" .. 
    DevChat.Colors.brightGreen .. "\t\t`Join(\"RoomName\")`" .. DevChat.Colors.reset .. " to join a room.\n" .. 
    DevChat.Colors.brightGreen .. "\t\t`Say(\"Msg\"[, \"RoomName\"])`" .. DevChat.Colors.reset .. " to post to a room (remembering your last choice for next time).\n" ..
    DevChat.Colors.brightGreen .. "\t\t`Replay([\"Count\"])`" .. DevChat.Colors.reset .. " to reprint the most recent messages from a chat.\n" ..
    DevChat.Colors.brightGreen .. "\t\t`Leave(\"RoomName\")`" .. DevChat.Colors.reset .. " at any time to unsubscribe from a chat.\n" ..
    DevChat.Colors.brightGreen .. "\t\t`Tip([\"Recipient\"])`" .. DevChat.Colors.reset .. " to send a token from the chatroom to the sender of the last message.\n\n" ..
    "Have fun, be respectful, and remember: Cypherpunks ship code! 🫡\n")
