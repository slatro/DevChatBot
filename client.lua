DevChat = {}

DevChat.Colors = {
    pink = "\27[38;5;206m",
    lightGreen = "\27[38;5;120m",
    lightBlue = "\27[38;5;111m",
    reset = "\27[0m",
    lightGray = "\27[38;5;246m"
}

DevChat.Router = "j597QkvQeMuDyTArdVv9dFF7yIWZNVwWa7jHmQqwEbk" -- Bu process ID'yi değiştirin
DevChat.InitRoom = "-5PaCcmaXJCRjC2B0NYo5PcuLiGgyRKYl1PQ9H8R7Kw" -- Bu process ID'yi değiştirin
DevChat.LastSend = DevChat.LastSend or DevChat.InitRoom

DevChat.LastReceive = {
    Room = DevChat.InitRoom,
    Sender = nil
}

DevChat.InitRooms = { [DevChat.InitRoom] = "DevChat-Main" }
DevChat.Rooms = DevChat.Rooms or DevChat.InitRooms

DevChat.Confirmations = DevChat.Confirmations or true

DevChat.findRoom =
    function(target)
        for address, name in pairs(DevChat.Rooms) do
            if target == name then
                return address
            end
        end
    end

DevChat.add =
    function(...)
        local arg = {...}
        ao.send({
            Target = DevChat.Router,
            Action = "Register",
            Name = arg[1] or Name,
            Address = arg[2] or ao.id
        })
    end

List =
    function()
        ao.send({ Target = DevChat.Router, Action = "Get-List" })
        return(DevChat.Colors.lightGray .. "Getting the room list from the DevChat index..." .. DevChat.Colors.reset)
    end

    Join =
    function(id, ...)
        local arg = {...}
        local addr = DevChat.findRoom(id) or id
        local nick = arg[1] or ao.id
        ao.send({ Target = addr, Action = "Register", Nickname = nick })
        print("Debug: Join requested with id: " .. id .. " and nickname: " .. nick)
        return(
            DevChat.Colors.lightGray ..
             "Registering with room " ..
            DevChat.Colors.lightBlue .. id .. 
            DevChat.Colors.lightGray .. "..." .. DevChat.Colors.reset)
    end

    Say = function(text, ...)
        local arg = {...}
        local id = arg[1]
        if id ~= nil then
            DevChat.LastSend = DevChat.findRoom(id) or id
        end
        local name = DevChat.Rooms[DevChat.LastSend] or id
        print("Debug: Preparing to send message: " .. text .. " to room: " .. name)
        ao.send({ Target = DevChat.LastSend, Action = "Broadcast", Data = text })
        print("Debug: Message sent with text: " .. text .. " to room: " .. name)
        if DevChat.Confirmations then
            return(DevChat.Colors.lightGray .. "Broadcasting to " .. DevChat.Colors.lightBlue ..
                name .. DevChat.Colors.lightGray .. "..." .. DevChat.Colors.reset)
        else
            return ""
        end
    end
    

    function Broadcast(from, data, type)
        print("Broadcasting " .. type .. " message from " .. from .. ". Content:\n" .. data)
        local lastUsers = {}
        for i = #Messages - 100, #Messages, 1 do
            lastUsers[Messages[i].From] = 1 
        end
        for user, _ in pairs(lastUsers) do
            DispatchMessage(user, from, data, type)
        end
        table.insert(Messages, { From = from, Type = type, Data = data })
        print("Message broadcasted successfully from: " .. from .. " with content: " .. data)
    end


Tip =
    function(...) -- Recipient, Target, Qty
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
        return(DevChat.Colors.lightGray .. "Sent tip of " ..
            DevChat.Colors.lightGreen .. qty .. DevChat.Colors.lightGray ..
            " to " .. DevChat.Colors.pink .. recipient .. DevChat.Colors.lightGray ..
            " in room " .. DevChat.Colors.lightBlue .. roomName .. DevChat.Colors.lightGray ..
            "."
        )
    end

Replay =
    function(...) -- depth, room
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
            DevChat.Colors.lightGray ..
             "Requested replay of the last " ..
            DevChat.Colors.lightGreen .. depth .. 
            DevChat.Colors.lightGray .. " messages from " .. DevChat.Colors.lightBlue ..
            roomName .. DevChat.Colors.reset .. ".")
    end

Leave =
    function(id)
        local addr = DevChat.findRoom(id) or id
        ao.send({ Target = addr, Action = "Unregister" })
        print("Debug: Leave requested with id: " .. id)
        return(
            DevChat.Colors.lightGray ..
             "Leaving room " ..
            DevChat.Colors.lightBlue .. id ..
            DevChat.Colors.lightGray .. "..." .. DevChat.Colors.reset)
    end

-- Handlers tablosunu tanımlayın ve eklemeler yapın
Handlers = {
    utils = {
        hasMatchingTag = function(tag, value)
            return function(m)
                return m[tag] == value
            end
        end
    },
    add = function(action, condition, func)
        -- Bu örnek, Handlers tablosuna bir işleyici ekler
        -- Gerçek implementasyonunuzda bu işlevi değiştirin
        print("Handler added for action: " .. action)
    end
}

ao = {
    send = function(data)
        -- ao modülünün gönderim işlevi örnek olarak tanımlandı
        -- Gerçek implementasyonunuzda bu işlevi değiştirin
        print("Sending data: ")
        for k, v in pairs(data) do
            print(k .. ": " .. tostring(v))
        end
    end,
    id = "ao-id-example" -- Örnek olarak ao id
}

Handlers.add(
    "DevChat-Broadcasted",
    Handlers.utils.hasMatchingTag("Action", "Broadcasted"),
    function (m)
        local shortRoom = DevChat.Rooms[m.From] or string.sub(m.From, 1, 6)
        if m.Broadcaster == ao.id then
            if DevChat.Confirmations == true then
                print(
                    DevChat.Colors.lightGray .. "[Received confirmation of your broadcast in "
                    .. DevChat.Colors.lightBlue .. shortRoom .. DevChat.Colors.lightGray .. ".]"
                    .. DevChat.Colors.reset)
            end
        else
            local nick = string.sub(m.Nickname, 1, 10)
            if m.Broadcaster ~= m.Nickname then
                nick = nick .. DevChat.Colors.lightGray .. "#" .. string.sub(m.Broadcaster, 1, 3)
            end
            print(
                "[" .. DevChat.Colors.pink .. nick .. DevChat.Colors.reset
                .. "@" .. DevChat.Colors.lightBlue .. shortRoom .. DevChat.Colors.reset
                .. "]> " .. DevChat.Colors.lightGreen .. m.Data .. DevChat.Colors.reset
            )

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
                rows = rows .. DevChat.Colors.lightBlue .. "        " .. name .. DevChat.Colors.reset .. "\n"
                DevChat.Rooms[address] = name
            end
        end

        print(
            intro .. rows .. "\nJoin a chat by running `Join(\"chatName\"[, \"yourNickname\"])`! You can leave chats with `Leave(\"name\")`."
        )
    end
)


if DevChatRegistered == nil then
    DevChatRegistered = true
    Join(DevChat.InitRoom)
end

return(
    DevChat.Colors.lightBlue .. "\n\nWelcome to ao DevChat v0.1!\n\n" .. DevChat.Colors.reset ..
    "DevChat is a simple service that helps the ao community communicate as we build our new computer.\n" ..
    "The interface is simple. Run...\n\n" ..
    DevChat.Colors.lightGreen .. "\t\t`List()`" .. DevChat.Colors.reset .. " to see which rooms are available.\n" .. 
    DevChat.Colors.lightGreen .. "\t\t`Join(\"RoomName\")`" .. DevChat.Colors.reset .. " to join a room.\n" .. 
    DevChat.Colors.lightGreen .. "\t\t`Say(\"Msg\"[, \"RoomName\"])`" .. DevChat.Colors.reset .. " to post to a room (remembering your last choice for next time).\n" ..
    DevChat.Colors.lightGreen .. "\t\t`Replay([\"Count\"])`" .. DevChat.Colors.reset .. " to reprint the most recent messages from a chat.\n" ..
    DevChat.Colors.lightGreen .. "\t\t`Leave(\"RoomName\")`" .. DevChat.Colors.reset .. " at any time to unsubscribe from a chat.\n" ..
    DevChat.Colors.lightGreen .. "\t\t`Tip([\"Recipient\"])`" .. DevChat.Colors.reset .. " to send a token from the chatroom to the sender of the last message.\n\n" ..
    "You have already been registered to the " .. DevChat.Colors.lightBlue .. DevChat.Rooms[DevChat.InitRoom] .. DevChat.Colors.reset .. ".\n" ..
    "Have fun, be respectful, and remember: Cypherpunks ship code! 🫡")
