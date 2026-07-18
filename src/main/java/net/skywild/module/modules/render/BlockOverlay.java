package net.skywild.module.modules.render;
import net.minecraft.util.math.RayTraceResult;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender3D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.*;
import net.skywild.utils.RenderUtils;
import java.awt.Color;
public class BlockOverlay extends Module {
    private final ColorSetting color = addColorSetting("Color", new Color(255, 255, 255, 100));
    private final NumberSetting lineWidth = addNumberSetting("Line Width", 2.0, 0.5, 5.0, 0.5);
    public BlockOverlay() { super("BlockOverlay", "Custom block overlay", ModuleCategory.RENDER); }
    @EventTarget public void onRender3D(EventRender3D event) {
        if (nullCheck() || mc.objectMouseOver == null || mc.objectMouseOver.typeOfHit != RayTraceResult.Type.BLOCK) return;
        RenderUtils.drawBlockOverlay(mc.objectMouseOver.getBlockPos(), color.getColor(), lineWidth.getValueFloat());
    }
}
