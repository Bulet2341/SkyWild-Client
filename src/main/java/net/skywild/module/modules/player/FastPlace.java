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
