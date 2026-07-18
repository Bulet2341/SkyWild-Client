package net.skywild.module.modules.combat;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
public class Reach extends Module {
    private final NumberSetting distance = addNumberSetting("Distance", 3.5, 3.0, 6.0, 0.1);
    public Reach() { super("Reach", "Extends your attack reach", ModuleCategory.COMBAT); }
    public float getReachDistance() { return distance.getValueFloat(); }
}
