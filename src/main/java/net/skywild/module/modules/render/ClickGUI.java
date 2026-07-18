package net.skywild.module.modules.render;
import net.skywild.gui.clickgui.ClickGUIScreen;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import org.lwjgl.input.Keyboard;
public class ClickGUI extends Module {
    public ClickGUI() { super("ClickGUI", "Opens the click GUI", ModuleCategory.RENDER, Keyboard.KEY_RSHIFT); }
    @Override public void onEnable() { mc.displayGuiScreen(new ClickGUIScreen()); setEnabled(false); }
}
