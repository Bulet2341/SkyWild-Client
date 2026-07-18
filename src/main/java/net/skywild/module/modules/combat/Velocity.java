package net.skywild.module.modules.combat;
import net.minecraft.network.play.server.SPacketEntityVelocity;
import net.minecraft.network.play.server.SPacketExplosion;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventPacket;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.ModeSetting;
import net.skywild.setting.NumberSetting;
import org.lwjgl.input.Keyboard;
public class Velocity extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Cancel", "Cancel", "Custom", "Jump", "Reverse");
    private final NumberSetting horizontal = addNumberSetting("Horizontal", 0.0, -100.0, 100.0, 5.0);
    private final NumberSetting vertical = addNumberSetting("Vertical", 0.0, -100.0, 100.0, 5.0);
    public Velocity() { super("Velocity", "Modifies knockback received", ModuleCategory.COMBAT, Keyboard.KEY_V); }
    @EventTarget public void onPacket(EventPacket event) {
        if (nullCheck()) return;
        if (event.getPacket() instanceof SPacketEntityVelocity) {
            SPacketEntityVelocity packet = (SPacketEntityVelocity) event.getPacket();
            if (packet.getEntityID() == mc.player.getEntityId()) {
                switch (mode.getValue()) {
                    case "Cancel": event.setCancelled(true); break;
                    case "Custom": event.setCancelled(true); mc.player.motionX = (packet.getMotionX() / 8000.0) * (horizontal.getValue() / 100.0); mc.player.motionY = (packet.getMotionY() / 8000.0) * (vertical.getValue() / 100.0); mc.player.motionZ = (packet.getMotionZ() / 8000.0) * (horizontal.getValue() / 100.0); break;
                    case "Reverse": event.setCancelled(true); mc.player.motionX = -(packet.getMotionX() / 8000.0) * 0.4; mc.player.motionY = packet.getMotionY() / 8000.0; mc.player.motionZ = -(packet.getMotionZ() / 8000.0) * 0.4; break;
                }
            }
        }
        if (event.getPacket() instanceof SPacketExplosion && mode.is("Cancel")) event.setCancelled(true);
    }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        setSuffix(mode.getValue());
        if (mode.is("Jump") && mc.player.hurtTime > 0 && mc.player.onGround) mc.player.jump();
    }
}
