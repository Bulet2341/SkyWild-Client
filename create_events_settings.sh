#!/bin/bash
echo "Creating Event System..."

# --- EVENT BASE ---
cat > src/main/java/net/skywild/event/Event.java << 'EOF'
package net.skywild.event;
public abstract class Event {
    private boolean cancelled;
    private EventType type = EventType.PRE;
    public boolean isCancelled() { return cancelled; }
    public void setCancelled(boolean cancelled) { this.cancelled = cancelled; }
    public EventType getType() { return type; }
    public void setType(EventType type) { this.type = type; }
    public boolean isPre() { return type == EventType.PRE; }
    public boolean isPost() { return type == EventType.POST; }
}
EOF

cat > src/main/java/net/skywild/event/EventType.java << 'EOF'
package net.skywild.event;
public enum EventType { PRE, POST }
EOF

cat > src/main/java/net/skywild/event/EventTarget.java << 'EOF'
package net.skywild.event;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface EventTarget { int priority() default 0; }
EOF

cat > src/main/java/net/skywild/event/EventManager.java << 'EOF'
package net.skywild.event;
import java.lang.reflect.Method;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
public class EventManager {
    private final Map<Class<? extends Event>, List<EventEntry>> registry = new ConcurrentHashMap<>();
    public void register(Object listener) {
        for (Method method : listener.getClass().getDeclaredMethods()) {
            if (method.isAnnotationPresent(EventTarget.class) && method.getParameterTypes().length == 1) {
                Class<? extends Event> eventClass = (Class<? extends Event>) method.getParameterTypes()[0];
                method.setAccessible(true);
                EventTarget annotation = method.getAnnotation(EventTarget.class);
                registry.computeIfAbsent(eventClass, k -> new CopyOnWriteArrayList<>()).add(new EventEntry(listener, method, annotation.priority()));
                registry.get(eventClass).sort(Comparator.comparingInt(e -> -e.priority));
            }
        }
    }
    public void unregister(Object listener) {
        for (List<EventEntry> entries : registry.values()) {
            entries.removeIf(entry -> entry.instance == listener);
        }
    }
    public Event call(Event event) {
        List<EventEntry> entries = registry.get(event.getClass());
        if (entries != null) {
            for (EventEntry entry : entries) {
                try { entry.method.invoke(entry.instance, event); } catch (Exception e) { System.err.println("[SkyWild] Error calling event: " + e.getMessage()); }
            }
        }
        return event;
    }
    private static class EventEntry {
        final Object instance; final Method method; final int priority;
        EventEntry(Object instance, Method method, int priority) { this.instance = instance; this.method = method; this.priority = priority; }
    }
}
EOF

# --- EVENT SUBCLASSES ---
cat > src/main/java/net/skywild/event/events/EventUpdate.java << 'EOF'
package net.skywild.event.events;
import net.skywild.event.Event;
public class EventUpdate extends Event {}
EOF

cat > src/main/java/net/skywild/event/events/EventTick.java << 'EOF'
package net.skywild.event.events;
import net.skywild.event.Event;
public class EventTick extends Event {}
EOF

cat > src/main/java/net/skywild/event/events/EventRender2D.java << 'EOF'
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
EOF

cat > src/main/java/net/skywild/event/events/EventRender3D.java << 'EOF'
package net.skywild.event.events;
import net.skywild.event.Event;
public class EventRender3D extends Event {
    private final float partialTicks;
    public EventRender3D(float partialTicks) { this.partialTicks = partialTicks; }
    public float getPartialTicks() { return partialTicks; }
}
EOF

cat > src/main/java/net/skywild/event/events/EventMotion.java << 'EOF'
package net.skywild.event.events;
import net.skywild.event.Event;
public class EventMotion extends Event {
    private double x, y, z; private float yaw, pitch; private boolean onGround;
    public EventMotion(double x, double y, double z, float yaw, float pitch, boolean onGround) {
        this.x = x; this.y = y; this.z = z; this.yaw = yaw; this.pitch = pitch; this.onGround = onGround;
    }
    public double getX() { return x; } public void setX(double x) { this.x = x; }
    public double getY() { return y; } public void setY(double y) { this.y = y; }
    public double getZ() { return z; } public void setZ(double z) { this.z = z; }
    public float getYaw() { return yaw; } public void setYaw(float yaw) { this.yaw = yaw; }
    public float getPitch() { return pitch; } public void setPitch(float pitch) { this.pitch = pitch; }
    public boolean isOnGround() { return onGround; } public void setOnGround(boolean onGround) { this.onGround = onGround; }
}
EOF

cat > src/main/java/net/skywild/event/events/EventKey.java << 'EOF'
package net.skywild.event.events;
import net.skywild.event.Event;
public class EventKey extends Event {
    private final int key;
    public EventKey(int key) { this.key = key; }
    public int getKey() { return key; }
}
EOF

cat > src/main/java/net/skywild/event/events/EventPacket.java << 'EOF'
package net.skywild.event.events;
import net.minecraft.network.Packet;
import net.skywild.event.Event;
public class EventPacket extends Event {
    private Packet<?> packet;
    public EventPacket(Packet<?> packet) { this.packet = packet; }
    public Packet<?> getPacket() { return packet; }
    public void setPacket(Packet<?> packet) { this.packet = packet; }
}
EOF

cat > src/main/java/net/skywild/event/events/EventMove.java << 'EOF'
package net.skywild.event.events;
import net.skywild.event.Event;
public class EventMove extends Event {
    private double x, y, z;
    public EventMove(double x, double y, double z) { this.x = x; this.y = y; this.z = z; }
    public double getX() { return x; } public void setX(double x) { this.x = x; }
    public double getY() { return y; } public void setY(double y) { this.y = y; }
    public double getZ() { return z; } public void setZ(double z) { this.z = z; }
}
EOF

cat > src/main/java/net/skywild/event/events/EventChat.java << 'EOF'
package net.skywild.event.events;
import net.skywild.event.Event;
public class EventChat extends Event {
    private String message;
    public EventChat(String message) { this.message = message; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
EOF

echo "Creating Settings System..."

# --- SETTINGS BASE ---
cat > src/main/java/net/skywild/setting/Setting.java << 'EOF'
package net.skywild.setting;
import net.skywild.module.Module;
import java.util.function.Supplier;
public abstract class Setting {
    protected String name; protected Module parent; protected Supplier<Boolean> visibility;
    public Setting(String name) { this.name = name; this.visibility = () -> true; }
    public String getName() { return name; }
    public Module getParent() { return parent; }
    public void setParent(Module parent) { this.parent = parent; }
    public Setting setVisibility(Supplier<Boolean> visibility) { this.visibility = visibility; return this; }
    public boolean isVisible() { return visibility.get(); }
}
EOF

cat > src/main/java/net/skywild/setting/BooleanSetting.java << 'EOF'
package net.skywild.setting;
public class BooleanSetting extends Setting {
    private boolean value;
    public BooleanSetting(String name, boolean defaultValue) { super(name); this.value = defaultValue; }
    public boolean isEnabled() { return value; }
    public void setEnabled(boolean value) { this.value = value; }
    public void toggle() { this.value = !this.value; }
}
EOF

cat > src/main/java/net/skywild/setting/NumberSetting.java << 'EOF'
package net.skywild.setting;
public class NumberSetting extends Setting {
    private double value, min, max, increment;
    public NumberSetting(String name, double value, double min, double max, double increment) {
        super(name); this.value = value; this.min = min; this.max = max; this.increment = increment;
    }
    public double getValue() { return value; }
    public float getValueFloat() { return (float) value; }
    public int getValueInt() { return (int) value; }
    public void setValue(double value) {
        double precision = 1.0 / increment;
        this.value = Math.round(Math.max(min, Math.min(max, value)) * precision) / precision;
    }
    public double getMin() { return min; }
    public double getMax() { return max; }
    public double getIncrement() { return increment; }
}
EOF

cat > src/main/java/net/skywild/setting/ModeSetting.java << 'EOF'
package net.skywild.setting;
import java.util.Arrays;
import java.util.List;
public class ModeSetting extends Setting {
    private String value; private final List<String> modes;
    public ModeSetting(String name, String defaultValue, String... modes) {
        super(name); this.value = defaultValue; this.modes = Arrays.asList(modes);
    }
    public String getValue() { return value; }
    public void setValue(String value) { if (modes.contains(value)) this.value = value; }
    public boolean is(String mode) { return value.equalsIgnoreCase(mode); }
    public List<String> getModes() { return modes; }
    public void cycle() {
        int index = modes.indexOf(value);
        index = (index + 1) % modes.size();
        value = modes.get(index);
    }
}
EOF

cat > src/main/java/net/skywild/setting/ColorSetting.java << 'EOF'
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
EOF

echo "Done!"
