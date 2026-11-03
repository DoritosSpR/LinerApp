import SwiftUI

// MARK: - Track Row

struct TrackRow: View {
    let track: Track
    let index: Int?
    let showArtwork: Bool
    let showArtist: Bool
    let showAlbum: Bool
    let onTap: () -> Void
    let onPlay: () -> Void
    let onMore: () -> Void

    @State private var isHovered = false
    @EnvironmentObject private var audioPlayer: AudioPlayer
    @EnvironmentObject private var musicLibrary: MusicLibrary

    init(
        track: Track,
        index: Int? = nil,
        showArtwork: Bool = true,
        showArtist: Bool = true,
        showAlbum: Bool = false,
        onTap: @escaping () -> Void = {},
        onPlay: @escaping () -> Void = {},
        onMore: @escaping () -> Void = {}
    ) {
        self.track = track
        self.index = index
        self.showArtwork = showArtwork
        self.showArtist = showArtist
        self.showAlbum = showAlbum
        self.onTap = onTap
        self.onPlay = onPlay
        self.onMore = onMore
    }

    private var isPlaying: Bool {
        audioPlayer.currentTrack?.id == track.id && audioPlayer.isPlaying
    }

    private var isCurrentTrack: Bool {
        audioPlayer.currentTrack?.id == track.id
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: LinerSpacing.md) {
                // Index / Play Button
                ZStack {
                    if let index = index, !isCurrentTrack {
                        Text("\(index)")
                            .font(.linerMonoCaption)
                            .foregroundColor(.linerTextTertiary)
                            .frame(width: 24)
                    } else if isCurrentTrack {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.linerPrimary)
                            .symbolEffect(.bounce, value: isPlaying)
                    }
                }
                .frame(width: 24)

                // Artwork
                if showArtwork {
                    TrackArtwork(track: track, size: 52)
                }

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.linerBody.weight(.medium))
                        .foregroundColor(.linerTextPrimary)
                        .lineLimit(1)

                    if showArtist {
                        Text(track.artist.name)
                            .font(.linerSubheadline)
                            .foregroundColor(.linerTextSecondary)
                            .lineLimit(1)
                    }

                    if showAlbum, let album = track.album {
                        Text(album.title)
                            .font(.linerCaption1)
                            .foregroundColor(.linerTextTertiary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Duration / Actions
                HStack(spacing: LinerSpacing.sm) {
                    if isCurrentTrack && isPlaying {
                        LiveWaveform()
                            .frame(width: 40)
                    } else {
                        Text(track.formattedDuration)
                            .font(.linerMonoCaption)
                            .foregroundColor(.linerTextTertiary)
                            .frame(width: 40, alignment: .trailing)
                    }

                    IconButton(
                        icon: musicLibrary.isFavorite(track) ? "heart.fill" : "heart",
                        size: .small,
                        variant: .plain,
                        accessibilityLabel: musicLibrary.isFavorite(track) ? "Remove from favorites" : "Add to favorites"
                    ) {
                        musicLibrary.toggleFavorite(track)
                    }
                    .opacity(isHovered || isCurrentTrack ? 1 : 0)
                    .animation(.linerEaseOut, value: isHovered)

                    IconButton(
                        icon: "ellipsis",
                        size: .small,
                        variant: .plain
                    ) {
                        onMore()
                    }
                    .opacity(isHovered ? 1 : 0)
                    .animation(.linerEaseOut, value: isHovered)
                }
            }
            .padding(.horizontal, LinerSpacing.md)
            .padding(.vertical, LinerSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: LinerRadius.md)
                    .fill(isCurrentTrack ? Color.linerPrimary.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: LinerRadius.md)
                    .stroke(isCurrentTrack ? Color.linerPrimary.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovered = $0 }
        .contextMenu {
            TrackContextMenu(track: track)
        }
    }
}

// MARK: - Track Artwork

struct TrackArtwork: View {
    let track: Track
    let size: CGFloat
    let cornerRadius: CGFloat

    init(track: Track, size: CGFloat, cornerRadius: CGFloat = LinerRadius.sm) {
        self.track = track
        self.size = size
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Group {
            if let url = track.artworkURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.linerGradientPrimary.opacity(0.3))
            Image(systemName: "music.note")
                .font(.system(size: size * 0.35))
                .foregroundColor(.linerPrimary)
        }
    }
}

// MARK: - Album/Playlist Card

struct MediaCard: View {
    let title: String
    let subtitle: String?
    let artworkURL: URL?
    let size: CardSize
    let onTap: () -> Void

    enum CardSize {
        case small
        case medium
        case large

        var dimension: CGFloat {
            switch self {
            case .small: return 140
            case .medium: return 180
            case .large: return 240
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: return LinerRadius.sm
            case .medium: return LinerRadius.md
            case .large: return LinerRadius.lg
            }
        }

        var fontSize: Font {
            switch self {
            case .small: return .linerSubheadline
            case .medium: return .linerHeadline
            case .large: return .linerTitle3
            }
        }

        var subtitleFont: Font {
            switch self {
            case .small: return .linerCaption1
            case .medium: return .linerSubheadline
            case .large: return .linerBody
            }
        }
    }

    init(
        title: String,
        subtitle: String? = nil,
        artworkURL: URL? = nil,
        size: CardSize = .medium,
        onTap: @escaping () -> Void = {}
    ) {
        self.title = title
        self.subtitle = subtitle
        self.artworkURL = artworkURL
        self.size = size
        self.onTap = onTap
    }

    var body: some View {
        Button(action: {
            LinerHaptic.light()
            onTap()
        }) {
            VStack(alignment: .leading, spacing: LinerSpacing.sm) {
                // Artwork
                Group {
                    if let url = artworkURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                placeholder
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                placeholder
                            @unknown default:
                                placeholder
                            }
                        }
                    } else {
                        placeholder
                    }
                }
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .stroke(Color.linerBorder.opacity(0.3), lineWidth: 0.5)
                )

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(size.fontSize.weight(.semibold))
                        .foregroundColor(.linerTextPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(size.subtitleFont)
                            .foregroundColor(.linerTextSecondary)
                            .lineLimit(1)
                    }
                }
                .frame(width: size.dimension, alignment: .leading)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(Color.linerGradientPrimary.opacity(0.3))
            Image(systemName: "music.note.list")
                .font(.system(size: size.dimension * 0.3))
                .foregroundColor(.linerPrimary)
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.linerTitle2.weight(.bold))
                    .foregroundColor(.linerTextPrimary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.linerSubheadline)
                        .foregroundColor(.linerTextSecondary)
                }
            }

            Spacer()

            if let actionTitle = actionTitle, let action = action {
                SecondaryButton(actionTitle, variant: .ghost, action: action)
            }
        }
        .padding(.horizontal, LinerSpacing.md)
    }
}

// MARK: - Live Waveform Animation

struct LiveWaveform: View {
    @State private var phase = 0.0

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.linerPrimary)
                    .frame(width: 3, height: waveformHeight(for: index))
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(index) * 0.1),
                        value: phase
                    )
            }
        }
        .onAppear {
            phase = 1
        }
    }

    private func waveformHeight(for index: Int) -> CGFloat {
        let baseHeights: [CGFloat] = [8, 14, 10, 16, 12]
        return baseHeights[index] * (phase > 0 ? 1.2 : 0.6)
    }
}

// MARK: - Track Context Menu

struct TrackContextMenu: View {
    let track: Track
    @EnvironmentObject private var musicLibrary: MusicLibrary
    @EnvironmentObject private var audioPlayer: AudioPlayer

    var body: some View {
        Button(action: {
            musicLibrary.toggleFavorite(track)
        }) {
            Label(
                musicLibrary.isFavorite(track) ? "Remove from Favorites" : "Add to Favorites",
                systemImage: musicLibrary.isFavorite(track) ? "heart.slash" : "heart"
            )
        }

        Button(action: {
            audioPlayer.playNext()
        }) {
            Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
        }

        Button(action: {
            audioPlayer.playPrevious()
        }) {
            Label("Play Later", systemImage: "text.line.last.and.arrowtriangle.forward")
        }

        Divider()

        Button(action: {
            // Add to playlist
        }) {
            Label("Add to Playlist...", systemImage: "plus.rectangle.on.rectangle")
        }

        Button(action: {
            // Share
        }) {
            Label("Share", systemImage: "square.and.arrow.up")
        }

        Divider()

        Button(role: .destructive, action: {
            // Remove from library
        }) {
            Label("Remove from Library", systemImage: "trash")
        }
    }
}

// MARK: - Empty State

struct EmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: LinerSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.linerTextTertiary)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: LinerSpacing.sm) {
                Text(title)
                    .font(.linerTitle2.weight(.semibold))
                    .foregroundColor(.linerTextPrimary)

                Text(message)
                    .font(.linerBody)
                    .foregroundColor(.linerTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LinerSpacing.xl)
            }

            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(actionTitle, icon: "plus", action: action)
                    .padding(.top, LinerSpacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(LinerSpacing.xxl)
    }
}