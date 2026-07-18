#!/bin/bash
echo "Creating Utilities, Commands, Config, and Module Base..."

# --- MODULE BASE ---
cat > src/main/java/net/skywild/module/ModuleCategory.java << 'EOF'
package net.skywild.module;
public enum ModuleCategory {
    COMBAT("Combat", 0xFF4444), MOVEMENT("Movement", 0x44FF44),
    RENDER("Render", 0x4444FF), PLAYER("Player", 0xFFFF44), WORLD("World", 0xFF44FF);
    private final String name; private final int color;
    ModuleCategory(String name, int color) { this.name = name; this.color = color; }
    public String getName() { return name; } public int getColor() { return color; }
}
EOF

cat > src/main/java/net/skywild/module/Module.java << 'EOF'
package net.skywild.module;
import net.minecraft.client.Minecraft;
import net.skywild.SkyWildClient;
import net.skywild.setting.*;
import java.util.ArrayList;
import java.util.List;
public abstract class Module {
    protected static final Minecraft mc = Minecraft.getMinecraft();
    private String name, description; private ModuleCategory category; private int keyBind;
    private boolean enabled, visible = true; private String suffix = "";
    private final List<Setting> settings = new ArrayList<>();
    public Module(String name, String description, ModuleCategory category, int keyBind) {
        this.name = name; this.description = description; this.category = category; this.keyBind = keyBind;
    }
    public Module(String name, String description, ModuleCategory category) { this(name, description, category, 0); }
    public void toggle() { setEnabled(!enabled); }
    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
        if (enabled) { onEnable(); SkyWildClient.getInstance().getEventManager().register(this); }
        else { SkyWildClient.getInstance().getEventManager().unregister(this); onDisable(); }
    }
    public void onEnable() {} public void onDisable() {}
    protected BooleanSetting addBooleanSetting(String name, boolean defaultValue) { BooleanSetting setting = new BooleanSetting(name, defaultValue); setting.setParent(this); settings.add(setting); return setting; }
    protected NumberSetting addNumberSetting(String name, double value, double min, double max, double increment) { NumberSetting setting = new NumberSetting(name, value, min, max, increment); setting.setParent(this); settings.add(setting); return setting; }
    protected ModeSetting addModeSetting(String name, String defaultValue, String... modes) { ModeSetting setting = new ModeSetting(name, defaultValue, modes); setting.setParent(this); settings.add(setting); return setting; }
    protected ColorSetting addColorSetting(String name, java.awt.Color defaultColor) { ColorSetting setting = new ColorSetting(name, defaultColor); setting.setParent(this); settings.add(setting); return setting; }
    protected boolean nullCheck() { return mc.player == null || mc.world == null; }
    public String getName() { return name; } public String getDescription() { return description; }
    public ModuleCategory getCategory() { return category; } public int getKeyBind() { return keyBind; }
    public void setKeyBind(int keyBind) { this.keyBind = keyBind; } public boolean isEnabled() { return enabled; }
    public boolean isVisible() { return visible; } public void setVisible(boolean visible) { this.visible = visible; }
    public String getSuffix() { return suffix; } protected void setSuffix(String suffix) { this.suffix = suffix; }
    public List<Setting> getSettings() { return settings; }
    public String getDisplayName() { return suffix.isEmpty() ? name : name + " \u00A77" + suffix; }
}
EOF

# --- UTILS ---
cat > src/main/java/net/skywild/utils/TimerUtil.java << 'EOF'
package net.skywild.utils;
public class TimerUtil {
    private long lastTime;
    public TimerUtil() { this.lastTime = System.currentTimeMillis(); }
    public boolean hasTimeElapsed(long time) { return System.currentTimeMillis() - lastTime >= time; }
    public long getElapsedTime() { return System.currentTimeMillis() - lastTime; }
    public void reset() { this.lastTime = System.currentTimeMillis(); }
}
EOF

cat > src/main/java/net/skywild/utils/ChatUtils.java << 'EOF'
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
EOF

cat > src/main/java/net/skywild/utils/ColorUtils.java << 'EOF'
package net.skywild.utils;
import java.awt.Color;
public class ColorUtils {
    public static int getRainbow(int speed, int offset, float saturation, float brightness) {
        float hue = (System.currentTimeMillis() + offset) % speed; hue /= speed;
        return Color.HSBtoRGB(hue, saturation, brightness);
    }
    public static int getGradient(Color color1, Color color2, int offset) {
        float progress = (float) (Math.sin((System.currentTimeMillis() + offset) / 1000.0) + 1) / 2;
        int r = (int) (color1.getRed() + (color2.getRed() - color1.getRed()) * progress);
        int g = (int) (color1.getGreen() + (color2.getGreen() - color1.getGreen()) * progress);
        int b = (int) (color1.getBlue() + (color2.getBlue() - color1.getBlue()) * progress);
        return new Color(r, g, b).getRGB();
    }
    public static int getAstolfo(int speed, int offset) {
        float hue = (System.currentTimeMillis() + offset) % speed; hue /= speed;
        if (hue > 0.5) { hue = 1 - hue; } hue = 0.5f + hue * 0.25f;
        return Color.HSBtoRGB(hue, 0.5f, 1.0f);
    }
}
EOF

cat > src/main/java/net/skywild/utils/MathUtils.java << 'EOF'
package net.skywild.utils;
import java.util.Random;
public class MathUtils {
    private static final Random random = new Random();
    public static double randomDouble(double min, double max) { return min + random.nextDouble() * (max - min); }
    public static int randomInt(int min, int max) { return min + random.nextInt(max - min + 1); }
    public static float clamp(float value, float min, float max) { return Math.max(min, Math.min(max, value)); }
    public static double clamp(double value, double min, double max) { return Math.max(min, Math.min(max, value)); }
    public static float lerp(float start, float end, float amount) { return start + (end - start) * amount; }
}
EOF

cat > src/main/java/net/skywild/utils/PlayerUtils.java << 'EOF'
package net.skywild.utils;
import net.minecraft.client.Minecraft;
import net.minecraft.init.MobEffects;
public class PlayerUtils {
    private static final Minecraft mc = Minecraft.getMinecraft();
    public static boolean isMoving() { return mc.player != null && (mc.player.moveForward != 0 || mc.player.moveStrafing != 0); }
    public static void setSpeed(double speed) {
        double yaw = getDirection();
        mc.player.motionX = -Math.sin(yaw) * speed; mc.player.motionZ = Math.cos(yaw) * speed;
    }
    public static double getDirection() {
        float rotationYaw = mc.player.rotationYaw; float forward = mc.player.moveForward; float strafe = mc.player.moveStrafing;
        if (forward < 0) rotationYaw += 180;
        if (forward != 0) { if (strafe > 0) rotationYaw -= 45 * (forward > 0 ? 1 : -1); if (strafe < 0) rotationYaw += 45 * (forward > 0 ? 1 : -1); strafe = 0; }
        if (strafe > 0) rotationYaw -= 90; if (strafe < 0) rotationYaw += 90;
        return Math.toRadians(rotationYaw);
    }
}
EOF

cat > src/main/java/net/skywild/utils/RotationUtils.java << 'EOF'
package net.skywild.utils;
import net.minecraft.client.Minecraft;
import net.minecraft.entity.EntityLivingBase;
import net.minecraft.util.EnumFacing;
import net.minecraft.util.math.BlockPos;
import net.minecraft.util.math.MathHelper;
import net.minecraft.util.math.Vec3d;
public class RotationUtils {
    private static final Minecraft mc = Minecraft.getMinecraft();
    public static float[] getRotations(EntityLivingBase entity) {
        double diffX = entity.posX + (entity.posX - entity.lastTickPosX) - mc.player.posX;
        double diffY = entity.posY + entity.getEyeHeight() - (mc.player.posY + mc.player.getEyeHeight());
        double diffZ = entity.posZ + (entity.posZ - entity.lastTickPosZ) - mc.player.posZ;
        double dist = Math.sqrt(diffX * diffX + diffZ * diffZ);
        float yaw = (float) (Math.atan2(diffZ, diffX) * 180.0 / Math.PI) - 90.0f;
        float pitch = (float) -(Math.atan2(diffY, dist) * 180.0 / Math.PI);
        return new float[]{yaw, pitch};
    }
    public static float[] getBlockRotations(BlockPos pos, EnumFacing facing) {
        Vec3d eyePos = mc.player.getPositionEyes(1.0f);
        Vec3d target = new Vec3d(pos.getX() + 0.5, pos.getY() + 0.5, pos.getZ() + 0.5).add(new Vec3d(facing.getDirectionVec()).scale(0.5));
        double diffX = target.x - eyePos.x; double diffY = target.y - eyePos.y; double diffZ = target.z - eyePos.z;
        double dist = Math.sqrt(diffX * diffX + diffZ * diffZ);
        float yaw = (float) (Math.atan2(diffZ, diffX) * 180.0 / Math.PI) - 90.0f;
        float pitch = (float) -(Math.atan2(diffY, dist) * 180.0 / Math.PI);
        return new float[]{yaw, pitch};
    }
    public static float smoothRotation(float current, float target, float speed) { return current + getAngleDifference(current, target) * speed; }
    public static float getAngleDifference(float current, float target) { return MathHelper.wrapDegrees(target - current); }
}
EOF

cat > src/main/java/net/skywild/utils/RenderUtils.java << 'EOF'
package net.skywild.utils;
import net.minecraft.client.Minecraft;
import net.minecraft.client.renderer.BufferBuilder;
import net.minecraft.client.renderer.GlStateManager;
import net.minecraft.client.renderer.Tessellator;
import net.minecraft.client.renderer.vertex.DefaultVertexFormats;
import net.minecraft.entity.Entity;
import net.minecraft.util.math.BlockPos;
import org.lwjgl.opengl.GL11;
import java.awt.Color;
public class RenderUtils {
    private static final Minecraft mc = Minecraft.getMinecraft();
    public static void drawEntityBox(Entity entity, double x, double y, double z, Color color, float lineWidth, float partialTicks) {
        GL11.glPushMatrix(); GL11.glBlendFunc(GL11.GL_SRC_ALPHA, GL11.GL_ONE_MINUS_SRC_ALPHA); GL11.glEnable(GL11.GL_BLEND);
        GL11.glDisable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_DEPTH_TEST); GL11.glDepthMask(false); GL11.glLineWidth(lineWidth);
        float halfWidth = entity.width / 2.0f;
        GlStateManager.color(color.getRed() / 255f, color.getGreen() / 255f, color.getBlue() / 255f, 0.3f);
        drawFilledBox(x - halfWidth, y, z - halfWidth, x + halfWidth, y + entity.height, z + halfWidth);
        GlStateManager.color(color.getRed() / 255f, color.getGreen() / 255f, color.getBlue() / 255f, 1.0f);
        drawOutlinedBox(x - halfWidth, y, z - halfWidth, x + halfWidth, y + entity.height, z + halfWidth);
        GL11.glDepthMask(true); GL11.glEnable(GL11.GL_DEPTH_TEST); GL11.glEnable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_BLEND); GL11.glPopMatrix();
    }
    public static void drawEntityOutline(Entity entity, double x, double y, double z, Color color, float lineWidth) {
        GL11.glPushMatrix(); GL11.glBlendFunc(GL11.GL_SRC_ALPHA, GL11.GL_ONE_MINUS_SRC_ALPHA); GL11.glEnable(GL11.GL_BLEND);
        GL11.glDisable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_DEPTH_TEST); GL11.glDepthMask(false); GL11.glLineWidth(lineWidth);
        float halfWidth = entity.width / 2.0f;
        GlStateManager.color(color.getRed() / 255f, color.getGreen() / 255f, color.getBlue() / 255f, 1.0f);
        drawOutlinedBox(x - halfWidth, y, z - halfWidth, x + halfWidth, y + entity.height, z + halfWidth);
        GL11.glDepthMask(true); GL11.glEnable(GL11.GL_DEPTH_TEST); GL11.glEnable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_BLEND); GL11.glPopMatrix();
    }
    public static void drawTracer(double x, double y, double z, Color color, float lineWidth) {
        GL11.glPushMatrix(); GL11.glBlendFunc(GL11.GL_SRC_ALPHA, GL11.GL_ONE_MINUS_SRC_ALPHA); GL11.glEnable(GL11.GL_BLEND);
        GL11.glDisable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_DEPTH_TEST); GL11.glDepthMask(false); GL11.glLineWidth(lineWidth);
        GlStateManager.color(color.getRed() / 255f, color.getGreen() / 255f, color.getBlue() / 255f, color.getAlpha() / 255f);
        GL11.glBegin(GL11.GL_LINES); GL11.glVertex3d(0, mc.player.getEyeHeight(), 0); GL11.glVertex3d(x, y, z); GL11.glEnd();
        GL11.glDepthMask(true); GL11.glEnable(GL11.GL_DEPTH_TEST); GL11.glEnable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_BLEND); GL11.glPopMatrix();
    }
    public static void drawBlockOverlay(BlockPos pos, Color color, float lineWidth) {
        double x = pos.getX() - mc.getRenderManager().viewerPosX; double y = pos.getY() - mc.getRenderManager().viewerPosY; double z = pos.getZ() - mc.getRenderManager().viewerPosZ;
        GL11.glPushMatrix(); GL11.glBlendFunc(GL11.GL_SRC_ALPHA, GL11.GL_ONE_MINUS_SRC_ALPHA); GL11.glEnable(GL11.GL_BLEND);
        GL11.glDisable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_DEPTH_TEST); GL11.glDepthMask(false); GL11.glLineWidth(lineWidth);
        GlStateManager.color(color.getRed() / 255f, color.getGreen() / 255f, color.getBlue() / 255f, 0.3f); drawFilledBox(x, y, z, x + 1, y + 1, z + 1);
        GlStateManager.color(color.getRed() / 255f, color.getGreen() / 255f, color.getBlue() / 255f, 1.0f); drawOutlinedBox(x, y, z, x + 1, y + 1, z + 1);
        GL11.glDepthMask(true); GL11.glEnable(GL11.GL_DEPTH_TEST); GL11.glEnable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_BLEND); GL11.glPopMatrix();
    }
    private static void drawFilledBox(double minX, double minY, double minZ, double maxX, double maxY, double maxZ) {
        Tessellator tessellator = Tessellator.getInstance(); BufferBuilder buffer = tessellator.getBuffer();
        buffer.begin(GL11.GL_QUADS, DefaultVertexFormats.POSITION);
        buffer.pos(minX, minY, minZ).endVertex(); buffer.pos(maxX, minY, minZ).endVertex(); buffer.pos(maxX, minY, maxZ).endVertex(); buffer.pos(minX, minY, maxZ).endVertex();
        buffer.pos(minX, maxY, minZ).endVertex(); buffer.pos(minX, maxY, maxZ).endVertex(); buffer.pos(maxX, maxY, maxZ).endVertex(); buffer.pos(maxX, maxY, minZ).endVertex();
        buffer.pos(minX, minY, minZ).endVertex(); buffer.pos(minX, maxY, minZ).endVertex(); buffer.pos(maxX, maxY, minZ).endVertex(); buffer.pos(maxX, minY, minZ).endVertex();
        buffer.pos(minX, minY, maxZ).endVertex(); buffer.pos(maxX, minY, maxZ).endVertex(); buffer.pos(maxX, maxY, maxZ).endVertex(); buffer.pos(minX, maxY, maxZ).endVertex();
        buffer.pos(minX, minY, minZ).endVertex(); buffer.pos(minX, minY, maxZ).endVertex(); buffer.pos(minX, maxY, maxZ).endVertex(); buffer.pos(minX, maxY, minZ).endVertex();
        buffer.pos(maxX, minY, minZ).endVertex(); buffer.pos(maxX, maxY, minZ).endVertex(); buffer.pos(maxX, maxY, maxZ).endVertex(); buffer.pos(maxX, minY, maxZ).endVertex();
        tessellator.draw();
    }
    private static void drawOutlinedBox(double minX, double minY, double minZ, double maxX, double maxY, double maxZ) {
        GL11.glBegin(GL11.GL_LINE_STRIP); GL11.glVertex3d(minX, minY, minZ); GL11.glVertex3d(maxX, minY, minZ); GL11.glVertex3d(maxX, minY, maxZ); GL11.glVertex3d(minX, minY, maxZ); GL11.glVertex3d(minX, minY, minZ); GL11.glEnd();
        GL11.glBegin(GL11.GL_LINE_STRIP); GL11.glVertex3d(minX, maxY, minZ); GL11.glVertex3d(maxX, maxY, minZ); GL11.glVertex3d(maxX, maxY, maxZ); GL11.glVertex3d(minX, maxY, maxZ); GL11.glVertex3d(minX, maxY, minZ); GL11.glEnd();
        GL11.glBegin(GL11.GL_LINES); GL11.glVertex3d(minX, minY, minZ); GL11.glVertex3d(minX, maxY, minZ); GL11.glVertex3d(maxX, minY, minZ); GL11.glVertex3d(maxX, maxY, minZ); GL11.glVertex3d(maxX, minY, maxZ); GL11.glVertex3d(maxX, maxY, maxZ); GL11.glVertex3d(minX, minY, maxZ); GL11.glVertex3d(minX, maxY, maxZ); GL11.glEnd();
    }
}
EOF

# --- FRIENDS ---
cat > src/main/java/net/skywild/friends/FriendManager.java << 'EOF'
package net.skywild.friends;
import java.util.ArrayList;
import java.util.List;
public class FriendManager {
    private final List<String> friends = new ArrayList<>();
    public void addFriend(String name) { if (!isFriend(name)) friends.add(name); }
    public void removeFriend(String name) { friends.removeIf(f -> f.equalsIgnoreCase(name)); }
    public boolean isFriend(String name) { return friends.stream().anyMatch(f -> f.equalsIgnoreCase(name)); }
    public void clearFriends() { friends.clear(); }
    public List<String> getFriends() { return friends; }
}
EOF

# --- COMMANDS ---
cat > src/main/java/net/skywild/command/Command.java << 'EOF'
package net.skywild.command;
public abstract class Command {
    private final String name; private final String description; private final String[] aliases;
    public Command(String name, String description, String... aliases) { this.name = name; this.description = description; this.aliases = aliases; }
    public abstract void execute(String[] args);
    public String getName() { return name; } public String getDescription() { return description; } public String[] getAliases() { return aliases; }
}
EOF

cat > src/main/java/net/skywild/command/CommandManager.java << 'EOF'
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
EOF

cat > src/main/java/net/skywild/command/commands/BindCommand.java << 'EOF'
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
EOF

cat > src/main/java/net/skywild/command/commands/HelpCommand.java << 'EOF'
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
EOF

cat > src/main/java/net/skywild/command/commands/ToggleCommand.java << 'EOF'
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
EOF

cat > src/main/java/net/skywild/command/commands/ConfigCommand.java << 'EOF'
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
EOF

cat > src/main/java/net/skywild/command/commands/FriendCommand.java << 'EOF'
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
EOF

# --- CONFIG MANAGER ---
cat > src/main/java/net/skywild/config/ConfigManager.java << 'EOF'
package net.skywild.config;
import com.google.gson.*;
import net.skywild.SkyWildClient;
import net.skywild.module.Module;
import net.skywild.setting.*;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
public class ConfigManager {
    private final Path configDir; private final Path configFile;
    public ConfigManager() { configDir = Paths.get("skywild"); configFile = configDir.resolve("config.json"); }
    public void save() {
        try {
            if (!Files.exists(configDir)) { Files.createDirectories(configDir); }
            JsonObject root = new JsonObject(); JsonObject modulesJson = new JsonObject();
            for (Module module : SkyWildClient.getInstance().getModuleManager().getModules()) {
                JsonObject moduleJson = new JsonObject();
                moduleJson.addProperty("enabled", module.isEnabled()); moduleJson.addProperty("keyBind", module.getKeyBind()); moduleJson.addProperty("visible", module.isVisible());
                JsonObject settingsJson = new JsonObject();
                for (Setting setting : module.getSettings()) {
                    if (setting instanceof BooleanSetting) { settingsJson.addProperty(setting.getName(), ((BooleanSetting) setting).isEnabled()); }
                    else if (setting instanceof NumberSetting) { settingsJson.addProperty(setting.getName(), ((NumberSetting) setting).getValue()); }
                    else if (setting instanceof ModeSetting) { settingsJson.addProperty(setting.getName(), ((ModeSetting) setting).getValue()); }
                    else if (setting instanceof ColorSetting) { ColorSetting cs = (ColorSetting) setting; JsonObject colorJson = new JsonObject(); colorJson.addProperty("rgb", cs.getColor().getRGB()); colorJson.addProperty("rainbow", cs.isRainbow()); settingsJson.add(setting.getName(), colorJson); }
                }
                moduleJson.add("settings", settingsJson); modulesJson.add(module.getName(), moduleJson);
            }
            root.add("modules", modulesJson);
            JsonArray friendsJson = new JsonArray(); for (String friend : SkyWildClient.getInstance().getFriendManager().getFriends()) { friendsJson.add(friend); }
            root.add("friends", friendsJson);
            Gson gson = new GsonBuilder().setPrettyPrinting().create(); Files.write(configFile, gson.toJson(root).getBytes());
            System.out.println("[SkyWild] Config saved.");
        } catch (Exception e) { System.err.println("[SkyWild] Failed to save config: " + e.getMessage()); e.printStackTrace(); }
    }
    public void load() {
        try {
            if (!Files.exists(configFile)) return;
            String json = new String(Files.readAllBytes(configFile)); JsonObject root = new JsonParser().parse(json).getAsJsonObject();
            if (root.has("modules")) {
                JsonObject modulesJson = root.getAsJsonObject("modules");
                for (Module module : SkyWildClient.getInstance().getModuleManager().getModules()) {
                    if (!modulesJson.has(module.getName())) continue;
                    JsonObject moduleJson = modulesJson.getAsJsonObject(module.getName());
                    if (moduleJson.has("keyBind")) { module.setKeyBind(moduleJson.get("keyBind").getAsInt()); }
                    if (moduleJson.has("visible")) { module.setVisible(moduleJson.get("visible").getAsBoolean()); }
                    if (moduleJson.has("enabled") && moduleJson.get("enabled").getAsBoolean()) { module.setEnabled(true); }
                    if (moduleJson.has("settings")) {
                        JsonObject settingsJson = moduleJson.getAsJsonObject("settings");
                        for (Setting setting : module.getSettings()) {
                            if (!settingsJson.has(setting.getName())) continue;
                            if (setting instanceof BooleanSetting) { ((BooleanSetting) setting).setEnabled(settingsJson.get(setting.getName()).getAsBoolean()); }
                            else if (setting instanceof NumberSetting) { ((NumberSetting) setting).setValue(settingsJson.get(setting.getName()).getAsDouble()); }
                            else if (setting instanceof ModeSetting) { ((ModeSetting) setting).setValue(settingsJson.get(setting.getName()).getAsString()); }
                            else if (setting instanceof ColorSetting) { JsonObject colorJson = settingsJson.getAsJsonObject(setting.getName()); if (colorJson != null) { ((ColorSetting) setting).setColor(new java.awt.Color(colorJson.get("rgb").getAsInt(), true)); ((ColorSetting) setting).setRainbow(colorJson.get("rainbow").getAsBoolean()); } }
                        }
                    }
                }
            }
            if (root.has("friends")) { JsonArray friendsJson = root.getAsJsonArray("friends"); for (JsonElement element : friendsJson) { SkyWildClient.getInstance().getFriendManager().addFriend(element.getAsString()); } }
            System.out.println("[SkyWild] Config loaded.");
        } catch (Exception e) { System.err.println("[SkyWild] Failed to load config: " + e.getMessage()); e.printStackTrace(); }
    }
}
EOF

echo "Done!"
