// DevChat değişkenini tanımlayın
const DevChat = { InitRoom: "I6c7tto7uXzZROotNxb8F1m86ORv4DeG1PzqXoXfQ4U"};

// Discord.js eklentisi bağlantı için gerekiyor
const { Client, GatewayIntentBits } = require('discord.js');
const WebSocket = require('ws');

// Permaweb ve AO kütüphanesine erişim gerekli.
const { message, createDataItemSigner } = require('@permaweb/aoconnect');
const { readFileSync } = require('fs');

const token = 'Your_Discord_Bot_Token';
const channelId = 'Dicord_Channel_ID';

const walletPath = '/root/.aos.json';
const walletContent = JSON.parse(readFileSync(walletPath).toString());

async function relayMessageToDevChat(incomingMsg) {
  const senderName = incomingMsg.author.username;
  const msgContent = incomingMsg.content;

  console.log(`Preparing to relay message from ${senderName} to DevChat`);

  await message({
    process: 'IVsB6cwDL-2CgUxWgMcj-JXOhytSsH9a6poylDutLFU',
    tags: [
      { name: 'Action', value: 'TransferToDevChat' },
      { name: 'Content', value: msgContent },
      { name: 'Sender', value: senderName },
    ],
    signer: createDataItemSigner(walletContent),
    data: msgContent,
  })
  .then(response => {
    console.log('Message successfully relayed to DevChat:', response);
  })
  .catch(error => {
    console.error('Error relaying message to DevChat:', error);
  });
}

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
  ]
});

client.once('ready', () => {
  console.log(`Logged in as ${client.user.tag}!`);
  startWebSocketServer();
});

client.login(token);

function startWebSocketServer() {
  const wss = new WebSocket.Server({ port: 8080 });

  wss.on('connection', ws => {
    console.log('WebSocket connection established');

    ws.on('message', async (message) => {
      const decodedMessage = message.toString();
      console.log('Received message from WebSocket:', decodedMessage);
      const channel = await client.channels.fetch(channelId);
      if (channel) {
        channel.send(decodedMessage)
          .then(() => {
            console.log('Message sent to Discord');
            relayMessageToDevChat({ author: { username: 'AO Terminal' }, content: decodedMessage });
          })
          .catch(console.error);
      } else {
        console.error('Could not find the Discord channel.');
      }
    });

    ws.on('close', () => {
      console.log('WebSocket connection closed');
    });
  });

  console.log('WebSocket server started on port 8080');
}

client.on('messageCreate', message => {
  console.log(`Message from ${message.author.username}: ${message.content}`);
  relayMessageToDevChat(message);
});
