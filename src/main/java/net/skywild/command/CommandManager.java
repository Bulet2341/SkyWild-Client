package net.skywild.command;
import net.skywild.SkyWildClient;
import net.skywild.command.commands.*;
import net.skywild.utils.ChatUtils;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
public class CommandManager {
    private final List<Command> commands = new ArrayList<>();
    public void init() {
        commands.add(new BindCommand()); commands.add(new HelpCommand()); commands.add(new ToggleCommand());
        commands.add(new ConfigCommand()); commands.add(new FriendCommand());
    }
    public boolean handleChat(String message) {
        if (!message.startsWith(SkyWildClient.COMMAND_PREFIX)) return false;
        String[] parts = message.substring(SkyWildClient.COMMAND_PREFIX.length()).split(" ");
        String commandName = parts[0].toLowerCase();
        String[] args = Arrays.copyOfRange(parts, 1, parts.length);
        for (Command command : commands) {
            if (command.getName().equalsIgnoreCase(commandName) || Arrays.asList(command.getAliases()).contains(commandName)) {
                try { command.execute(args); } catch (Exception e) { ChatUtils.error("Error: " + e.getMessage()); }
                return true;
            }
        }
        ChatUtils.error("Unknown command: " + commandName);
        return true;
    }
    public List<Command> getCommands() { return commands; }
}
