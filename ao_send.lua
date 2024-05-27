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
