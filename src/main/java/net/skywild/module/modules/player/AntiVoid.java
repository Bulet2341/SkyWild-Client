package net.skywild.module.modules.player;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
public class AntiVoid extends Module {
    private final NumberSetting maxFall = addNumberSetting("Max Fall", 10, 5, 50, 1);
    private double lastX, lastY, lastZ;
    public AntiVoid() { super("AntiVoid", "Prevents void fall", ModuleCategory.PLAYER); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        if (mc.player.onGround) { lastX = mc.player.posX; lastY = mc.player.posY; lastZ = mc.player.posZ; }
        if (mc.player.fallDistance > maxFall.getValue() && mc.player.posY < 0) { mc.player.setPosition(lastX, lastY, lastZ); mc.player.motionY = 0; mc.player.fallDistance = 0; }
    }
}
