package net.skywild.gui.mainmenu;
import net.minecraft.client.gui.*;
import net.minecraft.client.renderer.GlStateManager;
import net.skywild.SkyWildClient;
import net.skywild.utils.ColorUtils;
import java.io.IOException;
public class SkyWildMainMenu extends GuiScreen {
    @Override public void initGui() {
        super.initGui(); this.buttonList.clear();
        int centerX = this.width / 2; int startY = this.height / 2 + 10;
        this.buttonList.add(new GuiButton(1, centerX - 100, startY, 200, 20, "Singleplayer"));
        this.buttonList.add(new GuiButton(2, centerX - 100, startY + 24, 200, 20, "Multiplayer"));
        this.buttonList.add(new GuiButton(3, centerX - 100, startY + 48, 200, 20, "Settings"));
        this.buttonList.add(new GuiButton(4, centerX - 100, startY + 72, 200, 20, "Quit"));
    }
    @Override public void drawScreen(int mouseX, int mouseY, float partialTicks) {
        this.drawGradientRect(0, 0, this.width, this.height, 0xFF0a0a1a, 0xFF1a1a3e);
        String title = SkyWildClient.CLIENT_NAME; float titleScale = 4.0f;
        GlStateManager.pushMatrix(); GlStateManager.scale(titleScale, titleScale, 1);
        int titleWidth = this.fontRenderer.getStringWidth(title); float titleX = (this.width / titleScale - titleWidth) / 2; float titleY = (this.height / 2 - 60) / titleScale;
        float charX = titleX;
        for (int i = 0; i < title.length(); i++) {
            int color = ColorUtils.getRainbow(3000, i * 200, 0.8f, 1.0f); String ch = String.valueOf(title.charAt(i));
            this.fontRenderer.drawStringWithShadow(ch, charX, titleY, color); charX += this.fontRenderer.getStringWidth(ch);
        }
        GlStateManager.popMatrix();
        String version = "v" + SkyWildClient.CLIENT_VERSION;
        this.fontRenderer.drawStringWithShadow(version, (this.width - this.fontRenderer.getStringWidth(version)) / 2.0f, this.height / 2.0f - 15, 0xFF888888);
        String credits = "Developed by " + SkyWildClient.CLIENT_AUTHOR;
        this.fontRenderer.drawStringWithShadow(credits, 2, this.height - 12, 0xFF555555);
        super.drawScreen(mouseX, mouseY, partialTicks);
    }
    @Override protected void actionPerformed(GuiButton button) throws IOException {
        switch (button.id) {
            case 1: mc.displayGuiScreen(new GuiWorldSelection(this)); break;
            case 2: mc.displayGuiScreen(new GuiMultiplayer(this)); break;
            case 3: mc.displayGuiScreen(new GuiOptions(this, mc.gameSettings)); break;
            case 4: mc.shutdown(); break;
        }
    }
}
