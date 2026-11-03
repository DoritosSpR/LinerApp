import SwiftUI

// MARK: - Lyrics View

struct LyricsView: View {
    let lyrics: Lyrics?
    let currentTime: TimeInterval
    let onDismiss: () -> Void

    @State private var scrollProxy: ScrollViewProxy?
    @State private var currentLineIndex: Int = 0
    @Namespace private var lineNamespace

    var body: some View {
        ZStack {
            // Background
            Color.linerBackground
                .ignoresSafeArea()

            // Fallback for no lyrics
            if lyrics == nil || (lyrics?.synced?.isEmpty ?? true) && (lyrics?.plain?.isEmpty ?? true) {
                NoLyricsView()
            } else if let syncedLyrics = lyrics?.synced, !syncedLyrics.isEmpty {
                SyncedLyricsView(
                    lines: syncedLyrics,
                    currentTime: currentTime,
                    currentLineIndex: $currentLineIndex,
                    scrollProxy: $scrollProxy,
                    namespace: lineNamespace
                )
            } else if let plainLyrics = lyrics?.plain, !plainLyrics.isEmpty {
                PlainLyricsView(text: plainLyrics)
            }
        }
        .safeAreaInset(edge: .top) {
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

                Text("Lyrics")
                    .font(.linerHeadline)
                    .foregroundColor(.linerTextPrimary)

                Spacer()

                IconButton(
                    icon: "square.and.arrow.up",
                    size: .medium,
                    variant: .glass
                ) {
                    // Share lyrics
                }
            }
            .padding(.horizontal, LinerSpacing.lg)
            .padding(.top, LinerSpacing.lg)
            .padding(.bottom, LinerSpacing.md)
            .background(
                Color.linerBackground
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
            )
        }
    }
}

// MARK: - Synced Lyrics View

struct SyncedLyricsView: View {
    let lines: [SyncedLine]
    let currentTime: TimeInterval
    @Binding var currentLineIndex: Int
    @Binding var scrollProxy: ScrollViewProxy?
    let namespace: Namespace.ID

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: LinerSpacing.lg) {
                    ForEach(lines.indices, id: \.self) { index in
                        let line = lines[index]
                        let isCurrent = index == currentLineIndex
                        let isNext = index == currentLineIndex + 1

                        SyncedLyricsLine(
                            line: line,
                            isCurrent: isCurrent,
                            isNext: isNext,
                            namespace: namespace
                        )
                        .id(index)
                    }
                }
                .padding(.horizontal, LinerSpacing.xl)
                .padding(.vertical, LinerSpacing.xxl)
            }
            .onAppear {
                scrollProxy = proxy
            }
            .onChange(of: currentLineIndex) { newIndex in
                withAnimation(.linerSpring) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
        .onChange(of: currentTime) { newTime in
            updateCurrentLine(for: newTime)
        }
    }

    private func updateCurrentLine(for time: TimeInterval) {
        var newIndex = 0
        for (index, line) in lines.enumerated() {
            if line.time <= time {
                newIndex = index
            } else {
                break
            }
        }
        if newIndex != currentLineIndex {
            withAnimation(.linerSpring) {
                currentLineIndex = newIndex
            }
        }
    }
}

// MARK: - Synced Lyrics Line

struct SyncedLyricsLine: View {
    let line: SyncedLine
    let isCurrent: Bool
    let isNext: Bool
    let namespace: Namespace.ID

    @State private var syllableProgress: [String: Double] = [:]

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            if let syllables = line.syllables, !syllables.isEmpty {
                // Syllable-level sync
                SyllableView(
                    syllables: syllables,
                    currentTime: line.time, // This would need actual current time passed
                    isCurrent: isCurrent
                )
            } else {
                // Line-level sync
                Text(line.text)
                    .font(.linerTitle3.weight(isCurrent ? .bold : .medium))
                    .foregroundColor(isCurrent ? .linerTextPrimary : .linerTextSecondary)
                    .multilineTextAlignment(.center)
                    .scaleEffect(isCurrent ? 1.05 : 1.0)
                    .animation(.linerSpring, value: isCurrent)
                    .matchedGeometryEffect(id: "line", in: namespace, isSource: isCurrent)
            }
        }
        .opacity(isCurrent ? 1.0 : (isNext ? 0.7 : 0.4))
        .animation(.linerEaseInOut, value: isCurrent)
    }
}

// MARK: - Syllable View

struct SyllableView: View {
    let syllables: [Syllable]
    let currentTime: TimeInterval
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: 2) {
            ForEach(syllables) { syllable in
                let progress = syllableProgress(for: syllable, at: currentTime)

                Text(syllable.text)
                    .font(.linerTitle3.weight(isCurrent ? .bold : .medium))
                    .foregroundColor(
                        progress > 0
                        ? Color.linerPrimary
                        : (isCurrent ? .linerTextPrimary : .linerTextSecondary)
                    )
                    .overlay(
                        GeometryReader { geo in
                            Rectangle()
                                .fill(Color.linerPrimary)
                                .frame(width: geo.size.width * progress)
                                .mask(
                                    Text(syllable.text)
                                        .font(.linerTitle3.weight(.bold))
                                )
                        }
                    )
            }
        }
    }

    private func syllableProgress(for syllable: Syllable, at time: TimeInterval) -> Double {
        guard syllable.endTime > syllable.startTime else { return 0 }
        let progress = (time - syllable.startTime) / (syllable.endTime - syllable.startTime)
        return max(0, min(1, progress))
    }
}

// MARK: - Plain Lyrics View

struct PlainLyricsView: View {
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .font(.linerBody)
                .foregroundColor(.linerTextSecondary)
                .multilineTextAlignment(.leading)
                .lineSpacing(8)
                .padding(.horizontal, LinerSpacing.xl)
                .padding(.vertical, LinerSpacing.xxl)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - No Lyrics View

struct NoLyricsView: View {
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Floating Lyrics Overlay (for mini player)

struct FloatingLyricsOverlay: View {
    let lyrics: Lyrics?
    let currentTime: TimeInterval
    let currentLine: String?
    let onTap: () -> Void

    var body: some View {
        if let currentLine = currentLine, !currentLine.isEmpty {
            Button(action: onTap) {
                Text(currentLine)
                    .font(.linerCallout.weight(.medium))
                    .foregroundColor(.linerTextPrimary)
                    .lineLimit(1)
                    .padding(.horizontal, LinerSpacing.lg)
                    .padding(.vertical, LinerSpacing.sm)
                    .background(
                        Capsule()
                            .fill(Color.linerSurfaceElevated)
                            .glassMorphism(intensity: .heavy)
                    )
                    .shadow(.medium)
            }
            .buttonStyle(PlainButtonStyle())
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

// MARK: - Karaoke Style Lyrics (Fullscreen)

struct KaraokeLyricsView: View {
    let lines: [SyncedLine]
    let currentTime: TimeInterval
    let onDismiss: () -> Void

    @State private var currentLineIndex: Int = 0

    var body: some View {
        ZStack {
            // Animated background
            Color.linerBackground
                .ignoresSafeArea()

            VStack {
                Spacer()

                // Previous line (fading out)
                if currentLineIndex > 0 {
                    Text(lines[currentLineIndex - 1].text)
                        .font(.linerTitle2)
                        .foregroundColor(.linerTextTertiary)
                        .opacity(0.3)
                        .transition(.opacity.combined(with: .scale))
                }

                // Current line (highlighted)
                if currentLineIndex < lines.count {
                    Text(lines[currentLineIndex].text)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.linerTextPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, LinerSpacing.xl)
                        .transition(.opacity.combined(with: .scale))
                        .id(currentLineIndex)
                }

                // Next line (preview)
                if currentLineIndex + 1 < lines.count {
                    Text(lines[currentLineIndex + 1].text)
                        .font(.linerTitle3)
                        .foregroundColor(.linerTextSecondary)
                        .opacity(0.5)
                        .transition(.opacity.combined(with: .scale))
                }

                Spacer()
                Spacer()
            }
            .animation(.linerSpring, value: currentLineIndex)

            // Dismiss button
            VStack {
                HStack {
                    Spacer()
                    IconButton(
                        icon: "xmark.circle.fill",
                        size: .large,
                        variant: .glass
                    ) {
                        onDismiss()
                    }
                    .padding(LinerSpacing.lg)
                }
                Spacer()
            }
        }
        .onChange(of: currentTime) { newTime in
            updateCurrentLine(for: newTime)
        }
    }

    private func updateCurrentLine(for time: TimeInterval) {
        var newIndex = 0
        for (index, line) in lines.enumerated() {
            if line.time <= time {
                newIndex = index
            } else {
                break
            }
        }
        if newIndex != currentLineIndex {
            currentLineIndex = newIndex
        }
    }
}