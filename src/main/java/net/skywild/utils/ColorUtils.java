package net.skywild.utils;
import java.awt.Color;
public class ColorUtils {
    public static int getRainbow(int speed, int offset, float saturation, float brightness) {
        float hue = (System.currentTimeMillis() + offset) % speed; hue /= speed;
        return Color.HSBtoRGB(hue, saturation, brightness);
    }
    public static int getGradient(Color color1, Color color2, int offset) {
        float progress = (float) (Math.sin((System.currentTimeMillis() + offset) / 1000.0) + 1) / 2;
        int r = (int) (color1.getRed() + (color2.getRed() - color1.getRed()) * progress);
        int g = (int) (color1.getGreen() + (color2.getGreen() - color1.getGreen()) * progress);
        int b = (int) (color1.getBlue() + (color2.getBlue() - color1.getBlue()) * progress);
        return new Color(r, g, b).getRGB();
    }
    public static int getAstolfo(int speed, int offset) {
        float hue = (System.currentTimeMillis() + offset) % speed; hue /= speed;
        if (hue > 0.5) { hue = 1 - hue; } hue = 0.5f + hue * 0.25f;
        return Color.HSBtoRGB(hue, 0.5f, 1.0f);
    }
}
