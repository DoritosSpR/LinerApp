import Foundation
import Combine

@MainActor
public final class MusicLibrary: ObservableObject {
    public static let shared = MusicLibrary()
    
    @Published public private(set) var tracks: [Track] = []
    @Published public private(set) var albums: [Album] = []
    @Published public private(set) var artists: [Artist] = []
    @Published public private(set) var playlists: [Playlist] = []
    @Published public private(set) var favorites: [Track] = []
    @Published public private(set) var recentlyPlayed: [Track] = []
    
    private let favoritesKey = "liner.favorites"
    private let recentlyPlayedKey = "liner.recentlyPlayed"
    
    private init() {
        loadPersistedData()
        if tracks.isEmpty { createSampleData() }
    }
    
    // MARK: - Persistence
    
    private func loadPersistedData() {
        if let data = UserDefaults.standard.data(forKey: "liner.favorites"),
           let decoded = try? JSONDecoder().decode([Track].self, from: data) {
            favorites = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "liner.recentlyPlayed"),
           let decoded = try? JSONDecoder().decode([Track].self, from: data) {
            recentlyPlayed = decoded
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: "liner.favorites")
        }
    }
    
    private func saveRecentlyPlayed() {
        if let data = try? JSONEncoder().encode(recentlyPlayed) {
            UserDefaults.standard.set(data, forKey: "liner.recentlyPlayed")
        }
    }
    
    // MARK: - Favorites
    
    public func toggleFavorite(_ track: Track) {
        if let index = favorites.firstIndex(where: { $0.id == track.id }) {
            favorites.remove(at: index)
        } else {
            var updatedTrack = track
            updatedTrack = Track(
                id: track.id, title: track.title, artist: track.artist, album: track.album,
                duration: track.duration, artworkURL: track.artworkURL, audioURL: track.audioURL,
                lyrics: track.lyrics, trackNumber: track.trackNumber, discNumber: track.discNumber,
                isExplicit: track.isExplicit, isFavorite: true, dateAdded: track.dateAdded,
                playCount: track.playCount, source: track.source
            )
            favorites.insert(updatedTrack, at: 0)
        }
        saveFavorites()
    }
    
    public func isFavorite(_ track: Track) -> Bool {
        favorites.contains { $0.id == track.id }
    }
    
    // MARK: - Recently Played
    
    public func addToRecentlyPlayed(_ track: Track) {
        recentlyPlayed.removeAll { $0.id == track.id }
        recentlyPlayed.insert(track, at: 0)
        if recentlyPlayed.count > 50 { recentlyPlayed = Array(recentlyPlayed.prefix(50)) }
        saveRecentlyPlayed()
    }
    
    // MARK: - Search Methods (for SearchService)
    
    public func searchTracks(query: String) -> [Track] {
        let lowercased = query.lowercased()
        return tracks.filter { $0.title.lowercased().contains(lowercased) || $0.artist.name.lowercased().contains(lowercased) }
    }
    
    public func searchArtists(query: String) -> [Artist] {
        let lowercased = query.lowercased()
        return artists.filter { $0.name.lowercased().contains(lowercased) }
    }
    
    public func searchAlbums(query: String) -> [Album] {
        let lowercased = query.lowercased()
        return albums.filter { $0.title.lowercased().contains(lowercased) }
    }
    
    public func searchPlaylists(query: String) -> [Playlist] {
        let lowercased = query.lowercased()
        return playlists.filter { $0.title.lowercased().contains(lowercased) }
    }
    
    // MARK: - Generic Search
    
    public func search(query: String) -> SearchResults {
        let lowercased = query.lowercased()
        let tracksResult = tracks.filter { $0.title.lowercased().contains(lowercased) || $0.artist.name.lowercased().contains(lowercased) }
        let artistsResult = artists.filter { $0.name.lowercased().contains(lowercased) }
        let albumsResult = albums.filter { $0.title.lowercased().contains(lowercased) }
        let playlistsResult = playlists.filter { $0.title.lowercased().contains(lowercased) }
        return SearchResults(tracks: tracksResult, artists: artistsResult, albums: albumsResult, playlists: playlistsResult)
    }
    
    // MARK: - Sample Data
    
    private func createSampleData() {
        let tameImpala = Artist(
            id: "artist-1",
            name: "Tame Impala",
            artworkURL: nil,
            genres: ["Psychedelic Rock", "Electronic"],
            biography: "Australian psychedelic music project led by Kevin Parker."
        )
        
        let currents = Artist(
            id: "artist-2",
            name: "The Currents",
            artworkURL: nil,
            genres: ["Indie Rock"],
            biography: "Australian indie rock band from Perth."
        )
        
        let sampleAlbum = Album(
            id: "album-1",
            title: "The Slow Rush",
            artist: tameImpala,
            artworkURL: nil,
            releaseDate: Date(),
            trackCount: 12,
            genre: "Psychedelic Rock"
        )
        
        let lyrics1 = Lyrics(synced: [
            SyncedLine(time: 5.2, text: "All this running around"),
            SyncedLine(time: 10.1, text: "I can't fight it long")
        ])
        
        let lyrics2 = Lyrics(synced: [
            SyncedLine(time: 3.1, text: "Someone said they left together"),
            SyncedLine(time: 8.2, text: "I ran out the door to get her")
        ])
        
        let lyrics3 = Lyrics(plain: "Eventually, we all find our way...")
        
        let sampleTracks = [
            Track(
                id: "track-1",
                title: "Let It Happen",
                artist: tameImpala,
                album: sampleAlbum,
                duration: 463,
                artworkURL: nil,
                audioURL: nil,
                lyrics: lyrics1,
                trackNumber: 1,
                discNumber: 1,
                isExplicit: false,
                isFavorite: true,
                dateAdded: Date(),
                playCount: 1234,
                source: .local
            ),
            Track(
                id: "track-2",
                title: "The Less I Know The Better",
                artist: tameImpala,
                album: sampleAlbum,
                duration: 216,
                artworkURL: nil,
                audioURL: nil,
                lyrics: lyrics2,
                trackNumber: 2,
                discNumber: 1,
                isExplicit: false,
                isFavorite: false,
                dateAdded: Date(),
                playCount: 987,
                source: .local
            ),
            Track(
                id: "track-3",
                title: "Eventually",
                artist: tameImpala,
                album: sampleAlbum,
                duration: 312,
                artworkURL: nil,
                audioURL: nil,
                lyrics: Lyrics(plain: "Eventually, we all find our way..."),
                trackNumber: 3,
                discNumber: 1,
                isExplicit: false,
                isFavorite: false,
                dateAdded: Date(),
                playCount: 876,
                source: .local
            ),
            Track(
                id: "track-4",
                title: "Let Me Down Easy",
                artist: currents,
                album: nil,
                duration: 245,
                artworkURL: nil,
                audioURL: nil,
                lyrics: nil,
                trackNumber: nil,
                discNumber: nil,
                isExplicit: false,
                isFavorite: false,
                dateAdded: Date(),
                playCount: 456,
                source: .local
            )
        ]
        
        tracks = sampleTracks
        albums = [sampleAlbum]
        artists = [tameImpala, currents]
        
        let currentUser = User(id: "user-1", username: "liner_user", displayName: "Liner User")
        
        let samplePlaylist = Playlist(
            id: "playlist-1",
            title: "Favorites",
            description: "Your favorite tracks",
            artworkURL: nil,
            tracks: sampleTracks.filter { $0.isFavorite },
            owner: currentUser,
            isPublic: false,
            isCollaborative: false
        )
        
        playlists = [samplePlaylist]
        favorites = sampleTracks.filter { $0.isFavorite }
        recentlyPlayed = Array(sampleTracks.prefix(3))
    }
}

public struct SearchResults {
    public let tracks: [Track]
    public let artists: [Artist]
    public let albums: [Album]
    public let playlists: [Playlist]
}
