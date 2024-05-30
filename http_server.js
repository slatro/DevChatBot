const { results } = require('@permaweb/aoconnect');
const WebSocket = require('ws');

// WebSocket bağlantısını başlatma
const wsServerUrl = 'ws://localhost:8080';
const websocket = new WebSocket(wsServerUrl);

let lastCursor = '';

websocket.on('open', () => {
  console.log('WebSocket bağlantısı başarıyla açıldı.');
});

websocket.on('error', (err) => {
  console.error('WebSocket Bağlantı Hatası:', err);
});

async function monitorDevChat() {
  try {
    if (!lastCursor) {
      const initialData = await results({
        process: 'IVsB6cwDL-2CgUxWgMcj-JXOhytSsH9a6poylDutLFU',
        sort: 'DESC',
        limit: 1,
      });
      lastCursor = initialData.edges[0]?.cursor || '';
      console.log('Başlangıç verileri:', initialData);
    }

    console.log('DevChat mesajlarını kontrol etme işlemi başlatılıyor...');
    const fetchedMessages = await results({
      process: 'IVsB6cwDL-2CgUxWgMcj-JXOhytSsH9a6poylDutLFU',
      from: lastCursor,
      sort: 'ASC',
      limit: 50,
    });

    for (const edge of fetchedMessages.edges.reverse()) {
      lastCursor = edge.cursor;
      console.log('Alınan yeni mesajlar:', edge.node.Messages);

      for (const msg of edge.node.Messages) {
        console.log('Mesaj Etiketleri:', msg.Tags);
      }

      const filteredMessages = edge.node.Messages.filter(msg => 
        msg.Tags.some(tag => tag.name === 'Action' && tag.value === 'Say')
      );
      console.log('Filtrelenmiş Mesajlar:', filteredMessages);

      for (const filteredMsg of filteredMessages) {
        const eventTag = filteredMsg.Tags.find(tag => tag.name === 'Event')?.value || 'SlatroChat1\'de Yeni Mesaj';
        const messageToSend = `${eventTag} : ${filteredMsg.Data}`;
        console.log('Gönderilecek Mesaj:', messageToSend);
        websocket.send(messageToSend);
      }
    }

  } catch (error) {
    console.error('DevChat kontrolü sırasında hata oluştu:', error);
    console.error('Hata Detayları:', error.message);
  } finally {
    setTimeout(monitorDevChat, 5000);
  }
}

monitorDevChat();
