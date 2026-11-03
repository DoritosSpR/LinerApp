import SwiftUI
import MessageUI

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject private var musicLibrary: MusicLibrary
    @EnvironmentObject private var audioPlayer: AudioPlayer
    @AppStorage("liner.crossfadeEnabled") private var crossfadeEnabled = true
    @AppStorage("liner.crossfadeDuration") private var crossfadeDuration = 5.0
    @AppStorage("liner.equalizerEnabled") private var equalizerEnabled = false
    @AppStorage("liner.lyricsAutoScroll") private var lyricsAutoScroll = true
    @AppStorage("liner.showExplicitContent") private var showExplicitContent = true
    @AppStorage("liner.offlineMode") private var offlineMode = false
    @AppStorage("liner.audioQuality") private var audioQuality = AudioQuality.high
    @AppStorage("liner.theme") private var theme = Theme.system

    @State private var showingAbout = false
    @State private var showingEqualizer = false
    @State private var cacheSize = "Calculating..."

    enum AudioQuality: String, CaseIterable, Identifiable {
        case low = "Low (96 kbps)"
        case normal = "Normal (160 kbps)"
        case high = "High (320 kbps)"
        case lossless = "Lossless (FLAC)"

        var id: String { rawValue }
    }

    enum Theme: String, CaseIterable, Identifiable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.linerBackground
                    .ignoresSafeArea()

                List {
                    // Account Section
                    Section {
                        AccountRow()
                    }
                    .listSectionSpacing(LinerSpacing.lg)

                    // Playback Section
                    Section(header: sectionHeader("Playback")) {
                        SettingsRow(
                            icon: "speaker.wave.2",
                            title: "Audio Quality",
                            subtitle: audioQuality.rawValue,
                            accessory: .navigation
                        ) {
                            // Navigate to audio quality
                        }

                        SettingsToggleRow(
                            icon: "waveform.badge.plus",
                            title: "Crossfade",
                            subtitle: "Smooth transitions between songs",
                            isOn: $crossfadeEnabled
                        )

                        if crossfadeEnabled {
                            SettingsSliderRow(
                                icon: "timer",
                                title: "Crossfade Duration",
                                value: $crossfadeDuration,
                                range: 1...12,
                                step: 1,
                                unit: "s"
                            )
                        }

                        SettingsToggleRow(
                            icon: "slider.horizontal.3",
                            title: "Equalizer",
                            subtitle: "Adjust audio frequencies",
                            isOn: $equalizerEnabled
                        ) {
                            showingEqualizer = true
                        }

                        SettingsToggleRow(
                            icon: "text.quote",
                            title: "Auto-scroll Lyrics",
                            subtitle: "Automatically scroll synced lyrics",
                            isOn: $lyricsAutoScroll
                        )
                    }
                    .listSectionSpacing(LinerSpacing.lg)

                    // Library Section
                    Section(header: sectionHeader("Library")) {
                        SettingsToggleRow(
                            icon: "exclamationmark.triangle",
                            title: "Show Explicit Content",
                            subtitle: "Display explicit content warnings",
                            isOn: $showExplicitContent
                        )

                        SettingsToggleRow(
                            icon: "wifi.slash",
                            title: "Offline Mode",
                            subtitle: "Only play downloaded music",
                            isOn: $offlineMode
                        )

                        SettingsRow(
                            icon: "externaldrive",
                            title: "Cache Size",
                            subtitle: cacheSize,
                            accessory: .none
                        ) {
                            calculateCacheSize()
                        }

                        SettingsRow(
                            icon: "arrow.down.circle",
                            title: "Downloads",
                            subtitle: "Manage downloaded music",
                            accessory: .navigation
                        ) {}
                    }
                    .listSectionSpacing(LinerSpacing.lg)

                    // Appearance Section
                    Section(header: sectionHeader("Appearance")) {
                        SettingsRow(
                            icon: "paintbrush",
                            title: "Theme",
                            subtitle: theme.rawValue,
                            accessory: .picker
                        ) {
                            // Theme picker handled by picker
                        }

                        SettingsRow(
                            icon: "moon",
                            title: "Dark Mode",
                            subtitle: "Automatic based on system",
                            accessory: .toggle
                        ) {}
                    }
                    .listSectionSpacing(LinerSpacing.lg)

                    // Social Section
                    Section(header: sectionHeader("Social")) {
                        SettingsRow(
                            icon: "person.2",
                            title: "Profile",
                            subtitle: "Edit your profile and preferences",
                            accessory: .navigation
                        ) {}

                        SettingsRow(
                            icon: "link",
                            title: "Connected Services",
                            subtitle: "Last.fm, Discord, etc.",
                            accessory: .navigation
                        ) {}
                    }
                    .listSectionSpacing(LinerSpacing.lg)

                    // About Section
                    Section(header: sectionHeader("About")) {
                        SettingsRow(
                            icon: "info.circle",
                            title: "About Liner",
                            subtitle: "Version 1.0.0",
                            accessory: .navigation
                        ) {
                            showingAbout = true
                        }

                        SettingsRow(
                            icon: "doc.text",
                            title: "Terms of Service",
                            subtitle: "Read our terms",
                            accessory: .navigation
                        ) {}

                        SettingsRow(
                            icon: "hand.raised",
                            title: "Privacy Policy",
                            subtitle: "How we protect your data",
                            accessory: .navigation
                        ) {}

                        SettingsRow(
                            icon: "star",
                            title: "Rate on App Store",
                            subtitle: "Help us improve",
                            accessory: .navigation
                        ) {}

                        SettingsRow(
                            icon: "envelope",
                            title: "Send Feedback",
                            subtitle: "Report a bug or suggest a feature",
                            accessory: .navigation
                        ) {}
                    }
                    .listSectionSpacing(LinerSpacing.lg)

                    // Danger Zone
                    Section(header: sectionHeader("Danger Zone")) {
                        SettingsRow(
                            icon: "trash",
                            title: "Clear Cache",
                            subtitle: "Free up storage space",
                            accessory: .destructive
                        ) {
                            clearCache()
                        }

                        SettingsRow(
                            icon: "arrow.clockwise",
                            title: "Reset Settings",
                            subtitle: "Restore all settings to defaults",
                            accessory: .destructive
                        ) {
                            resetSettings()
                        }

                        SettingsRow(
                            icon: "person.crop.circle.badge.minus",
                            title: "Sign Out",
                            subtitle: "Sign out of your account",
                            accessory: .destructive
                        ) {}
                    }
                    .listSectionSpacing(LinerSpacing.lg)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.linerBackground)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAbout) {
                AboutSheet()
            }
            .sheet(isPresented: $showingEqualizer) {
                EqualizerSheet()
            }
            .onAppear {
                calculateCacheSize()
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.linerFootnote.weight(.semibold))
            .foregroundColor(.linerTextTertiary)
            .textCase(.uppercase)
    }

    private func calculateCacheSize() {
        // Simulate cache calculation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            cacheSize = "\(Int.random(in: 50...500)) MB"
        }
    }

    private func clearCache() {
        cacheSize = "0 MB"
        LinerHaptic.success()
    }

    private func resetSettings() {
        crossfadeEnabled = true
        crossfadeDuration = 5.0
        equalizerEnabled = false
        lyricsAutoScroll = true
        showExplicitContent = true
        offlineMode = false
        audioQuality = .high
        theme = .system
        LinerHaptic.warning()
    }
}

// MARK: - Account Row

struct AccountRow: View {
    var body: some View {
        HStack(spacing: LinerSpacing.md) {
            Circle()
                .fill(Color.linerGradientPrimary)
                .frame(width: 56, height: 56)
                .overlay(
                    Text("U")
                        .font(.linerTitle2.weight(.bold))
                        .foregroundColor(.linerTextInverse)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("User Name")
                    .font(.linerHeadline.weight(.semibold))
                    .foregroundColor(.linerTextPrimary)

                Text("Free Account")
                    .font(.linerSubheadline)
                    .foregroundColor(.linerTextSecondary)
            }

            Spacer()

            IconButton(
                icon: "chevron.right",
                size: .small,
                variant: .glass
            ) {}
        }
        .padding(.vertical, LinerSpacing.xs)
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    enum Accessory {
        case none
        case navigation
        case toggle
        case picker
        case destructive
    }

    let icon: String
    let title: String
    let subtitle: String
    let accessory: Accessory
    let action: () -> Void

    init(
        icon: String,
        title: String,
        subtitle: String,
        accessory: Accessory = .none,
        action: @escaping () -> Void = {}
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.accessory = accessory
        self.action = action
    }

    var body: some View {
        Button(action: {
            if accessory != .destructive {
                LinerHaptic.light()
            } else {
                LinerHaptic.warning()
            }
            action()
        }) {
            HStack(spacing: LinerSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.linerBody.weight(.medium))
                        .foregroundColor(titleColor)

                    Text(subtitle)
                        .font(.linerSubheadline)
                        .foregroundColor(.linerTextSecondary)
                        .lineLimit(1)
                }

                Spacer()

                accessoryView
            }
        }
        .buttonStyle(PlainButtonStyle())
        .listRowBackground(Color.linerSurface)
    }

    private var iconColor: Color {
        accessory == .destructive ? .linerError : .linerPrimary
    }

    private var titleColor: Color {
        accessory == .destructive ? .linerError : .linerTextPrimary
    }

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .none:
            EmptyView()
        case .navigation:
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.linerTextTertiary)
        case .toggle:
            Toggle("", isOn: .constant(false))
                .labelsHidden()
        case .picker:
            Menu {
                ForEach(SettingsView.Theme.allCases) { theme in
                    Button(theme.rawValue) {}
                }
            } label: {
                HStack(spacing: 4) {
                    Text(Theme.system.rawValue)
                        .font(.linerSubheadline)
                        .foregroundColor(.linerTextSecondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.linerTextTertiary)
                }
            }
        case .destructive:
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.linerError)
        }
    }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
        self.action = action
    }

    var body: some View {
        HStack(spacing: LinerSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.linerPrimary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.linerBody.weight(.medium))
                    .foregroundColor(.linerTextPrimary)

                Text(subtitle)
                    .font(.linerSubheadline)
                    .foregroundColor(.linerTextSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .onChange(of: isOn) { _ in
                    LinerHaptic.selection()
                    action?()
                }
        }
        .listRowBackground(Color.linerSurface)
    }
}

// MARK: - Settings Slider Row

struct SettingsSliderRow: View {
    let icon: String
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String

    var body: some View {
        VStack(spacing: LinerSpacing.sm) {
            HStack(spacing: LinerSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.linerPrimary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.linerBody.weight(.medium))
                        .foregroundColor(.linerTextPrimary)

                    Text("\(Int(value)) \(unit)")
                        .font(.linerSubheadline)
                        .foregroundColor(.linerTextSecondary)
                }

                Spacer()
            }

            Slider(value: $value, in: range, step: step)
                .tint(.linerPrimary)
        }
        .listRowBackground(Color.linerSurface)
    }
}

// MARK: - About Sheet

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.linerBackground
                    .ignoresSafeArea()

                VStack(spacing: LinerSpacing.xl) {
                    // App Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: LinerRadius.xl)
                            .fill(Color.linerGradientPrimary)
                            .frame(width: 120, height: 120)

                        Image(systemName: "music.note")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(.linerTextInverse)
                    }
                    .shadow(.elevated)

                    VStack(spacing: LinerSpacing.sm) {
                        Text("Liner")
                            .font(.linerLargeTitle.weight(.bold))
                            .foregroundColor(.linerTextPrimary)

                        Text("Version 1.0.0")
                            .font(.linerBody)
                            .foregroundColor(.linerTextSecondary)

                        Text("Build 1 (2024)")
                            .font(.linerCaption1)
                            .foregroundColor(.linerTextTertiary)
                    }

                    Divider()
                        .background(Color.linerBorder)
                        .padding(.horizontal, LinerSpacing.xl)

                    VStack(spacing: LinerSpacing.md) {
                        InfoRow(label: "Made with", value: "Swift & SwiftUI")
                        InfoRow(label: "Audio Engine", value: "AVFoundation")
                        InfoRow(label: "Architecture", value: "MVVM + SwiftUI")
                        InfoRow(label: "Design", value: "Glass Morphism")
                    }
                    .padding(.horizontal, LinerSpacing.xl)

                    Spacer()

                    VStack(spacing: LinerSpacing.sm) {
                        Text("© 2024 Liner Team")
                            .font(.linerFootnote)
                            .foregroundColor(.linerTextTertiary)

                        Text("Built with ❤️ for music lovers")
                            .font(.linerFootnote)
                            .foregroundColor(.linerTextTertiary)
                    }

                    PrimaryButton("Done", action: { dismiss() })
                        .padding(.horizontal, LinerSpacing.xl)
                }
                .padding(.top, LinerSpacing.xl)
                .padding(.bottom, LinerSpacing.xxl)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.linerPrimary)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.linerSubheadline)
                .foregroundColor(.linerTextSecondary)

            Spacer()

            Text(value)
                .font(.linerSubheadline.weight(.medium))
                .foregroundColor(.linerTextPrimary)
        }
    }
}

// MARK: - Equalizer Sheet

struct EqualizerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("liner.eqBands") private var eqBandsData = Data()
    @State private var bands: [Double] = Array(repeating: 0, count: 10)

    let frequencies = [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.linerBackground
                    .ignoresSafeArea()

                VStack(spacing: LinerSpacing.xl) {
                    Text("Equalizer")
                        .font(.linerTitle1.weight(.bold))
                        .foregroundColor(.linerTextPrimary)

                    // EQ Visualizer
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(0..<bands.count, id: \.self) { index in
                            VStack(spacing: LinerSpacing.sm) {
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.linerBorder.opacity(0.2))
                                        .frame(width: 24, height: 160)

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(
                                            LinearGradient(
                                                colors: [.linerPrimary, .linerAccentLight],
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                        .frame(width: 24, height: max(4, 160 * (bands[index] + 12) / 24))
                                }

                                Text("\(frequencies[index]) Hz")
                                    .font(.linerCaption2)
                                    .foregroundColor(.linerTextTertiary)
                                    .rotationEffect(.degrees(-45))
                                    .fixedSize()
                            }
                        }
                    }
                    .frame(height: 220)
                    .padding(.horizontal, LinerSpacing.lg)

                    // Presets
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: LinerSpacing.sm) {
                            ForEach(EQPreset.allCases) { preset in
                                PresetChip(preset: preset, onTap: { applyPreset(preset) })
                            }
                        }
                        .padding(.horizontal, LinerSpacing.md)
                    }

                    Spacer()

                    HStack(spacing: LinerSpacing.md) {
                        SecondaryButton("Flat", variant: .outline, fullWidth: true) {
                            bands = Array(repeating: 0, count: 10)
                        }

                        PrimaryButton("Done", action: { dismiss() })
                    }
                    .padding(.horizontal, LinerSpacing.xl)
                }
                .padding(.top, LinerSpacing.xl)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.linerPrimary)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func applyPreset(_ preset: EQPreset) {
        bands = preset.values
        LinerHaptic.success()
    }
}

enum EQPreset: String, CaseIterable, Identifiable {
    case flat = "Flat"
    case bassBoost = "Bass Boost"
    case rock = "Rock"
    case pop = "Pop"
    case classical = "Classical"
    case jazz = "Jazz"
    case electronic = "Electronic"
    case vocal = "Vocal"

    var id: String { rawValue }

    var values: [Double] {
        switch self {
        case .flat: return [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        case .bassBoost: return [8, 6, 4, 2, 0, 0, 0, 0, 0, 0]
        case .rock: return [4, 2, 0, -2, -2, 0, 2, 4, 4, 4]
        case .pop: return [2, 4, 2, 0, -2, 0, 2, 4, 2, 0]
        case .classical: return [0, 0, 0, 0, 0, 2, 2, 2, 2, 2]
        case .jazz: return [2, 4, 2, 0, 0, 0, 0, -2, -2, -2]
        case .electronic: return [6, 4, 2, 0, -2, 0, 2, 4, 6, 6]
        case .vocal: return [0, 0, 0, -2, -4, -2, 0, 2, 4, 4]
        }
    }
}

struct PresetChip: View {
    let preset: EQPreset
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            LinerHaptic.light()
            onTap()
        }) {
            Text(preset.rawValue)
                .font(.linerSubheadline.weight(.medium))
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