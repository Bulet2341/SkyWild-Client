package net.skywild.module.modules.world;
import net.minecraft.tileentity.*;
import net.skywild.event.EventTarget;
import net.skywild.event.events.EventRender3D;
import net.skywild.module.Module;
import net.skywild.module.ModuleCategory;
import net.skywild.setting.BooleanSetting;
import net.skywild.utils.RenderUtils;
import java.awt.Color;
public class StorageESP extends Module {
    private final BooleanSetting chests = addBooleanSetting("Chests", true);
    private final BooleanSetting enderChests = addBooleanSetting("Ender Chests", true);
    private final BooleanSetting shulkers = addBooleanSetting("Shulkers", true);
    public StorageESP() { super("StorageESP", "Highlights storage blocks", ModuleCategory.WORLD); }
    @EventTarget public void onRender3D(EventRender3D event) {
        if (nullCheck()) return;
        for (TileEntity te : mc.world.loadedTileEntityList) {
            Color color = null;
            if (te instanceof TileEntityChest && chests.isEnabled()) color = new Color(255, 165, 0, 120);
            else if (te instanceof TileEntityEnderChest && enderChests.isEnabled()) color = new Color(150, 0, 255, 120);
            else if (te instanceof TileEntityShulkerBox && shulkers.isEnabled()) color = new Color(255, 100, 200, 120);
            if (color != null) RenderUtils.drawBlockOverlay(te.getPos(), color, 1.5f);
        }
    }
}
