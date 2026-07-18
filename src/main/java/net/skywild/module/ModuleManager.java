package net.skywild.module;

import net.minecraft.client.Minecraft;
import net.skywild.SkyWildClient;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventKey;
import net.skywild.module.modules.combat.*;
import net.skywild.module.modules.movement.*;
import net.skywild.module.modules.player.*;
import net.skywild.module.modules.render.*;
import net.skywild.module.modules.world.*;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class ModuleManager {

    private final List<Module> modules = new ArrayList<>();

    public void init() {
        // Combat
        modules.add(new KillAura());
        modules.add(new AutoClicker());
        modules.add(new Velocity());
        modules.add(new Criticals());
        modules.add(new Reach());
        modules.add(new WTap());
        modules.add(new AimAssist());

        // Movement
        modules.add(new Sprint());
        modules.add(new Speed());
        modules.add(new Fly());
        modules.add(new NoSlowdown());
        modules.add(new Step());
        modules.add(new InventoryMove());
        modules.add(new Eagle());
        modules.add(new Timer());

        // Render
        modules.add(new HUD());
        modules.add(new ESP());
        modules.add(new Tracers());
        modules.add(new Fullbright());
        modules.add(new BlockOverlay());
        modules.add(new Nametags());
        modules.add(new Chams());
        modules.add(new Animations());
        modules.add(new ClickGUI());
        modules.add(new CPS());
        modules.add(new ArmorStatus());
        modules.add(new Keystrokes());
        modules.add(new Crosshair());
        modules.add(new FPSDisplay());
        modules.add(new ToggleSneak());

        // Player
        modules.add(new NoFall());
        modules.add(new FastPlace());
        modules.add(new AntiVoid());
        modules.add(new AutoTool());
        modules.add(new ChestStealer());
        modules.add(new AutoArmor());
        modules.add(new Scaffold());

        // World
        modules.add(new TimeChanger());
        modules.add(new ChunkBorders());
        modules.add(new StorageESP());

        SkyWildClient.getInstance().getEventManager().register(this);
        System.out.println("[SkyWild] Loaded " + modules.size() + " modules.");
    }

    @EventTarget
    public void onKey(EventKey event) {
        for (Module module : modules) {
            if (module.getKeyBind() == event.getKey() && event.getKey() != 0) {
                module.toggle();
            }
        }
    }

    public List<Module> getModules() { return modules; }

    public Module getModule(String name) {
        return modules.stream().filter(m -> m.getName().equalsIgnoreCase(name)).findFirst().orElse(null);
    }

    @SuppressWarnings("unchecked")
    public <T extends Module> T getModule(Class<T> clazz) {
        return (T) modules.stream().filter(m -> m.getClass().equals(clazz)).findFirst().orElse(null);
    }

    public List<Module> getModulesByCategory(ModuleCategory category) {
        return modules.stream().filter(m -> m.getCategory() == category).collect(Collectors.toList());
    }

    public List<Module> getEnabledModules() {
        return modules.stream().filter(Module::isEnabled).collect(Collectors.toList());
    }

    public List<Module> getVisibleModules() {
        return modules.stream()
            .filter(Module::isEnabled)
            .filter(Module::isVisible)
            .sorted(Comparator.comparingInt(m -> -Minecraft.getMinecraft().fontRenderer.getStringWidth(m.getDisplayName())))
            .collect(Collectors.toList());
    }

    public boolean isEnabled(Class<? extends Module> clazz) {
        Module m = getModule(clazz);
        return m != null && m.isEnabled();
    }
}
