#!/bin/bash
echo "Creating GUI files..."

# --- CLICK GUI ---
cat > src/main/java/net/skywild/gui/clickgui/SettingComponent.java << 'EOF'
package net.skywild.gui.clickgui;
import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.Gui;
import net.skywild.setting.*;
public class SettingComponent {
    private final Setting setting; private final ModuleButton parent; private boolean dragging = false;
    public SettingComponent(Setting setting, ModuleButton parent) { this.setting = setting; this.parent = parent; }
    public void render(int x, int y, int width, int mouseX, int mouseY) {
        Minecraft mc = Minecraft.getMinecraft();
        if (setting instanceof BooleanSetting) {
            BooleanSetting bool = (BooleanSetting) setting; Gui.drawRect(x, y, x + width, y + 13, 0x88111111);
            Gui.drawRect(x + width - 12, y + 2, x + width - 2, y + 11, bool.isEnabled() ? 0xFF00CC66 : 0xFF444444);
            mc.fontRenderer.drawStringWithShadow(setting.getName(), x + 3, y + 3, 0xFFCCCCCC);
        } else if (setting instanceof NumberSetting) {
            NumberSetting num = (NumberSetting) setting; Gui.drawRect(x, y, x + width, y + 20, 0x88111111);
            mc.fontRenderer.drawStringWithShadow(setting.getName() + ": " + String.format("%.1f", num.getValue()), x + 3, y + 2, 0xFFCCCCCC);
            int sliderY = y + 12; int sliderW = width - 6; double percent = (num.getValue() - num.getMin()) / (num.getMax() - num.getMin());
            Gui.drawRect(x + 3, sliderY, x + 3 + sliderW, sliderY + 4, 0xFF333333); Gui.drawRect(x + 3, sliderY, (int) (x + 3 + sliderW * percent), sliderY + 4, 0xFF0099FF);
            if (dragging) { double newPercent = Math.max(0, Math.min(1, (mouseX - x - 3) / (double) sliderW)); num.setValue(num.getMin() + newPercent * (num.getMax() - num.getMin())); }
        } else if (setting instanceof ModeSetting) {
            ModeSetting mode = (ModeSetting) setting; Gui.drawRect(x, y, x + width, y + 13, 0x88111111);
            mc.fontRenderer.drawStringWithShadow(setting.getName() + ": " + mode.getValue(), x + 3, y + 3, 0xFF00AAFF);
        } else if (setting instanceof ColorSetting) {
            ColorSetting color = (ColorSetting) setting; Gui.drawRect(x, y, x + width, y + 13, 0x88111111);
            Gui.drawRect(x + width - 12, y + 2, x + width - 2, y + 11, color.getRGB());
            mc.fontRenderer.drawStringWithShadow(setting.getName() + (color.isRainbow() ? " (RB)" : ""), x + 3, y + 3, 0xFFCCCCCC);
        }
    }
    public void mouseClicked(int x, int y, int width, int mouseX, int mouseY, int button) {
        if (mouseX < x || mouseX > x + width || mouseY < y || mouseY > y + getHeight()) return;
        if (setting instanceof BooleanSetting) { ((BooleanSetting) setting).toggle(); }
        else if (setting instanceof NumberSetting) { dragging = true; }
        else if (setting instanceof ModeSetting) { if (button == 0) ((ModeSetting) setting).cycle(); }
        else if (setting instanceof ColorSetting) { if (button == 1) ((ColorSetting) setting).setRainbow(!((ColorSetting) setting).isRainbow()); }
    }
    public void mouseReleased() { dragging = false; }
    public int getHeight() { return setting instanceof NumberSetting ? 20 : 13; }
    public Setting getSetting() { return setting; }
}
EOF

cat > src/main/java/net/skywild/gui/clickgui/ModuleButton.java << 'EOF'
package net.skywild.gui.clickgui;
import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.Gui;
import net.skywild.module.Module;
import net.skywild.setting.Setting;
import net.skywild.utils.ColorUtils;
import org.lwjgl.input.Keyboard;
import java.util.ArrayList;
import java.util.List;
public class ModuleButton {
    private final Module module; private final CategoryPanel parent; int offsetY;
    private boolean expanded = false; private boolean binding = false;
    private final List<SettingComponent> settingComponents = new ArrayList<>();
    public ModuleButton(Module module, CategoryPanel parent, int offsetY) {
        this.module = module; this.parent = parent; this.offsetY = offsetY;
        for (Setting setting : module.getSettings()) settingComponents.add(new SettingComponent(setting, this));
    }
    public void render(int mouseX, int mouseY) {
        int x = parent.getX(), y = parent.getY() + parent.getHeaderHeight() + offsetY, w = parent.getWidth();
        boolean hovered = mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + 15;
        int bgColor = module.isEnabled() ? (hovered ? 0xCC1a5276 : 0xAA0f3460) : (hovered ? 0xAA222222 : 0x88111111);
        Gui.drawRect(x, y, x + w, y + 15, bgColor);
        if (module.isEnabled()) Gui.drawRect(x, y, x + 2, y + 15, ColorUtils.getRainbow(3000, offsetY * 50, 0.8f, 1.0f));
        Minecraft mc = Minecraft.getMinecraft();
        mc.fontRenderer.drawStringWithShadow(binding ? "Press a key..." : module.getName(), x + 5, y + 3, module.isEnabled() ? 0xFFFFFFFF : 0xFFAAAAAA);
        if (module.getKeyBind() != 0 && !binding) { String bindText = "[" + Keyboard.getKeyName(module.getKeyBind()) + "]"; mc.fontRenderer.drawStringWithShadow(bindText, x + w - mc.fontRenderer.getStringWidth(bindText) - 3, y + 3, 0xFF666666); }
        if (!module.getSettings().isEmpty()) mc.fontRenderer.drawStringWithShadow(expanded ? "-" : "+", x + w - 10, y + 3, 0xFFAAAAAA);
        if (expanded) { int settingY = 15; for (SettingComponent comp : settingComponents) { if (comp.getSetting().isVisible()) { comp.render(x + 2, y + settingY, w - 4, mouseX, mouseY); settingY += comp.getHeight(); } } }
    }
    public void mouseClicked(int mouseX, int mouseY, int button) {
        int x = parent.getX(), y = parent.getY() + parent.getHeaderHeight() + offsetY, w = parent.getWidth();
        if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + 15) {
            if (button == 0) module.toggle(); else if (button == 1) expanded = !expanded; else if (button == 2) binding = true; return;
        }
        if (expanded) { int settingY = 15; for (SettingComponent comp : settingComponents) { if (comp.getSetting().isVisible()) { comp.mouseClicked(x + 2, y + settingY, w - 4, mouseX, mouseY, button); settingY += comp.getHeight(); } } }
    }
    public void mouseReleased(int mouseX, int mouseY, int state) { if (expanded) { for (SettingComponent comp : settingComponents) comp.mouseReleased(); } }
    public void keyTyped(char typedChar, int keyCode) { if (binding) { module.setKeyBind(keyCode == Keyboard.KEY_ESCAPE ? 0 : keyCode); binding = false; } }
    public int getTotalHeight() { int h = 15; if (expanded) { for (SettingComponent comp : settingComponents) { if (comp.getSetting().isVisible()) h += comp.getHeight(); } } return h; }
    public Module getModule() { return module; }
}
EOF

cat > src/main/java/net/skywild/gui/clickgui/CategoryPanel.java << 'EOF'
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
EOF

cat > src/main/java/net/skywild/gui/clickgui/ClickGUIScreen.java << 'EOF'
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
EOF

# --- MAIN MENU ---
cat > src/main/java/net/skywild/gui/mainmenu/SkyWildMainMenu.java << 'EOF'
package net.skywild.gui.mainmenu;
import net.minecraft.client.gui.*;
import net.minecraft.client.renderer.GlStateManager;
import net.skywild.SkyWildClient;
import net.skywild.utils.ColorUtils;
import java.io.IOException;
public class SkyWildMainMenu extends GuiScreen {
    @Override public void initGui() {
        super.initGui(); this.buttonList.clear();
        int centerX = this.width / 2; int startY = this.height / 2 + 10;
        this.buttonList.add(new GuiButton(1, centerX - 100, startY, 200, 20, "Singleplayer"));
        this.buttonList.add(new GuiButton(2, centerX - 100, startY + 24, 200, 20, "Multiplayer"));
        this.buttonList.add(new GuiButton(3, centerX - 100, startY + 48, 200, 20, "Settings"));
        this.buttonList.add(new GuiButton(4, centerX - 100, startY + 72, 200, 20, "Quit"));
    }
    @Override public void drawScreen(int mouseX, int mouseY, float partialTicks) {
        this.drawGradientRect(0, 0, this.width, this.height, 0xFF0a0a1a, 0xFF1a1a3e);
        String title = SkyWildClient.CLIENT_NAME; float titleScale = 4.0f;
        GlStateManager.pushMatrix(); GlStateManager.scale(titleScale, titleScale, 1);
        int titleWidth = this.fontRenderer.getStringWidth(title); float titleX = (this.width / titleScale - titleWidth) / 2; float titleY = (this.height / 2 - 60) / titleScale;
        float charX = titleX;
        for (int i = 0; i < title.length(); i++) {
            int color = ColorUtils.getRainbow(3000, i * 200, 0.8f, 1.0f); String ch = String.valueOf(title.charAt(i));
            this.fontRenderer.drawStringWithShadow(ch, charX, titleY, color); charX += this.fontRenderer.getStringWidth(ch);
        }
        GlStateManager.popMatrix();
        String version = "v" + SkyWildClient.CLIENT_VERSION;
        this.fontRenderer.drawStringWithShadow(version, (this.width - this.fontRenderer.getStringWidth(version)) / 2.0f, this.height / 2.0f - 15, 0xFF888888);
        String credits = "Developed by " + SkyWildClient.CLIENT_AUTHOR;
        this.fontRenderer.drawStringWithShadow(credits, 2, this.height - 12, 0xFF555555);
        super.drawScreen(mouseX, mouseY, partialTicks);
    }
    @Override protected void actionPerformed(GuiButton button) throws IOException {
        switch (button.id) {
            case 1: mc.displayGuiScreen(new GuiWorldSelection(this)); break;
            case 2: mc.displayGuiScreen(new GuiMultiplayer(this)); break;
            case 3: mc.displayGuiScreen(new GuiOptions(this, mc.gameSettings)); break;
            case 4: mc.shutdown(); break;
        }
    }
}
EOF

echo "Done!"
