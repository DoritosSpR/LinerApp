import SwiftUI

// MARK: - Library View

struct LibraryView: View {
    @EnvironmentObject private var musicLibrary: MusicLibrary
    @EnvironmentObject private var audioPlayer: AudioPlayer
    @State private var selectedFilter: LibraryFilter = .all
    @State private var sortOption: SortOption = .recentlyAdded
    @State private var searchText = ""
    @State private var showingPlaylistCreator = false
    @State private var newPlaylistName = ""

    enum LibraryFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case tracks = "Tracks"
        case artists = "Artists"
        case albums = "Albums"
        case playlists = "Playlists"

        var id: String { rawValue }
        var icon: String {
            switch self {
            case .all: return "music.note.list"
            case .tracks: return "music.note"
            case .artists: return "person.2"
            case .albums: return "square.stack"
            case .playlists: return "list.bullet.rectangle"
            }
        }
    }

    enum SortOption: String, CaseIterable, Identifiable {
        case recentlyAdded = "Recently Added"
        case recentlyPlayed = "Recently Played"
        case alphabetical = "A-Z"
        case artist = "Artist"
        case playCount = "Most Played"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.linerBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Filter tabs
                    FilterTabsView(selectedFilter: $selectedFilter)

                    // Content
                    ScrollView {
                        LazyVStack(spacing: LinerSpacing.xl, pinnedViews: [.sectionHeaders]) {
                            switch selectedFilter {
                            case .all:
                                AllLibraryContent()
                            case .tracks:
                                TracksContent(sortOption: $sortOption, searchText: $searchText)
                            case .artists:
                                ArtistsContent(searchText: $searchText)
                            case .albums:
                                AlbumsContent(searchText: $searchText)
                            case .playlists:
                                PlaylistsContent(
                                    searchText: $searchText,
                                    showingPlaylistCreator: $showingPlaylistCreator,
                                    newPlaylistName: $newPlaylistName
                                )
                            }
                        }
                        .padding(.bottom, 120) // Space for mini player
                    }
                    .refreshable {
                        // Pull to refresh
                    }
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort By", selection: $sortOption) {
                            ForEach(SortOption.allCases) { option in
                                Label(option.rawValue, systemImage: sortIcon(for: option))
                                    .tag(option)
                            }
                        }
                    } label: {
                        IconButton(
                            icon: "arrow.up.arrow.down",
                            size: .medium,
                            variant: .glass
                        ) {}
                    }
                }
            }
            .sheet(isPresented: $showingPlaylistCreator) {
                CreatePlaylistSheet(
                    name: $newPlaylistName,
                    isPresented: $showingPlaylistCreator,
                    onCreate: { name in
                        createPlaylist(name: name)
                    }
                )
            }
        }
    }

    private func sortIcon(for option: SortOption) -> String {
        switch option {
        case .recentlyAdded: return "clock.badge.plus"
        case .recentlyPlayed: return "clock.arrow.circlepath"
        case .alphabetical: return "textformat.abc"
        case .artist: return "person"
        case .playCount: return "chart.bar"
        }
    }

    private func createPlaylist(name: String) {
        let playlist = Playlist(
            id: UUID().uuidString,
            title: name,
            description: nil,
            artworkURL: nil,
            tracks: [],
            owner: nil,
            isPublic: false,
            isCollaborative: false,
            trackCount: 0,
            totalDuration: 0,
            dateCreated: Date(),
            dateModified: Date()
        )
        musicLibrary.createPlaylist(playlist)
    }
}

// MARK: - Filter Tabs

struct FilterTabsView: View {
    @Binding var selectedFilter: LibraryView.LibraryFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LinerSpacing.sm) {
                ForEach(LibraryView.LibraryFilter.allCases) { filter in
                    FilterTab(
                        filter: filter,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.linerSpring) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, LinerSpacing.md)
        }
        .padding(.vertical, LinerSpacing.sm)
        .background(
            Color.linerBackground
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
    }
}

struct FilterTab: View {
    let filter: LibraryView.LibraryFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            LinerHaptic.selection()
            action()
        }) {
            HStack(spacing: LinerSpacing.xs) {
                Image(systemName: filter.icon)
                    .font(.linerSubheadline.weight(.medium))
                Text(filter.rawValue)
                    .font(.linerSubheadline.weight(.medium))
            }
            .foregroundColor(isSelected ? .linerTextInverse : .linerTextSecondary)
            .padding(.horizontal, LinerSpacing.lg)
            .padding(.vertical, LinerSpacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? Color.linerGradientPrimary : Color.linerGlassLight)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.linerBorder.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.linerSpring, value: isSelected)
    }
}

// MARK: - All Library Content

struct AllLibraryContent: View {
    @EnvironmentObject private var musicLibrary: MusicLibrary

    var body: some View {
        VStack(spacing: LinerSpacing.xl) {
            // Recently Played
            if !musicLibrary.recentlyPlayed.isEmpty {
                SectionHeader(title: "Recently Played", actionTitle: "See All") {
                    // Navigate to recently played
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: LinerSpacing.md) {
                        ForEach(musicLibrary.recentlyPlayed.prefix(10)) { track in
                            MediaCard(
                                title: track.title,
                                subtitle: track.artist.name,
                                artworkURL: track.artworkURL,
                                size: .medium
                            ) {
                                // Play track
                            }
                        }
                    }
                    .padding(.horizontal, LinerSpacing.md)
                }
            }

            // Favorites
            if !musicLibrary.favorites.isEmpty {
                SectionHeader(title: "Favorites", actionTitle: "See All") {}

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: LinerSpacing.md) {
                        ForEach(musicLibrary.favorites.prefix(10)) { track in
                            MediaCard(
                                title: track.title,
                                subtitle: track.artist.name,
                                artworkURL: track.artworkURL,
                                size: .medium
                            ) {}
                        }
                    }
                    .padding(.horizontal, LinerSpacing.md)
                }
            }

            // Playlists
            if !musicLibrary.playlists.isEmpty {
                SectionHeader(title: "Playlists", actionTitle: "See All") {}

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: LinerSpacing.md) {
                        ForEach(musicLibrary.playlists.prefix(10)) { playlist in
                            MediaCard(
                                title: playlist.title,
                                subtitle: "\(playlist.trackCount) songs",
                                artworkURL: playlist.artworkURL,
                                size: .medium
                            ) {}
                        }
                    }
                    .padding(.horizontal, LinerSpacing.md)
                }
            }

            // Artists
            if !musicLibrary.artists.isEmpty {
                SectionHeader(title: "Artists", actionTitle: "See All") {}

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: LinerSpacing.md) {
                        ForEach(musicLibrary.artists.prefix(10)) { artist in
                            MediaCard(
                                title: artist.name,
                                subtitle: "\(artist.genres.first ?? "Artist")",
                                artworkURL: artist.artworkURL,
                                size: .medium
                            ) {}
                        }
                    }
                    .padding(.horizontal, LinerSpacing.md)
                }
            }
        }
    }
}

// MARK: - Tracks Content

struct TracksContent: View {
    @EnvironmentObject private var musicLibrary: MusicLibrary
    @EnvironmentObject private var audioPlayer: AudioPlayer
    @Binding var sortOption: LibraryView.SortOption
    @Binding var searchText: String

    var filteredTracks: [Track] {
        var tracks = musicLibrary.tracks

        if !searchText.isEmpty {
            tracks = tracks.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.artist.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch sortOption {
        case .recentlyAdded:
            tracks.sort { $0.dateAdded > $1.dateAdded }
        case .recentlyPlayed:
            // Would need play history
            tracks.sort { $0.dateAdded > $1.dateAdded }
        case .alphabetical:
            tracks.sort { $0.title < $1.title }
        case .artist:
            tracks.sort { $0.artist.name < $1.artist.name }
        case .playCount:
            tracks.sort { $0.playCount > $1.playCount }
        }

        return tracks
    }

    var body: some View {
        VStack(spacing: LinerSpacing.md) {
            // Search bar
            SearchBar(text: $searchText, placeholder: "Search tracks...")

            // Track list
            if filteredTracks.isEmpty {
                EmptyState(
                    icon: "music.note",
                    title: searchText.isEmpty ? "No Tracks" : "No Results",
                    message: searchText.isEmpty
                        ? "Add music to your library to get started"
                        : "Try a different search term"
                )
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(filteredTracks.indices, id: \.self) { index in
                        let track = filteredTracks[index]
                        TrackRow(
                            track: track,
                            index: index + 1,
                            showArtist: true,
                            showAlbum: true
                        ) {
                            // Tap action
                        } onPlay: {
                            audioPlayer.load(track: track, queue: filteredTracks, startIndex: index)
                        } onMore: {
                            // Show context menu
                        }
                        .padding(.horizontal, LinerSpacing.md)
                    }
                }
            }
        }
    }
}

// MARK: - Artists Content

struct ArtistsContent: View {
    @EnvironmentObject private var musicLibrary: MusicLibrary
    @Binding var searchText: String

    var filteredArtists: [Artist] {
        if searchText.isEmpty { return musicLibrary.artists }
        return musicLibrary.artists.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: LinerSpacing.md) {
            SearchBar(text: $searchText, placeholder: "Search artists...")

            if filteredArtists.isEmpty {
                EmptyState(icon: "person.2", title: "No Artists", message: "Add music to see artists")
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 160), spacing: LinerSpacing.md)],
                    spacing: LinerSpacing.md
                ) {
                    ForEach(filteredArtists) { artist in
                        MediaCard(
                            title: artist.name,
                            subtitle: "\(artist.genres.first ?? "Artist")",
                            artworkURL: artist.artworkURL,
                            size: .medium
                        ) {}
                    }
                }
                .padding(.horizontal, LinerSpacing.md)
            }
        }
    }
}

// MARK: - Albums Content

struct AlbumsContent: View {
    @EnvironmentObject private var musicLibrary: MusicLibrary
    @Binding var searchText: String

    var filteredAlbums: [Album] {
        if searchText.isEmpty { return musicLibrary.albums }
        return musicLibrary.albums.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: LinerSpacing.md) {
            SearchBar(text: $searchText, placeholder: "Search albums...")

            if filteredAlbums.isEmpty {
                EmptyState(icon: "square.stack", title: "No Albums", message: "Add music to see albums")
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 160), spacing: LinerSpacing.md)],
                    spacing: LinerSpacing.md
                ) {
                    ForEach(filteredAlbums) { album in
                        MediaCard(
                            title: album.title,
                            subtitle: album.artist.name,
                            artworkURL: album.artworkURL,
                            size: .medium
                        ) {}
                    }
                }
                .padding(.horizontal, LinerSpacing.md)
            }
        }
    }
}

// MARK: - Playlists Content

struct PlaylistsContent: View {
    @EnvironmentObject private var musicLibrary: MusicLibrary
    @Binding var searchText: String
    @Binding var showingPlaylistCreator: Bool
    @Binding var newPlaylistName: String

    var filteredPlaylists: [Playlist] {
        if searchText.isEmpty { return musicLibrary.playlists }
        return musicLibrary.playlists.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: LinerSpacing.md) {
            HStack {
                SearchBar(text: $searchText, placeholder: "Search playlists...")

                IconButton(
                    icon: "plus",
                    size: .medium,
                    variant: .primary
                ) {
                    showingPlaylistCreator = true
                }
            }

            if filteredPlaylists.isEmpty {
                EmptyState(
                    icon: "list.bullet.rectangle",
                    title: "No Playlists",
                    message: "Create your first playlist",
                    actionTitle: "Create Playlist"
                ) {
                    showingPlaylistCreator = true
                }
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 160), spacing: LinerSpacing.md)],
                    spacing: LinerSpacing.md
                ) {
                    ForEach(filteredPlaylists) { playlist in
                        MediaCard(
                            title: playlist.title,
                            subtitle: "\(playlist.trackCount) songs",
                            artworkURL: playlist.artworkURL,
                            size: .medium
                        ) {}
                    }
                }
                .padding(.horizontal, LinerSpacing.md)
            }
        }
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: LinerSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.linerBody)
                .foregroundColor(.linerTextTertiary)

            TextField(placeholder, text: $text)
                .font(.linerBody)
                .foregroundColor(.linerTextPrimary)
                .textFieldStyle(PlainTextFieldStyle())

            if !text.isEmpty {
                IconButton(
                    icon: "xmark.circle.fill",
                    size: .small,
                    variant: .plain
                ) {
                    text = ""
                }
            }
        }
        .padding(.horizontal, LinerSpacing.md)
        .padding(.vertical, LinerSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: LinerRadius.full)
                .fill(Color.linerGlassLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: LinerRadius.full)
                .stroke(Color.linerBorder.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, LinerSpacing.md)
    }
}

// MARK: - Create Playlist Sheet

struct CreatePlaylistSheet: View {
    @Binding var name: String
    @Binding var isPresented: Bool
    let onCreate: (String) -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.linerBackground
                    .ignoresSafeArea()

                VStack(spacing: LinerSpacing.xl) {
                    Image(systemName: "list.bullet.rectangle.badge.plus")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(.linerPrimary)
                        .symbolRenderingMode(.hierarchical)

                    VStack(spacing: LinerSpacing.sm) {
                        Text("New Playlist")
                            .font(.linerTitle1.weight(.bold))
                            .foregroundColor(.linerTextPrimary)

                        Text("Give your playlist a name")
                            .font(.linerBody)
                            .foregroundColor(.linerTextSecondary)
                    }

                    TextField("Playlist Name", text: $name)
                        .font(.linerTitle3)
                        .foregroundColor(.linerTextPrimary)
                        .multilineTextAlignment(.center)
                        .padding(LinerSpacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: LinerRadius.lg)
                                .fill(Color.linerSurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: LinerRadius.lg)
                                .stroke(Color.linerBorder, lineWidth: 1)
                        )
                        .focused($isFocused)
                        .padding(.horizontal, LinerSpacing.xl)

                    PrimaryButton(
                        "Create Playlist",
                        icon: "checkmark",
                        isDisabled: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                        fullWidth: true
                    ) {
                        onCreate(name.trimmingCharacters(in: .whitespacesAndNewlines))
                        isPresented = false
                    }
                    .padding(.horizontal, LinerSpacing.xl)

                    Spacer()
                }
                .padding(.top, LinerSpacing.xxl)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.linerTextSecondary)
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            isFocused = true
        }
    }
}