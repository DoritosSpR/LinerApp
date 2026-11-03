import SwiftUI

// MARK: - Search View

struct SearchView: View {
    @EnvironmentObject private var searchService: SearchService
    @EnvironmentObject private var musicLibrary: MusicLibrary
    @EnvironmentObject private var audioPlayer: AudioPlayer

    @State private var searchText = ""
    @State private var isSearching = false
    @FocusState private var isSearchFocused: Bool
    @Namespace private var searchNamespace

    var body: some View {
        NavigationStack {
            ZStack {
                Color.linerBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search Bar
                    SearchBarView(
                        text: $searchText,
                        isFocused: $isSearchFocused,
                        onSubmit: performSearch,
                        onClear: clearSearch
                    )
                    .padding(.horizontal, LinerSpacing.md)
                    .padding(.top, LinerSpacing.md)
                    .padding(.bottom, LinerSpacing.sm)

                    // Content
                    if searchText.isEmpty {
                        SearchEmptyState(
                            recentSearches: searchService.recentSearches,
                            onRecentSearchTap: { query in
                                searchText = query
                                performSearch()
                            },
                            onClearRecent: {
                                searchService.clearRecentSearches()
                            }
                        )
                    } else if isSearching {
                        SearchLoadingView()
                    } else if searchService.searchResults.isEmpty {
                        SearchNoResultsView(query: searchText)
                    } else {
                        SearchResultsView(
                            results: searchService.searchResults,
                            query: searchText
                        )
                    }

                    Spacer()
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                isSearchFocused = true
            }
        }
    }

    private func performSearch() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSearching = true
        searchService.search(query: trimmed)

        // Simulate search delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSearching = false
        }
    }

    private func clearSearch() {
        searchText = ""
        searchService.clearSearch()
        isSearchFocused = true
    }
}

// MARK: - Search Bar View

struct SearchBarView: View {
    @Binding var text: String
    @Binding var isFocused: Bool
    let onSubmit: () -> Void
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: LinerSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.linerTitle3.weight(.medium))
                .foregroundColor(isFocused ? .linerPrimary : .linerTextTertiary)
                .animation(.linerEaseOut, value: isFocused)

            TextField("Search songs, artists, albums...", text: $text)
                .font(.linerTitle3)
                .foregroundColor(.linerTextPrimary)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isFocused)
                .onSubmit(onSubmit)

            if !text.isEmpty {
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.linerTitle3)
                        .foregroundColor(.linerTextTertiary)
                }
                .transition(.scale.combined(with: .opacity))
            }

            if isFocused {
                Button("Cancel") {
                    isFocused = false
                }
                .font(.linerHeadline)
                .foregroundColor(.linerPrimary)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal, LinerSpacing.lg)
        .padding(.vertical, LinerSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: LinerRadius.xl)
                .fill(Color.linerSurface)
                .glassMorphism(intensity: .light, border: false)
        )
        .overlay(
            RoundedRectangle(cornerRadius: LinerRadius.xl)
                .stroke(
                    isFocused ? Color.linerPrimary : Color.linerBorder.opacity(0.3),
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .shadow(.subtle)
        .animation(.linerSpring, value: isFocused)
    }
}

// MARK: - Search Empty State

struct SearchEmptyState: View {
    let recentSearches: [String]
    let onRecentSearchTap: (String) -> Void
    let onClearRecent: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: LinerSpacing.xl) {
                // Illustration
                ZStack {
                    Circle()
                        .fill(Color.linerGradientPrimary.opacity(0.15))
                        .frame(width: 160, height: 160)

                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 56, weight: .light))
                        .foregroundColor(.linerPrimary)
                        .symbolRenderingMode(.hierarchical)
                }
                .padding(.top, LinerSpacing.xxl)

                VStack(spacing: LinerSpacing.md) {
                    Text("What do you want to listen to?")
                        .font(.linerTitle1.weight(.bold))
                        .foregroundColor(.linerTextPrimary)
                        .multilineTextAlignment(.center)

                    Text("Search for songs, artists, albums, or playlists")
                        .font(.linerBody)
                        .foregroundColor(.linerTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, LinerSpacing.xl)
                }

                // Recent searches
                if !recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: LinerSpacing.md) {
                        HStack {
                            Text("Recent Searches")
                                .font(.linerHeadline.weight(.semibold))
                                .foregroundColor(.linerTextPrimary)

                            Spacer()

                            Button(action: onClearRecent) {
                                Text("Clear")
                                    .font(.linerSubheadline.weight(.medium))
                                    .foregroundColor(.linerPrimary)
                            }
                        }
                        .padding(.horizontal, LinerSpacing.md)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: LinerSpacing.sm) {
                                ForEach(recentSearches, id: \.self) { query in
                                    RecentSearchChip(query: query, onTap: onRecentSearchTap)
                                }
                            }
                            .padding(.horizontal, LinerSpacing.md)
                        }
                    }
                }

                Spacer()
            }
            .padding(.bottom, LinerSpacing.xxl)
        }
    }
}

struct RecentSearchChip: View {
    let query: String
    let onTap: (String) -> Void

    var body: some View {
        Button(action: { onTap(query) }) {
            HStack(spacing: LinerSpacing.xs) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.linerCaption1)
                Text(query)
                    .font(.linerSubheadline)
            }
            .foregroundColor(.linerTextPrimary)
            .padding(.horizontal, LinerSpacing.md)
            .padding(.vertical, LinerSpacing.sm)
            .background(
                Capsule()
                    .fill(Color.linerGlassMedium)
            )
            .overlay(
                Capsule()
                    .stroke(Color.linerBorder.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Search Loading View

struct SearchLoadingView: View {
    @State private var rotation = 0.0

    var body: some View {
        VStack(spacing: LinerSpacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.linerPrimary.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.linerGradientPrimary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(rotation))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
            }
            .onAppear {
                rotation = 360
            }

            Text("Searching...")
                .font(.linerHeadline)
                .foregroundColor(.linerTextSecondary)

            Spacer()
        }
    }
}

// MARK: - Search No Results View

struct SearchNoResultsView: View {
    let query: String

    var body: some View {
        VStack(spacing: LinerSpacing.lg) {
            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.linerTextTertiary)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: LinerSpacing.sm) {
                Text("No Results for \"\(query)\"")
                    .font(.linerTitle2.weight(.semibold))
                    .foregroundColor(.linerTextPrimary)

                Text("Try a different search term or check your spelling")
                    .font(.linerBody)
                    .foregroundColor(.linerTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LinerSpacing.xl)
            }

            Spacer()
        }
    }
}

// MARK: - Search Results View

struct SearchResultsView: View {
    let results: SearchService.SearchResults
    let query: String
    @EnvironmentObject private var audioPlayer: AudioPlayer

    var body: some View {
        ScrollView {
            LazyVStack(spacing: LinerSpacing.xl, pinnedViews: [.sectionHeaders]) {
                // Top Result (if tracks exist)
                if let topTrack = results.tracks.first {
                    SectionHeader(title: "Top Result") {}

                    TrackRow(
                        track: topTrack,
                        showArtist: true,
                        showAlbum: true
                    ) {} onPlay: {
                        audioPlayer.load(track: topTrack, queue: results.tracks, startIndex: 0)
                    } onMore: {}
                    .padding(.horizontal, LinerSpacing.md)
                }

                // Tracks
                if !results.tracks.isEmpty {
                    SectionHeader(
                        title: "Songs",
                        subtitle: "\(results.tracks.count) results",
                        actionTitle: "See All"
                    ) {}

                    LazyVStack(spacing: 0) {
                        ForEach(results.tracks.indices, id: \.self) { index in
                            let track = results.tracks[index]
                            TrackRow(
                                track: track,
                                index: index + 1,
                                showArtist: true,
                                showAlbum: true
                            ) {} onPlay: {
                                audioPlayer.load(track: track, queue: results.tracks, startIndex: index)
                            } onMore: {}
                            .padding(.horizontal, LinerSpacing.md)
                        }
                    }
                }

                // Artists
                if !results.artists.isEmpty {
                    SectionHeader(
                        title: "Artists",
                        subtitle: "\(results.artists.count) results"
                    ) {}

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LinerSpacing.md) {
                            ForEach(results.artists) { artist in
                                MediaCard(
                                    title: artist.name,
                                    subtitle: artist.genres.first ?? "Artist",
                                    artworkURL: artist.artworkURL,
                                    size: .medium
                                ) {}
                            }
                        }
                        .padding(.horizontal, LinerSpacing.md)
                    }
                }

                // Albums
                if !results.albums.isEmpty {
                    SectionHeader(
                        title: "Albums",
                        subtitle: "\(results.albums.count) results"
                    ) {}

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LinerSpacing.md) {
                            ForEach(results.albums) { album in
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

                // Playlists
                if !results.playlists.isEmpty {
                    SectionHeader(
                        title: "Playlists",
                        subtitle: "\(results.playlists.count) results"
                    ) {}

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: LinerSpacing.md) {
                            ForEach(results.playlists) { playlist in
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
            .padding(.bottom, 120)
        }
    }
}