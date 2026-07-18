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
        if (sprint.isEnabled() && mc.player.moveForward > 0 && !mc.player.isSneaking() && !mc.player.isCollidedHorizontally) mc.player.setSprinting(true);
    }
}
