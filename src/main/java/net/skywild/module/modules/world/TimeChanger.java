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
