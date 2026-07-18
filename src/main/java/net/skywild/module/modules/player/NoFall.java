package net.skywild.module.modules.player;
import net.minecraft.network.play.client.CPacketPlayer;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.ModeSetting;
public class NoFall extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Packet", "Packet", "MLG");
    public NoFall() { super("NoFall", "Prevents fall damage", ModuleCategory.PLAYER); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck() || mc.player.fallDistance <= 2.5) return;
        if (mode.is("Packet") || mode.is("MLG")) {
            mc.player.connection.sendPacket(new CPacketPlayer(true));
            if (mode.is("MLG")) mc.player.fallDistance = 0;
        }
    }
}
