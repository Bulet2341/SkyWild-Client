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
