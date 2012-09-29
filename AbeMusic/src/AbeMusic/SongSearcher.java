package AbeMusic;

import java.util.List;

import com.echonest.api.v4.Artist;
import com.echonest.api.v4.ArtistParams;
import com.echonest.api.v4.EchoNestAPI;
import com.echonest.api.v4.EchoNestException;
import com.echonest.api.v4.Params;
import com.echonest.api.v4.Song;
import com.echonest.api.v4.SongCatalog;
import com.echonest.api.v4.SongCatalogItem;
import com.echonest.api.v4.SongParams;


public class SongSearcher {
    private EchoNestAPI en;

    public SongSearcher() throws EchoNestException {
        en = new EchoNestAPI();
        en.setTraceSends(false);
        en.setTraceRecvs(false);
    }

    public void dumpSong(Song song) throws EchoNestException {
        System.out.printf("%s\n", song.getTitle());
        System.out.printf("   artist: %s\n", song.getArtistName());
        System.out.printf("   dur   : %.3f\n", song.getDuration());
        System.out.printf("   BPM   : %.3f\n", song.getTempo());
        System.out.printf("   Mode  : %d\n", song.getMode());
        System.out.printf("   S hot : %.3f\n", song.getSongHotttnesss());
        System.out.printf("   A hot : %.3f\n", song.getArtistHotttnesss());
        System.out.printf("   A fam : %.3f\n", song.getArtistFamiliarity());
        System.out.printf("   A loc : %s\n", song.getArtistLocation());
        System.out.printf("   ID : %s\n", song.getID());
    }

    public void searchSongsByArtist(String artist, int results)
            throws EchoNestException {
        Params p = new Params();
        p.add("artist", artist);
        p.add("bucket", "audio_summary");
        p.add("bucket", "artist_hotttnesss");
        p.add("results", results);

        List<Song> songs = en.searchSongs(p);
        for (Song song : songs) {
            dumpSong(song);
            System.out.println();
        }
    }

    public void searchSongsByTempo(String artist, int results)
            throws EchoNestException {
        Params p = new Params();
        p.add("artist", artist);
        p.add("bucket", "audio_summary");
        p.add("results", results);
        p.add("sort", "tempo-asc");

        List<Song> songs = en.searchSongs(p);
        for (Song song : songs) {
            System.out.printf("%.0f %s %s\n", song.getTempo(), song
                    .getArtistName(), song.getTitle());
        }
    }

    public void searchForFastestSongsByArtist(String artist, int results)
            throws EchoNestException {
        ArtistParams ap = new ArtistParams();
        ap.addName(artist);
        List<Artist> artists = en.searchArtists(ap);
        if (artists.size() > 0) {
            Params p = new Params();
            p.add("artist_id", artists.get(0).getID());
            p.add("bucket", "audio_summary");
            p.add("results", results);
            p.add("sort", "tempo-desc");

            List<Song> songs = en.searchSongs(p);
            for (Song song : songs) {
                System.out.printf("%.0f %s %s\n", song.getTempo(), song
                        .getArtistName(), song.getTitle());
            }
        }
    }

    public void searchSongsByTitle(String title, int results)
            throws EchoNestException {
        Params p = new Params();
        p.add("title", title);
        p.add("results", results);
        List<Song> songs = en.searchSongs(p);
        for (Song song : songs) {
            dumpSong(song);
            System.out.println();
        }
    }

    public Double getTempo(String artistName, String title)
            throws EchoNestException {
        SongParams p = new SongParams();
        p.setArtist(artistName);
        p.setTitle(title);
        p.setResults(1);
        p.includeAudioSummary();
        List<Song> songs = en.searchSongs(p);
        if (songs.size() > 0) {
            double tempo = songs.get(0).getTempo();
            return Double.valueOf(tempo);
        } else {
            return null;
        }
    }
    
    public String getNameFromID(String id) throws EchoNestException
    {
        SongCatalog songs = en.getSongCatalogByID(id);
        List<SongCatalogItem>songlist = songs.read(0,1);
        if (songlist.size() > 0)
            return songlist.get(0).getSongName();

        return "That ID doesn't exist!";
    }

    public void stats() {
        en.showStats();
    }
}
