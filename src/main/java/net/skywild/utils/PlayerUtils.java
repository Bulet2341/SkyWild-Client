package net.skywild.utils;
import net.minecraft.client.Minecraft;
import net.minecraft.init.MobEffects;
public class PlayerUtils {
    private static final Minecraft mc = Minecraft.getMinecraft();
    public static boolean isMoving() { return mc.player != null && (mc.player.moveForward != 0 || mc.player.moveStrafing != 0); }
    public static void setSpeed(double speed) {
        double yaw = getDirection();
        mc.player.motionX = -Math.sin(yaw) * speed; mc.player.motionZ = Math.cos(yaw) * speed;
    }
    public static double getDirection() {
        float rotationYaw = mc.player.rotationYaw; float forward = mc.player.moveForward; float strafe = mc.player.moveStrafing;
        if (forward < 0) rotationYaw += 180;
        if (forward != 0) { if (strafe > 0) rotationYaw -= 45 * (forward > 0 ? 1 : -1); if (strafe < 0) rotationYaw += 45 * (forward > 0 ? 1 : -1); strafe = 0; }
        if (strafe > 0) rotationYaw -= 90; if (strafe < 0) rotationYaw += 90;
        return Math.toRadians(rotationYaw);
    }
}
