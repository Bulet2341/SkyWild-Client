package net.skywild.gui.clickgui;
import net.minecraft.client.gui.GuiScreen;
import net.skywild.SkyWildClient;
import net.skywild.module.ModuleCategory;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
public class ClickGUIScreen extends GuiScreen {
    private final List<CategoryPanel> panels = new ArrayList<>();
    public ClickGUIScreen() { int startX = 10; for (ModuleCategory category : ModuleCategory.values()) { panels.add(new CategoryPanel(category, startX, 10)); startX += 115; } }
    @Override public void drawScreen(int mouseX, int mouseY, float partialTicks) { drawDefaultBackground(); for (CategoryPanel panel : panels) panel.render(mouseX, mouseY); }
    @Override protected void mouseClicked(int mouseX, int mouseY, int mouseButton) throws IOException { super.mouseClicked(mouseX, mouseY, mouseButton); for (CategoryPanel panel : panels) panel.mouseClicked(mouseX, mouseY, mouseButton); }
    @Override protected void mouseReleased(int mouseX, int mouseY, int state) { super.mouseReleased(mouseX, mouseY, state); for (CategoryPanel panel : panels) panel.mouseReleased(mouseX, mouseY, state); }
    @Override protected void keyTyped(char typedChar, int keyCode) throws IOException { if (keyCode == 1 || keyCode == org.lwjgl.input.Keyboard.KEY_RSHIFT) { mc.displayGuiScreen(null); return; } super.keyTyped(typedChar, keyCode); for (CategoryPanel panel : panels) panel.keyTyped(typedChar, keyCode); }
    @Override public boolean doesGuiPauseGame() { return false; }
    @Override public void onGuiClosed() { SkyWildClient.getInstance().getConfigManager().save(); }
}
