import SwiftUI

// MARK: - Now Playing View (Fullscreen)

struct NowPlayingView: View {
    @EnvironmentObject private var audioPlayer: AudioPlayer
    @EnvironmentObject private var musicLibrary: MusicLibrary
    @State private var showLyrics = false
    @State private var showQueue = false
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Background
            Color.linerBackground
                .ignoresSafeArea()

            // Artwork background blur
            if let track = audioPlayer.currentTrack,
               let artworkURL = track.artworkURL {
                AsyncImage(url: artworkURL) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 80)
                            .opacity(0.4)
                    }
                }
                .ignoresSafeArea()
            } else {
                Color.linerGradientBackground
                    .ignoresSafeArea()
            }

            // Dark overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            // Main content
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.linerTextPrimary)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("Now Playing")
                        .font(.linerHeadline.weight(.semibold))
                        .foregroundColor(.linerTextPrimary)

                    Spacer()

                    Button(action: { showLyrics = true }) {
                        Image(systemName: "text.quote")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.linerTextPrimary)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, LinerSpacing.lg)
                .padding(.top, LinerSpacing.lg)

                Spacer()

                // Artwork with animation
                if let track = audioPlayer.currentTrack {
                    TrackArtwork(track: track, size: 320, cornerRadius: LinerRadius.lg)
                        .shadow(.floating, color: .black.opacity(0.5))
                        .scaleEffect(audioPlayer.isPlaying ? 1.0 : 0.98)
                        .animation(.linerSpring, value: audioPlayer.isPlaying)
                        .padding(.bottom, LinerSpacing.xl)
                }

                // Track Info
                if let track = audioPlayer.currentTrack {
                    VStack(spacing: LinerSpacing.sm) {
                        Text(track.title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
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

                // Progress Bar
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

                // Main Controls
                PlaybackControls(
                    audioPlayer: audioPlayer,
                    onPrevious: { audioPlayer.playPrevious() },
                    onPlayPause: { audioPlayer.togglePlayPause() },
                    onNext: { audioPlayer.playNext() },
                    onShuffle: { audioPlayer.toggleShuffle() },
                    onRepeat: { audioPlayer.toggleRepeatMode() }
                )
                .padding(.bottom, LinerSpacing.xl)

                // Bottom Actions
                HStack(spacing: LinerSpacing.xl) {
                    // Volume
                    Menu {
                        VolumeSliderView(volume: Binding(
                            get: { audioPlayer.player?.volume ?? 1.0 },
                            set: { audioPlayer.player?.volume = $0 }
                        ))
                    } label: {
                        IconButton(
                            icon: "speaker.wave.2",
                            size: .medium,
                            variant: .glass
                        ) {}
                    }

                    Spacer()

                    // Queue
                    Button(action: { showQueue = true }) {
                        IconButton(
                            icon: "list.bullet",
                            size: .medium,
                            variant: .glass
                        ) {}
                    }

                    Spacer()

                    // AirPlay
                    Button(action: {}) {
                        IconButton(
                            icon: "airplayaudio",
                            size: .medium,
                            variant: .glass
                        ) {}
                    }

                    // Lyrics
                    Button(action: { showLyrics = true }) {
                        IconButton(
                            icon: "text.quote",
                            size: .medium,
                            variant: .glass
                        ) {}
                    }
                }
                .padding(.horizontal, LinerSpacing.xl)
                .padding(.bottom, LinerSpacing.xl)
            }
        }
        .sheet(isPresented: $showLyrics) {
            if let track = audioPlayer.currentTrack,
               let lyrics = track.lyrics {
                LyricsView(
                    lyrics: lyrics,
                    currentTime: audioPlayer.currentTime,
                    onDismiss: { showLyrics = false }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            } else {
                NoLyricsSheet(onDismiss: { showLyrics = false })
            }
        }
        .sheet(isPresented: $showQueue) {
            QueueSheet(onDismiss: { showQueue = false })
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Volume Slider View

struct VolumeSliderView: View {
    @Binding var volume: Float

    var body: some View {
        VStack(spacing: LinerSpacing.md) {
            HStack {
                Image(systemName: "speaker.wave.1")
                    .foregroundColor(.linerTextSecondary)
                Slider(value: $volume, in: 0...1)
                    .tint(.linerPrimary)
                Image(systemName: "speaker.wave.3")
                    .foregroundColor(.linerTextSecondary)
            }
            .padding(.horizontal, LinerSpacing.lg)

            HStack {
                IconButton(
                    icon: "speaker.slash",
                    size: .small,
                    variant: .glass
                ) {
                    volume = 0
                }

                Spacer()

                Text("\(Int(volume * 100))%")
                    .font(.linerMonoBody)
                    .foregroundColor(.linerTextSecondary)
            }
            .padding(.horizontal, LinerSpacing.lg)
        }
        .padding(LinerSpacing.lg)
        .frame(width: 280)
    }
}

// MARK: - No Lyrics Sheet

struct NoLyricsSheet: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: LinerSpacing.lg) {
            Image(systemName: "music.note.list")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.linerTextTertiary)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: LinerSpacing.sm) {
                Text("No Lyrics Available")
                    .font(.linerTitle2.weight(.semibold))
                    .foregroundColor(.linerTextPrimary)

                Text("Lyrics for this track aren't available yet")
                    .font(.linerBody)
                    .foregroundColor(.linerTextSecondary)
                    .multilineTextAlignment(.center)
            }

            PrimaryButton("Close", action: onDismiss)
                .padding(.horizontal, LinerSpacing.xl)
        }
        .padding(LinerSpacing.xxl)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Queue Sheet

struct QueueSheet: View {
    @EnvironmentObject private var audioPlayer: AudioPlayer
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.linerBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Up Next")
                            .font(.linerTitle2.weight(.bold))
                            .foregroundColor(.linerTextPrimary)

                        Spacer()

                        Text("\(audioPlayer.queue.count) songs")
                            .font(.linerSubheadline)
                            .foregroundColor(.linerTextSecondary)
                    }
                    .padding(.horizontal, LinerSpacing.lg)
                    .padding(.vertical, LinerSpacing.md)

                    Divider()
                        .background(Color.linerBorder)

                    // Current Track
                    if let currentTrack = audioPlayer.currentTrack {
                        TrackRow(
                            track: currentTrack,
                            showArtist: true,
                            showAlbum: false
                        ) {} onPlay: {} onMore: {}
                        .padding(.horizontal, LinerSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: LinerRadius.md)
                                .fill(Color.linerPrimary.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: LinerRadius.md)
                                .stroke(Color.linerPrimary.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, LinerSpacing.md)
                        .padding(.vertical, LinerSpacing.sm)
                    }

                    Divider()
                        .background(Color.linerBorder)
                        .padding(.vertical, LinerSpacing.sm)

                    // Queue List
                    if audioPlayer.queue.isEmpty {
                        EmptyState(
                            icon: "list.bullet",
                            title: "Queue Empty",
                            message: "Add songs to play next"
                        )
                    } else {
                        List {
                            ForEach(audioPlayer.queue.indices, id: \.self) { index in
                                let track = audioPlayer.queue[index]
                                let isCurrent = audioPlayer.currentTrack?.id == track.id

                                TrackRow(
                                    track: track,
                                    index: isCurrent ? nil : index + 1,
                                    showArtist: true,
                                    showAlbum: false
                                ) {} onPlay: {
                                    audioPlayer.currentIndex = index
                                    audioPlayer.load(track: track, queue: audioPlayer.queue, startIndex: index)
                                } onMore: {}
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(
                                    top: 4,
                                    leading: LinerSpacing.md,
                                    bottom: 4,
                                    trailing: LinerSpacing.md
                                ))
                            }
                            .onMove { from, to in
                                // Reorder queue
                            }
                            .onDelete { indexSet in
                                // Remove from queue
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { onDismiss() }
                        .foregroundColor(.linerPrimary)
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Clear Queue", role: .destructive) {
                            audioPlayer.queue = []
                        }
                    } label: {
                        IconButton(
                            icon: "ellipsis.circle",
                            size: .medium,
                            variant: .glass
                        ) {}
                    }
                }
            }
        }
    }
}

// MARK: - Floating Lyrics Line (for mini player)

struct FloatingLyricsLine: View {
    let lyrics: Lyrics?
    let currentTime: TimeInterval

    var currentLine: String? {
        guard let synced = lyrics?.synced else { return nil }
        var line: String?
        for l in synced {
            if l.time <= currentTime {
                line = l.text
            } else {
                break
            }
        }
        return line
    }

    var body: some View {
        if let line = currentLine, !line.isEmpty {
            Text(line)
                .font(.linerCallout.weight(.medium))
                .foregroundColor(.linerTextPrimary)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, LinerSpacing.lg)
                .padding(.vertical, LinerSpacing.xs)
                .background(
                    Capsule()
                        .fill(Color.linerSurfaceElevated)
                        .glassMorphism(intensity: .heavy)
                )
                .shadow(.medium)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}