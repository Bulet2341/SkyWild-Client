package net.skywild.event.events;
import net.minecraft.client.gui.ScaledResolution;
import net.skywild.event.Event;
public class EventRender2D extends Event {
    private final ScaledResolution scaledResolution;
    private final float partialTicks;
    public EventRender2D(ScaledResolution sr, float partialTicks) { this.scaledResolution = sr; this.partialTicks = partialTicks; }
    public ScaledResolution getScaledResolution() { return scaledResolution; }
    public float getPartialTicks() { return partialTicks; }
}
