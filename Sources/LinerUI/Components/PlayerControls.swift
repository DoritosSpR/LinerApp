import SwiftUI

// MARK: - Progress Bar

struct ProgressBar: View {
    @Binding var progress: Double
    let bufferedProgress: Double
    let onSeek: (Double) -> Void
    let onSeekEnd: (Double) -> Void

    @State private var isDragging = false
    @State private var dragLocation: CGFloat = 0
    @State private var geometryWidth: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let thumbSize: CGFloat = 16

            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.linerBorder.opacity(0.3))
                    .frame(height: 4)

                // Buffered progress
                Capsule()
                    .fill(Color.linerPrimary.opacity(0.3))
                    .frame(width: width * bufferedProgress, height: 4)

                // Played progress
                Capsule()
                    .fill(Color.linerGradientPrimary)
                    .frame(width: width * (isDragging ? dragLocation / width : progress), height: 4)

                // Thumb
                Circle()
                    .fill(Color.linerTextInverse)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(x: (isDragging ? dragLocation : width * progress) - thumbSize / 2)
                    .scaleEffect(isDragging ? 1.2 : (isHovered ? 1.1 : 1.0))
                    .animation(.linerSpringFast, value: isDragging)
                    .animation(.linerEaseOut, value: isHovered)
            }
            .frame(height: 44) // Larger touch target
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        dragLocation = max(0, min(width, value.location.x))
                    }
                    .onEnded { value in
                        let newProgress = max(0, min(1, value.location.x / width))
                        onSeekEnd(newProgress)
                        isDragging = false
                    }
            )
            .onHover { isHovered = $0 }
        }
        .frame(height: 44)
        .onAppear {
            // Store geometry width for calculations
        }
    }

    @State private var isHovered = false
}

// MARK: - Time Display

struct TimeDisplay: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    let showRemaining: Bool

    init(currentTime: TimeInterval, duration: TimeInterval, showRemaining: Bool = false) {
        self.currentTime = currentTime
        self.duration = duration
        self.showRemaining = showRemaining
    }

    var body: some View {
        Text(formattedTime)
            .font(.linerMonoCaption)
            .foregroundColor(.linerTextSecondary)
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.linerEaseOut, value: currentTime)
    }

    private var formattedTime: String {
        let time = showRemaining ? -(duration - currentTime) : currentTime
        let minutes = Int(abs(time)) / 60
        let seconds = Int(abs(time)) % 60
        let sign = time < 0 ? "-" : ""
        return "\(sign)\(minutes):\(String(format: "%02d", seconds))"
    }
}

// MARK: - Volume Slider

struct VolumeSlider: View {
    @Binding var volume: Float
    let onChange: (Float) -> Void

    @State private var isDragging = false

    var body: some View {
        HStack(spacing: LinerSpacing.sm) {
            Image(systemName: volumeIcon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.linerTextSecondary)
                .frame(width: 20)

            GeometryReader { geometry in
                let width = geometry.size.width
                let thumbSize: CGFloat = 14

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.linerBorder.opacity(0.3))
                        .frame(height: 4)

                    Capsule()
                        .fill(Color.linerGradientPrimary)
                        .frame(width: width * CGFloat(volume), height: 4)

                    Circle()
                        .fill(Color.linerTextInverse)
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                        .offset(x: width * CGFloat(volume) - thumbSize / 2)
                        .scaleEffect(isDragging ? 1.3 : 1.0)
                        .animation(.linerSpringFast, value: isDragging)
                }
                .frame(height: 32)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            let newVolume = max(0, min(1, Float(value.location.x / width)))
                            volume = newVolume
                            onChange(newVolume)
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
            }
            .frame(width: 80, height: 32)
        }
    }

    private var volumeIcon: String {
        if volume == 0 { return "speaker.slash.fill" }
        else if volume < 0.33 { return "speaker.wave.1.fill" }
        else if volume < 0.66 { return "speaker.wave.2.fill" }
        else { return "speaker.wave.3.fill" }
    }
}

// MARK: - Playback Controls

struct PlaybackControls: View {
    @ObservedObject var audioPlayer: AudioPlayer
    let onPrevious: () -> Void
    let onPlayPause: () -> Void
    let onNext: () -> Void
    let onShuffle: () -> Void
    let onRepeat: () -> Void

    var body: some View {
        HStack(spacing: LinerSpacing.lg) {
            // Shuffle
            IconButton(
                icon: "shuffle",
                size: .medium,
                variant: audioPlayer.shuffleEnabled ? .primary : .glass,
                accessibilityLabel: audioPlayer.shuffleEnabled ? "Disable Shuffle" : "Enable Shuffle"
            ) {
                onShuffle()
            }

            // Previous
            PlaybackButton(icon: "backward.fill", size: 44, variant: .glass) {
                onPrevious()
            }

            // Play/Pause
            PlaybackButton(
                icon: audioPlayer.isPlaying ? "pause.fill" : "play.fill",
                size: 64,
                variant: .primary,
                isActive: audioPlayer.isPlaying
            ) {
                onPlayPause()
            }

            // Next
            PlaybackButton(icon: "forward.fill", size: 44, variant: .glass) {
                onNext()
            }

            // Repeat
            IconButton(
                icon: repeatIcon,
                size: .medium,
                variant: audioPlayer.repeatMode != .off ? .primary : .glass,
                accessibilityLabel: repeatAccessibilityLabel
            ) {
                onRepeat()
            }
        }
    }

    private var repeatIcon: String {
        switch audioPlayer.repeatMode {
        case .off: return "repeat"
        case .queue: return "repeat"
        case .track: return "repeat.1"
        }
    }

    private var repeatAccessibilityLabel: String {
        switch audioPlayer.repeatMode {
        case .off: return "Enable Repeat Queue"
        case .queue: return "Enable Repeat Track"
        case .track: return "Disable Repeat"
        }
    }
}

// MARK: - Mini Player Bar

struct MiniPlayerBar: View {
    @ObservedObject var audioPlayer: AudioPlayer
    let onExpand: () -> Void

    var body: some View {
        if let track = audioPlayer.currentTrack {
            Button(action: onExpand) {
                HStack(spacing: LinerSpacing.md) {
                    TrackArtwork(track: track, size: 48, cornerRadius: LinerRadius.sm)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.linerSubheadline.weight(.medium))
                            .foregroundColor(.linerTextPrimary)
                            .lineLimit(1)

                        Text(track.artist.name)
                            .font(.linerCaption1)
                            .foregroundColor(.linerTextSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    PlaybackButton(
                        icon: audioPlayer.isPlaying ? "pause.fill" : "play.fill",
                        size: 40,
                        variant: .primary
                    ) {
                        audioPlayer.togglePlayPause()
                    }

                    IconButton(
                        icon: "forward.fill",
                        size: .medium,
                        variant: .glass
                    ) {
                        audioPlayer.playNext()
                    }
                }
                .padding(.horizontal, LinerSpacing.md)
                .padding(.vertical, LinerSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.linerSurfaceElevated)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                )
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.linerBorder.opacity(0.3)),
                    alignment: .top
                )
            }
            .buttonStyle(PlainButtonStyle())
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

// MARK: - Fullscreen Player

struct FullscreenPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer
    let onDismiss: () -> Void
    let onLyrics: () -> Void
    let onQueue: () -> Void

    @Namespace private var animationNamespace

    var body: some View {
        ZStack {
            // Background with artwork blur
            if let track = audioPlayer.currentTrack,
               let artworkURL = track.artworkURL {
                AsyncImage(url: artworkURL) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 80)
                            .opacity(0.6)
                    }
                }
            } else {
                Color.linerGradientBackground
            }

            // Dark overlay
            Color.black.opacity(0.7)

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    IconButton(
                        icon: "chevron.down",
                        size: .medium,
                        variant: .glass
                    ) {
                        onDismiss()
                    }

                    Spacer()

                    Text("Now Playing")
                        .font(.linerHeadline)
                        .foregroundColor(.linerTextPrimary)

                    Spacer()

                    IconButton(
                        icon: "text.quote",
                        size: .medium,
                        variant: .glass
                    ) {
                        onLyrics()
                    }
                }
                .padding(.horizontal, LinerSpacing.lg)
                .padding(.top, LinerSpacing.lg)

                Spacer()

                // Artwork
                if let track = audioPlayer.currentTrack {
                    TrackArtwork(track: track, size: 300, cornerRadius: LinerRadius.lg)
                        .matchedGeometryEffect(id: "artwork", in: animationNamespace)
                        .shadow(.floating, color: .black.opacity(0.4))
                        .padding(.bottom, LinerSpacing.xl)
                }

                // Track Info
                if let track = audioPlayer.currentTrack {
                    VStack(spacing: LinerSpacing.sm) {
                        Text(track.title)
                            .font(.linerTitle1.weight(.bold))
                            .foregroundColor(.linerTextPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)

                        Text(track.artist.name)
                            .font(.linerTitle3)
                            .foregroundColor(.linerTextSecondary)

                        if let album = track.album {
                            Text(album.title)
                                .font(.linerBody)
                                .foregroundColor(.linerTextTertiary)
                        }
                    }
                    .padding(.horizontal, LinerSpacing.xl)
                    .padding(.bottom, LinerSpacing.xl)
                }

                // Progress
                VStack(spacing: LinerSpacing.sm) {
                    ProgressBar(
                        progress: Binding(
                            get: { audioPlayer.duration > 0 ? audioPlayer.currentTime / audioPlayer.duration : 0 },
                            set: { _ in }
                        ),
                        bufferedProgress: 1.0,
                        onSeek: { _ in },
                        onSeekEnd: { progress in
                            audioPlayer.seek(to: progress * audioPlayer.duration)
                        }
                    )

                    HStack {
                        TimeDisplay(
                            currentTime: audioPlayer.currentTime,
                            duration: audioPlayer.duration,
                            showRemaining: true
                        )
                        Spacer()
                        TimeDisplay(
                            currentTime: audioPlayer.currentTime,
                            duration: audioPlayer.duration
                        )
                    }
                    .padding(.horizontal, LinerSpacing.xl)
                }
                .padding(.bottom, LinerSpacing.lg)

                // Controls
                PlaybackControls(
                    audioPlayer: audioPlayer,
                    onPrevious: { audioPlayer.playPrevious() },
                    onPlayPause: { audioPlayer.togglePlayPause() },
                    onNext: { audioPlayer.playNext() },
                    onShuffle: { audioPlayer.toggleShuffle() },
                    onRepeat: { audioPlayer.toggleRepeatMode() }
                )
                .padding(.bottom, LinerSpacing.xl)

                // Bottom actions
                HStack(spacing: LinerSpacing.xl) {
                    IconButton(
                        icon: "speaker.wave.2",
                        size: .medium,
                        variant: .glass
                    ) {
                        // Volume popover
                    }

                    Spacer()

                    IconButton(
                        icon: "list.bullet",
                        size: .medium,
                        variant: .glass
                    ) {
                        onQueue()
                    }

                    Spacer()

                    IconButton(
                        icon: "airplayaudio",
                        size: .medium,
                        variant: .glass
                    ) {
                        // AirPlay
                    }
                }
                .padding(.horizontal, LinerSpacing.xl)
                .padding(.bottom, LinerSpacing.xl)
            }
        }
        .ignoresSafeArea()
    }
}