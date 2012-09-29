package AbeMusic;

import com.echonest.api.v4.EchoNestException;
import java.util.List;
import java.sql.*;

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
		
		//
		// Connect to MySQL
		//
		String url = "jdbc:mysql://hackathon.cdgfhz5tzus1.us-west-2.rds.amazonaws.com/";
		String dbName = "hackathon";
		String userName = "admin"; 
		String driver = "com.mysql.jdbc.Driver";
		String password = "javapython";
		
		try 
		{
			Class.forName(driver).newInstance();
			Connection connection = DriverManager.getConnection(url+dbName,userName,password);
			
			//Do some shit...
			Statement stmt = connection.createStatement();
			ResultSet rs = stmt.executeQuery("SELECT * FROM song");
			while (rs.next()) 
			{
				System.out.print(rs.getString(2) + " - ");
				System.out.println(rs.getString(3));
			}

			
			connection.close();
		} catch (Exception e) 
		{
			e.printStackTrace();
		}
		
    }
}
