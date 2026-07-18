package net.skywild.module.modules.render;
import net.minecraft.entity.Entity;
import net.minecraft.entity.EntityLivingBase;
import net.minecraft.entity.player.EntityPlayer;
import net.skywild.SkyWildClient;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender3D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import net.skywild.utils.RenderUtils;
import java.awt.Color;
public class ESP extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Box", "Box", "Outline");
    private final BooleanSetting players = addBooleanSetting("Players", true);
    private final ColorSetting espColor = addColorSetting("Color", new Color(255, 50, 50));
    private final ColorSetting friendColor = addColorSetting("Friend Color", new Color(50, 255, 50));
    private final NumberSetting lineWidth = addNumberSetting("Line Width", 2.0, 0.5, 5.0, 0.5);
    public ESP() { super("ESP", "Highlights entities", ModuleCategory.RENDER); }
    @EventTarget public void onRender3D(EventRender3D event) {
        if (nullCheck()) return;
        for (Entity entity : mc.world.loadedEntityList) {
            if (!(entity instanceof EntityLivingBase) || entity == mc.player || ((EntityLivingBase) entity).isDead) continue;
            if (entity instanceof EntityPlayer && !players.isEnabled()) continue;
            Color color = SkyWildClient.getInstance().getFriendManager().isFriend(entity.getName()) ? friendColor.getColor() : espColor.getColor();
            double x = entity.lastTickPosX + (entity.posX - entity.lastTickPosX) * event.getPartialTicks() - mc.getRenderManager().viewerPosX;
            double y = entity.lastTickPosY + (entity.posY - entity.lastTickPosY) * event.getPartialTicks() - mc.getRenderManager().viewerPosY;
            double z = entity.lastTickPosZ + (entity.posZ - entity.lastTickPosZ) * event.getPartialTicks() - mc.getRenderManager().viewerPosZ;
            if (mode.is("Box")) RenderUtils.drawEntityBox(entity, x, y, z, color, lineWidth.getValueFloat(), event.getPartialTicks());
            else if (mode.is("Outline")) RenderUtils.drawEntityOutline(entity, x, y, z, color, lineWidth.getValueFloat());
        }
    }
}
