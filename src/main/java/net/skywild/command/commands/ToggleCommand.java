package net.skywild.command.commands;
import net.skywild.SkyWildClient;
import net.skywild.command.Command;
import net.skywild.module.Module;
import net.skywild.utils.ChatUtils;
public class ToggleCommand extends Command {
    public ToggleCommand() { super("toggle", "Toggle a module", "t"); }
    @Override
    public void execute(String[] args) {
        if (args.length < 1) { ChatUtils.info("Usage: .toggle <module>"); return; }
        Module module = SkyWildClient.getInstance().getModuleManager().getModule(args[0]);
        if (module == null) { ChatUtils.error("Module not found: " + args[0]); return; }
        module.toggle();
        ChatUtils.info(module.getName() + " has been " + (module.isEnabled() ? "\u00A7aenabled" : "\u00A7cdisabled"));
    }
}
