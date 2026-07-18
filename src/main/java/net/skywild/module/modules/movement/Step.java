package net.skywild.module.modules.movement;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
public class Step extends Module {
    private final NumberSetting height = addNumberSetting("Height", 1.0, 0.5, 5.0, 0.5);
    public Step() { super("Step", "Allows you to step up blocks", ModuleCategory.MOVEMENT); }
    @EventTarget public void onUpdate(EventUpdate event) { if (!nullCheck()) mc.player.stepHeight = (float) height.getValue(); }
    @Override public void onDisable() { if (mc.player != null) mc.player.stepHeight = 0.6F; }
}
