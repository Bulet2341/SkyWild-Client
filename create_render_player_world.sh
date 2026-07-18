#!/bin/bash
echo "Creating Render, Player, and World modules..."

# --- RENDER MODULES ---
cat > src/main/java/net/skywild/module/modules/render/HUD.java << 'EOF'
package net.skywild.module.modules.render;
import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.Gui;
import net.minecraft.client.gui.ScaledResolution;
import net.skywild.SkyWildClient;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender2D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import net.skywild.utils.ColorUtils;
import java.awt.Color;
import java.util.List;
public class HUD extends Module {
    private final BooleanSetting watermark = addBooleanSetting("Watermark", true);
    private final BooleanSetting arrayList = addBooleanSetting("ArrayList", true);
    private final BooleanSetting coordinates = addBooleanSetting("Coordinates", true);
    private final BooleanSetting shadow = addBooleanSetting("Text Shadow", true);
    private final ModeSetting colorMode = addModeSetting("Color", "Rainbow", "Rainbow", "Gradient", "Static", "Astolfo");
    private final ColorSetting staticColor = addColorSetting("Static Color", new Color(0, 200, 255));
    private final BooleanSetting background = addBooleanSetting("Background", true);
    public HUD() { super("HUD", "Client HUD", ModuleCategory.RENDER); }
    @EventTarget public void onRender2D(EventRender2D event) {
        if (nullCheck()) return;
        ScaledResolution sr = event.getScaledResolution(); int width = sr.getScaledWidth(); int height = sr.getScaledHeight();
        if (watermark.isEnabled()) {
            String wm = SkyWildClient.CLIENT_NAME + " v" + SkyWildClient.CLIENT_VERSION; int wmC = getColor(0);
            if (background.isEnabled()) { Gui.drawRect(1,1,mc.fontRenderer.getStringWidth(wm)+5,13,0x90000000); Gui.drawRect(1,1,mc.fontRenderer.getStringWidth(wm)+5,2,wmC); }
            if (shadow.isEnabled()) mc.fontRenderer.drawStringWithShadow(wm, 3, 3, wmC); else mc.fontRenderer.drawString(wm, 3, 3, wmC);
        }
        if (arrayList.isEnabled()) {
            List<Module> modules = SkyWildClient.getInstance().getModuleManager().getVisibleModules(); int yOffset = 2;
            for (int i = 0; i < modules.size(); i++) {
                Module mod = modules.get(i); String dn = mod.getDisplayName(); int sw = mc.fontRenderer.getStringWidth(dn); int x = width - sw - 4; int color = getColor(i * 150);
                if (background.isEnabled()) { Gui.drawRect(x-2, yOffset-1, width, yOffset+10, 0x90000000); Gui.drawRect(width-1, yOffset-1, width, yOffset+10, color); }
                if (shadow.isEnabled()) mc.fontRenderer.drawStringWithShadow(dn, x, yOffset, color); else mc.fontRenderer.drawString(dn, x, yOffset, color);
                yOffset += 11;
            }
        }
        if (coordinates.isEnabled()) {
            String coords = String.format("XYZ: %.1f / %.1f / %.1f", mc.player.posX, mc.player.posY, mc.player.posZ);
            if (shadow.isEnabled()) mc.fontRenderer.drawStringWithShadow(coords, 2, height-12, 0xFFFFFFFF); else mc.fontRenderer.drawString(coords, 2, height-12, 0xFFFFFFFF);
        }
        String fpsStr = "FPS: " + Minecraft.getDebugFPS(); int fpsY = coordinates.isEnabled() ? height-24 : height-12;
        if (shadow.isEnabled()) mc.fontRenderer.drawStringWithShadow(fpsStr, 2, fpsY, 0xFFFFFFFF); else mc.fontRenderer.drawString(fpsStr, 2, fpsY, 0xFFFFFFFF);
    }
    private int getColor(int offset) {
        switch (colorMode.getValue()) {
            case "Rainbow": return ColorUtils.getRainbow(3000, offset, 0.8f, 1.0f);
            case "Gradient": return ColorUtils.getGradient(new Color(0,200,255), new Color(200,0,255), offset);
            case "Astolfo": return ColorUtils.getAstolfo(3000, offset);
            case "Static": return staticColor.getRGB();
            default: return 0xFFFFFFFF;
        }
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/render/ESP.java << 'EOF'
package net.skywild.module.modules.render;
import net.minecraft.entity.Entity;
import net.minecraft.entity.EntityLivingBase;
import net.minecraft.entity.player.EntityPlayer;
import net.skywild.SkyWildClient;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender3D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import net.skywild.utils.RenderUtils;
import java.awt.Color;
public class ESP extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Box", "Box", "Outline");
    private final BooleanSetting players = addBooleanSetting("Players", true);
    private final ColorSetting espColor = addColorSetting("Color", new Color(255, 50, 50));
    private final ColorSetting friendColor = addColorSetting("Friend Color", new Color(50, 255, 50));
    private final NumberSetting lineWidth = addNumberSetting("Line Width", 2.0, 0.5, 5.0, 0.5);
    public ESP() { super("ESP", "Highlights entities", ModuleCategory.RENDER); }
    @EventTarget public void onRender3D(EventRender3D event) {
        if (nullCheck()) return;
        for (Entity entity : mc.world.loadedEntityList) {
            if (!(entity instanceof EntityLivingBase) || entity == mc.player || ((EntityLivingBase) entity).isDead) continue;
            if (entity instanceof EntityPlayer && !players.isEnabled()) continue;
            Color color = SkyWildClient.getInstance().getFriendManager().isFriend(entity.getName()) ? friendColor.getColor() : espColor.getColor();
            double x = entity.lastTickPosX + (entity.posX - entity.lastTickPosX) * event.getPartialTicks() - mc.getRenderManager().viewerPosX;
            double y = entity.lastTickPosY + (entity.posY - entity.lastTickPosY) * event.getPartialTicks() - mc.getRenderManager().viewerPosY;
            double z = entity.lastTickPosZ + (entity.posZ - entity.lastTickPosZ) * event.getPartialTicks() - mc.getRenderManager().viewerPosZ;
            if (mode.is("Box")) RenderUtils.drawEntityBox(entity, x, y, z, color, lineWidth.getValueFloat(), event.getPartialTicks());
            else if (mode.is("Outline")) RenderUtils.drawEntityOutline(entity, x, y, z, color, lineWidth.getValueFloat());
        }
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/render/Tracers.java << 'EOF'
package net.skywild.module.modules.render;
import net.minecraft.entity.Entity;
import net.minecraft.entity.player.EntityPlayer;
import net.skywild.SkyWildClient;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender3D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import net.skywild.utils.RenderUtils;
import java.awt.Color;
public class Tracers extends Module {
    private final BooleanSetting players = addBooleanSetting("Players", true);
    private final ColorSetting tracerColor = addColorSetting("Color", new Color(255, 255, 255));
    private final NumberSetting width = addNumberSetting("Width", 1.0, 0.5, 5.0, 0.5);
    public Tracers() { super("Tracers", "Lines to entities", ModuleCategory.RENDER); }
    @EventTarget public void onRender3D(EventRender3D event) {
        if (nullCheck()) return;
        for (Entity entity : mc.world.loadedEntityList) {
            if (entity == mc.player || !(entity instanceof EntityPlayer) || !players.isEnabled()) continue;
            Color color = SkyWildClient.getInstance().getFriendManager().isFriend(entity.getName()) ? Color.GREEN : tracerColor.getColor();
            double x = entity.lastTickPosX + (entity.posX - entity.lastTickPosX) * event.getPartialTicks() - mc.getRenderManager().viewerPosX;
            double y = entity.lastTickPosY + (entity.posY - entity.lastTickPosY) * event.getPartialTicks() - mc.getRenderManager().viewerPosY;
            double z = entity.lastTickPosZ + (entity.posZ - entity.lastTickPosZ) * event.getPartialTicks() - mc.getRenderManager().viewerPosZ;
            RenderUtils.drawTracer(x, y + entity.height / 2, z, color, width.getValueFloat());
        }
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/render/Fullbright.java << 'EOF'
package net.skywild.module.modules.render;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.ModeSetting;
public class Fullbright extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Gamma", "Gamma", "Potion");
    private float previousGamma;
    public Fullbright() { super("Fullbright", "See in the dark", ModuleCategory.RENDER); }
    @Override public void onEnable() { if (mc.gameSettings != null) previousGamma = mc.gameSettings.gammaSetting; }
    @Override public void onDisable() { if (mc.gameSettings != null) mc.gameSettings.gammaSetting = previousGamma; }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        if (mode.is("Gamma")) mc.gameSettings.gammaSetting = 100.0F;
        else if (mode.is("Potion")) mc.player.addPotionEffect(new net.minecraft.potion.PotionEffect(net.minecraft.init.MobEffects.NIGHT_VISION, 999999, 0, false, false));
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/render/BlockOverlay.java << 'EOF'
package net.skywild.module.modules.render;
import net.minecraft.util.math.RayTraceResult;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender3D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import net.skywild.utils.RenderUtils;
import java.awt.Color;
public class BlockOverlay extends Module {
    private final ColorSetting color = addColorSetting("Color", new Color(255, 255, 255, 100));
    private final NumberSetting lineWidth = addNumberSetting("Line Width", 2.0, 0.5, 5.0, 0.5);
    public BlockOverlay() { super("BlockOverlay", "Custom block overlay", ModuleCategory.RENDER); }
    @EventTarget public void onRender3D(EventRender3D event) {
        if (nullCheck() || mc.objectMouseOver == null || mc.objectMouseOver.typeOfHit != RayTraceResult.Type.BLOCK) return;
        RenderUtils.drawBlockOverlay(mc.objectMouseOver.getBlockPos(), color.getColor(), lineWidth.getValueFloat());
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/render/Nametags.java << 'EOF'
package net.skywild.module.modules.render;
import net.minecraft.client.gui.Gui;
import net.minecraft.client.renderer.GlStateManager;
import net.minecraft.entity.Entity;
import net.minecraft.entity.player.EntityPlayer;
import net.skywild.SkyWildClient;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender3D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import org.lwjgl.opengl.GL11;
public class Nametags extends Module {
    private final NumberSetting scale = addNumberSetting("Scale", 1.0, 0.5, 3.0, 0.1);
    private final BooleanSetting health = addBooleanSetting("Health", true);
    private final BooleanSetting background = addBooleanSetting("Background", true);
    public Nametags() { super("Nametags", "Better nametags", ModuleCategory.RENDER); }
    @EventTarget public void onRender3D(EventRender3D event) {
        if (nullCheck()) return;
        for (Entity entity : mc.world.loadedEntityList) {
            if (!(entity instanceof EntityPlayer) || entity == mc.player) continue;
            EntityPlayer player = (EntityPlayer) entity;
            double x = player.lastTickPosX + (player.posX - player.lastTickPosX) * event.getPartialTicks() - mc.getRenderManager().viewerPosX;
            double y = player.lastTickPosY + (player.posY - player.lastTickPosY) * event.getPartialTicks() - mc.getRenderManager().viewerPosY + player.height + 0.5;
            double z = player.lastTickPosZ + (player.posZ - player.lastTickPosZ) * event.getPartialTicks() - mc.getRenderManager().viewerPosZ;
            renderNametag(player, x, y, z);
        }
    }
    private void renderNametag(EntityPlayer player, double x, double y, double z) {
        boolean isFriend = SkyWildClient.getInstance().getFriendManager().isFriend(player.getName());
        StringBuilder sb = new StringBuilder();
        if (isFriend) sb.append("\u00A7a"); sb.append(player.getName());
        if (health.isEnabled()) { float hp = player.getHealth(); String c = hp > 15 ? "\u00A7a" : hp > 10 ? "\u00A7e" : hp > 5 ? "\u00A76" : "\u00A7c"; sb.append(" ").append(c).append(String.format("%.1f", hp)).append("\u00A74\u2764"); }
        String text = sb.toString(); float dist = (float) mc.player.getDistance(player); float ns = (float)(scale.getValue() * 0.01 * Math.max(dist, 4.0));
        GlStateManager.pushMatrix(); GlStateManager.translate(x, y, z); GlStateManager.rotate(-mc.getRenderManager().playerViewY, 0, 1, 0); GlStateManager.rotate(mc.getRenderManager().playerViewX, 1, 0, 0); GlStateManager.scale(-ns, -ns, ns);
        GlStateManager.disableLighting(); GlStateManager.depthMask(false); GlStateManager.disableDepth(); GlStateManager.enableBlend();
        int tw = mc.fontRenderer.getStringWidth(text);
        if (background.isEnabled()) Gui.drawRect(-tw/2-2, -2, tw/2+2, mc.fontRenderer.FONT_HEIGHT+1, 0x80000000);
        mc.fontRenderer.drawStringWithShadow(text, -tw/2.0f, 0, 0xFFFFFFFF);
        GlStateManager.enableDepth(); GlStateManager.depthMask(true); GlStateManager.enableLighting(); GlStateManager.disableBlend(); GlStateManager.color(1,1,1,1); GlStateManager.popMatrix();
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/render/Chams.java << 'EOF'
package net.skywild.module.modules.render;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import java.awt.Color;
public class Chams extends Module {
    private final BooleanSetting colored = addBooleanSetting("Colored", true);
    private final ColorSetting visibleColor = addColorSetting("Visible Color", new Color(50, 255, 50));
    private final ColorSetting hiddenColor = addColorSetting("Hidden Color", new Color(255, 50, 50));
    private final BooleanSetting showHidden = addBooleanSetting("Show Through Walls", true);
    public Chams() { super("Chams", "See entities through walls", ModuleCategory.RENDER); }
    public boolean isColored() { return colored.isEnabled(); }
    public Color getVisibleColor() { return visibleColor.getColor(); }
    public Color getHiddenColor() { return hiddenColor.getColor(); }
    public boolean showThroughWalls() { return showHidden.isEnabled(); }
}
EOF

cat > src/main/java/net/skywild/module/modules/render/Animations.java << 'EOF'
package net.skywild.module.modules.render;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
public class Animations extends Module {
    private final ModeSetting swingMode = addModeSetting("Swing", "1.7", "1.7", "1.8", "Smooth");
    private final NumberSetting swingSpeed = addNumberSetting("Swing Speed", 1.0, 0.5, 3.0, 0.1);
    private final BooleanSetting oldBlockhit = addBooleanSetting("Old Blockhit", true);
    public Animations() { super("Animations", "Customize animations", ModuleCategory.RENDER); }
    public String getSwingMode() { return swingMode.getValue(); }
    public float getSwingSpeed() { return swingSpeed.getValueFloat(); }
    public boolean isOldBlockhit() { return oldBlockhit.isEnabled(); }
}
EOF

cat > src/main/java/net/skywild/module/modules/render/ClickGUI.java << 'EOF'
package net.skywild.module.modules.render;
import net.skywild.gui.clickgui.ClickGUIScreen;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import org.lwjgl.input.Keyboard;
public class ClickGUI extends Module {
    public ClickGUI() { super("ClickGUI", "Opens the click GUI", ModuleCategory.RENDER, Keyboard.KEY_RSHIFT); }
    @Override public void onEnable() { mc.displayGuiScreen(new ClickGUIScreen()); setEnabled(false); }
}
EOF

cat > src/main/java/net/skywild/module/modules/render/CPS.java << 'EOF'
package net.skywild.module.modules.render;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender2D;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
import org.lwjgl.input.Mouse;
import java.util.ArrayList;
import java.util.List;
public class CPS extends Module {
    private final NumberSetting x = addNumberSetting("X", 5, 0, 500, 1);
    private final NumberSetting y = addNumberSetting("Y", 50, 0, 300, 1);
    private final List<Long> leftClicks = new ArrayList<>(), rightClicks = new ArrayList<>();
    private boolean wasLeft, wasRight;
    public CPS() { super("CPS", "Shows CPS", ModuleCategory.RENDER); }
    @EventTarget public void onUpdate(EventUpdate event) {
        boolean lDown = Mouse.isButtonDown(0), rDown = Mouse.isButtonDown(1);
        if (lDown && !wasLeft) leftClicks.add(System.currentTimeMillis());
        if (rDown && !wasRight) rightClicks.add(System.currentTimeMillis());
        wasLeft = lDown; wasRight = rDown; long now = System.currentTimeMillis();
        leftClicks.removeIf(t -> now - t > 1000); rightClicks.removeIf(t -> now - t > 1000);
    }
    @EventTarget public void onRender2D(EventRender2D event) {
        if (nullCheck()) return;
        mc.fontRenderer.drawStringWithShadow(leftClicks.size() + " | " + rightClicks.size() + " CPS", x.getValueFloat(), y.getValueFloat(), 0xFFFFFFFF);
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/render/ArmorStatus.java << 'EOF'
package net.skywild.module.modules.render;
import net.minecraft.client.gui.ScaledResolution;
import net.minecraft.client.renderer.GlStateManager;
import net.minecraft.client.renderer.RenderHelper;
import net.minecraft.item.ItemStack;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender2D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.BooleanSetting;
public class ArmorStatus extends Module {
    private final BooleanSetting showDurability = addBooleanSetting("Durability", true);
    public ArmorStatus() { super("ArmorStatus", "Shows armor durability", ModuleCategory.RENDER); }
    @EventTarget public void onRender2D(EventRender2D event) {
        if (nullCheck()) return;
        ScaledResolution sr = event.getScaledResolution(); int startX = sr.getScaledWidth() - 20, startY = sr.getScaledHeight() / 2 - 32;
        GlStateManager.pushMatrix(); RenderHelper.enableGUIStandardItemLighting();
        for (int i = 3; i >= 0; i--) {
            ItemStack stack = mc.player.inventory.armorInventory.get(i);
            if (stack.isEmpty()) continue;
            int yPos = startY + (3 - i) * 18; mc.getRenderItem().renderItemAndEffectIntoGUI(stack, startX, yPos);
            if (showDurability.isEnabled() && stack.getMaxDamage() > 0) {
                int pct = (int)(((stack.getMaxDamage() - stack.getItemDamage()) / (float)stack.getMaxDamage()) * 100);
                int color = pct > 60 ? 0xFF00FF00 : pct > 30 ? 0xFFFFFF00 : 0xFFFF0000;
                mc.fontRenderer.drawStringWithShadow(pct + "%", startX + 18, yPos + 5, color);
            }
        }
        RenderHelper.disableStandardItemLighting(); GlStateManager.popMatrix();
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/render/Keystrokes.java << 'EOF'
package net.skywild.module.modules.render;
import net.minecraft.client.gui.Gui;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender2D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import org.lwjgl.input.Keyboard;
import org.lwjgl.input.Mouse;
import java.awt.Color;
public class Keystrokes extends Module {
    private final NumberSetting posX = addNumberSetting("X", 5, 0, 500, 1);
    private final NumberSetting posY = addNumberSetting("Y", 100, 0, 500, 1);
    private final ColorSetting activeColor = addColorSetting("Active Color", new Color(255, 255, 255, 180));
    private final ColorSetting inactiveColor = addColorSetting("Inactive Color", new Color(0, 0, 0, 100));
    public Keystrokes() { super("Keystrokes", "Shows pressed keys", ModuleCategory.RENDER); }
    @EventTarget public void onRender2D(EventRender2D event) {
        if (nullCheck()) return;
        int x = posX.getValueInt(), y = posY.getValueInt(), size = 22, gap = 2;
        drawKey("W", x+size+gap, y, size, Keyboard.isKeyDown(mc.gameSettings.keyBindForward.getKeyCode()));
        drawKey("A", x, y+size+gap, size, Keyboard.isKeyDown(mc.gameSettings.keyBindLeft.getKeyCode()));
        drawKey("S", x+size+gap, y+size+gap, size, Keyboard.isKeyDown(mc.gameSettings.keyBindBack.getKeyCode()));
        drawKey("D", x+(size+gap)*2, y+size+gap, size, Keyboard.isKeyDown(mc.gameSettings.keyBindRight.getKeyCode()));
        drawKey("LMB", x, y+(size+gap)*2, size+(size+gap)/2-1, Mouse.isButtonDown(0));
        drawKey("RMB", x+size+gap+(size+gap)/2+1, y+(size+gap)*2, size+(size+gap)/2-1, Mouse.isButtonDown(1));
        drawKey("---", x, y+(size+gap)*3, size*3+gap*2, Keyboard.isKeyDown(mc.gameSettings.keyBindJump.getKeyCode()));
    }
    private void drawKey(String text, int x, int y, int width, boolean pressed) {
        int bg = pressed ? activeColor.getRGB() : inactiveColor.getRGB(); int textColor = pressed ? 0xFF000000 : 0xFFFFFFFF; int h = text.equals("---") ? 14 : 22;
        Gui.drawRect(x, y, x+width, y+h, bg);
        int tx = x + (width - mc.fontRenderer.getStringWidth(text)) / 2; int ty = y + (h - mc.fontRenderer.FONT_HEIGHT) / 2;
        mc.fontRenderer.drawStringWithShadow(text, tx, ty, textColor);
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/render/Crosshair.java << 'EOF'
package net.skywild.module.modules.render;
import net.minecraft.client.gui.Gui;
import net.minecraft.client.gui.ScaledResolution;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender2D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import java.awt.Color;
public class Crosshair extends Module {
    private final ModeSetting style = addModeSetting("Style", "Cross", "Cross", "Dot");
    private final NumberSetting size = addNumberSetting("Size", 5, 1, 20, 1);
    private final NumberSetting gap = addNumberSetting("Gap", 3, 0, 10, 1);
    private final NumberSetting thickness = addNumberSetting("Thickness", 1, 1, 5, 1);
    private final ColorSetting color = addColorSetting("Color", Color.WHITE);
    public Crosshair() { super("Crosshair", "Custom crosshair", ModuleCategory.RENDER); }
    @EventTarget public void onRender2D(EventRender2D event) {
        if (nullCheck()) return;
        ScaledResolution sr = event.getScaledResolution(); int cx = sr.getScaledWidth()/2, cy = sr.getScaledHeight()/2;
        int rgb = color.getRGB(), sz = size.getValueInt(), g = gap.getValueInt(), t = thickness.getValueInt();
        if (style.is("Cross")) {
            Gui.drawRect(cx-t/2, cy-g-sz, cx+t/2+1, cy-g, rgb); Gui.drawRect(cx-t/2, cy+g+1, cx+t/2+1, cy+g+sz+1, rgb);
            Gui.drawRect(cx-g-sz, cy-t/2, cx-g, cy+t/2+1, rgb); Gui.drawRect(cx+g+1, cy-t/2, cx+g+sz+1, cy+t/2+1, rgb);
        } else if (style.is("Dot")) { Gui.drawRect(cx-t, cy-t, cx+t+1, cy+t+1, rgb); }
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/render/FPSDisplay.java << 'EOF'
package net.skywild.module.modules.render;
import net.minecraft.client.Minecraft;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender2D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
public class FPSDisplay extends Module {
    private final NumberSetting x = addNumberSetting("X", 5, 0, 500, 1);
    private final NumberSetting y = addNumberSetting("Y", 30, 0, 300, 1);
    public FPSDisplay() { super("FPS Display", "Shows FPS counter", ModuleCategory.RENDER); }
    @EventTarget public void onRender2D(EventRender2D event) {
        if (nullCheck()) return;
        mc.fontRenderer.drawStringWithShadow("FPS: " + Minecraft.getDebugFPS(), x.getValueFloat(), y.getValueFloat(), 0xFFFFFFFF);
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/render/ToggleSneak.java << 'EOF'
package net.skywild.module.modules.render;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.BooleanSetting;
public class ToggleSneak extends Module {
    private final BooleanSetting sprint = addBooleanSetting("Toggle Sprint", true);
    public ToggleSneak() { super("ToggleSneak", "Toggle sprint/sneak", ModuleCategory.RENDER); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        if (sprint.isEnabled() && mc.player.moveForward > 0 && !mc.player.isSneaking() && !mc.player.collidedHorizontally) mc.player.setSprinting(true);
    }
}
EOF

# --- PLAYER MODULES ---
cat > src/main/java/net/skywild/module/modules/player/NoFall.java << 'EOF'
package net.skywild.module.modules.player;
import net.minecraft.network.play.client.CPacketPlayer;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.ModeSetting;
public class NoFall extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Packet", "Packet", "MLG");
    public NoFall() { super("NoFall", "Prevents fall damage", ModuleCategory.PLAYER); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck() || mc.player.fallDistance <= 2.5) return;
        if (mode.is("Packet") || mode.is("MLG")) {
            mc.player.connection.sendPacket(new CPacketPlayer(true));
            if (mode.is("MLG")) mc.player.fallDistance = 0;
        }
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/player/FastPlace.java << 'EOF'
package net.skywild.module.modules.player;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
public class FastPlace extends Module {
    private final NumberSetting delay = addNumberSetting("Delay", 0, 0, 4, 1);
    public FastPlace() { super("FastPlace", "Removes block placement delay", ModuleCategory.PLAYER); }
    @EventTarget public void onUpdate(EventUpdate event) { if (!nullCheck()) mc.rightClickDelayTimer = delay.getValueInt(); }
    @Override public void onDisable() { mc.rightClickDelayTimer = 4; }
}
EOF

cat > src/main/java/net/skywild/module/modules/player/AntiVoid.java << 'EOF'
package net.skywild.module.modules.player;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
public class AntiVoid extends Module {
    private final NumberSetting maxFall = addNumberSetting("Max Fall", 10, 5, 50, 1);
    private double lastX, lastY, lastZ;
    public AntiVoid() { super("AntiVoid", "Prevents void fall", ModuleCategory.PLAYER); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        if (mc.player.onGround) { lastX = mc.player.posX; lastY = mc.player.posY; lastZ = mc.player.posZ; }
        if (mc.player.fallDistance > maxFall.getValue() && mc.player.posY < 0) { mc.player.setPosition(lastX, lastY, lastZ); mc.player.motionY = 0; mc.player.fallDistance = 0; }
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/player/AutoTool.java << 'EOF'
package net.skywild.module.modules.player;
import net.minecraft.block.state.IBlockState;
import net.minecraft.item.ItemStack;
import net.minecraft.util.math.RayTraceResult;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
public class AutoTool extends Module {
    public AutoTool() { super("AutoTool", "Auto switches best tool", ModuleCategory.PLAYER); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck() || !mc.gameSettings.keyBindAttack.isKeyDown()) return;
        if (mc.objectMouseOver == null || mc.objectMouseOver.typeOfHit != RayTraceResult.Type.BLOCK) return;
        IBlockState state = mc.world.getBlockState(mc.objectMouseOver.getBlockPos());
        float bestSpeed = 1.0f; int bestSlot = -1;
        for (int i = 0; i < 9; i++) {
            ItemStack stack = mc.player.inventory.getStackInSlot(i);
            if (!stack.isEmpty()) { float speed = stack.getDestroySpeed(state); if (speed > bestSpeed) { bestSpeed = speed; bestSlot = i; } }
        }
        if (bestSlot != -1) mc.player.inventory.currentItem = bestSlot;
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/player/ChestStealer.java << 'EOF'
package net.skywild.module.modules.player;
import net.minecraft.client.gui.inventory.GuiChest;
import net.minecraft.inventory.ClickType;
import net.minecraft.inventory.ContainerChest;
import net.minecraft.item.ItemStack;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import net.skywild.utils.TimerUtil;
public class ChestStealer extends Module {
    private final NumberSetting delay = addNumberSetting("Delay", 100, 0, 500, 10);
    private final BooleanSetting autoClose = addBooleanSetting("Auto Close", true);
    private final TimerUtil timer = new TimerUtil();
    public ChestStealer() { super("ChestStealer", "Steals from chests", ModuleCategory.PLAYER); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck() || !(mc.currentScreen instanceof GuiChest)) return;
        ContainerChest chest = (ContainerChest) mc.player.openContainer; int rows = chest.getLowerChestInventory().getSizeInventory(); boolean empty = true;
        for (int i = 0; i < rows; i++) {
            ItemStack stack = chest.getLowerChestInventory().getStackInSlot(i);
            if (!stack.isEmpty()) { empty = false; if (timer.hasTimeElapsed((long)delay.getValue())) { mc.playerController.windowClick(chest.windowId, i, 0, ClickType.QUICK_MOVE, mc.player); timer.reset(); return; } }
        }
        if (empty && autoClose.isEnabled()) mc.player.closeScreen();
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/player/AutoArmor.java << 'EOF'
package net.skywild.module.modules.player;
import net.minecraft.inventory.ClickType;
import net.minecraft.item.*;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
import net.skywild.utils.TimerUtil;
public class AutoArmor extends Module {
    private final NumberSetting delay = addNumberSetting("Delay", 150, 0, 500, 10);
    private final TimerUtil timer = new TimerUtil();
    public AutoArmor() { super("AutoArmor", "Equips best armor", ModuleCategory.PLAYER); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck() || !timer.hasTimeElapsed((long)delay.getValue())) return;
        for (int armorSlot = 0; armorSlot < 4; armorSlot++) {
            ItemStack current = mc.player.inventory.armorInventory.get(armorSlot); int bestProt = current.isEmpty() ? -1 : getProtection(current); int bestSlot = -1;
            for (int i = 9; i < 45; i++) {
                ItemStack stack = mc.player.inventoryContainer.getSlot(i).getStack();
                if (stack.isEmpty() || !(stack.getItem() instanceof ItemArmor)) continue;
                ItemArmor armor = (ItemArmor) stack.getItem(); if (armor.armorType.getIndex() != armorSlot) continue;
                int prot = getProtection(stack); if (prot > bestProt) { bestProt = prot; bestSlot = i; }
            }
            if (bestSlot != -1) {
                if (!current.isEmpty()) mc.playerController.windowClick(0, 8 - armorSlot, 0, ClickType.QUICK_MOVE, mc.player);
                mc.playerController.windowClick(0, bestSlot, 0, ClickType.QUICK_MOVE, mc.player); timer.reset(); return;
            }
        }
    }
    private int getProtection(ItemStack stack) { return (stack.getItem() instanceof ItemArmor) ? ((ItemArmor)stack.getItem()).damageReduceAmount : 0; }
}
EOF

cat > src/main/java/net/skywild/module/modules/player/Scaffold.java << 'EOF'
package net.skywild.module.modules.player;
import net.minecraft.item.ItemBlock;
import net.minecraft.item.ItemStack;
import net.minecraft.util.EnumFacing;
import net.minecraft.util.EnumHand;
import net.minecraft.util.math.BlockPos;
import net.minecraft.util.math.Vec3d;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import org.lwjgl.input.Keyboard;
public class Scaffold extends Module {
    private final BooleanSetting tower = addBooleanSetting("Tower", true);
    private final BooleanSetting autoSwitch = addBooleanSetting("Auto Switch", true);
    public Scaffold() { super("Scaffold", "Places blocks below you", ModuleCategory.PLAYER, Keyboard.KEY_G); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        BlockPos below = new BlockPos(mc.player.posX, mc.player.posY - 1, mc.player.posZ);
        if (!mc.world.getBlockState(below).getMaterial().isReplaceable()) return;
        BlockPos target = null; EnumFacing facing = null;
        for (EnumFacing f : EnumFacing.values()) { BlockPos offset = below.offset(f); if (!mc.world.getBlockState(offset).getMaterial().isReplaceable()) { target = offset; facing = f.getOpposite(); break; } }
        if (target == null || facing == null) return;
        int slot = findBlock(); if (slot == -1) return;
        int old = mc.player.inventory.currentItem; if (autoSwitch.isEnabled()) mc.player.inventory.currentItem = slot;
        Vec3d hit = new Vec3d(target).add(0.5, 0.5, 0.5).add(new Vec3d(facing.getDirectionVec()).scale(0.5));
        mc.playerController.processRightClickBlock(mc.player, mc.world, target, facing, hit, EnumHand.MAIN_HAND); mc.player.swingArm(EnumHand.MAIN_HAND);
        if (tower.isEnabled() && mc.gameSettings.keyBindJump.isKeyDown()) mc.player.motionY = 0.42;
        if (autoSwitch.isEnabled()) mc.player.inventory.currentItem = old;
    }
    private int findBlock() {
        for (int i = 0; i < 9; i++) { ItemStack s = mc.player.inventory.getStackInSlot(i); if (!s.isEmpty() && s.getItem() instanceof ItemBlock) return i; } return -1;
    }
}
EOF

# --- WORLD MODULES ---
cat > src/main/java/net/skywild/module/modules/world/TimeChanger.java << 'EOF'
package net.skywild.module.modules.world;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
public class TimeChanger extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Custom", "Custom", "Day", "Night", "Sunset");
    private final NumberSetting customTime = addNumberSetting("Time", 6000, 0, 24000, 500);
    public TimeChanger() { super("TimeChanger", "Changes world time client-side", ModuleCategory.WORLD); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        long time; switch (mode.getValue()) { case "Day": time = 6000; break; case "Night": time = 18000; break; case "Sunset": time = 12500; break; default: time = customTime.getValueInt(); break; }
        mc.world.setWorldTime(time); setSuffix(mode.getValue());
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/world/ChunkBorders.java << 'EOF'
package net.skywild.module.modules.world;
import net.minecraft.client.renderer.GlStateManager;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender3D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import org.lwjgl.opengl.GL11;
import java.awt.Color;
public class ChunkBorders extends Module {
    private final ColorSetting color = addColorSetting("Color", new Color(255, 255, 0, 180));
    private final NumberSetting height = addNumberSetting("Height", 256, 16, 256, 16);
    public ChunkBorders() { super("ChunkBorders", "Shows chunk boundaries", ModuleCategory.WORLD); }
    @EventTarget public void onRender3D(EventRender3D event) {
        if (nullCheck()) return;
        int cx = mc.player.chunkCoordX * 16, cz = mc.player.chunkCoordZ * 16, h = height.getValueInt();
        double rx = mc.getRenderManager().viewerPosX, ry = mc.getRenderManager().viewerPosY, rz = mc.getRenderManager().viewerPosZ;
        Color c = color.getColor();
        GL11.glPushMatrix(); GL11.glTranslated(-rx, -ry, -rz); GL11.glDisable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_DEPTH_TEST); GL11.glLineWidth(1.5f);
        GlStateManager.color(c.getRed()/255f, c.getGreen()/255f, c.getBlue()/255f, c.getAlpha()/255f);
        GL11.glBegin(GL11.GL_LINES);
        for (int i = 0; i <= 16; i++) {
            GL11.glVertex3d(cx+i, 0, cz); GL11.glVertex3d(cx+i, h, cz); GL11.glVertex3d(cx+i, 0, cz+16); GL11.glVertex3d(cx+i, h, cz+16);
            GL11.glVertex3d(cx, 0, cz+i); GL11.glVertex3d(cx, h, cz+i); GL11.glVertex3d(cx+16, 0, cz+i); GL11.glVertex3d(cx+16, h, cz+i);
        }
        GL11.glEnd(); GL11.glEnable(GL11.GL_DEPTH_TEST); GL11.glEnable(GL11.GL_TEXTURE_2D); GL11.glPopMatrix();
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/world/StorageESP.java << 'EOF'
package net.skywild.module.modules.world;
import net.minecraft.tileentity.*;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender3D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.BooleanSetting;
import net.skywild.utils.RenderUtils;
import java.awt.Color;
public class StorageESP extends Module {
    private final BooleanSetting chests = addBooleanSetting("Chests", true);
    private final BooleanSetting enderChests = addBooleanSetting("Ender Chests", true);
    private final BooleanSetting shulkers = addBooleanSetting("Shulkers", true);
    public StorageESP() { super("StorageESP", "Highlights storage blocks", ModuleCategory.WORLD); }
    @EventTarget public void onRender3D(EventRender3D event) {
        if (nullCheck()) return;
        for (TileEntity te : mc.world.loadedTileEntityList) {
            Color color = null;
            if (te instanceof TileEntityChest && chests.isEnabled()) color = new Color(255, 165, 0, 120);
            else if (te instanceof TileEntityEnderChest && enderChests.isEnabled()) color = new Color(150, 0, 255, 120);
            else if (te instanceof TileEntityShulkerBox && shulkers.isEnabled()) color = new Color(255, 100, 200, 120);
            if (color != null) RenderUtils.drawBlockOverlay(te.getPos(), color, 1.5f);
        }
    }
}
EOF

echo "Done!"
