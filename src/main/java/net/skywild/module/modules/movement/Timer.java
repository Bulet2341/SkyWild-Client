package net.skywild.module.modules.movement;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
public class Timer extends Module {
    private final NumberSetting speed = addNumberSetting("Speed", 1.5, 0.1, 5.0, 0.1);
    public Timer() { super("Timer", "Changes game speed", ModuleCategory.MOVEMENT); }
    @EventTarget public void onUpdate(EventUpdate event) { if (!nullCheck()) { mc.timer.timerSpeed = speed.getValueFloat(); setSuffix(String.format("%.1f", speed.getValue())); } }
    @Override public void onDisable() { mc.timer.timerSpeed = 1.0F; }
}
