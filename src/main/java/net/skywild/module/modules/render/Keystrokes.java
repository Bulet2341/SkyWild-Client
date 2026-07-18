package net.skywild.module.modules.render;
import net.minecraft.client.gui.Gui;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender2D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import org.lwjgl.input.Keyboard;
import org.lwjgl.input.Mouse;
import java.awt.Color;
public class Keystrokes extends Module {
    private final NumberSetting posX = addNumberSetting("X", 5, 0, 500, 1);
    private final NumberSetting posY = addNumberSetting("Y", 100, 0, 500, 1);
    private final ColorSetting activeColor = addColorSetting("Active Color", new Color(255, 255, 255, 180));
    private final ColorSetting inactiveColor = addColorSetting("Inactive Color", new Color(0, 0, 0, 100));
    public Keystrokes() { super("Keystrokes", "Shows pressed keys", ModuleCategory.RENDER); }
    @EventTarget public void onRender2D(EventRender2D event) {
        if (nullCheck()) return;
        int x = posX.getValueInt(), y = posY.getValueInt(), size = 22, gap = 2;
        drawKey("W", x+size+gap, y, size, Keyboard.isKeyDown(mc.gameSettings.keyBindForward.getKeyCode()));
        drawKey("A", x, y+size+gap, size, Keyboard.isKeyDown(mc.gameSettings.keyBindLeft.getKeyCode()));
        drawKey("S", x+size+gap, y+size+gap, size, Keyboard.isKeyDown(mc.gameSettings.keyBindBack.getKeyCode()));
        drawKey("D", x+(size+gap)*2, y+size+gap, size, Keyboard.isKeyDown(mc.gameSettings.keyBindRight.getKeyCode()));
        drawKey("LMB", x, y+(size+gap)*2, size+(size+gap)/2-1, Mouse.isButtonDown(0));
        drawKey("RMB", x+size+gap+(size+gap)/2+1, y+(size+gap)*2, size+(size+gap)/2-1, Mouse.isButtonDown(1));
        drawKey("---", x, y+(size+gap)*3, size*3+gap*2, Keyboard.isKeyDown(mc.gameSettings.keyBindJump.getKeyCode()));
    }
    private void drawKey(String text, int x, int y, int width, boolean pressed) {
        int bg = pressed ? activeColor.getRGB() : inactiveColor.getRGB(); int textColor = pressed ? 0xFF000000 : 0xFFFFFFFF; int h = text.equals("---") ? 14 : 22;
        Gui.drawRect(x, y, x+width, y+h, bg);
        int tx = x + (width - mc.fontRenderer.getStringWidth(text)) / 2; int ty = y + (h - mc.fontRenderer.FONT_HEIGHT) / 2;
        mc.fontRenderer.drawStringWithShadow(text, tx, ty, textColor);
    }
}
