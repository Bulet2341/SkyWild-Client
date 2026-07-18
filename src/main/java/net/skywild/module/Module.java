package net.skywild.module;
import net.minecraft.client.Minecraft;
import net.skywild.SkyWildClient;
import net.skywild.setting.*;
import java.util.ArrayList;
import java.util.List;
public abstract class Module {
    protected static final Minecraft mc = Minecraft.getMinecraft();
    private String name, description; private ModuleCategory category; private int keyBind;
    private boolean enabled, visible = true; private String suffix = "";
    private final List<Setting> settings = new ArrayList<>();
    public Module(String name, String description, ModuleCategory category, int keyBind) {
        this.name = name; this.description = description; this.category = category; this.keyBind = keyBind;
    }
    public Module(String name, String description, ModuleCategory category) { this(name, description, category, 0); }
    public void toggle() { setEnabled(!enabled); }
    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
        if (enabled) { onEnable(); SkyWildClient.getInstance().getEventManager().register(this); }
        else { SkyWildClient.getInstance().getEventManager().unregister(this); onDisable(); }
    }
    public void onEnable() {} public void onDisable() {}
    protected BooleanSetting addBooleanSetting(String name, boolean defaultValue) { BooleanSetting setting = new BooleanSetting(name, defaultValue); setting.setParent(this); settings.add(setting); return setting; }
    protected NumberSetting addNumberSetting(String name, double value, double min, double max, double increment) { NumberSetting setting = new NumberSetting(name, value, min, max, increment); setting.setParent(this); settings.add(setting); return setting; }
    protected ModeSetting addModeSetting(String name, String defaultValue, String... modes) { ModeSetting setting = new ModeSetting(name, defaultValue, modes); setting.setParent(this); settings.add(setting); return setting; }
    protected ColorSetting addColorSetting(String name, java.awt.Color defaultColor) { ColorSetting setting = new ColorSetting(name, defaultColor); setting.setParent(this); settings.add(setting); return setting; }
    protected boolean nullCheck() { return mc.player == null || mc.world == null; }
    public String getName() { return name; } public String getDescription() { return description; }
    public ModuleCategory getCategory() { return category; } public int getKeyBind() { return keyBind; }
    public void setKeyBind(int keyBind) { this.keyBind = keyBind; } public boolean isEnabled() { return enabled; }
    public boolean isVisible() { return visible; } public void setVisible(boolean visible) { this.visible = visible; }
    public String getSuffix() { return suffix; } protected void setSuffix(String suffix) { this.suffix = suffix; }
    public List<Setting> getSettings() { return settings; }
    public String getDisplayName() { return suffix.isEmpty() ? name : name + " \u00A77" + suffix; }
}
