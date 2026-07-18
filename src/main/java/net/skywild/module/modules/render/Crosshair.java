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
