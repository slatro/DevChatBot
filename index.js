const { Client, GatewayIntentBits } = require('discord.js');
const { exec } = require('child_process');

// DevChat değişkenini tanımlayın
const DevChat = {
    InitRoom: "I6c7tto7uXzZROotNxb8F1m86ORv4DeG1PzqXoXfQ4U"
};

// Discord istemcisini oluşturun
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
        GatewayIntentBits.GuildPresences,
        GatewayIntentBits.GuildMembers
    ]
});

// Discord bot tokeninizi buraya ekleyin
const token = 'Your_Discord_Token';

client.once('ready', () => {
    console.log('Ready!');
    // Bot başlatıldığında Join fonksiyonunu çağırın
    exec(`lua /root/DevChatBot/client.lua -e "Join('${DevChat.InitRoom}', 'ao')"`, (error) => {
        if (error) {
            console.error(`Error: ${error}`);
        } else {
            console.log('Welcome to DevChat!');
        }
    });
});

client.on('messageCreate', message => {
    // Botun kendisinin gönderdiği mesajları dikkate almayın
    if (message.author.bot) return;

    // Mesajın alındığını doğrulamak için yazdırın
    console.log(`${message.author.username}: ${message.content}`);

    // Kanal ID'sini kontrol edin
    const channelId = 'Your_channel_id'; // Bu kısmı kendi kanal ID'nizle değiştirin
    if (message.channel.id === channelId) {
        const username = message.author.username;
        const text = message.content;

        // Komutları kontrol et
        if (message.content.startsWith('!devchat')) {
            const [command, ...args] = message.content.split(' ').slice(1);
            const argString = args.join(' ');

            // Komutun çalıştırıldığını doğrulamak için yazdırın
            console.log(`Executing command: ${command} with args: ${argString}`);

            switch (command) {
                case 'join':
                    const [room, nickname = 'Anonymous'] = argString.split(' ');
                    message.channel.send(`Joining DevChat room: ${room} with nickname: ${nickname}`);
                    exec(`lua /root/DevChatBot/client.lua -e "Join('${room}', '${nickname}')"`, (error) => {
                        if (error) {
                            message.channel.send(`Error: ${error}`);
                            console.error(`Error: ${error}`);
                        } else {
                            message.channel.send(`Successfully joined room: ${room} with nickname: ${nickname}`);
                            console.log(`Joined room: ${room} with nickname: ${nickname}`);
                        }
                    });
                    break;
                case 'say':
                    const username = message.author.username;
                    const text = args.join(' ');
                    const commandString = `lua /root/DevChatBot/client.lua -e "Say('${text.replace(/'/g, "\\'")}', '${username}')"`;                
                    console.log(`Executing command: ${commandString}`);
                    exec(commandString, (error) => {
                        if (error) {
                            console.error(`Error: ${error}`);
                        } else {
                            const formattedMessage = `${username}: ${text}`;
                            console.log(formattedMessage); // Terminale yazdır
                        }
                    });
                    break;
                case 'leave':
                    message.channel.send('Leaving DevChat room...');
                    exec(`lua /root/DevChatBot/client.lua -e "Leave()"`, (error) => {
                        if (error) {
                            message.channel.send(`Error: ${error}`);
                            console.error(`Error: ${error}`);
                        } else {
                            message.channel.send('Successfully left the room.');
                            console.log('Left the room.');
                        }
                    });
                    break;
                case 'list':
                    message.channel.send('Listing DevChat rooms...');
                    exec(`lua /root/DevChatBot/client.lua -e "List()"`, (error, stdout) => {
                        if (error) {
                            message.channel.send(`Error: ${error}`);
                            console.error(`Error: ${error}`);
                        } else {
                            message.channel.send(`Available rooms: ${stdout}`);
                            console.log(`Rooms listed: ${stdout}`);
                        }
                    });
                    break;
                case 'tip':
                    const [recipient, quantity = 1] = argString.split(' ');
                    message.channel.send(`Sending tip to ${recipient} of ${quantity} tokens...`);
                    exec(`lua /root/DevChatBot/client.lua -e "Tip('${recipient}', '${quantity}')"`, (error) => {
                        if (error) {
                            message.channel.send(`Error: ${error}`);
                            console.error(`Error: ${error}`);
                        } else {
                            message.channel.send(`Tip sent to ${recipient} of ${quantity} tokens.`);
                            console.log(`Tip sent to ${recipient} of ${quantity} tokens.`);
                        }
                    });
                    break;
                case 'replay':
                    const depth = argString || 3;
                    message.channel.send(`Replaying last ${depth} messages...`);
                    exec(`lua /root/DevChatBot/client.lua -e "Replay('${depth}')"`).unref();
                    break;
                default:
                    message.channel.send('Invalid DevChat command.');
                    console.error('Invalid DevChat command.');
            }
        } else {
            // Doğrudan mesajları `Say` komutuyla işleyin
            const commandString = `lua /root/DevChatBot/client.lua -e "Say('${text.replace(/'/g, "\\'")}', '${username}')"`;                
            console.log(`Executing command: ${commandString}`);
            exec(commandString, (error) => {
                if (error) {
                    console.error(`Error: ${error}`);
                } else {
                    const formattedMessage = `${username}: ${text}`;
                    console.log(formattedMessage); // Terminale yazdır
                }
            });
        }

    }
});

// Botunuzu Discord'a bağlayın
client.login(token);
