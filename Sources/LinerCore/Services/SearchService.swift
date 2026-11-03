import Foundation; import Combine
@MainActor public final class SearchService: ObservableObject {
    public static let shared = SearchService()
    @Published public private(set) var searchResults: SearchResults = SearchResults()
    @Published public private(set) var isSearching = false
    @Published public private(set) var recentSearches: [String] = []
    private let ud = UserDefaults.standard; private let key = "liner.rs"; private var c = Set<AnyCancellable>()
    private init() { load() }
    func load() { if let d = UserDefaults.standard.data(forKey: "liner.rs"), let d = try? JSONDecoder().decode([String].self, from: d) { recentSearches = d } }
    func save() { if let e = try? JSONEncoder().encode(recentSearches) { UserDefaults.standard.set(e, forKey: "liner.rs") } }
    func search(_ q: String) {
        guard !q.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { searchResults = SearchResults(query: q); return }
        isSearching = true; searchResults = SearchResults(query: q)
        recentSearches.removeAll { $0.lowercased() == q.lowercased() }; recentSearches.insert(q, at: 0)
        if recentSearches.count > 10 { recentSearches = Array(recentSearches.prefix(10)) }
        save()
        let lt = MusicLibrary.shared.searchTracks(q: query); let la = MusicLibrary.shared.searchArtists(q: query)
        let lb = MusicLibrary.shared.searchAlbums(q: query); let lp = MusicLibrary.shared.searchPlaylists(q: query)
        DispatchQueue.main.async { [weak self] in self?.searchResults.tracks = lt; self?.searchResults.artists = la; self?.searchResults.albums = lb; self?.searchResults.playlists = lp }
        Task { await online(q) }
    }
    func online(_ q: String) async { try? await Task.sleep(nanoseconds: 500_000_000); await MainActor.run { [weak self] in self?.isSearching = false } }
    func clear() { searchResults = SearchResults() }
    func remove(_ q: String) { recentSearches.removeAll { $0 == q }; save() }
    func clearAll() { recentSearches = []; save() }
    private func save() { if let e = try? JSONEncoder().encode(recentSearches) { UserDefaults.standard.set(e, forKey: "liner.rs") } }
    private func load() { if let d = UserDefaults.standard.data(forKey: "liner.rs"), let d = try? JSONDecoder().decode([String].self, from: d) { recentSearches = d } }
}
public struct SearchResults { public var tracks: [Track] = []; public var artists: [Artist] = []; public var albums: [Album] = []; public var playlists: [Playlist] = []; public var query: String = ""; public var isEmpty: Bool { tracks.isEmpty && artists.isEmpty && albums.isEmpty && playlists.isEmpty }; public init() {} public init(query: String) { self.query = query } }