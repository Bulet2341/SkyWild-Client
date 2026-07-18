package net.skywild.module.modules.movement;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.BooleanSetting;
public class NoSlowdown extends Module {
    private final BooleanSetting items = addBooleanSetting("Items", true);
    private final BooleanSetting soulsand = addBooleanSetting("Soulsand", true);
    public NoSlowdown() { super("NoSlowdown", "Prevents being slowed down", ModuleCategory.MOVEMENT); }
    public boolean shouldCancelItems() { return items.isEnabled(); }
    public boolean shouldCancelSoulsand() { return soulsand.isEnabled(); }
}
