package net.skywild.config;
import com.google.gson.*;
import net.skywild.SkyWildClient;
import net.skywild.module.Module;
import net.skywild.setting.*;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
public class ConfigManager {
    private final Path configDir; private final Path configFile;
    public ConfigManager() { configDir = Paths.get("skywild"); configFile = configDir.resolve("config.json"); }
    public void save() {
        try {
            if (!Files.exists(configDir)) { Files.createDirectories(configDir); }
            JsonObject root = new JsonObject(); JsonObject modulesJson = new JsonObject();
            for (Module module : SkyWildClient.getInstance().getModuleManager().getModules()) {
                JsonObject moduleJson = new JsonObject();
                moduleJson.addProperty("enabled", module.isEnabled()); moduleJson.addProperty("keyBind", module.getKeyBind()); moduleJson.addProperty("visible", module.isVisible());
                JsonObject settingsJson = new JsonObject();
                for (Setting setting : module.getSettings()) {
                    if (setting instanceof BooleanSetting) { settingsJson.addProperty(setting.getName(), ((BooleanSetting) setting).isEnabled()); }
                    else if (setting instanceof NumberSetting) { settingsJson.addProperty(setting.getName(), ((NumberSetting) setting).getValue()); }
                    else if (setting instanceof ModeSetting) { settingsJson.addProperty(setting.getName(), ((ModeSetting) setting).getValue()); }
                    else if (setting instanceof ColorSetting) { ColorSetting cs = (ColorSetting) setting; JsonObject colorJson = new JsonObject(); colorJson.addProperty("rgb", cs.getColor().getRGB()); colorJson.addProperty("rainbow", cs.isRainbow()); settingsJson.add(setting.getName(), colorJson); }
                }
                moduleJson.add("settings", settingsJson); modulesJson.add(module.getName(), moduleJson);
            }
            root.add("modules", modulesJson);
            JsonArray friendsJson = new JsonArray(); for (String friend : SkyWildClient.getInstance().getFriendManager().getFriends()) { friendsJson.add(friend); }
            root.add("friends", friendsJson);
            Gson gson = new GsonBuilder().setPrettyPrinting().create(); Files.write(configFile, gson.toJson(root).getBytes());
            System.out.println("[SkyWild] Config saved.");
        } catch (Exception e) { System.err.println("[SkyWild] Failed to save config: " + e.getMessage()); e.printStackTrace(); }
    }
    public void load() {
        try {
            if (!Files.exists(configFile)) return;
            String json = new String(Files.readAllBytes(configFile)); JsonObject root = new JsonParser().parse(json).getAsJsonObject();
            if (root.has("modules")) {
                JsonObject modulesJson = root.getAsJsonObject("modules");
                for (Module module : SkyWildClient.getInstance().getModuleManager().getModules()) {
                    if (!modulesJson.has(module.getName())) continue;
                    JsonObject moduleJson = modulesJson.getAsJsonObject(module.getName());
                    if (moduleJson.has("keyBind")) { module.setKeyBind(moduleJson.get("keyBind").getAsInt()); }
                    if (moduleJson.has("visible")) { module.setVisible(moduleJson.get("visible").getAsBoolean()); }
                    if (moduleJson.has("enabled") && moduleJson.get("enabled").getAsBoolean()) { module.setEnabled(true); }
                    if (moduleJson.has("settings")) {
                        JsonObject settingsJson = moduleJson.getAsJsonObject("settings");
                        for (Setting setting : module.getSettings()) {
                            if (!settingsJson.has(setting.getName())) continue;
                            if (setting instanceof BooleanSetting) { ((BooleanSetting) setting).setEnabled(settingsJson.get(setting.getName()).getAsBoolean()); }
                            else if (setting instanceof NumberSetting) { ((NumberSetting) setting).setValue(settingsJson.get(setting.getName()).getAsDouble()); }
                            else if (setting instanceof ModeSetting) { ((ModeSetting) setting).setValue(settingsJson.get(setting.getName()).getAsString()); }
                            else if (setting instanceof ColorSetting) { JsonObject colorJson = settingsJson.getAsJsonObject(setting.getName()); if (colorJson != null) { ((ColorSetting) setting).setColor(new java.awt.Color(colorJson.get("rgb").getAsInt(), true)); ((ColorSetting) setting).setRainbow(colorJson.get("rainbow").getAsBoolean()); } }
                        }
                    }
                }
            }
            if (root.has("friends")) { JsonArray friendsJson = root.getAsJsonArray("friends"); for (JsonElement element : friendsJson) { SkyWildClient.getInstance().getFriendManager().addFriend(element.getAsString()); } }
            System.out.println("[SkyWild] Config loaded.");
        } catch (Exception e) { System.err.println("[SkyWild] Failed to load config: " + e.getMessage()); e.printStackTrace(); }
    }
}
