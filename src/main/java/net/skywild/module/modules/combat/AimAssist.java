package net.skywild.module.modules.combat;
import net.minecraft.entity.EntityLivingBase;
import net.minecraft.entity.player.EntityPlayer;
import net.skywild.SkyWildClient;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.BooleanSetting;
import net.skywild.setting.NumberSetting;
import net.skywild.utils.RotationUtils;
import org.lwjgl.input.Mouse;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
public class AimAssist extends Module {
    private final NumberSetting range = addNumberSetting("Range", 4.5, 1.0, 8.0, 0.5);
    private final NumberSetting speed = addNumberSetting("Speed", 45.0, 10.0, 100.0, 5.0);
    private final NumberSetting fov = addNumberSetting("FOV", 90.0, 15.0, 360.0, 5.0);
    private final BooleanSetting verticalAim = addBooleanSetting("Vertical", false);
    private final BooleanSetting clickAim = addBooleanSetting("Click Aim Only", true);
    public AimAssist() { super("AimAssist", "Subtly assists your aim", ModuleCategory.COMBAT); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck() || (clickAim.isEnabled() && !Mouse.isButtonDown(0))) return;
        EntityLivingBase target = getTarget();
        if (target == null) return;
        float[] rotations = RotationUtils.getRotations(target);
        mc.player.rotationYaw += RotationUtils.getAngleDifference(mc.player.rotationYaw, rotations[0]) * (float) (speed.getValue() / 100.0) * 0.5f;
        if (verticalAim.isEnabled()) mc.player.rotationPitch += (rotations[1] - mc.player.rotationPitch) * (float) (speed.getValue() / 100.0) * 0.3f;
    }
    private EntityLivingBase getTarget() {
        List<EntityLivingBase> targets = mc.world.loadedEntityList.stream().filter(e -> e instanceof EntityPlayer && e != mc.player && mc.player.getDistanceToEntity(e) <= range.getValue() && !((EntityLivingBase) e).isDead && Math.abs(RotationUtils.getAngleDifference(mc.player.rotationYaw, RotationUtils.getRotations((EntityLivingBase) e)[0])) <= fov.getValue() / 2 && !SkyWildClient.getInstance().getFriendManager().isFriend(e.getName())).map(e -> (EntityLivingBase) e).sorted(Comparator.comparingDouble(e -> mc.player.getDistanceToEntity(e))).collect(Collectors.toList());
        return targets.isEmpty() ? null : targets.get(0);
    }
}
