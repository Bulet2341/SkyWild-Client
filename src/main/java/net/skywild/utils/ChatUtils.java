package net.skywild.utils;
import net.minecraft.client.Minecraft;
import net.minecraft.util.text.TextComponentString;
import net.skywild.SkyWildClient;
public class ChatUtils {
    private static final String PREFIX = "\u00A78[\u00A7b" + SkyWildClient.CLIENT_NAME + "\u00A78] \u00A7r";
    public static void info(String message) { sendMessage(PREFIX + message); }
    public static void error(String message) { sendMessage(PREFIX + "\u00A7c" + message); }
    public static void success(String message) { sendMessage(PREFIX + "\u00A7a" + message); }
    public static void warning(String message) { sendMessage(PREFIX + "\u00A7e" + message); }
    private static void sendMessage(String message) {
        if (Minecraft.getMinecraft().player != null) { Minecraft.getMinecraft().player.sendMessage(new TextComponentString(message)); }
    }
}
