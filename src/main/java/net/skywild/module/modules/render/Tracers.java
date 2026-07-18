package net.skywild.module.modules.render;
import net.minecraft.entity.Entity;
import net.minecraft.entity.player.EntityPlayer;
import net.skywild.SkyWildClient;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender3D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import net.skywild.utils.RenderUtils;
import java.awt.Color;
public class Tracers extends Module {
    private final BooleanSetting players = addBooleanSetting("Players", true);
    private final ColorSetting tracerColor = addColorSetting("Color", new Color(255, 255, 255));
    private final NumberSetting width = addNumberSetting("Width", 1.0, 0.5, 5.0, 0.5);
    public Tracers() { super("Tracers", "Lines to entities", ModuleCategory.RENDER); }
    @EventTarget public void onRender3D(EventRender3D event) {
        if (nullCheck()) return;
        for (Entity entity : mc.world.loadedEntityList) {
            if (entity == mc.player || !(entity instanceof EntityPlayer) || !players.isEnabled()) continue;
            Color color = SkyWildClient.getInstance().getFriendManager().isFriend(entity.getName()) ? Color.GREEN : tracerColor.getColor();
            double x = entity.lastTickPosX + (entity.posX - entity.lastTickPosX) * event.getPartialTicks() - mc.getRenderManager().viewerPosX;
            double y = entity.lastTickPosY + (entity.posY - entity.lastTickPosY) * event.getPartialTicks() - mc.getRenderManager().viewerPosY;
            double z = entity.lastTickPosZ + (entity.posZ - entity.lastTickPosZ) * event.getPartialTicks() - mc.getRenderManager().viewerPosZ;
            RenderUtils.drawTracer(x, y + entity.height / 2, z, color, width.getValueFloat());
        }
    }
}
