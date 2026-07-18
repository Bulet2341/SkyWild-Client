package net.skywild.module.modules.render;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.ModeSetting;
public class Fullbright extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Gamma", "Gamma", "Potion");
    private float previousGamma;
    public Fullbright() { super("Fullbright", "See in the dark", ModuleCategory.RENDER); }
    @Override public void onEnable() { if (mc.gameSettings != null) previousGamma = mc.gameSettings.gammaSetting; }
    @Override public void onDisable() { if (mc.gameSettings != null) mc.gameSettings.gammaSetting = previousGamma; }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        if (mode.is("Gamma")) mc.gameSettings.gammaSetting = 100.0F;
        else if (mode.is("Potion")) mc.player.addPotionEffect(new net.minecraft.potion.PotionEffect(net.minecraft.init.MobEffects.NIGHT_VISION, 999999, 0, false, false));
    }
}
