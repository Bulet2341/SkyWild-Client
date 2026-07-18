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
