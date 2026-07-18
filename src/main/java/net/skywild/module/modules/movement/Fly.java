package net.skywild.module.modules.movement;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.ModeSetting;
import net.skywild.setting.NumberSetting;
import net.skywild.utils.PlayerUtils;
import org.lwjgl.input.Keyboard;
public class Fly extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Vanilla", "Vanilla", "Creative", "Glide");
    private final NumberSetting flySpeed = addNumberSetting("Speed", 2.0, 0.5, 10.0, 0.5);
    public Fly() { super("Fly", "Allows you to fly", ModuleCategory.MOVEMENT, Keyboard.KEY_F); }
    @Override public void onDisable() { if (mc.player != null) { mc.player.capabilities.isFlying = false; mc.player.capabilities.setFlySpeed(0.05f); if (!mc.player.capabilities.isCreativeMode) mc.player.capabilities.allowFlying = false; } }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        setSuffix(mode.getValue());
        switch (mode.getValue()) {
            case "Vanilla": case "Creative": mc.player.capabilities.allowFlying = true; mc.player.capabilities.isFlying = true; mc.player.capabilities.setFlySpeed((float) (flySpeed.getValue() * 0.05)); break;
            case "Glide": if (!mc.player.onGround) { mc.player.motionY = -0.1; if (PlayerUtils.isMoving()) PlayerUtils.setSpeed(flySpeed.getValue() * 0.2873); } break;
        }
    }
}
