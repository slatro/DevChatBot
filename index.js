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
const token = 'YOUR_DISCORD_BOT_TOKEN';

client.once('ready', () => {
    console.log('Ready!');
    // Bot başlatıldığında Join fonksiyonunu çağırın
    exec(`lua /root/DevChatBot/client.lua -e "Join('${DevChat.InitRoom}', 'ao')"`, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error: ${stderr}`);
        } else {
            console.log(`Joined: ${stdout}`);
        }
    });
});

client.on('messageCreate', message => {
    if (message.content.startsWith('!devchat')) {
        const [command, ...args] = message.content.split(' ').slice(1);
        const argString = args.join(' ');

        switch(command) {
            case 'join':
                const [room, nickname = 'Anonymous'] = argString.split(' ');
                message.channel.send(`Joining DevChat room: ${room} with nickname: ${nickname}`);
                exec(`lua /root/DevChatBot/client.lua -e "Join('${room}', '${nickname}')"`, (error, stdout, stderr) => {
                    if (error) {
                        message.channel.send(`Error: ${stderr}`);
                        console.error(`Error: ${stderr}`);
                    } else {
                        message.channel.send(`Successfully joined room: ${room} with nickname: ${nickname}`);
                        console.log(`Joined: ${stdout}`);
                    }
                });
                break;
            case 'say':
                const username = message.author.username;
                const text = args.join(' ');
                const commandString = `lua /root/DevChatBot/client.lua -e "Say('${text.replace(/'/g, "\\'")}', '${username}')"`;                
                exec(commandString, (error, stdout, stderr) => {
                    if (error) {
                        console.error(`Error: ${stderr}`);
                    } else {
                        const formattedMessage = `${username}: ${text}`;
                        console.log(formattedMessage); // Terminale yazdır
                    }
                });
                message.channel.send(`Message from "${username}": ${text}`);
                break;
            case 'leave':
                message.channel.send('Leaving DevChat room...');
                exec(`lua /root/DevChatBot/client.lua -e "Leave()"`, (error, stdout, stderr) => {
                    if (error) {
                        message.channel.send(`Error: ${stderr}`);
                        console.error(`Error: ${stderr}`);
                    } else {
                        message.channel.send('Successfully left the room.');
                        console.log(`Left: ${stdout}`);
                    }
                });
                break;
            case 'list':
                message.channel.send('Listing DevChat rooms...');
                exec(`lua /root/DevChatBot/client.lua -e "List()"`, (error, stdout, stderr) => {
                    if (error) {
                        message.channel.send(`Error: ${stderr}`);
                        console.error(`Error: ${stderr}`);
                    } else {
                        message.channel.send(`Available rooms: ${stdout}`);
                        console.log(`Rooms: ${stdout}`);
                    }
                });
                break;
            case 'tip':
                const [recipient, quantity = 1] = argString.split(' ');
                message.channel.send(`Sending tip to ${recipient} of ${quantity} tokens...`);
                exec(`lua /root/DevChatBot/client.lua -e "Tip('${recipient}', '${quantity}')"`, (error, stdout, stderr) => {
                    if (error) {
                        message.channel.send(`Error: ${stderr}`);
                        console.error(`Error: ${stderr}`);
                    } else {
                        message.channel.send(`Tip sent to ${recipient} of ${quantity} tokens.`);
                        console.log(`Tip sent: ${stdout}`);
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
    }
});

// Botunuzu Discord'a bağlayın
client.login(token);
