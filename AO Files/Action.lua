local json = require("json")

-- Say işlemi için handler ekleniyor
Handlers.add(
  "Say",
  Handlers.utils.hasMatchingTag("Action", "Say"),
  function (msg)
    -- Mesajın kimden geldiği bilgisini alıyoruz
    local fromText = msg.From
    -- Oda bilgisi yoksa varsayılan "default" oda olarak ayarlanıyor
    local room = msg.Room or "default"
    
    -- Gelen mesajı işlemek için ao nesnesine bir gönderim yapıyoruz
    ao.send({
      Target = ao.id,
      Action = "SendDiscordMsg",
      Data = msg.Data,
      Event = "Mesaj şu odada: " .. room,
      OriginatingFrom = fromText
    })
    
    -- Mesajın işlendiğine dair bir log yazısı ekliyoruz
    print("Mesaj işlendi ve Discord'a gönderildi: " .. msg.Data)
  end
)
