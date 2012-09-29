package AbeMusic;

import java.net.*;
import java.util.List;
import java.util.ArrayList;
import java.io.*; 

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

public class SimilarSongFinder
{
    SimilarSongFinder()
    {
	
    }
    
    List<AbeMusicSong> findSimilarSong(String songId, int number)
    {
    	if(songId == null || songId.isEmpty() || songId == "")
    		return null;
    	
		String URLstring = "http://developer.echonest.com/api/v4/playlist/static?api_key=N6E4NIOVYMTHNDM8J&song_id=" + songId + "&format=json&results=" + number + "&type=song-radio";
		List<AbeMusicSong> resultList = new ArrayList<AbeMusicSong>();
		String result = "";
		try
		{
		    URL url = new URL(URLstring);
		    
			try
			{
			    URLConnection connection = url.openConnection();
			    BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
			    String inputLine;
	
			    while ((inputLine = in.readLine()) != null) 
				result += inputLine;
			    in.close();
			}
			catch(IOException e)
			{
			    e.printStackTrace();
			    return null;
			}
		}
		catch (MalformedURLException e)
		{
		    e.printStackTrace();
		    return null;
		}
		
		//System.out.println(result);
		
		Object obj = JSONValue.parse(result);
		JSONObject jsonObject = (JSONObject) obj;
		JSONObject response = (JSONObject)jsonObject.get("response");
		JSONArray songs = (JSONArray)response.get("songs");
		
		for (int i=0; i<songs.size(); i++) 
		{
		    AbeMusicSong song = new AbeMusicSong();
		    song.Artist = ((JSONObject)songs.get(i)).get("artist_name").toString();
		    song.Name = ((JSONObject)songs.get(i)).get("title").toString();
		    //System.out.println(resultId);
		    resultList.add(song);
		}
		
		return resultList;
    }
}


