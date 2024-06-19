Handlers.add(
    "BroadcastDiscord",
    Handlers.utils.hasMatchingTag("Action", "BroadcastDiscord"),
    function(m)
        local userTag = m.Event or "Unknown"
        
        local x = "Discord-User:" .. userTag .. ": " .. (m.Data or "No Message")
        Say(x)
    end
)
