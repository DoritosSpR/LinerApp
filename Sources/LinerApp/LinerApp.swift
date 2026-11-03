import SwiftUI

@main
struct LinerApp: App {
    @StateObject private var audioPlayer = AudioPlayer.shared
    @StateObject private var musicLibrary = MusicLibrary.shared
    @StateObject private var searchService = SearchService.shared

    @State private var selectedTab: Tab = .home
    @State private var showNowPlaying = false

    enum Tab: String, CaseIterable {
        case home = "Home"
        case library = "Library"
        case search = "Search"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .home: return "house"
            case .library: return "music.note.list"
            case .search: return "magnifyingglass"
            case .settings: return "gear"
            }
        }

        var selectedIcon: String {
            switch self {
            case .home: return "house.fill"
            case .library: return "music.note.list"
            case .search: return "magnifyingglass"
            case .settings: return "gear"
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label(Tab.home.rawValue, systemImage: selectedTab == .home ? Tab.home.selectedIcon : Tab.home.icon)
                        }
                        .tag(Tab.home)

                    LibraryView()
                        .tabItem {
                            Label(Tab.library.rawValue, systemImage: selectedTab == .library ? Tab.library.selectedIcon : Tab.library.icon)
                        }
                        .tag(Tab.library)

                    SearchView()
                        .tabItem {
                            Label(Tab.search.rawValue, systemImage: selectedTab == .search ? Tab.search.selectedIcon : Tab.search.icon)
                        }
                        .tag(Tab.search)

                    SettingsView()
                        .tabItem {
                            Label(Tab.settings.rawValue, systemImage: selectedTab == .settings ? Tab.settings.selectedIcon : Tab.settings.icon)
                        }
                        .tag(Tab.settings)
                }
                .environmentObject(audioPlayer)
                .environmentObject(musicLibrary)
                .environmentObject(searchService)
                .accentColor(.linerPrimary)
                .onAppear {
                    setupTabBarAppearance()
                }

                // Mini Player Bar
                if audioPlayer.currentTrack != nil {
                    MiniPlayerBar(audioPlayer: audioPlayer) {
                        showNowPlaying = true
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.linerSpring, value: audioPlayer.currentTrack != nil)
                }
            }
            .fullScreenCover(isPresented: $showNowPlaying) {
                NowPlayingView()
                    .environmentObject(audioPlayer)
                    .environmentObject(musicLibrary)
                    .environmentObject(searchService)
            }
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.shadowColor = .clear

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor(Color.linerTextTertiary)
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.linerTextTertiary),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        itemAppearance.selected.iconColor = UIColor(Color.linerPrimary)
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.linerPrimary),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject private var musicLibrary: MusicLibrary
    @EnvironmentObject private var audioPlayer: AudioPlayer

    var body: some View {
        NavigationStack {
            ZStack {
                Color.linerBackground
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: LinerSpacing.xl, pinnedViews: [.sectionHeaders]) {
                        // Hero Section
                        HeroSection()

                        // Continue Listening
                        if !musicLibrary.recentlyPlayed.isEmpty {
                            ContinueListeningSection()
                        }

                        // Favorites
                        if !musicLibrary.favorites.isEmpty {
                            FavoritesSection()
                        }

                        // Recent Playlists
                        if !musicLibrary.playlists.isEmpty {
                            RecentPlaylistsSection()
                        }

                        // Discover Artists
                        if !musicLibrary.artists.isEmpty {
                            DiscoverArtistsSection()
                        }

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, LinerSpacing.md)
                }
                .refreshable {
                    // Pull to refresh
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Settings") {}
                        Button("Profile") {}
                        Divider()
                        Button("Sign Out", role: .destructive) {}
                    } label: {
                        Circle()
                            .fill(Color.linerGradientPrimary)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("U")
                                    .font(.linerSubheadline.weight(.bold))
                                    .foregroundColor(.linerTextInverse)
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Hero Section

struct HeroSection: View {
    @EnvironmentObject private var musicLibrary: MusicLibrary
    @EnvironmentObject private var audioPlayer: AudioPlayer

    var body: some View {
        VStack(spacing: LinerSpacing.md) {
            if let recentTrack = musicLibrary.recentlyPlayed.first {
                // Featured Track Card
                Button(action: {
                    audioPlayer.load(track: recentTrack, queue: musicLibrary.recentlyPlayed, startIndex: 0)
                }) {
                    HStack(spacing: LinerSpacing.lg) {
                        TrackArtwork(track: recentTrack, size: 80, cornerRadius: LinerRadius.md)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Continue Listening")
                                .font(.linerCaption1.weight(.semibold))
                                .foregroundColor(.linerPrimary)
                                .textCase(.uppercase)

                            Text(recentTrack.title)
                                .font(.linerTitle2.weight(.bold))
                                .foregroundColor(.linerTextPrimary)
                                .lineLimit(1)

                            Text(recentTrack.artist.name)
                                .font(.linerSubheadline)
                                .foregroundColor(.linerTextSecondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        PlaybackButton(
                            icon: "play.fill",
                            size: 48,
                            variant: .primary
                        ) {
                            audioPlayer.load(track: recentTrack, queue: musicLibrary.recentlyPlayed, startIndex: 0)
                        }
                    }
                    .padding(LinerSpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: LinerRadius.xl)
                            .fill(Color.linerSurface)
                            .glassMorphism(intensity: .medium)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: LinerRadius.xl)
                            .stroke(Color.linerBorder.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // Empty State Hero
                VStack(spacing: LinerSpacing.lg) {
                    Image(systemName: "music.note")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(.linerTextTertiary)
                        .symbolRenderingMode(.hierarchical)

                    VStack(spacing: LinerSpacing.sm) {
                        Text("Welcome to Liner")
                            .font(.linerTitle1.weight(.bold))
                            .foregroundColor(.linerTextPrimary)

                        Text("Add music to your library to get started")
                            .font(.linerBody)
                            .foregroundColor(.linerTextSecondary)
                            .multilineTextAlignment(.center)
                    }

                    PrimaryButton("Add Music", icon: "plus", fullWidth: false) {
                        // Navigate to add music
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(LinerSpacing.xxl)
                .background(
                    RoundedRectangle(cornerRadius: LinerRadius.xl)
                        .fill(Color.linerSurface)
                        .glassMorphism(intensity: .light)
                )
            }
        }
    }
}

// MARK: - Continue Listening Section

struct ContinueListeningSection: View {
    @EnvironmentObject private var musicLibrary: MusicLibrary
    @EnvironmentObject private var audioPlayer: AudioPlayer

    var body: some View {
        SectionHeader(title: "Continue Listening", actionTitle: "See All") {}

        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: LinerSpacing.md) {
                ForEach(musicLibrary.recentlyPlayed.prefix(8)) { track in
                    MediaCard(
                        title: track.title,
                        subtitle: track.artist.name,
                        artworkURL: track.artworkURL,
                        size: .medium
                    ) {
                        audioPlayer.load(track: track, queue: musicLibrary.recentlyPlayed, startIndex: 0)
                    }
                }
            }
            .padding(.horizontal, LinerSpacing.md)
        }
    }
}

// MARK: - Favorites Section

struct FavoritesSection: View {
    @EnvironmentObject private var musicLibrary: MusicLibrary
    @EnvironmentObject private var audioPlayer: AudioPlayer

    var body: some View {
        SectionHeader(title: "Your Favorites", actionTitle: "See All") {}

        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: LinerSpacing.md) {
                ForEach(musicLibrary.favorites.prefix(8)) { track in
                    MediaCard(
                        title: track.title,
                        subtitle: track.artist.name,
                        artworkURL: track.artworkURL,
                        size: .medium
                    ) {
                        audioPlayer.load(track: track, queue: musicLibrary.favorites, startIndex: 0)
                    }
                }
            }
            .padding(.horizontal, LinerSpacing.md)
        }
    }
}

// MARK: - Recent Playlists Section

struct RecentPlaylistsSection: View {
    @EnvironmentObject private var musicLibrary: MusicLibrary

    var body: some View {
        SectionHeader(title: "Playlists", actionTitle: "See All") {}

        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: LinerSpacing.md) {
                ForEach(musicLibrary.playlists.prefix(8)) { playlist in
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

// MARK: - Discover Artists Section

struct DiscoverArtistsSection: View {
    @EnvironmentObject private var musicLibrary: MusicLibrary

    var body: some View {
        SectionHeader(title: "Artists", actionTitle: "See All") {}

        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: LinerSpacing.md) {
                ForEach(musicLibrary.artists.prefix(8)) { artist in
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
}