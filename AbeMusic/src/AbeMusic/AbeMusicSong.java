package AbeMusic;

public class AbeMusicSong
{
    public AbeMusicSong(){}
    String Artist;
    String Name;
    
    @Override public String toString()
    {
	return Artist + " - " + Name;
    }
}