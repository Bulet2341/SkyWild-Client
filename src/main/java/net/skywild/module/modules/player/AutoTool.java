package net.skywild.module.modules.player;
import net.minecraft.block.state.IBlockState;
import net.minecraft.item.ItemStack;
import net.minecraft.util.math.RayTraceResult;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
public class AutoTool extends Module {
    public AutoTool() { super("AutoTool", "Auto switches best tool", ModuleCategory.PLAYER); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck() || !mc.gameSettings.keyBindAttack.isKeyDown()) return;
        if (mc.objectMouseOver == null || mc.objectMouseOver.typeOfHit != RayTraceResult.Type.BLOCK) return;
        IBlockState state = mc.world.getBlockState(mc.objectMouseOver.getBlockPos());
        float bestSpeed = 1.0f; int bestSlot = -1;
        for (int i = 0; i < 9; i++) {
            ItemStack stack = mc.player.inventory.getStackInSlot(i);
            if (!stack.isEmpty()) { float speed = stack.getStrVsBlock(state); if (speed > bestSpeed) { bestSpeed = speed; bestSlot = i; } }
        }
        if (bestSlot != -1) mc.player.inventory.currentItem = bestSlot;
    }
}
