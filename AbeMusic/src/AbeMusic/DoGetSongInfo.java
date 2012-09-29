package AbeMusic;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import com.echonest.api.v4.Song;

public class DoGetSongInfo extends Thread 
{
	public void run()
	{	
		try 
		{
			Class.forName(AbeMusic.DB_DRIVER).newInstance();
			Connection connection = DriverManager.getConnection(AbeMusic.DB_URL+AbeMusic.DB_NAME,AbeMusic.DB_USER,AbeMusic.DB_PASSWORD);
			
			Statement stmt = connection.createStatement();
			ResultSet rs = stmt.executeQuery("SELECT * FROM song");
			
			PreparedStatement updateStmt = connection.prepareStatement("UPDATE song SET danceability=?, loudness=?, hotness=?, energy=?, tempo=?, echonest_id=? WHERE songid=?");
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
					updateStmt.setString(6, s.getID());
					updateStmt.setInt(7, rs.getInt(1));
					
					updateStmt.executeUpdate();
					
					System.out.print(rs.getString(2) + " - ");
					System.out.println(rs.getString(3));
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
