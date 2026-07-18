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
