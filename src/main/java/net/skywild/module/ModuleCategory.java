package net.skywild.module;
public enum ModuleCategory {
    COMBAT("Combat", 0xFF4444), MOVEMENT("Movement", 0x44FF44),
    RENDER("Render", 0x4444FF), PLAYER("Player", 0xFFFF44), WORLD("World", 0xFF44FF);
    private final String name; private final int color;
    ModuleCategory(String name, int color) { this.name = name; this.color = color; }
    public String getName() { return name; } public int getColor() { return color; }
}
