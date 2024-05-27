local socket = require("socket")
local json = require("cjson")

local server = assert(socket.bind("0.0.0.0", 8080))

print("HTTP server running on http://localhost:8080/")

while true do
    local client = server:accept()
    client:settimeout(10)

    local request, err = client:receive()
    if not err then
        print("Received request: " .. request)

        -- HTTP isteğini işleyin
        if request:find("POST /send") then
            local headers = {}
            local body = ""
            local line, err
            repeat
                line, err = client:receive()
                if line and line ~= "" then
                    headers[#headers + 1] = line
                end
            until err or line == ""

            if not err then
                body, err = client:receive(tonumber(headers["Content-Length"]))
                if not err then
                    print("Received body: " .. body)

                    -- Body'yi JSON olarak ayrıştırın ve ao ortamına mesaj gönderin
                    local message = json.decode(body)
                    if message then
                        ao.send({
                            Target = message.Target,
                            Action = message.Action,
                            Data = message.Data,
                            Username = message.Username
                        })
                        client:send("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nMessage sent successfully")
                    else
                        client:send("HTTP/1.1 400 Bad Request\r\nContent-Type: text/plain\r\n\r\nInvalid JSON")
                    end
                end
            end
        else
            -- Basit "hello world" yanıtı
            client:send("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nHello World")
        end
    end
    client:close()
end
