package net.skywild.command.commands;
import net.skywild.SkyWildClient;
import net.skywild.command.Command;
import net.skywild.utils.ChatUtils;
public class ConfigCommand extends Command {
    public ConfigCommand() { super("config", "Save/load config", "cfg"); }
    @Override
    public void execute(String[] args) {
        if (args.length < 1) { ChatUtils.info("Usage: .config <save/load>"); return; }
        if (args[0].equalsIgnoreCase("save")) { SkyWildClient.getInstance().getConfigManager().save(); ChatUtils.info("Config saved!"); }
        else if (args[0].equalsIgnoreCase("load")) { SkyWildClient.getInstance().getConfigManager().load(); ChatUtils.info("Config loaded!"); }
        else { ChatUtils.error("Usage: .config <save/load>"); }
    }
}
