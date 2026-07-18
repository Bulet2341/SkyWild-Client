package net.skywild.module.modules.player;
import net.minecraft.inventory.ClickType;
import net.minecraft.item.*;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
import net.skywild.utils.TimerUtil;
public class AutoArmor extends Module {
    private final NumberSetting delay = addNumberSetting("Delay", 150, 0, 500, 10);
    private final TimerUtil timer = new TimerUtil();
    public AutoArmor() { super("AutoArmor", "Equips best armor", ModuleCategory.PLAYER); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck() || !timer.hasTimeElapsed((long)delay.getValue())) return;
        for (int armorSlot = 0; armorSlot < 4; armorSlot++) {
            ItemStack current = mc.player.inventory.armorInventory.get(armorSlot); int bestProt = current.isEmpty() ? -1 : getProtection(current); int bestSlot = -1;
            for (int i = 9; i < 45; i++) {
                ItemStack stack = mc.player.inventoryContainer.getSlot(i).getStack();
                if (stack.isEmpty() || !(stack.getItem() instanceof ItemArmor)) continue;
                ItemArmor armor = (ItemArmor) stack.getItem(); if (armor.armorType.getIndex() != armorSlot) continue;
                int prot = getProtection(stack); if (prot > bestProt) { bestProt = prot; bestSlot = i; }
            }
            if (bestSlot != -1) {
                if (!current.isEmpty()) mc.playerController.windowClick(0, 8 - armorSlot, 0, ClickType.QUICK_MOVE, mc.player);
                mc.playerController.windowClick(0, bestSlot, 0, ClickType.QUICK_MOVE, mc.player); timer.reset(); return;
            }
        }
    }
    private int getProtection(ItemStack stack) { return (stack.getItem() instanceof ItemArmor) ? ((ItemArmor)stack.getItem()).damageReduceAmount : 0; }
}
