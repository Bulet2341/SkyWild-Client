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
