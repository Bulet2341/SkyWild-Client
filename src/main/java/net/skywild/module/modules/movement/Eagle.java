package net.skywild.module.modules.movement;
import net.minecraft.client.settings.KeyBinding;
import net.minecraft.util.math.BlockPos;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.BooleanSetting;
public class Eagle extends Module {
    private final BooleanSetting edgeOnly = addBooleanSetting("Edge Only", true);
    public Eagle() { super("Eagle", "Automatically sneaks at edges", ModuleCategory.MOVEMENT); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        boolean overVoid = mc.world.isAirBlock(new BlockPos(mc.player.posX, mc.player.posY - 1, mc.player.posZ));
        boolean shouldSneak = edgeOnly.isEnabled() ? (overVoid && mc.player.onGround) : mc.player.onGround;
        KeyBinding.setKeyBindState(mc.gameSettings.keyBindSneak.getKeyCode(), shouldSneak);
    }
    @Override public void onDisable() { if (mc.gameSettings != null) KeyBinding.setKeyBindState(mc.gameSettings.keyBindSneak.getKeyCode(), false); }
}
