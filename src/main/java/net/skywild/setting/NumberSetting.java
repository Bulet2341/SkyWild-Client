package net.skywild.setting;
public class NumberSetting extends Setting {
    private double value, min, max, increment;
    public NumberSetting(String name, double value, double min, double max, double increment) {
        super(name); this.value = value; this.min = min; this.max = max; this.increment = increment;
    }
    public double getValue() { return value; }
    public float getValueFloat() { return (float) value; }
    public int getValueInt() { return (int) value; }
    public void setValue(double value) {
        double precision = 1.0 / increment;
        this.value = Math.round(Math.max(min, Math.min(max, value)) * precision) / precision;
    }
    public double getMin() { return min; }
    public double getMax() { return max; }
    public double getIncrement() { return increment; }
}
