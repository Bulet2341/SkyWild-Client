package net.skywild.utils;
public class TimerUtil {
    private long lastTime;
    public TimerUtil() { this.lastTime = System.currentTimeMillis(); }
    public boolean hasTimeElapsed(long time) { return System.currentTimeMillis() - lastTime >= time; }
    public long getElapsedTime() { return System.currentTimeMillis() - lastTime; }
    public void reset() { this.lastTime = System.currentTimeMillis(); }
}
