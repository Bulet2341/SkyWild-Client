#!/bin/bash
echo "Applying fixes to SkyWild modules..."

# 1. Fix getDistance to getDistanceToEntity (KillAura, AimAssist, Nametags)
sed -i 's/mc.player.getDistance(living)/mc.player.getDistanceToEntity(living)/g' src/main/java/net/skywild/module/modules/combat/KillAura.java
sed -i 's/mc.player.getDistance(e)/mc.player.getDistanceToEntity(e)/g' src/main/java/net/skywild/module/modules/combat/KillAura.java
sed -i 's/mc.player.getDistance(e)/mc.player.getDistanceToEntity(e)/g' src/main/java/net/skywild/module/modules/combat/AimAssist.java
sed -i 's/mc.player.getDistance(player)/mc.player.getDistanceToEntity(player)/g' src/main/java/net/skywild/module/modules/render/Nametags.java

# 2. Fix Vec3d add to addVector (Scaffold)
sed -i 's/\.add(0.5, 0.5, 0.5)/.addVector(0.5, 0.5, 0.5)/g' src/main/java/net/skywild/module/modules/player/Scaffold.java

# 3. Fix collidedHorizontally to isCollidedHorizontally (Sprint, ToggleSneak)
sed -i 's/collidedHorizontally/isCollidedHorizontally/g' src/main/java/net/skywild/module/modules/movement/Sprint.java
sed -i 's/collidedHorizontally/isCollidedHorizontally/g' src/main/java/net/skywild/module/modules/render/ToggleSneak.java

# 4. Fix getDestroySpeed to getStrVsBlock (AutoTool)
sed -i 's/getDestroySpeed(state)/getStrVsBlock(state)/g' src/main/java/net/skywild/module/modules/player/AutoTool.java

# 5. Fix KeyBinding.pressed to setKeyBindState (Eagle)
sed -i 's/mc.gameSettings.keyBindSneak.pressed = overVoid \&\& mc.player.onGround/net.minecraft.client.settings.KeyBinding.setKeyBindState(mc.gameSettings.keyBindSneak.getKeyCode(), overVoid \&\& mc.player.onGround)/g' src/main/java/net/skywild/module/modules/movement/Eagle.java
sed -i 's/mc.gameSettings.keyBindSneak.pressed = false/net.minecraft.client.settings.KeyBinding.setKeyBindState(mc.gameSettings.keyBindSneak.getKeyCode(), false)/g' src/main/java/net/skywild/module/modules/movement/Eagle.java

# 6. Fix Private Access: Use Reflection or Access Transformers? 
# We will use "((Accessor)mc).field" style logic where possible, or just fix Minecraft.java to be public.
# Since we have the source, making fields public in Minecraft.java is the easiest/cleanest fix.

echo "Making Minecraft.java fields public..."
sed -i 's/private final Timer timer/public final Timer timer/g' src/main/java/net/minecraft/client/Minecraft.java
sed -i 's/private int rightClickDelayTimer/public int rightClickDelayTimer/g' src/main/java/net/minecraft/client/Minecraft.java
sed -i 's/private void clickMouse/public void clickMouse/g' src/main/java/net/minecraft/client/Minecraft.java
sed -i 's/private void rightClickMouse/public void rightClickMouse/g' src/main/java/net/minecraft/client/Minecraft.java

# 7. Timer logic fix (1.12 uses tickLength, not timerSpeed directly)
# We will modify net/minecraft/util/Timer.java to add a public timerSpeed for ease of use
echo "Adjusting Timer.java for compatibility..."
sed -i '/public float elapsedPartialTicks;/a \    public float timerSpeed = 1.0F;' src/main/java/net/minecraft/util/Timer.java
sed -i 's/this.elapsedPartialTicks = (float)(i - this.lastSyncSysClock) \/ this.tickLength;/this.elapsedPartialTicks = (float)(i - this.lastSyncSysClock) \/ this.tickLength * this.timerSpeed;/g' src/main/java/net/minecraft/util/Timer.java

echo "Fixes applied! Running build..."
