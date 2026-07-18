package net.skywild.command.commands;
import net.skywild.SkyWildClient;
import net.skywild.command.Command;
import net.skywild.module.Module;
import net.skywild.utils.ChatUtils;
import org.lwjgl.input.Keyboard;
public class BindCommand extends Command {
    public BindCommand() { super("bind", "Bind a module to a key", "b"); }
    @Override
    public void execute(String[] args) {
        if (args.length < 2) { ChatUtils.info("Usage: .bind <module> <key>"); return; }
        Module module = SkyWildClient.getInstance().getModuleManager().getModule(args[0]);
        if (module == null) { ChatUtils.error("Module not found: " + args[0]); return; }
        if (args[1].equalsIgnoreCase("none")) { module.setKeyBind(0); ChatUtils.info("Unbound " + module.getName()); return; }
        int keyCode = Keyboard.getKeyIndex(args[1].toUpperCase());
        if (keyCode == 0) { ChatUtils.error("Invalid key: " + args[1]); return; }
        module.setKeyBind(keyCode);
        ChatUtils.info("Bound " + module.getName() + " to " + args[1].toUpperCase());
    }
}
