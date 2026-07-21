const { Client, GatewayIntentBits, SlashCommandBuilder, EmbedBuilder } = require('discord.js');

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
                .setName('containment')
                .setDescription('Shows the Umbrella Corp containment protocol.')
        );
        console.log('✅ /containment command registered!');
    } catch (error) {
        console.error(error);
    }
});

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

client.on('interactionCreate', async (interaction) => {
    if (!interaction.isCommand()) return;

    if (interaction.commandName === 'containment') {
        const embed = new EmbedBuilder()
            .setColor(0x8B0000)
            .setTitle('Umbrella Corporation')
            .setDescription(
                'don\'t type in this channel. if you do, you\'re banned. no warnings. no appeals.'
            )
            .setFooter({ text: 'death' });

        await interaction.reply({ embeds: [embed] });
    }
});

client.login(TOKEN);
