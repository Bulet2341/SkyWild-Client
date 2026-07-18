package net.skywild.module.modules.render;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
public class Animations extends Module {
    private final ModeSetting swingMode = addModeSetting("Swing", "1.7", "1.7", "1.8", "Smooth");
    private final NumberSetting swingSpeed = addNumberSetting("Swing Speed", 1.0, 0.5, 3.0, 0.1);
    private final BooleanSetting oldBlockhit = addBooleanSetting("Old Blockhit", true);
    public Animations() { super("Animations", "Customize animations", ModuleCategory.RENDER); }
    public String getSwingMode() { return swingMode.getValue(); }
    public float getSwingSpeed() { return swingSpeed.getValueFloat(); }
    public boolean isOldBlockhit() { return oldBlockhit.isEnabled(); }
}
