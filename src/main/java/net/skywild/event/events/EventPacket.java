package net.skywild.event.events;
import net.minecraft.network.Packet;
import net.skywild.event.Event;
public class EventPacket extends Event {
    private Packet<?> packet;
    public EventPacket(Packet<?> packet) { this.packet = packet; }
    public Packet<?> getPacket() { return packet; }
    public void setPacket(Packet<?> packet) { this.packet = packet; }
}
