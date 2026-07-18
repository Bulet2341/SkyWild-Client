package net.skywild.module.modules.combat;
import net.minecraft.network.play.client.CPacketUseEntity;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventPacket;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
public class WTap extends Module {
    private final NumberSetting chance = addNumberSetting("Chance", 100.0, 0.0, 100.0, 5.0);
    public WTap() { super("WTap", "Automatically W-taps for more knockback", ModuleCategory.COMBAT); }
    @EventTarget public void onPacket(EventPacket event) {
        if (nullCheck()) return;
        if (event.getPacket() instanceof CPacketUseEntity) {
            CPacketUseEntity packet = (CPacketUseEntity) event.getPacket();
            if (packet.getAction() == CPacketUseEntity.Action.ATTACK && Math.random() * 100 < chance.getValue()) { mc.player.setSprinting(false); }
        }
    }
}
