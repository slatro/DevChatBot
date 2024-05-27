Rooms = Rooms or {}

Handlers = Handlers or {
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

ao = ao or {
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
    "Join",
    Handlers.utils.hasMatchingTag("Action", "Join"),
    function(m)
        print("Adding room '" .. m.Name .. "'. Added by: " .. m.From)
        local address = m.Address or m.From
        table.insert(Rooms, { Address = address, Name = m.Name, AddedBy = m.From })
        ao.send({
            Target = m.From,
            Action = "Joined"
        })
    end
)

Handlers.add(
    "Get-List",
    Handlers.utils.hasMatchingTag("Action", "Get-List"),
    function(m)
        print("Listing rooms for: " .. m.From)
        local reply = { Target = m.From, Action = "Room-List" }
        for i = 1, #Rooms do
            reply["Room-" .. Rooms[i].Name] = Rooms[i].Address
        end
        ao.send(reply)
    end
)

Handlers.add(
    "Unregister",
    Handlers.utils.hasMatchingTag("Action", "Unregister"),
    function(m)
        local room = nil
        for i = 1, #Rooms do
            if Rooms[i].Name == m.Name then
                room = Rooms[i]
                room.Index = i
            end
        end

        if m.From ~= room.AddedBy then
            print("UNAUTH: Remove attempt by " .. m.From .. " for '" .. m.Name .. "'!")
            return
        end

        table.remove(Rooms, room.Index)
    end
)
