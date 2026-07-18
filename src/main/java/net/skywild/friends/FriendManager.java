package net.skywild.friends;
import java.util.ArrayList;
import java.util.List;
public class FriendManager {
    private final List<String> friends = new ArrayList<>();
    public void addFriend(String name) { if (!isFriend(name)) friends.add(name); }
    public void removeFriend(String name) { friends.removeIf(f -> f.equalsIgnoreCase(name)); }
    public boolean isFriend(String name) { return friends.stream().anyMatch(f -> f.equalsIgnoreCase(name)); }
    public void clearFriends() { friends.clear(); }
    public List<String> getFriends() { return friends; }
}
