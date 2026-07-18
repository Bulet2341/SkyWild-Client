package net.skywild.module.modules.movement;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventMotion;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.ModeSetting;
import net.skywild.setting.NumberSetting;
import net.skywild.utils.PlayerUtils;
import org.lwjgl.input.Keyboard;
public class Speed extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "BHop", "BHop", "Vanilla", "YPort");
    private final NumberSetting speed = addNumberSetting("Speed", 1.5, 0.5, 5.0, 0.1);
    public Speed() { super("Speed", "Makes you move faster", ModuleCategory.MOVEMENT, Keyboard.KEY_Z); }
    @Override public void onDisable() { mc.timer.timerSpeed = 1.0F; }
    @EventTarget public void onMotion(EventMotion event) {
        if (nullCheck() || !event.isPre() || !PlayerUtils.isMoving()) return;
        setSuffix(mode.getValue());
        switch (mode.getValue()) {
            case "BHop": if (mc.player.onGround) mc.player.jump(); PlayerUtils.setSpeed(speed.getValue() * 0.2873); break;
            case "Vanilla": PlayerUtils.setSpeed(speed.getValue() * 0.2873); break;
            case "YPort": if (mc.player.onGround) { mc.player.motionY = 0.42; PlayerUtils.setSpeed(speed.getValue() * 0.2873); } else { mc.player.motionY = -1; } break;
        }
    }
}
