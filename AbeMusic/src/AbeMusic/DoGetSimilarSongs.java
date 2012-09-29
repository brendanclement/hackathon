package AbeMusic;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import java.util.List;

public class DoGetSimilarSongs extends Thread 
{
	public static int NUMBER_OF_SIMILAR_SONGS = 10;
	
	public void run()
	{
		try 
		{
			Class.forName(AbeMusic.DB_DRIVER).newInstance();
			Connection connection = DriverManager.getConnection(AbeMusic.DB_URL+AbeMusic.DB_NAME,AbeMusic.DB_USER,AbeMusic.DB_PASSWORD);
			
			Statement stmt = connection.createStatement();
			ResultSet rs = stmt.executeQuery("SELECT * FROM song");
			
			PreparedStatement updateStmt = connection.prepareStatement("INSERT INTO similar_songs (songid, title, artist) VALUES (?,?,?)");
			while (rs.next()) 
			{
				SimilarSongFinder songFinder = new SimilarSongFinder();
				
				List<AbeMusicSong> songList = null;
				if(rs.getString(9) != null && rs.getString(9) != "")
				{
					songList = songFinder.findSimilarSong(rs.getString(9), NUMBER_OF_SIMILAR_SONGS);
				}
					
				if(songList == null || songList.isEmpty())
				{
					Thread.sleep((long) (Math.random()*1000 + 1000));
					continue;
				}
				
				for(AbeMusicSong s : songList)
				{
					updateStmt.setInt(1, rs.getInt(1));
					updateStmt.setString(2, s.Name);
					updateStmt.setString(3, s.Artist);
					
					System.out.println("Insert similar song " + s.Name); 
					
					updateStmt.executeUpdate();
				}
				
				Thread.sleep((long) (Math.random()*1000 + 1000));
			}
			connection.close();	
		} 
		catch (Exception e) 
		{
			e.printStackTrace();
		}

	}
}
