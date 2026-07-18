package net.skywild.module.modules.player;
import net.minecraft.item.ItemBlock;
import net.minecraft.item.ItemStack;
import net.minecraft.util.EnumFacing;
import net.minecraft.util.EnumHand;
import net.minecraft.util.math.BlockPos;
import net.minecraft.util.math.Vec3d;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import org.lwjgl.input.Keyboard;
public class Scaffold extends Module {
    private final BooleanSetting tower = addBooleanSetting("Tower", true);
    private final BooleanSetting autoSwitch = addBooleanSetting("Auto Switch", true);
    public Scaffold() { super("Scaffold", "Places blocks below you", ModuleCategory.PLAYER, Keyboard.KEY_G); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        BlockPos below = new BlockPos(mc.player.posX, mc.player.posY - 1, mc.player.posZ);
        if (!mc.world.getBlockState(below).getMaterial().isReplaceable()) return;
        BlockPos target = null; EnumFacing facing = null;
        for (EnumFacing f : EnumFacing.values()) { BlockPos offset = below.offset(f); if (!mc.world.getBlockState(offset).getMaterial().isReplaceable()) { target = offset; facing = f.getOpposite(); break; } }
        if (target == null || facing == null) return;
        int slot = findBlock(); if (slot == -1) return;
        int old = mc.player.inventory.currentItem; if (autoSwitch.isEnabled()) mc.player.inventory.currentItem = slot;
        Vec3d hit = new Vec3d(target).addVector(0.5, 0.5, 0.5).add(new Vec3d(facing.getDirectionVec()).scale(0.5));
        mc.playerController.processRightClickBlock(mc.player, mc.world, target, facing, hit, EnumHand.MAIN_HAND); mc.player.swingArm(EnumHand.MAIN_HAND);
        if (tower.isEnabled() && mc.gameSettings.keyBindJump.isKeyDown()) mc.player.motionY = 0.42;
        if (autoSwitch.isEnabled()) mc.player.inventory.currentItem = old;
    }
    private int findBlock() {
        for (int i = 0; i < 9; i++) { ItemStack s = mc.player.inventory.getStackInSlot(i); if (!s.isEmpty() && s.getItem() instanceof ItemBlock) return i; } return -1;
    }
}
