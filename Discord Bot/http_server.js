const { results } = require('@permaweb/aoconnect');
const WebSocket = require('ws');

// Initiate Websocket connection

let cursor = '';
const ws = new WebSocket('ws://localhost:8080');

let sentMessages = new Set();
const MESSAGE_EXPIRATION_TIME = 1000; // 1 saniye

ws.on('open', () => {
  console.log('WebSocket connection opened');
});

ws.on('error', (error) => {
  console.error('WebSocket Error:', error);
});

async function DevChatCheking() {
  try {
    if (cursor === '') {
      const resultsOut = await results({
        process: '6I1JBBc9SOMtqFxlX7OoYgsMh7QeZk2fFwUCHTUqshg',
        sort: 'DESC',
        limit: 1,
      });
      cursor = resultsOut.edges[0].cursor;
      console.log('Last Results', resultsOut);
    }

    console.log('DevChatCheck');
    const resultsOut2 = await results({
      process: '6I1JBBc9SOMtqFxlX7OoYgsMh7QeZk2fFwUCHTUqshg',
      from: cursor,
      sort: 'ASC',
      limit: 50,
    });

    for (const element of resultsOut2.edges.reverse()) {
      cursor = element.cursor;
      console.log('Element Data:', JSON.stringify(element.node, null, 2));

      const messagesData = element.node.Messages.filter(e => {
        return e.Tags && e.Tags.length > 0 && e.Tags.some(f => f.name === 'Action' && f.value === 'Broadcasted');
      });
      console.log('Filtered Message Data:', messagesData);

      for (const messagesItem of messagesData) {
        const content = messagesItem.Data || 'No content';
        const nicknameTag = messagesItem.Tags.find(tag => tag.name === 'Nickname');
        const nickname = nicknameTag ? nicknameTag.value : 'Unknown';

        const formattedNickname = `${nickname.substring(0, 5)}***${nickname.substring(nickname.length - 5)}`;

      
        if (nickname === '_TvvXcFb4RWIPUg03g_8jfTjgNyQMpKt6wMcEBEaByE') {
          console.log(`Mesaj gönderilmiyor: ${content} - Nickname: ${nickname}`);
          continue;
        }

        if (!sentMessages.has(content)) {
          const discordMessage = `USER_FROM_AOS, [${formattedNickname}] >>>> ${content}`;
          console.log('Yakalanan Mesaj:', content);
          // Sedn to Discord
          await sendToDiscord(discordMessage);


          sentMessages.add(content);
          // Remove the message from the set after a certain time
          setTimeout(() => {
            sentMessages.delete(content);
          }, MESSAGE_EXPIRATION_TIME);
        }
      }
    }
  } catch (error) {
    console.error('DevChatCheck Error:', error);
  } finally {
    setTimeout(DevChatCheking, 5000);
  }
}

async function sendToDiscord(content) {
  const ws = new WebSocket('ws://localhost:8080');

  ws.on('open', () => {
    ws.send(content);
    console.log(`Mesaj Discord'a gönderildi: ${content}`);
  });

  ws.on('error', (error) => {
    console.error('WebSocket hatasý:', error);
  });

  ws.on('close', () => {
    console.log('WebSocket baðlantýsý kapandý');
  });
}

DevChatCheking();
