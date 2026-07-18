package net.skywild.setting;
import java.awt.Color;
public class ColorSetting extends Setting {
    private Color color; private boolean rainbow;
    public ColorSetting(String name, Color defaultColor) { super(name); this.color = defaultColor; this.rainbow = false; }
    public Color getColor() {
        if (rainbow) { float hue = (System.currentTimeMillis() % 3000) / 3000.0f; return Color.getHSBColor(hue, 0.8f, 1.0f); }
        return color;
    }
    public int getRGB() { return getColor().getRGB(); }
    public void setColor(Color color) { this.color = color; }
    public boolean isRainbow() { return rainbow; }
    public void setRainbow(boolean rainbow) { this.rainbow = rainbow; }
}
