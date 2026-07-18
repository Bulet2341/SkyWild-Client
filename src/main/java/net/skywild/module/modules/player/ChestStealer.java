package net.skywild.module.modules.player;
import net.minecraft.client.gui.inventory.GuiChest;
import net.minecraft.inventory.ClickType;
import net.minecraft.inventory.ContainerChest;
import net.minecraft.item.ItemStack;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import net.skywild.utils.TimerUtil;
public class ChestStealer extends Module {
    private final NumberSetting delay = addNumberSetting("Delay", 100, 0, 500, 10);
    private final BooleanSetting autoClose = addBooleanSetting("Auto Close", true);
    private final TimerUtil timer = new TimerUtil();
    public ChestStealer() { super("ChestStealer", "Steals from chests", ModuleCategory.PLAYER); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck() || !(mc.currentScreen instanceof GuiChest)) return;
        ContainerChest chest = (ContainerChest) mc.player.openContainer; int rows = chest.getLowerChestInventory().getSizeInventory(); boolean empty = true;
        for (int i = 0; i < rows; i++) {
            ItemStack stack = chest.getLowerChestInventory().getStackInSlot(i);
            if (!stack.isEmpty()) { empty = false; if (timer.hasTimeElapsed((long)delay.getValue())) { mc.playerController.windowClick(chest.windowId, i, 0, ClickType.QUICK_MOVE, mc.player); timer.reset(); return; } }
        }
        if (empty && autoClose.isEnabled()) mc.player.closeScreen();
    }
}
