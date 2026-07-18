package net.skywild.command.commands;
import net.skywild.SkyWildClient;
import net.skywild.command.Command;
import net.skywild.utils.ChatUtils;
public class HelpCommand extends Command {
    public HelpCommand() { super("help", "Shows all commands", "h", "?"); }
    @Override
    public void execute(String[] args) {
        ChatUtils.info("\u00A7b=== SkyWild Commands ===");
        for (Command cmd : SkyWildClient.getInstance().getCommandManager().getCommands()) {
            ChatUtils.info("\u00A7a." + cmd.getName() + " \u00A77- " + cmd.getDescription());
        }
    }
}
