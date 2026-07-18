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
