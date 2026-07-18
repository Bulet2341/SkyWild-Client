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
