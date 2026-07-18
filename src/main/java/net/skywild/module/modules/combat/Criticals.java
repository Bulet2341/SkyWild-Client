package net.skywild.module.modules.combat;
import net.minecraft.network.play.client.CPacketPlayer;
import net.minecraft.network.play.client.CPacketUseEntity;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventPacket;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.ModeSetting;
public class Criticals extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Packet", "Packet", "MiniJump", "FullJump");
    public Criticals() { super("Criticals", "Always land critical hits", ModuleCategory.COMBAT); }
    @EventTarget public void onPacket(EventPacket event) {
        if (nullCheck() || !mc.player.onGround) return;
        if (event.getPacket() instanceof CPacketUseEntity) {
            CPacketUseEntity packet = (CPacketUseEntity) event.getPacket();
            if (packet.getAction() == CPacketUseEntity.Action.ATTACK) {
                switch (mode.getValue()) {
                    case "Packet": mc.player.connection.sendPacket(new CPacketPlayer.Position(mc.player.posX, mc.player.posY + 0.0625, mc.player.posZ, false)); mc.player.connection.sendPacket(new CPacketPlayer.Position(mc.player.posX, mc.player.posY, mc.player.posZ, false)); break;
                    case "MiniJump": mc.player.motionY = 0.1; break;
                    case "FullJump": mc.player.jump(); break;
                }
            }
        }
    }
}
