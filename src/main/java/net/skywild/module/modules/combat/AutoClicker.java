package net.skywild.module.modules.combat;
import net.minecraft.util.EnumHand;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.BooleanSetting;
import net.skywild.setting.NumberSetting;
import net.skywild.utils.TimerUtil;
import org.lwjgl.input.Mouse;
import java.util.Random;
public class AutoClicker extends Module {
    private final NumberSetting minCPS = addNumberSetting("Min CPS", 8.0, 1.0, 20.0, 1.0);
    private final NumberSetting maxCPS = addNumberSetting("Max CPS", 12.0, 1.0, 20.0, 1.0);
    private final BooleanSetting leftClick = addBooleanSetting("Left Click", true);
    private final BooleanSetting rightClick = addBooleanSetting("Right Click", false);
    private final TimerUtil timer = new TimerUtil();
    private final Random random = new Random();
    private long nextClickDelay;
    public AutoClicker() { super("AutoClicker", "Automatically clicks for you", ModuleCategory.COMBAT); }
    @Override public void onEnable() { updateDelay(); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        if (timer.hasTimeElapsed(nextClickDelay)) {
            if (leftClick.isEnabled() && Mouse.isButtonDown(0)) {
                if (mc.objectMouseOver != null && mc.objectMouseOver.entityHit != null) { mc.playerController.attackEntity(mc.player, mc.objectMouseOver.entityHit); mc.player.swingArm(EnumHand.MAIN_HAND); }
                else { mc.clickMouse(); }
            }
            if (rightClick.isEnabled() && Mouse.isButtonDown(1)) { mc.rightClickMouse(); }
            updateDelay(); timer.reset();
        }
    }
    private void updateDelay() {
        double min = Math.min(minCPS.getValue(), maxCPS.getValue()), max = Math.max(minCPS.getValue(), maxCPS.getValue());
        nextClickDelay = (long) (1000.0 / (min + random.nextDouble() * (max - min)));
    }
}
