const { Client, GatewayIntentBits, SlashCommandBuilder, EmbedBuilder } = require('discord.js');

// Reads your secret keys from viirless.net
const TOKEN = process.env.TOKEN;
const TRAP_CHANNEL_ID = process.env.TRAP_CHANNEL_ID;
const GUILD_ID = process.env.GUILD_ID;

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
        GatewayIntentBits.GuildMembers
    ]
});

client.once('ready', async () => {
    console.log(`✅ ${client.user.tag} is online.`);

    try {
        const guild = client.guilds.cache.get(GUILD_ID);
        if (!guild) return console.log('❌ Guild not found!');

        await guild.commands.create(
            new SlashCommandBuilder()
                .setName('graveyard')
                .setDescription('Shows the Umbrella Corp containment protocol.')
        );
        console.log('✅ /graveyard command registered!');
    } catch (error) {
        console.error(error);
    }
});

// --- THE TRAP: Auto-ban anyone who types here ---
client.on('messageCreate', async (message) => {
    if (!message.guild || message.author.bot) return;

    if (message.channel.id === TRAP_CHANNEL_ID) {
        try {
            await message.member.ban({ reason: 'Umbrella Corp: Unauthorized entry.' });
            console.log(`🔨 Banned ${message.author.tag}`);
        } catch (error) {
            console.error(error);
        }
    }
});

// --- THE COMMAND: /graveyard ---
client.on('interactionCreate', async (interaction) => {
    if (!interaction.isCommand()) return;

    if (interaction.commandName === 'graveyard') {
        const embed = new EmbedBuilder()
    .setColor(0x8B0000)
    .setTitle('☣️ SECTOR G-7')
    .setDescription(
        'So you got RAT\'d. Cool.\n\n' +
        'This channel is where your infected files end up. We don\'t care if you\'re a victim or the attacker—both are equally dumb in our book.\n\n' +
        '**Rule:** Don\'t type here. Seriously. We\'re not explaining this twice.\n' +
        '**Consequence:** You type, you\'re gone. No appeals, no modmail, no crying in DMs. We won\'t even read them.\n\n' +
        'Honestly, if you get banned, that\'s a you problem. Take the L and move on.'
    )
    .addFields(
        { name: '⬆️ Your job', value: 'Drop the file. Walk away. Forget this exists.', inline: true },
        { name: '🚫 Our job', value: 'Ban you if you breathe here. Simple.', inline: true }
    )
    .setFooter({ text: 'Umbrella IT • We don\'t get paid enough for this.' });

        await interaction.reply({ embeds: [embed] });
    }
});

client.login(TOKEN);
