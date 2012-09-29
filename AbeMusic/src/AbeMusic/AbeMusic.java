package AbeMusic;

import com.echonest.api.v4.EchoNestException;
import com.echonest.api.v4.Song;

import java.util.List;
import java.sql.*;

public class AbeMusic 
{
    public static void main (String [] args) throws EchoNestException
    {
		System.setProperty("ECHO_NEST_API_KEY", "AKVMXWRE6L6YD0R4B");
		
//		SongSearcher songSearcher = new SongSearcher();
//		songSearcher.searchSongsByArtist("Led Zeppelin", 2);
//		
//		SimilarSongFinder finder = new SimilarSongFinder();
//		List<AbeMusicSong> similarSongs = finder.findSimilarSong("SOSWQFI12B0B80B0E5", 10);
		
//		System.out.println("Songs similar to 'The Intro' by Led Zeppelin");
		
//		for(AbeMusicSong s : similarSongs)
//		{
//		    System.out.println(s.toString());
//		}
		
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
			ResultSet rs = stmt.executeQuery("SELECT * FROM song WHERE danceability IS NULL AND songid > 3152");
			
			PreparedStatement updateStmt = connection.prepareStatement("UPDATE song SET danceability=?, loudness=?, hotness=?, energy=?, tempo=? WHERE songid=?");
			Thread.sleep(1000*120);
			while (rs.next()) 
			{
				
				SongSearcher songSearcher = new SongSearcher();
				Song s = songSearcher.searchSongByTitleAndArtist(rs.getString(3), rs.getString(2));
				if(s != null)
				{
					updateStmt.setFloat(1, (float) s.getDanceability());
					updateStmt.setFloat(2, (float) s.getLoudness());
					updateStmt.setFloat(3, (float) s.getSongHotttnesss());
					updateStmt.setFloat(4, (float) s.getEnergy());
					updateStmt.setFloat(5, (float) s.getTempo());
					updateStmt.setInt(6, rs.getInt(1));
					
					updateStmt.executeUpdate();
					
					System.out.print(rs.getString(2) + " - ");
					System.out.println(rs.getString(3));
				}
				
				Thread.sleep((long) (Math.random()*1000 + 1000));
			}

			
			connection.close();
		} catch (Exception e) 
		{
			e.printStackTrace();
		}
		
    }
}
