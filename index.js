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
            .setTitle('☣️ UMBRELLA CORP | SECTOR G-7')
            .setDescription(
                'This is a quarantine zone.\n\n' +
                '**Protocol:** Do not type here. If your device sent a file here, leave it. The AI will analyze it.\n\n' +
                '**Warning:** Typing in this channel is a violation of Umbrella Security Policy. You will be terminated instantly.'
            )
            .addFields(
                { name: '⬆️ What to do', value: 'Absolutely nothing. Just read.', inline: true },
                { name: '⚠️ Violation', value: 'Instant Permaban. No appeals.', inline: true }
            )
            .setFooter({ text: 'Umbrella Cyber Division' });

        await interaction.reply({ embeds: [embed] });
    }
});

client.login(TOKEN);
