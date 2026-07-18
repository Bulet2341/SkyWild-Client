#!/bin/bash
echo "Creating Combat and Movement modules..."

# --- COMBAT MODULES ---
cat > src/main/java/net/skywild/module/modules/combat/KillAura.java << 'EOF'
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
                if (mc.player.getDistance(living) > range.getValue()) continue;
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
            default: targets.sort(Comparator.comparingDouble(e -> mc.player.getDistance(e))); break;
        }
        return targets.get(0);
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/combat/AutoClicker.java << 'EOF'
package net.skywild.module.modules.combat;
import net.minecraft.util.EnumHand;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.BooleanSetting;
import net.skywild.setting.NumberSetting;
import net.skywild.utils.TimerUtil;
import org.lwjgl.input.Mouse;
import java.util.Random;
public class AutoClicker extends Module {
    private final NumberSetting minCPS = addNumberSetting("Min CPS", 8.0, 1.0, 20.0, 1.0);
    private final NumberSetting maxCPS = addNumberSetting("Max CPS", 12.0, 1.0, 20.0, 1.0);
    private final BooleanSetting leftClick = addBooleanSetting("Left Click", true);
    private final BooleanSetting rightClick = addBooleanSetting("Right Click", false);
    private final TimerUtil timer = new TimerUtil();
    private final Random random = new Random();
    private long nextClickDelay;
    public AutoClicker() { super("AutoClicker", "Automatically clicks for you", ModuleCategory.COMBAT); }
    @Override public void onEnable() { updateDelay(); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        if (timer.hasTimeElapsed(nextClickDelay)) {
            if (leftClick.isEnabled() && Mouse.isButtonDown(0)) {
                if (mc.objectMouseOver != null && mc.objectMouseOver.entityHit != null) { mc.playerController.attackEntity(mc.player, mc.objectMouseOver.entityHit); mc.player.swingArm(EnumHand.MAIN_HAND); }
                else { mc.clickMouse(); }
            }
            if (rightClick.isEnabled() && Mouse.isButtonDown(1)) { mc.rightClickMouse(); }
            updateDelay(); timer.reset();
        }
    }
    private void updateDelay() {
        double min = Math.min(minCPS.getValue(), maxCPS.getValue()), max = Math.max(minCPS.getValue(), maxCPS.getValue());
        nextClickDelay = (long) (1000.0 / (min + random.nextDouble() * (max - min)));
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/combat/Velocity.java << 'EOF'
package net.skywild.module.modules.combat;
import net.minecraft.network.play.server.SPacketEntityVelocity;
import net.minecraft.network.play.server.SPacketExplosion;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventPacket;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.ModeSetting;
import net.skywild.setting.NumberSetting;
import org.lwjgl.input.Keyboard;
public class Velocity extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Cancel", "Cancel", "Custom", "Jump", "Reverse");
    private final NumberSetting horizontal = addNumberSetting("Horizontal", 0.0, -100.0, 100.0, 5.0);
    private final NumberSetting vertical = addNumberSetting("Vertical", 0.0, -100.0, 100.0, 5.0);
    public Velocity() { super("Velocity", "Modifies knockback received", ModuleCategory.COMBAT, Keyboard.KEY_V); }
    @EventTarget public void onPacket(EventPacket event) {
        if (nullCheck()) return;
        if (event.getPacket() instanceof SPacketEntityVelocity) {
            SPacketEntityVelocity packet = (SPacketEntityVelocity) event.getPacket();
            if (packet.getEntityID() == mc.player.getEntityId()) {
                switch (mode.getValue()) {
                    case "Cancel": event.setCancelled(true); break;
                    case "Custom": event.setCancelled(true); mc.player.motionX = (packet.getMotionX() / 8000.0) * (horizontal.getValue() / 100.0); mc.player.motionY = (packet.getMotionY() / 8000.0) * (vertical.getValue() / 100.0); mc.player.motionZ = (packet.getMotionZ() / 8000.0) * (horizontal.getValue() / 100.0); break;
                    case "Reverse": event.setCancelled(true); mc.player.motionX = -(packet.getMotionX() / 8000.0) * 0.4; mc.player.motionY = packet.getMotionY() / 8000.0; mc.player.motionZ = -(packet.getMotionZ() / 8000.0) * 0.4; break;
                }
            }
        }
        if (event.getPacket() instanceof SPacketExplosion && mode.is("Cancel")) event.setCancelled(true);
    }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        setSuffix(mode.getValue());
        if (mode.is("Jump") && mc.player.hurtTime > 0 && mc.player.onGround) mc.player.jump();
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/combat/Criticals.java << 'EOF'
package net.skywild.module.modules.combat;
import net.minecraft.network.play.client.CPacketPlayer;
import net.minecraft.network.play.client.CPacketUseEntity;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventPacket;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.ModeSetting;
public class Criticals extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Packet", "Packet", "MiniJump", "FullJump");
    public Criticals() { super("Criticals", "Always land critical hits", ModuleCategory.COMBAT); }
    @EventTarget public void onPacket(EventPacket event) {
        if (nullCheck() || !mc.player.onGround) return;
        if (event.getPacket() instanceof CPacketUseEntity) {
            CPacketUseEntity packet = (CPacketUseEntity) event.getPacket();
            if (packet.getAction() == CPacketUseEntity.Action.ATTACK) {
                switch (mode.getValue()) {
                    case "Packet": mc.player.connection.sendPacket(new CPacketPlayer.Position(mc.player.posX, mc.player.posY + 0.0625, mc.player.posZ, false)); mc.player.connection.sendPacket(new CPacketPlayer.Position(mc.player.posX, mc.player.posY, mc.player.posZ, false)); break;
                    case "MiniJump": mc.player.motionY = 0.1; break;
                    case "FullJump": mc.player.jump(); break;
                }
            }
        }
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/combat/Reach.java << 'EOF'
package net.skywild.module.modules.combat;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
public class Reach extends Module {
    private final NumberSetting distance = addNumberSetting("Distance", 3.5, 3.0, 6.0, 0.1);
    public Reach() { super("Reach", "Extends your attack reach", ModuleCategory.COMBAT); }
    public float getReachDistance() { return distance.getValueFloat(); }
}
EOF

cat > src/main/java/net/skywild/module/modules/combat/WTap.java << 'EOF'
package net.skywild.module.modules.combat;
import net.minecraft.network.play.client.CPacketUseEntity;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventPacket;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
public class WTap extends Module {
    private final NumberSetting chance = addNumberSetting("Chance", 100.0, 0.0, 100.0, 5.0);
    public WTap() { super("WTap", "Automatically W-taps for more knockback", ModuleCategory.COMBAT); }
    @EventTarget public void onPacket(EventPacket event) {
        if (nullCheck()) return;
        if (event.getPacket() instanceof CPacketUseEntity) {
            CPacketUseEntity packet = (CPacketUseEntity) event.getPacket();
            if (packet.getAction() == CPacketUseEntity.Action.ATTACK && Math.random() * 100 < chance.getValue()) { mc.player.setSprinting(false); }
        }
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/combat/AimAssist.java << 'EOF'
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
        List<EntityLivingBase> targets = mc.world.loadedEntityList.stream().filter(e -> e instanceof EntityPlayer && e != mc.player && mc.player.getDistance(e) <= range.getValue() && !((EntityLivingBase) e).isDead && Math.abs(RotationUtils.getAngleDifference(mc.player.rotationYaw, RotationUtils.getRotations((EntityLivingBase) e)[0])) <= fov.getValue() / 2 && !SkyWildClient.getInstance().getFriendManager().isFriend(e.getName())).map(e -> (EntityLivingBase) e).sorted(Comparator.comparingDouble(e -> mc.player.getDistance(e))).collect(Collectors.toList());
        return targets.isEmpty() ? null : targets.get(0);
    }
}
EOF

# --- MOVEMENT MODULES ---
cat > src/main/java/net/skywild/module/modules/movement/Sprint.java << 'EOF'
package net.skywild.module.modules.movement;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.ModeSetting;
import org.lwjgl.input.Keyboard;
public class Sprint extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Legit", "Legit", "Omni");
    public Sprint() { super("Sprint", "Automatically sprints", ModuleCategory.MOVEMENT, Keyboard.KEY_X); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        setSuffix(mode.getValue());
        boolean canSprint = !mc.player.isSneaking() && !mc.player.collidedHorizontally;
        if (mode.is("Legit") && mc.player.moveForward > 0 && canSprint) mc.player.setSprinting(true);
        else if (mode.is("Omni") && (mc.player.moveForward != 0 || mc.player.moveStrafing != 0) && canSprint) mc.player.setSprinting(true);
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/movement/Speed.java << 'EOF'
package net.skywild.module.modules.movement;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventMotion;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.ModeSetting;
import net.skywild.setting.NumberSetting;
import net.skywild.utils.PlayerUtils;
import org.lwjgl.input.Keyboard;
public class Speed extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "BHop", "BHop", "Vanilla", "YPort");
    private final NumberSetting speed = addNumberSetting("Speed", 1.5, 0.5, 5.0, 0.1);
    public Speed() { super("Speed", "Makes you move faster", ModuleCategory.MOVEMENT, Keyboard.KEY_Z); }
    @Override public void onDisable() { mc.timer.timerSpeed = 1.0F; }
    @EventTarget public void onMotion(EventMotion event) {
        if (nullCheck() || !event.isPre() || !PlayerUtils.isMoving()) return;
        setSuffix(mode.getValue());
        switch (mode.getValue()) {
            case "BHop": if (mc.player.onGround) mc.player.jump(); PlayerUtils.setSpeed(speed.getValue() * 0.2873); break;
            case "Vanilla": PlayerUtils.setSpeed(speed.getValue() * 0.2873); break;
            case "YPort": if (mc.player.onGround) { mc.player.motionY = 0.42; PlayerUtils.setSpeed(speed.getValue() * 0.2873); } else { mc.player.motionY = -1; } break;
        }
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/movement/Fly.java << 'EOF'
package net.skywild.module.modules.movement;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.ModeSetting;
import net.skywild.setting.NumberSetting;
import net.skywild.utils.PlayerUtils;
import org.lwjgl.input.Keyboard;
public class Fly extends Module {
    private final ModeSetting mode = addModeSetting("Mode", "Vanilla", "Vanilla", "Creative", "Glide");
    private final NumberSetting flySpeed = addNumberSetting("Speed", 2.0, 0.5, 10.0, 0.5);
    public Fly() { super("Fly", "Allows you to fly", ModuleCategory.MOVEMENT, Keyboard.KEY_F); }
    @Override public void onDisable() { if (mc.player != null) { mc.player.capabilities.isFlying = false; mc.player.capabilities.setFlySpeed(0.05f); if (!mc.player.capabilities.isCreativeMode) mc.player.capabilities.allowFlying = false; } }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        setSuffix(mode.getValue());
        switch (mode.getValue()) {
            case "Vanilla": case "Creative": mc.player.capabilities.allowFlying = true; mc.player.capabilities.isFlying = true; mc.player.capabilities.setFlySpeed((float) (flySpeed.getValue() * 0.05)); break;
            case "Glide": if (!mc.player.onGround) { mc.player.motionY = -0.1; if (PlayerUtils.isMoving()) PlayerUtils.setSpeed(flySpeed.getValue() * 0.2873); } break;
        }
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/movement/NoSlowdown.java << 'EOF'
package net.skywild.module.modules.movement;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.BooleanSetting;
public class NoSlowdown extends Module {
    private final BooleanSetting items = addBooleanSetting("Items", true);
    private final BooleanSetting soulsand = addBooleanSetting("Soulsand", true);
    public NoSlowdown() { super("NoSlowdown", "Prevents being slowed down", ModuleCategory.MOVEMENT); }
    public boolean shouldCancelItems() { return items.isEnabled(); }
    public boolean shouldCancelSoulsand() { return soulsand.isEnabled(); }
}
EOF

cat > src/main/java/net/skywild/module/modules/movement/Step.java << 'EOF'
package net.skywild.module.modules.movement;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
public class Step extends Module {
    private final NumberSetting height = addNumberSetting("Height", 1.0, 0.5, 5.0, 0.5);
    public Step() { super("Step", "Allows you to step up blocks", ModuleCategory.MOVEMENT); }
    @EventTarget public void onUpdate(EventUpdate event) { if (!nullCheck()) mc.player.stepHeight = (float) height.getValue(); }
    @Override public void onDisable() { if (mc.player != null) mc.player.stepHeight = 0.6F; }
}
EOF

cat > src/main/java/net/skywild/module/modules/movement/InventoryMove.java << 'EOF'
package net.skywild.module.modules.movement;
import net.minecraft.client.gui.GuiChat;
import net.minecraft.client.settings.KeyBinding;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import org.lwjgl.input.Keyboard;
public class InventoryMove extends Module {
    public InventoryMove() { super("InventoryMove", "Move while in inventories", ModuleCategory.MOVEMENT); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck() || mc.currentScreen == null || mc.currentScreen instanceof GuiChat) return;
        KeyBinding[] keys = { mc.gameSettings.keyBindForward, mc.gameSettings.keyBindBack, mc.gameSettings.keyBindLeft, mc.gameSettings.keyBindRight, mc.gameSettings.keyBindJump };
        for (KeyBinding key : keys) KeyBinding.setKeyBindState(key.getKeyCode(), Keyboard.isKeyDown(key.getKeyCode()));
    }
}
EOF

cat > src/main/java/net/skywild/module/modules/movement/Eagle.java << 'EOF'
package net.skywild.module.modules.movement;
import net.minecraft.util.math.BlockPos;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.BooleanSetting;
public class Eagle extends Module {
    private final BooleanSetting edgeOnly = addBooleanSetting("Edge Only", true);
    public Eagle() { super("Eagle", "Automatically sneaks at edges", ModuleCategory.MOVEMENT); }
    @EventTarget public void onUpdate(EventUpdate event) {
        if (nullCheck()) return;
        boolean overVoid = mc.world.isAirBlock(new BlockPos(mc.player.posX, mc.player.posY - 1, mc.player.posZ));
        mc.gameSettings.keyBindSneak.pressed = edgeOnly.isEnabled() ? (overVoid && mc.player.onGround) : mc.player.onGround;
    }
    @Override public void onDisable() { if (mc.gameSettings != null) mc.gameSettings.keyBindSneak.pressed = false; }
}
EOF

cat > src/main/java/net/skywild/module/modules/movement/Timer.java << 'EOF'
package net.skywild.module.modules.movement;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventUpdate;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.NumberSetting;
public class Timer extends Module {
    private final NumberSetting speed = addNumberSetting("Speed", 1.5, 0.1, 5.0, 0.1);
    public Timer() { super("Timer", "Changes game speed", ModuleCategory.MOVEMENT); }
    @EventTarget public void onUpdate(EventUpdate event) { if (!nullCheck()) { mc.timer.timerSpeed = speed.getValueFloat(); setSuffix(String.format("%.1f", speed.getValue())); } }
    @Override public void onDisable() { mc.timer.timerSpeed = 1.0F; }
}
EOF

echo "Done!"
