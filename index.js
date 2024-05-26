const { Client, GatewayIntentBits } = require('discord.js');
const { exec } = require('child_process');

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
const token = 'Discord-bot-token';

client.once('ready', () => {
    console.log('Ready!');
});

client.on('messageCreate', message => {
    if (message.content.startsWith('!devchat')) {
        const command = message.content.split(' ')[1];
        const args = message.content.split(' ').slice(2);
        switch(command) {
            case 'join':
                const room = args[0];
                const nickname = args[1] || 'Anonymous';
                message.channel.send(`Joining DevChat room: ${room} with nickname: ${nickname}`);
                exec(`lua /root/DevChatBot/client.lua -e "Join('${room}', '${nickname}')"`, (error, stdout, stderr) => {
                    if (error) {
                        message.channel.send(`Error: ${stderr}`);
                        console.error(`Error: ${stderr}`);
                    } else {
                        message.channel.send(`Joined: ${stdout}`);
                        console.log(`Joined: ${stdout}`);
                    }
                });
                break;
            case 'say':
                const msg = args.join(' ');
                message.channel.send(`Saying in DevChat: ${msg}`);
                exec(`lua /root/DevChatBot/client.lua -e "Say('${msg}')"`, (error, stdout, stderr) => {
                    if (error) {
                        message.channel.send(`Error: ${stderr}`);
                        console.error(`Error: ${stderr}`);
                    } else {
                        message.channel.send(`Message Sent: ${stdout}`);
                        console.log(`Message Sent: ${stdout}`);
                        console.log(`Stdout: ${stdout}`);
                        console.log(`Stderr: ${stderr}`);
                    }
                });
                break;
            case 'leave':
                message.channel.send('Leaving DevChat room...');
                exec(`lua /root/DevChatBot/client.lua -e "Leave()"`, (error, stdout, stderr) => {
                    if (error) {
                        message.channel.send(`Error: ${stderr}`);
                        console.error(`Error: ${stderr}`);
                    } else {
                        message.channel.send(`Left: ${stdout}`);
                        console.log(`Left: ${stdout}`);
                    }
                });
                break;
            default:
                message.channel.send('Invalid DevChat command.');
                console.error('Invalid DevChat command.');
        }
    }
});

// Botunuzu Discord'a bağlayın
client.login(token);
