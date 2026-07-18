package net.skywild.module.modules.render;
import net.minecraft.client.gui.ScaledResolution;
import net.minecraft.client.renderer.GlStateManager;
import net.minecraft.client.renderer.RenderHelper;
import net.minecraft.item.ItemStack;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender2D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.BooleanSetting;
public class ArmorStatus extends Module {
    private final BooleanSetting showDurability = addBooleanSetting("Durability", true);
    public ArmorStatus() { super("ArmorStatus", "Shows armor durability", ModuleCategory.RENDER); }
    @EventTarget public void onRender2D(EventRender2D event) {
        if (nullCheck()) return;
        ScaledResolution sr = event.getScaledResolution(); int startX = sr.getScaledWidth() - 20, startY = sr.getScaledHeight() / 2 - 32;
        GlStateManager.pushMatrix(); RenderHelper.enableGUIStandardItemLighting();
        for (int i = 3; i >= 0; i--) {
            ItemStack stack = mc.player.inventory.armorInventory.get(i);
            if (stack.isEmpty()) continue;
            int yPos = startY + (3 - i) * 18; mc.getRenderItem().renderItemAndEffectIntoGUI(stack, startX, yPos);
            if (showDurability.isEnabled() && stack.getMaxDamage() > 0) {
                int pct = (int)(((stack.getMaxDamage() - stack.getItemDamage()) / (float)stack.getMaxDamage()) * 100);
                int color = pct > 60 ? 0xFF00FF00 : pct > 30 ? 0xFFFFFF00 : 0xFFFF0000;
                mc.fontRenderer.drawStringWithShadow(pct + "%", startX + 18, yPos + 5, color);
            }
        }
        RenderHelper.disableStandardItemLighting(); GlStateManager.popMatrix();
    }
}
