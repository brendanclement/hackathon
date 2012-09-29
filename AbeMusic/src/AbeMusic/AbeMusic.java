package AbeMusic;

import com.echonest.api.v4.EchoNestException;
import java.util.List;

public class AbeMusic 
{
    public static void main (String [] args) throws EchoNestException
    {
	System.setProperty("ECHO_NEST_API_KEY", "AKVMXWRE6L6YD0R4B");
	
	SongSearcher songSearcher = new SongSearcher();
	songSearcher.searchSongsByArtist("Led Zeppelin", 2);
	
	SimilarSongFinder finder = new SimilarSongFinder();
	List<AbeMusicSong> similarSongs = finder.findSimilarSong("SOSWQFI12B0B80B0E5", 10);
	
	System.out.println("Songs similar to 'The Intro' by Led Zeppelin");
	
	for(AbeMusicSong s : similarSongs)
	{
	    System.out.println(s.toString());
	}
    }
}
