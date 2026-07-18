package net.skywild.module.modules.combat;
import net.minecraft.entity.Entity;
import net.minecraft.entity.EntityLivingBase;
import net.minecraft.entity.monster.EntityMob;
import net.minecraft.entity.passive.EntityAnimal;
import net.minecraft.entity.player.EntityPlayer;
import net.minecraft.util.EnumHand;
import net.skywild.SkyWildClient;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventMotion;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import net.skywild.utils.RotationUtils;
import net.skywild.utils.TimerUtil;
import org.lwjgl.input.Keyboard;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
public class KillAura extends Module {
    private final NumberSetting range = addNumberSetting("Range", 4.0, 1.0, 6.0, 0.1);
    private final NumberSetting aps = addNumberSetting("APS", 12.0, 1.0, 20.0, 0.5);
    private final ModeSetting priority = addModeSetting("Priority", "Distance", "Distance", "Health", "Angle");
    private final ModeSetting rotationMode = addModeSetting("Rotation", "Smooth", "Smooth", "Instant", "None");
    private final NumberSetting smoothness = addNumberSetting("Smoothness", 50.0, 10.0, 100.0, 5.0);
    private final BooleanSetting players = addBooleanSetting("Players", true);
    private final BooleanSetting mobs = addBooleanSetting("Mobs", false);
    private final BooleanSetting animals = addBooleanSetting("Animals", false);
    private final BooleanSetting throughWalls = addBooleanSetting("ThroughWalls", false);
    private EntityLivingBase target;
    private final TimerUtil attackTimer = new TimerUtil();
    public KillAura() { super("KillAura", "Automatically attacks nearby entities", ModuleCategory.COMBAT, Keyboard.KEY_R); }
    @Override public void onDisable() { target = null; }
    @EventTarget public void onMotion(EventMotion event) {
        if (nullCheck()) return;
        target = getTarget();
        if (target == null) { setSuffix(""); return; }
        setSuffix(target.getName());
        if (event.isPre() && !rotationMode.is("None")) {
            float[] rotations = RotationUtils.getRotations(target);
            if (rotationMode.is("Smooth")) {
                float speed = (float) (smoothness.getValue() / 100.0);
                event.setYaw(RotationUtils.smoothRotation(mc.player.rotationYaw, rotations[0], speed));
                event.setPitch(RotationUtils.smoothRotation(mc.player.rotationPitch, rotations[1], speed));
            } else { event.setYaw(rotations[0]); event.setPitch(rotations[1]); }
        }
    }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck() || target == null) return;
        if (attackTimer.hasTimeElapsed((long) (1000.0 / aps.getValue()))) {
            mc.playerController.attackEntity(mc.player, target);
            mc.player.swingArm(EnumHand.MAIN_HAND);
            attackTimer.reset();
        }
    }
    private EntityLivingBase getTarget() {
        List<EntityLivingBase> targets = new ArrayList<>();
        for (Entity entity : mc.world.loadedEntityList) {
            if (entity instanceof EntityLivingBase) {
                EntityLivingBase living = (EntityLivingBase) entity;
                if (living == mc.player || living.isDead || living.getHealth() <= 0) continue;
                if (mc.player.getDistanceToEntity(living) > range.getValue()) continue;
                if (!throughWalls.isEnabled() && !mc.player.canEntityBeSeen(living)) continue;
                if (living instanceof EntityPlayer && (!players.isEnabled() || SkyWildClient.getInstance().getFriendManager().isFriend(living.getName()))) continue;
                if (living instanceof EntityMob && !mobs.isEnabled()) continue;
                if (living instanceof EntityAnimal && !animals.isEnabled()) continue;
                targets.add(living);
            }
        }
        if (targets.isEmpty()) return null;
        switch (priority.getValue()) {
            case "Health": targets.sort(Comparator.comparingDouble(EntityLivingBase::getHealth)); break;
            case "Angle": targets.sort(Comparator.comparingDouble(e -> Math.abs(RotationUtils.getAngleDifference(mc.player.rotationYaw, RotationUtils.getRotations(e)[0])))); break;
            default: targets.sort(Comparator.comparingDouble(e -> mc.player.getDistanceToEntity(e))); break;
        }
        return targets.get(0);
    }
}
