package net.skywild.gui.clickgui;
import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.Gui;
import net.skywild.SkyWildClient;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.utils.ColorUtils;
import java.util.ArrayList;
import java.util.List;
public class CategoryPanel {
    private final ModuleCategory category; private int x, y; private final int width = 110; private final int headerHeight = 18;
    private boolean open = true; private boolean dragging = false; private int dragX, dragY;
    private final List<ModuleButton> moduleButtons = new ArrayList<>();
    public CategoryPanel(ModuleCategory category, int x, int y) {
        this.category = category; this.x = x; this.y = y;
        for (Module module : SkyWildClient.getInstance().getModuleManager().getModulesByCategory(category)) moduleButtons.add(new ModuleButton(module, this, 0));
    }
    public void render(int mouseX, int mouseY) {
        if (dragging) { x = mouseX - dragX; y = mouseY - dragY; }
        Gui.drawRect(x, y, x + width, y + headerHeight, 0xFF1a1a2e); Gui.drawRect(x, y + headerHeight - 1, x + width, y + headerHeight, ColorUtils.getRainbow(3000, 0, 0.8f, 1.0f));
        Minecraft.getMinecraft().fontRenderer.drawStringWithShadow(category.getName(), x + 5, y + 5, 0xFFFFFFFF);
        Minecraft.getMinecraft().fontRenderer.drawStringWithShadow(open ? "\u25BC" : "\u25B6", x + width - 12, y + 5, 0xFFAAAAAA);
        if (open) {
            int currentY = 0; for (ModuleButton button : moduleButtons) { button.offsetY = currentY; currentY += button.getTotalHeight(); }
            Gui.drawRect(x, y + headerHeight, x + width, y + headerHeight + currentY, 0xCC16213e);
            for (ModuleButton button : moduleButtons) button.render(mouseX, mouseY);
        }
    }
    public void mouseClicked(int mouseX, int mouseY, int button) {
        if (mouseX >= x && mouseX <= x + width && mouseY >= y && mouseY <= y + headerHeight) { if (button == 0) { dragging = true; dragX = mouseX - x; dragY = mouseY - y; } else if (button == 1) { open = !open; } return; }
        if (open) { for (ModuleButton moduleButton : moduleButtons) moduleButton.mouseClicked(mouseX, mouseY, button); }
    }
    public void mouseReleased(int mouseX, int mouseY, int state) { dragging = false; for (ModuleButton button : moduleButtons) button.mouseReleased(mouseX, mouseY, state); }
    public void keyTyped(char typedChar, int keyCode) { for (ModuleButton button : moduleButtons) button.keyTyped(typedChar, keyCode); }
    public int getX() { return x; } public int getY() { return y; } public int getWidth() { return width; } public int getHeaderHeight() { return headerHeight; }
}
