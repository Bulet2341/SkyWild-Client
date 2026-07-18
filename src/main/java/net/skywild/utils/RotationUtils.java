package net.skywild.utils;
import net.minecraft.client.Minecraft;
import net.minecraft.entity.EntityLivingBase;
import net.minecraft.util.EnumFacing;
import net.minecraft.util.math.BlockPos;
import net.minecraft.util.math.MathHelper;
import net.minecraft.util.math.Vec3d;
public class RotationUtils {
    private static final Minecraft mc = Minecraft.getMinecraft();
    public static float[] getRotations(EntityLivingBase entity) {
        double diffX = entity.posX + (entity.posX - entity.lastTickPosX) - mc.player.posX;
        double diffY = entity.posY + entity.getEyeHeight() - (mc.player.posY + mc.player.getEyeHeight());
        double diffZ = entity.posZ + (entity.posZ - entity.lastTickPosZ) - mc.player.posZ;
        double dist = Math.sqrt(diffX * diffX + diffZ * diffZ);
        float yaw = (float) (Math.atan2(diffZ, diffX) * 180.0 / Math.PI) - 90.0f;
        float pitch = (float) -(Math.atan2(diffY, dist) * 180.0 / Math.PI);
        return new float[]{yaw, pitch};
    }
    public static float[] getBlockRotations(BlockPos pos, EnumFacing facing) {
        Vec3d eyePos = mc.player.getPositionEyes(1.0f);
        Vec3d target = new Vec3d(pos.getX() + 0.5, pos.getY() + 0.5, pos.getZ() + 0.5).add(new Vec3d(facing.getDirectionVec()).scale(0.5));
        double diffX = target.x - eyePos.x; double diffY = target.y - eyePos.y; double diffZ = target.z - eyePos.z;
        double dist = Math.sqrt(diffX * diffX + diffZ * diffZ);
        float yaw = (float) (Math.atan2(diffZ, diffX) * 180.0 / Math.PI) - 90.0f;
        float pitch = (float) -(Math.atan2(diffY, dist) * 180.0 / Math.PI);
        return new float[]{yaw, pitch};
    }
    public static float smoothRotation(float current, float target, float speed) { return current + getAngleDifference(current, target) * speed; }
    public static float getAngleDifference(float current, float target) { return MathHelper.wrapDegrees(target - current); }
}
