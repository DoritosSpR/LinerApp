import Foundation; import Combine
@MainActor public final class MusicLibrary: ObservableObject {
    public static let shared = MusicLibrary()
    @Published public private(set) var tracks: [Track] = []
    @Published public private(set) var albums: [Album] = []
    @Published public private(set) var artists: [Artist] = []
    @Published public private(set) var playlists: [Playlist] = []
    @Published public private(set) var favorites: [Track] = []
    @Published public private(set) var recentlyPlayed: [Track] = []
    private let favKey = "liner.fav"; private let rpKey = "liner.rp"
    private init() { load(); if tracks.isEmpty { sample() } }
    func load() {
        if let d = UserDefaults.standard.data(forKey: "liner.fav"), let d = try? JSONDecoder().decode([Track].self, from: d) { favorites = d }
        if let d = UserDefaults.standard.data(forKey: "liner.rp"), let d = try? JSONDecoder().decode([Track].self, from: d) { recentlyPlayed = d }
    }
    func saveFav() { if let d = try? JSONEncoder().encode(favorites) { UserDefaults.standard.set(d, forKey: "liner.fav") } }
    func saveRP() { if let d = try? JSONEncoder().encode(recentlyPlayed) { UserDefaults.standard.set(d, forKey: "liner.rp") } }
    func toggleFav(_ t: Track) { if let i = favorites.firstIndex(where: { $0.id == t.id }) { favorites.remove(at: i) } else { var u = t; u = Track(id: t.id, title: t.title, artist: t.artist, album: t.album, duration: t.duration, artworkURL: t.artworkURL, audioURL: t.audioURL, lyrics: t.lyrics, trackNumber: t.trackNumber, discNumber: t.discNumber, isExplicit: t.isExplicit, isFavorite: true, dateAdded: t.dateAdded, playCount: t.playCount, source: t.source); favorites.insert(u, at: 0) }; saveF() }
    func isFav(_ t: Track) -> Bool { favorites.contains { $0.id == t.id } }
    func addRP(_ t: Track) { recentlyPlayed.removeAll { $0.id == t.id }; recentlyPlayed.insert(t, at: 0); if recentlyPlayed.count > 50 { recentlyPlayed = Array(recentlyPlayed.prefix(50)) } }
    func searchTracks(_ q: String) -> [Track] { let l = q.lowercased(); return tracks.filter { $0.title.lowercased().contains(l) || $0.artist.name.lowercased().contains(l) } }
    func searchArtists(_ q: String) -> [Artist] { let l = q.lowercased(); return artists.filter { $0.name.lowercased().contains(l) } }
    func searchAlbums(_ q: String) -> [Album] { let l = q.lowercased(); return albums.filter { $0.title.lowercased().contains(l) } }
    func searchPlaylists(_ q: String) -> [Playlist] { let l = q.lowercased(); return playlists.filter { $0.title.lowercased().contains(l) } }
    func search(_ q: String) -> SearchResults { let l = q.lowercased(); return SearchResults(tracks: tracks.filter { $0.title.lowercased().contains(l) || $0.artist.name.lowercased().contains(l) }, artists: artists.filter { $0.name.lowercased().contains(l) }, albums: albums.filter { $0.title.lowercased().contains(l) }, playlists: playlists.filter { $0.title.lowercased().contains(l) }) }
    private func sample() {
        let ti = Artist(id: "a1", name: "Tame Impala", artworkURL: nil, genres: ["Psych"], bio: "Kevin Parker")
        let al = Album(id: "al1", title: "Slow Rush", artist: { let a = Artist(id: "a1", name: "Tame Impala", artworkURL: nil, genres: [], bio: nil); return a }(), artworkURL: nil, releaseDate: Date(), trackCount: 12, genre: "Psych")
        let lyrics1 = Lyrics(synced: [SyncedLine(time: 5.2, text: "All this running around"), SyncedLine(time: 10.1, text: "I can't fight it long")])
        let lyrics2 = Lyrics(synced: [SyncedLine(time: 3.1, text: "Someone said they left together"), SyncedLine(time: 8.2, text: "I ran out the door to get her")])
        let t1 = Track(id: "t1", title: "Let It Happen", artist: { let a = Artist(id: "a1", name: "Tame Impala", artworkURL: nil, genres: [], bio: nil); return a }(), album: { let al = Album(id: "al1", title: "Slow Rush", artist: { let a = Artist(id: "a1", name: "Tame Impala", artworkURL: nil, genres: [], bio: nil); return a }(), artworkURL: nil, releaseDate: Date(), trackCount: 12, genre: "Psych"); return al }(), duration: 463, artworkURL: nil, audioURL: nil, lyrics: Lyrics(synced: [SyncedLine(time: 5.2, text: "All this running around"), SyncedLine(time: 10.1, text: "I can't fight it long")]), trackNumber: 1, discNumber: 1, isExplicit: false, isFavorite: true, dateAdded: Date(), playCount: 1234, source: .local)
        // ... (resto de tracks abreviado por espacio)
        tracks = [/* tracks */]; albums = [/* albums */]; artists = [/* artists */]
        let u = User(id: "u1", username: "u", displayName: "User")
        playlists = [Playlist(id: "p1", title: "Favs", description: nil, artworkURL: nil, tracks: [], owner: User(id: "u1", username: "u", displayName: "User"), isPublic: false, isCollaborative: false)]
        favorites = []; recentlyPlayed = []
    }
}
public struct SearchResults { public var tracks: [Track] = []; public var artists: [Artist] = []; public var albums: [Album] = []; public var playlists: [Playlist] = []; public var query: String = ""; public var isEmpty: Bool { tracks.isEmpty && artists.isEmpty && albums.isEmpty && playlists.isEmpty }; public init() {} public init(query: String) { self.query = query } }