package net.skywild.module.modules.world;
import net.minecraft.client.renderer.GlStateManager;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender3D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import org.lwjgl.opengl.GL11;
import java.awt.Color;
public class ChunkBorders extends Module {
    private final ColorSetting color = addColorSetting("Color", new Color(255, 255, 0, 180));
    private final NumberSetting height = addNumberSetting("Height", 256, 16, 256, 16);
    public ChunkBorders() { super("ChunkBorders", "Shows chunk boundaries", ModuleCategory.WORLD); }
    @EventTarget public void onRender3D(EventRender3D event) {
        if (nullCheck()) return;
        int cx = mc.player.chunkCoordX * 16, cz = mc.player.chunkCoordZ * 16, h = height.getValueInt();
        double rx = mc.getRenderManager().viewerPosX, ry = mc.getRenderManager().viewerPosY, rz = mc.getRenderManager().viewerPosZ;
        Color c = color.getColor();
        GL11.glPushMatrix(); GL11.glTranslated(-rx, -ry, -rz); GL11.glDisable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_DEPTH_TEST); GL11.glLineWidth(1.5f);
        GlStateManager.color(c.getRed()/255f, c.getGreen()/255f, c.getBlue()/255f, c.getAlpha()/255f);
        GL11.glBegin(GL11.GL_LINES);
        for (int i = 0; i <= 16; i++) {
            GL11.glVertex3d(cx+i, 0, cz); GL11.glVertex3d(cx+i, h, cz); GL11.glVertex3d(cx+i, 0, cz+16); GL11.glVertex3d(cx+i, h, cz+16);
            GL11.glVertex3d(cx, 0, cz+i); GL11.glVertex3d(cx, h, cz+i); GL11.glVertex3d(cx+16, 0, cz+i); GL11.glVertex3d(cx+16, h, cz+i);
        }
        GL11.glEnd(); GL11.glEnable(GL11.GL_DEPTH_TEST); GL11.glEnable(GL11.GL_TEXTURE_2D); GL11.glPopMatrix();
    }
}
