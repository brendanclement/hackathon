package AbeMusic;

import com.echonest.api.v4.EchoNestException;

public class AbeMusic 
{
	public static String DB_URL = "jdbc:mysql://hackathon.cdgfhz5tzus1.us-west-2.rds.amazonaws.com/";
	public static String DB_NAME = "hackathon";
	public static String DB_USER = "admin";
	public static String DB_PASSWORD = "javapython";
	public static String DB_DRIVER = "com.mysql.jdbc.Driver";
	
    public static void main (String [] args) throws EchoNestException
    {
		System.setProperty("ECHO_NEST_API_KEY", "AKVMXWRE6L6YD0R4B");

		System.out.println("Starting...");
		
		Thread songInfoThread = new DoGetSongInfo();
		songInfoThread.start();
		
		Thread similarSongThread = new DoGetSimilarSongs();
		similarSongThread.start();		
    }
}
