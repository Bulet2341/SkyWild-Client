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
