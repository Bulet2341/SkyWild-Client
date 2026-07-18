package net.skywild.utils;
import java.util.Random;
public class MathUtils {
    private static final Random random = new Random();
    public static double randomDouble(double min, double max) { return min + random.nextDouble() * (max - min); }
    public static int randomInt(int min, int max) { return min + random.nextInt(max - min + 1); }
    public static float clamp(float value, float min, float max) { return Math.max(min, Math.min(max, value)); }
    public static double clamp(double value, double min, double max) { return Math.max(min, Math.min(max, value)); }
    public static float lerp(float start, float end, float amount) { return start + (end - start) * amount; }
}
