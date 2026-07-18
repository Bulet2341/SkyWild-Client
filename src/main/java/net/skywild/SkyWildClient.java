package net.skywild;

import net.minecraft.client.Minecraft;
import net.skywild.command.CommandManager;
import net.skywild.config.ConfigManager;
import net.skywild.event.EventManager;
import net.skywild.friends.FriendManager;
import net.skywild.module.ModuleManager;

public class SkyWildClient {

    public static final String CLIENT_NAME = "SkyWild";
    public static final String CLIENT_VERSION = "1.0.0";
    public static final String CLIENT_AUTHOR = "SkyWild Team";
    public static final String COMMAND_PREFIX = ".";

    private static SkyWildClient instance;

    private EventManager eventManager;
    private ModuleManager moduleManager;
    private CommandManager commandManager;
    private ConfigManager configManager;
    private FriendManager friendManager;

    public static SkyWildClient getInstance() {
        if (instance == null) {
            instance = new SkyWildClient();
        }
        return instance;
    }

    public void init() {
        System.out.println("[" + CLIENT_NAME + "] Initializing v" + CLIENT_VERSION);
        this.eventManager = new EventManager();
        this.friendManager = new FriendManager();
        this.moduleManager = new ModuleManager();
        this.commandManager = new CommandManager();
        this.configManager = new ConfigManager();
        this.moduleManager.init();
        this.commandManager.init();
        this.configManager.load();
        System.out.println("[" + CLIENT_NAME + "] Ready! " + moduleManager.getModules().size() + " modules loaded.");
    }

    public void shutdown() {
        System.out.println("[" + CLIENT_NAME + "] Shutting down...");
        this.configManager.save();
    }

    public static Minecraft mc() {
        return Minecraft.getMinecraft();
    }

    public EventManager getEventManager() { return eventManager; }
    public ModuleManager getModuleManager() { return moduleManager; }
    public CommandManager getCommandManager() { return commandManager; }
    public ConfigManager getConfigManager() { return configManager; }
    public FriendManager getFriendManager() { return friendManager; }
}
