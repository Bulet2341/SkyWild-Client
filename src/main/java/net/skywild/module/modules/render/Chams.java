package net.skywild.module.modules.render;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import java.awt.Color;
public class Chams extends Module {
    private final BooleanSetting colored = addBooleanSetting("Colored", true);
    private final ColorSetting visibleColor = addColorSetting("Visible Color", new Color(50, 255, 50));
    private final ColorSetting hiddenColor = addColorSetting("Hidden Color", new Color(255, 50, 50));
    private final BooleanSetting showHidden = addBooleanSetting("Show Through Walls", true);
    public Chams() { super("Chams", "See entities through walls", ModuleCategory.RENDER); }
    public boolean isColored() { return colored.isEnabled(); }
    public Color getVisibleColor() { return visibleColor.getColor(); }
    public Color getHiddenColor() { return hiddenColor.getColor(); }
    public boolean showThroughWalls() { return showHidden.isEnabled(); }
}
