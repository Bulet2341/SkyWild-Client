package net.skywild.module.modules.render;
import net.minecraft.client.gui.Gui;
import net.minecraft.client.renderer.GlStateManager;
import net.minecraft.entity.Entity;
import net.minecraft.entity.player.EntityPlayer;
import net.skywild.SkyWildClient;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender3D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import org.lwjgl.opengl.GL11;
public class Nametags extends Module {
    private final NumberSetting scale = addNumberSetting("Scale", 1.0, 0.5, 3.0, 0.1);
    private final BooleanSetting health = addBooleanSetting("Health", true);
    private final BooleanSetting background = addBooleanSetting("Background", true);
    public Nametags() { super("Nametags", "Better nametags", ModuleCategory.RENDER); }
    @EventTarget public void onRender3D(EventRender3D event) {
        if (nullCheck()) return;
        for (Entity entity : mc.world.loadedEntityList) {
            if (!(entity instanceof EntityPlayer) || entity == mc.player) continue;
            EntityPlayer player = (EntityPlayer) entity;
            double x = player.lastTickPosX + (player.posX - player.lastTickPosX) * event.getPartialTicks() - mc.getRenderManager().viewerPosX;
            double y = player.lastTickPosY + (player.posY - player.lastTickPosY) * event.getPartialTicks() - mc.getRenderManager().viewerPosY + player.height + 0.5;
            double z = player.lastTickPosZ + (player.posZ - player.lastTickPosZ) * event.getPartialTicks() - mc.getRenderManager().viewerPosZ;
            renderNametag(player, x, y, z);
        }
    }
    private void renderNametag(EntityPlayer player, double x, double y, double z) {
        boolean isFriend = SkyWildClient.getInstance().getFriendManager().isFriend(player.getName());
        StringBuilder sb = new StringBuilder();
        if (isFriend) sb.append("\u00A7a"); sb.append(player.getName());
        if (health.isEnabled()) { float hp = player.getHealth(); String c = hp > 15 ? "\u00A7a" : hp > 10 ? "\u00A7e" : hp > 5 ? "\u00A76" : "\u00A7c"; sb.append(" ").append(c).append(String.format("%.1f", hp)).append("\u00A74\u2764"); }
        String text = sb.toString(); float dist = (float) mc.player.getDistanceToEntity(player); float ns = (float)(scale.getValue() * 0.01 * Math.max(dist, 4.0));
        GlStateManager.pushMatrix(); GlStateManager.translate(x, y, z); GlStateManager.rotate(-mc.getRenderManager().playerViewY, 0, 1, 0); GlStateManager.rotate(mc.getRenderManager().playerViewX, 1, 0, 0); GlStateManager.scale(-ns, -ns, ns);
        GlStateManager.disableLighting(); GlStateManager.depthMask(false); GlStateManager.disableDepth(); GlStateManager.enableBlend();
        int tw = mc.fontRenderer.getStringWidth(text);
        if (background.isEnabled()) Gui.drawRect(-tw/2-2, -2, tw/2+2, mc.fontRenderer.FONT_HEIGHT+1, 0x80000000);
        mc.fontRenderer.drawStringWithShadow(text, -tw/2.0f, 0, 0xFFFFFFFF);
        GlStateManager.enableDepth(); GlStateManager.depthMask(true); GlStateManager.enableLighting(); GlStateManager.disableBlend(); GlStateManager.color(1,1,1,1); GlStateManager.popMatrix();
    }
}
