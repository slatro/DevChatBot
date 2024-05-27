AO Commands List

1. Uploading Chatroom File
This command loads your chatroom Lua file into the AO environment:
.load /root/DevChatBot/chatroom.lua

2. Uploading the Router File
This command loads your router Lua file into the AO environment:
.load /root/DevChatBot/router.lua

3. Uploading the Client File
This command loads your client Lua file into the AO environment:
.load /root/DevChatBot/client.lua

4. Launching and Recording Chatroom
You can use the following command to start your chatroom in the AO environment:

Send({ Target = "QEDxyaRlqdlVYFXcvBst5KbVIPNM6OYnZUVHqW6sjC4", Action = "Register", Name = "slatro" })
ao.send({ Target = "QEDxyaRlqdlVYFXcvBst5KbVIPNM6OYnZUVHqW6sjC4", Action = "Register", Name = "slatro" })

5. Send Message

Send({ Target = "I6c7tto7uXzZROotNxb8F1m86ORv4DeG1PzqXoXfQ4U", Action = "Broadcast", Data = "Your message here" })

6. You can use this command to exit a specific chatroom:

Send({ Target = "zHyIlElN6lyZBp3XnlKL62d3gy7g3TQs1VW_l3GZnqs", Action = "Unregister" })

7. Replaying Messages

Send({ Target = "WkzczA4V4zqagiFBsPhrEmVp01LLLcnOfw9wVsC4pdrA", Action = "Replay", Depth = 10 })  -- Replays the last 10 messages




Discord Commands List

When your bot is online in Discord, you can use the following commands in the Discord channel:

1. Join a Room

!devchat join DevChatRoom JohnDoe

2. Send Message

!devchat say Hello!

3. Leaving the room

!devchat leave

