package net.skywild.utils;
import net.minecraft.client.Minecraft;
import net.minecraft.client.renderer.BufferBuilder;
import net.minecraft.client.renderer.GlStateManager;
import net.minecraft.client.renderer.Tessellator;
import net.minecraft.client.renderer.vertex.DefaultVertexFormats;
import net.minecraft.entity.Entity;
import net.minecraft.util.math.BlockPos;
import org.lwjgl.opengl.GL11;
import java.awt.Color;
public class RenderUtils {
    private static final Minecraft mc = Minecraft.getMinecraft();
    public static void drawEntityBox(Entity entity, double x, double y, double z, Color color, float lineWidth, float partialTicks) {
        GL11.glPushMatrix(); GL11.glBlendFunc(GL11.GL_SRC_ALPHA, GL11.GL_ONE_MINUS_SRC_ALPHA); GL11.glEnable(GL11.GL_BLEND);
        GL11.glDisable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_DEPTH_TEST); GL11.glDepthMask(false); GL11.glLineWidth(lineWidth);
        float halfWidth = entity.width / 2.0f;
        GlStateManager.color(color.getRed() / 255f, color.getGreen() / 255f, color.getBlue() / 255f, 0.3f);
        drawFilledBox(x - halfWidth, y, z - halfWidth, x + halfWidth, y + entity.height, z + halfWidth);
        GlStateManager.color(color.getRed() / 255f, color.getGreen() / 255f, color.getBlue() / 255f, 1.0f);
        drawOutlinedBox(x - halfWidth, y, z - halfWidth, x + halfWidth, y + entity.height, z + halfWidth);
        GL11.glDepthMask(true); GL11.glEnable(GL11.GL_DEPTH_TEST); GL11.glEnable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_BLEND); GL11.glPopMatrix();
    }
    public static void drawEntityOutline(Entity entity, double x, double y, double z, Color color, float lineWidth) {
        GL11.glPushMatrix(); GL11.glBlendFunc(GL11.GL_SRC_ALPHA, GL11.GL_ONE_MINUS_SRC_ALPHA); GL11.glEnable(GL11.GL_BLEND);
        GL11.glDisable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_DEPTH_TEST); GL11.glDepthMask(false); GL11.glLineWidth(lineWidth);
        float halfWidth = entity.width / 2.0f;
        GlStateManager.color(color.getRed() / 255f, color.getGreen() / 255f, color.getBlue() / 255f, 1.0f);
        drawOutlinedBox(x - halfWidth, y, z - halfWidth, x + halfWidth, y + entity.height, z + halfWidth);
        GL11.glDepthMask(true); GL11.glEnable(GL11.GL_DEPTH_TEST); GL11.glEnable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_BLEND); GL11.glPopMatrix();
    }
    public static void drawTracer(double x, double y, double z, Color color, float lineWidth) {
        GL11.glPushMatrix(); GL11.glBlendFunc(GL11.GL_SRC_ALPHA, GL11.GL_ONE_MINUS_SRC_ALPHA); GL11.glEnable(GL11.GL_BLEND);
        GL11.glDisable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_DEPTH_TEST); GL11.glDepthMask(false); GL11.glLineWidth(lineWidth);
        GlStateManager.color(color.getRed() / 255f, color.getGreen() / 255f, color.getBlue() / 255f, color.getAlpha() / 255f);
        GL11.glBegin(GL11.GL_LINES); GL11.glVertex3d(0, mc.player.getEyeHeight(), 0); GL11.glVertex3d(x, y, z); GL11.glEnd();
        GL11.glDepthMask(true); GL11.glEnable(GL11.GL_DEPTH_TEST); GL11.glEnable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_BLEND); GL11.glPopMatrix();
    }
    public static void drawBlockOverlay(BlockPos pos, Color color, float lineWidth) {
        double x = pos.getX() - mc.getRenderManager().viewerPosX; double y = pos.getY() - mc.getRenderManager().viewerPosY; double z = pos.getZ() - mc.getRenderManager().viewerPosZ;
        GL11.glPushMatrix(); GL11.glBlendFunc(GL11.GL_SRC_ALPHA, GL11.GL_ONE_MINUS_SRC_ALPHA); GL11.glEnable(GL11.GL_BLEND);
        GL11.glDisable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_DEPTH_TEST); GL11.glDepthMask(false); GL11.glLineWidth(lineWidth);
        GlStateManager.color(color.getRed() / 255f, color.getGreen() / 255f, color.getBlue() / 255f, 0.3f); drawFilledBox(x, y, z, x + 1, y + 1, z + 1);
        GlStateManager.color(color.getRed() / 255f, color.getGreen() / 255f, color.getBlue() / 255f, 1.0f); drawOutlinedBox(x, y, z, x + 1, y + 1, z + 1);
        GL11.glDepthMask(true); GL11.glEnable(GL11.GL_DEPTH_TEST); GL11.glEnable(GL11.GL_TEXTURE_2D); GL11.glDisable(GL11.GL_BLEND); GL11.glPopMatrix();
    }
    private static void drawFilledBox(double minX, double minY, double minZ, double maxX, double maxY, double maxZ) {
        Tessellator tessellator = Tessellator.getInstance(); BufferBuilder buffer = tessellator.getBuffer();
        buffer.begin(GL11.GL_QUADS, DefaultVertexFormats.POSITION);
        buffer.pos(minX, minY, minZ).endVertex(); buffer.pos(maxX, minY, minZ).endVertex(); buffer.pos(maxX, minY, maxZ).endVertex(); buffer.pos(minX, minY, maxZ).endVertex();
        buffer.pos(minX, maxY, minZ).endVertex(); buffer.pos(minX, maxY, maxZ).endVertex(); buffer.pos(maxX, maxY, maxZ).endVertex(); buffer.pos(maxX, maxY, minZ).endVertex();
        buffer.pos(minX, minY, minZ).endVertex(); buffer.pos(minX, maxY, minZ).endVertex(); buffer.pos(maxX, maxY, minZ).endVertex(); buffer.pos(maxX, minY, minZ).endVertex();
        buffer.pos(minX, minY, maxZ).endVertex(); buffer.pos(maxX, minY, maxZ).endVertex(); buffer.pos(maxX, maxY, maxZ).endVertex(); buffer.pos(minX, maxY, maxZ).endVertex();
        buffer.pos(minX, minY, minZ).endVertex(); buffer.pos(minX, minY, maxZ).endVertex(); buffer.pos(minX, maxY, maxZ).endVertex(); buffer.pos(minX, maxY, minZ).endVertex();
        buffer.pos(maxX, minY, minZ).endVertex(); buffer.pos(maxX, maxY, minZ).endVertex(); buffer.pos(maxX, maxY, maxZ).endVertex(); buffer.pos(maxX, minY, maxZ).endVertex();
        tessellator.draw();
    }
    private static void drawOutlinedBox(double minX, double minY, double minZ, double maxX, double maxY, double maxZ) {
        GL11.glBegin(GL11.GL_LINE_STRIP); GL11.glVertex3d(minX, minY, minZ); GL11.glVertex3d(maxX, minY, minZ); GL11.glVertex3d(maxX, minY, maxZ); GL11.glVertex3d(minX, minY, maxZ); GL11.glVertex3d(minX, minY, minZ); GL11.glEnd();
        GL11.glBegin(GL11.GL_LINE_STRIP); GL11.glVertex3d(minX, maxY, minZ); GL11.glVertex3d(maxX, maxY, minZ); GL11.glVertex3d(maxX, maxY, maxZ); GL11.glVertex3d(minX, maxY, maxZ); GL11.glVertex3d(minX, maxY, minZ); GL11.glEnd();
        GL11.glBegin(GL11.GL_LINES); GL11.glVertex3d(minX, minY, minZ); GL11.glVertex3d(minX, maxY, minZ); GL11.glVertex3d(maxX, minY, minZ); GL11.glVertex3d(maxX, maxY, minZ); GL11.glVertex3d(maxX, minY, maxZ); GL11.glVertex3d(maxX, maxY, maxZ); GL11.glVertex3d(minX, minY, maxZ); GL11.glVertex3d(minX, maxY, maxZ); GL11.glEnd();
    }
}
