import SwiftUI

struct MediaCard: View {
    let title: String; let subtitle: String; let artworkURL: URL?; let size: CardSize; let action: () -> Void
    enum CardSize { case small, medium, large; var dimension: CGFloat { switch self { case .small: return 120; case .medium: return 160; case .large: return 220 } } }
    var body: some View {
        Button(action: action) { VStack(alignment: .leading, spacing: LinerSpacing.sm) { TrackArtwork(track: nil, size: size.dimension, cornerRadius: LinerRadius.md, artworkURL: artworkURL); VStack(alignment: .leading, spacing: 2) { Text(title).font(.linerSubheadline.weight(.semibold)).foregroundColor(.linerTextPrimary).lineLimit(2); Text(subtitle).font(.linerCaption1).foregroundColor(.linerTextSecondary).lineLimit(1) } }.frame(width: size.dimension) }.buttonStyle(PlainButtonStyle()).contextMenu { Menu("Options") { Button("Add to Queue") {}; Button("Add to Playlist") {}; Button("Share") {}; Divider(); Button(role: .destructive) { Label("Remove", systemImage: "trash") } } }
    }
}

struct TrackRow: View {
    let track: Track; let index: Int?; let onTap: () -> Void
    @EnvironmentObject private var musicLibrary: MusicLibrary
    var body: some View {
        Button(action: onTap) { HStack(spacing: LinerSpacing.md) { ZStack { if let index = index { Text("\(index + 1)").font(.linerCaption1.weight(.medium)).foregroundColor(.linerTextTertiary).frame(width: 24, alignment: .trailing) } else { Image(systemName: "play.fill").font(.linerCaption1).foregroundColor(.linerPrimary).frame(width: 24) } }; TrackArtwork(track: track, size: 48, cornerRadius: LinerRadius.sm); VStack(alignment: .leading, spacing: 2) { Text(track.title).font(.linerSubheadline.weight(.medium)).foregroundColor(.linerTextPrimary).lineLimit(1); Text(track.artist.name).font(.linerCaption1).foregroundColor(.linerTextSecondary).lineLimit(1) }; Spacer(); HStack(spacing: LinerSpacing.sm) { if let duration = track.duration { Text(formatDuration(duration)).font(.linerCaption2).foregroundColor(.linerTextTertiary) }; Button { musicLibrary.toggleFavorite(track) } label: { Image(systemName: musicLibrary.isFavorite(track) ? "heart.fill" : "heart").font(.linerSubheadline).foregroundColor(musicLibrary.isFavorite(track) ? .linerPrimary : .linerTextTertiary) }.buttonStyle(PlainButtonStyle()) } }.padding(.vertical, LinerSpacing.xs).contentShape(Rectangle()) }.buttonStyle(PlainButtonStyle()).contextMenu { Menu("Options") { Button("Add to Queue") {}; Button("Add to Playlist") {}; Button("Share") {}; Divider(); Button(role: .destructive) { Label("Remove", systemImage: "trash") } } }
    private func formatDuration(_ interval: TimeInterval) -> String { let m = Int(interval) / 60; let s = Int(interval) % 60; return String(format: "%d:%02d", m, s) }
}

struct SectionHeader: View {
    let title: String; let actionTitle: String?; let action: () -> Void
    init(title: String, actionTitle: String? = nil, action: @escaping () -> Void = {}) { self.title = title; self.actionTitle = actionTitle; self.action = action }
    var body: some View { HStack { Text(title).font(.linerTitle3.weight(.bold)).foregroundColor(.linerTextPrimary); Spacer(); if let actionTitle = actionTitle { Button(action: action) { Text(actionTitle).font(.linerSubheadline.weight(.semibold)).foregroundColor(.linerPrimary) } } }.padding(.horizontal, LinerSpacing.md) }
}

struct EmptyState: View {
    let icon: String; let title: String; let message: String; let actionTitle: String?; let action: (() -> Void)?
    init(icon: String, title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) { self.icon = icon; self.title = title; self.message = message; self.actionTitle = actionTitle; self.action = action }
    var body: some View { VStack(spacing: LinerSpacing.lg) { Image(systemName: icon).font(.system(size: 64, weight: .light)).foregroundColor(.linerTextTertiary).symbolRenderingMode(.hierarchical); VStack(spacing: LinerSpacing.sm) { Text(title).font(.linerTitle2.weight(.bold)).foregroundColor(.linerTextPrimary); Text(message).font(.linerBody).foregroundColor(.linerTextSecondary).multilineTextAlignment(.center).padding(.horizontal, LinerSpacing.xl) }; if let actionTitle = actionTitle, let action = action { PrimaryButton(actionTitle, icon: "plus", fullWidth: false, action: action) } }.frame(maxWidth: .infinity).padding(LinerSpacing.xxl) }
}

struct LiveWaveform: View {
    let isPlaying: Bool; let barCount: Int = 5; @State private var animating = false
    var body: some View { HStack(spacing: 3) { ForEach(0..<barCount, id: \.self) { index in Capsule().fill(Color.linerPrimary).frame(width: 3, height: isPlaying ? CGFloat.random(in: 4...16) : 4).animation(isPlaying ? Animation.easeInOut(duration: 0.3).repeatForever().delay(Double(index) * 0.1) : .default, value: animating) } }.onAppear { animating = isPlaying }.onChange(of: isPlaying) { _, new in animating = new } }
}

struct TrackArtwork: View {
    let track: Track?; let size: CGFloat; let cornerRadius: CGFloat; let artworkURL: URL?
    init(track: Track? = nil, size: CGFloat, cornerRadius: CGFloat, artworkURL: URL? = nil) { self.track = track; self.size = size; self.cornerRadius = cornerRadius; self.artworkURL = artworkURL ?? track?.artworkURL }
    var body: some View {
        if let url = artworkURL { AsyncImage(url: url) { phase in switch phase { case .empty: ProgressView().frame(width: size, height: size); case .success(let image): image.resizable().aspectRatio(contentMode: .fill).frame(width: size, height: size).clipped(); case .failure: placeholder; @unknown default: placeholder } } } else { placeholder }.frame(width: size, height: size).clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    private var placeholder: some View { RoundedRectangle(cornerRadius: cornerRadius).fill(Color.linerSurface).overlay(Image(systemName: "music.note").font(.system(size: size * 0.4, weight: .light)).foregroundColor(.linerTextTertiary)) }
}
