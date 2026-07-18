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
