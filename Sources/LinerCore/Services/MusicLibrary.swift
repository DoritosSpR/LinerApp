import Foundation
import Combine

final class MusicLibrary: ObservableObject {
    static let shared = MusicLibrary()

    @Published private(set) var tracks: [Track] = []
    @Published private(set) var playlists: [Playlist] = []
    @Published private(set) var artists: [Artist] = []
    @Published private(set) var albums: [Album] = []
    @Published private(set) var recentlyPlayed: [Track] = []
    @Published private(set) var favorites: [Track] = []

    private let userDefaults = UserDefaults.standard
    private let tracksKey = "liner.tracks"
    private let playlistsKey = "liner.playlists"
    private let recentlyPlayedKey = "liner.recentlyPlayed"
    private let favoritesKey = "liner.favorites"

    private init() {
        loadPersistedData()
        if tracks.isEmpty {
            loadSampleData()
        }
    }

    // MARK: - Persistence

    private func loadPersistedData() {
        if let data = userDefaults.data(forKey: tracksKey),
           let decoded = try? JSONDecoder().decode([Track].self, from: data) {
            tracks = decoded
        }

        if let data = userDefaults.data(forKey: playlistsKey),
           let decoded = try? JSONDecoder().decode([Playlist].self, from: data) {
            playlists = decoded
        }

        if let data = userDefaults.data(forKey: recentlyPlayedKey),
           let decoded = try? JSONDecoder().decode([Track].self, from: data) {
            recentlyPlayed = decoded
        }

        if let data = userDefaults.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([Track].self, from: data) {
            favorites = decoded
        }

        rebuildDerivedCollections()
    }

    private func saveTracks() {
        if let encoded = try? JSONEncoder().encode(tracks) {
            userDefaults.set(encoded, forKey: tracksKey)
        }
    }

    private func savePlaylists() {
        if let encoded = try? JSONEncoder().encode(playlists) {
            userDefaults.set(encoded, forKey: playlistsKey)
        }
    }

    private func saveRecentlyPlayed() {
        if let encoded = try? JSONEncoder().encode(recentlyPlayed) {
            userDefaults.set(encoded, forKey: recentlyPlayedKey)
        }
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            userDefaults.set(encoded, forKey: favoritesKey)
        }
    }

    private func rebuildDerivedCollections() {
        var artistDict: [String: Artist] = [:]
        var albumDict: [String: Album] = [:]

        for track in tracks {
            artistDict[track.artist.id] = track.artist
            if let album = track.album {
                albumDict[album.id] = album
            }
        }

        artists = Array(artistDict.values).sorted { $0.name < $1.name }
        albums = Array(albumDict.values).sorted { $0.title < $1.title }
    }

    // MARK: - Track Management

    func addTrack(_ track: Track) {
        tracks.append(track)
        saveTracks()
        rebuildDerivedCollections()
    }

    func addTracks(_ newTracks: [Track]) {
        tracks.append(contentsOf: newTracks)
        saveTracks()
        rebuildDerivedCollections()
    }

    func removeTrack(_ track: Track) {
        tracks.removeAll { $0.id == track.id }
        saveTracks()
        rebuildDerivedCollections()
    }

    func updateTrack(_ track: Track) {
        if let index = tracks.firstIndex(where: { $0.id == track.id }) {
            tracks[index] = track
            saveTracks()
        }
    }

    // MARK: - Recently Played

    func addToRecentlyPlayed(_ track: Track) {
        recentlyPlayed.removeAll { $0.id == track.id }
        recentlyPlayed.insert(track, at: 0)
        if recentlyPlayed.count > 50 {
            recentlyPlayed = Array(recentlyPlayed.prefix(50))
        }
        saveRecentlyPlayed()
    }

    // MARK: - Favorites

    func toggleFavorite(_ track: Track) {
        if let index = favorites.firstIndex(where: { $0.id == track.id }) {
            favorites.remove(at: index)
            var updatedTrack = track
            // Can't mutate, need to create new - handled in UI
        } else {
            favorites.insert(track, at: 0)
        }
        saveFavorites()
    }

    func isFavorite(_ track: Track) -> Bool {
        favorites.contains { $0.id == track.id }
    }

    // MARK: - Playlists

    func createPlaylist(_ playlist: Playlist) {
        playlists.append(playlist)
        savePlaylists()
    }

    func updatePlaylist(_ playlist: Playlist) {
        if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
            playlists[index] = playlist
            savePlaylists()
        }
    }

    func deletePlaylist(_ playlist: Playlist) {
        playlists.removeAll { $0.id == playlist.id }
        savePlaylists()
    }

    func addTrackToPlaylist(_ track: Track, playlist: Playlist) {
        var updatedPlaylist = playlist
        var updatedTracks = playlist.tracks
        if !updatedTracks.contains(where: { $0.id == track.id }) {
            updatedTracks.append(track)
            updatedPlaylist = Playlist(
                id: playlist.id,
                title: playlist.title,
                description: playlist.description,
                artworkURL: playlist.artworkURL,
                tracks: updatedTracks,
                owner: playlist.owner,
                isPublic: playlist.isPublic,
                isCollaborative: playlist.isCollaborative,
                trackCount: updatedTracks.count,
                totalDuration: updatedTracks.reduce(0) { $0 + $1.duration },
                dateCreated: playlist.dateCreated,
                dateModified: Date()
            )
            updatePlaylist(updatedPlaylist)
        }
    }

    // MARK: - Search

    func searchTracks(query: String) -> [Track] {
        guard !query.isEmpty else { return tracks }

        let lowercased = query.lowercased()
        return tracks.filter { track in
            track.title.lowercased().contains(lowercased) ||
            track.artist.name.lowercased().contains(lowercased) ||
            track.album?.title.lowercased().contains(lowercased) == true
        }
    }

    func searchArtists(query: String) -> [Artist] {
        guard !query.isEmpty else { return artists }

        let lowercased = query.lowercased()
        return artists.filter { $0.name.lowercased().contains(lowercased) }
    }

    func searchAlbums(query: String) -> [Album] {
        guard !query.isEmpty else { return albums }

        let lowercased = query.lowercased()
        return albums.filter { $0.title.lowercased().contains(lowercased) }
    }

    func searchPlaylists(query: String) -> [Playlist] {
        guard !query.isEmpty else { return playlists }

        let lowercased = query.lowercased()
        return playlists.filter { $0.title.lowercased().contains(lowercased) }
    }

    // MARK: - Sample Data

    private func loadSampleData() {
        let sampleArtist = Artist(
            id: "artist-1",
            name: "Tame Impala",
            artworkURL: nil,
            genres: ["Psychedelic Rock", "Electronic"]
        )

        let sampleAlbum = Album(
            id: "album-1",
            title: "Currents",
            artist: sampleArtist,
            artworkURL: nil,
            releaseDate: Date(),
            trackCount: 13
        )

        let sampleTracks = [
            Track(
                id: "track-1",
                title: "Let It Happen",
                artist: sampleArtist,
                album: sampleAlbum,
                duration: 465,
                artworkURL: nil,
                audioURL: nil,
                source: .local,
                lyrics: Lyrics(
                    synced: [
                        SyncedLine(time: 5.2, text: "All this running around", syllables: nil),
                        SyncedLine(time: 10.1, text: "I can't fight it long", syllables: nil),
                        SyncedLine(time: 15.3, text: "Something is happening", syllables: nil),
                        SyncedLine(time: 20.0, text: "I can't fight this feeling", syllables: nil),
                    ],
                    plain: "All this running around\nI can't fight it long\nSomething is happening\nI can't fight this feeling",
                    language: "en"
                ),
                playCount: 1234,
                isFavorite: true,
                dateAdded: Date()
            ),
            Track(
                id: "track-2",
                title: "The Less I Know The Better",
                artist: sampleArtist,
                album: sampleAlbum,
                duration: 216,
                artworkURL: nil,
                audioURL: nil,
                source: .local,
                lyrics: Lyrics(
                    synced: [
                        SyncedLine(time: 3.1, text: "Someone said they left together", syllables: nil),
                        SyncedLine(time: 8.2, text: "I ran out the door to get her", syllables: nil),
                        SyncedLine(time: 13.0, text: "She was holding hands with Trevor", syllables: nil),
                        SyncedLine(time: 18.5, text: "Not the greatest feeling ever", syllables: nil),
                    ],
                    plain: nil,
                    language: "en"
                ),
                playCount: 5678,
                isFavorite: true,
                dateAdded: Date()
            ),
            Track(
                id: "track-3",
                title: "Eventually",
                artist: sampleArtist,
                album: sampleAlbum,
                duration: 324,
                artworkURL: nil,
                audioURL: nil,
                source: .local,
                lyrics: nil,
                playCount: 987,
                isFavorite: false,
                dateAdded: Date()
            )
        ]

        tracks = sampleTracks
        artists = [sampleArtist]
        albums = [sampleAlbum]

        let samplePlaylist = Playlist(
            id: "playlist-1",
            title: "Favorites",
            description: "My favorite tracks",
            artworkURL: nil,
            tracks: sampleTracks.filter { $0.isFavorite },
            owner: nil,
            isPublic: false,
            isCollaborative: false,
            trackCount: 2,
            totalDuration: 681,
            dateCreated: Date(),
            dateModified: Date()
        )

        playlists = [samplePlaylist]
        favorites = sampleTracks.filter { $0.isFavorite }
        recentlyPlayed = Array(sampleTracks.prefix(3))

        saveTracks()
        savePlaylists()
        saveFavorites()
        saveRecentlyPlayed()
    }
}