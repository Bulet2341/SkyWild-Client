package net.skywild.command.commands;
import net.skywild.SkyWildClient;
import net.skywild.command.Command;
import net.skywild.friends.FriendManager;
import net.skywild.utils.ChatUtils;
public class FriendCommand extends Command {
    public FriendCommand() { super("friend", "Manage friends", "f"); }
    @Override
    public void execute(String[] args) {
        if (args.length < 1) { ChatUtils.info("Usage: .friend <add/remove/list/clear> [name]"); return; }
        FriendManager fm = SkyWildClient.getInstance().getFriendManager();
        switch (args[0].toLowerCase()) {
            case "add": if (args.length < 2) { ChatUtils.error("Usage: .friend add <name>"); return; } fm.addFriend(args[1]); ChatUtils.info("Added \u00A7a" + args[1] + "\u00A7f"); break;
            case "remove": if (args.length < 2) { ChatUtils.error("Usage: .friend remove <name>"); return; } fm.removeFriend(args[1]); ChatUtils.info("Removed \u00A7c" + args[1] + "\u00A7f"); break;
            case "list": ChatUtils.info("\u00A7b=== Friends ==="); fm.getFriends().forEach(f -> ChatUtils.info("\u00A7a" + f)); if (fm.getFriends().isEmpty()) ChatUtils.info("No friends."); break;
            case "clear": fm.clearFriends(); ChatUtils.info("Friends list cleared."); break;
        }
    }
}
