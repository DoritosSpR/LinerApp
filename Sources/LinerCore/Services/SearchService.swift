import Foundation
import Combine

final class SearchService: ObservableObject {
    static let shared = SearchService()

    @Published private(set) var searchResults: SearchResults = SearchResults()
    @Published private(set) var isSearching = false
    @Published private(set) var recentSearches: [String] = []

    private let userDefaults = UserDefaults.standard
    private let recentSearchesKey = "liner.recentSearches"
    private var cancellables = Set<AnyCancellable>()

    struct SearchResults {
        var tracks: [Track] = []
        var artists: [Artist] = []
        var albums: [Album] = []
        var playlists: [Playlist] = []
        var query: String = ""

        var isEmpty: Bool {
            tracks.isEmpty && artists.isEmpty && albums.isEmpty && playlists.isEmpty
        }
    }

    private init() {
        loadRecentSearches()
    }

    private func loadRecentSearches() {
        if let data = userDefaults.data(forKey: recentSearchesKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            recentSearches = decoded
        }
    }

    private func saveRecentSearches() {
        if let encoded = try? JSONEncoder().encode(recentSearches) {
            userDefaults.set(encoded, forKey: recentSearchesKey)
        }
    }

    func search(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = SearchResults(query: query)
            return
        }

        isSearching = true
        searchResults = SearchResults(query: query)

        // Add to recent searches
        recentSearches.removeAll { $0.lowercased() == query.lowercased() }
        recentSearches.insert(query, at: 0)
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        saveRecentSearches()

        // Local library search
        let localTracks = MusicLibrary.shared.searchTracks(query: query)
        let localArtists = MusicLibrary.shared.searchArtists(query: query)
        let localAlbums = MusicLibrary.shared.searchAlbums(query: query)
        let localPlaylists = MusicLibrary.shared.searchPlaylists(query: query)

        // Update with local results immediately
        DispatchQueue.main.async { [weak self] in
            self?.searchResults.tracks = localTracks
            self?.searchResults.artists = localArtists
            self?.searchResults.albums = localAlbums
            self?.searchResults.playlists = localPlaylists
        }

        // Simulate online search (would be real API calls in production)
        Task {
            await performOnlineSearch(query: query)
        }
    }

    private func performOnlineSearch(query: String) async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)

        // In a real app, this would call YouTube, SoundCloud, etc. APIs
        // For now, we'll just use local results

        await MainActor.run { [weak self] in
            self?.isSearching = false
        }
    }

    func clearSearch() {
        searchResults = SearchResults()
    }

    func removeRecentSearch(_ query: String) {
        recentSearches.removeAll { $0 == query }
        saveRecentSearches()
    }

    func clearRecentSearches() {
        recentSearches = []
        saveRecentSearches()
    }
}