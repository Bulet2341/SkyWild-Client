package net.skywild.module.modules.movement;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.ModeSetting;
import org.lwjgl.input.Keyboard;
public class Sprint extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Legit", "Legit", "Omni");
    public Sprint() { super("Sprint", "Automatically sprints", ModuleCategory.MOVEMENT, Keyboard.KEY_X); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        setSuffix(mode.getValue());
        boolean canSprint = !mc.player.isSneaking() && !mc.player.isCollidedHorizontally;
        if (mode.is("Legit") && mc.player.moveForward > 0 && canSprint) mc.player.setSprinting(true);
        else if (mode.is("Omni") && (mc.player.moveForward != 0 || mc.player.moveStrafing != 0) && canSprint) mc.player.setSprinting(true);
    }
}
