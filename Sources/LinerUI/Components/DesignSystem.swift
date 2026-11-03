import SwiftUI

// MARK: - Color Palette

extension Color {
    // Brand Colors
    static let linerPrimary = Color("LinerPrimary", bundle: .module)
    static let linerSecondary = Color("LinerSecondary", bundle: .module)
    static let linerAccent = Color("LinerAccent", bundle: .module)
    static let linerAccentLight = Color("LinerAccentLight", bundle: .module)

    // Semantic Colors
    static let linerBackground = Color("LinerBackground", bundle: .module)
    static let linerSurface = Color("LinerSurface", bundle: .module)
    static let linerSurfaceElevated = Color("LinerSurfaceElevated", bundle: .module)
    static let linerSurfaceOverlay = Color("LinerSurfaceOverlay", bundle: .module)

    static let linerTextPrimary = Color("LinerTextPrimary", bundle: .module)
    static let linerTextSecondary = Color("LinerTextSecondary", bundle: .module)
    static let linerTextTertiary = Color("LinerTextTertiary", bundle: .module)
    static let linerTextInverse = Color("LinerTextInverse", bundle: .module)

    static let linerBorder = Color("LinerBorder", bundle: .module)
    static let linerBorderFocus = Color("LinerBorderFocus", bundle: .module)

    static let linerError = Color("LinerError", bundle: .module)
    static let linerSuccess = Color("LinerSuccess", bundle: .module)
    static let linerWarning = Color("LinerWarning", bundle: .module)

    // Glass Morphism
    static let linerGlassLight = Color.white.opacity(0.1)
    static let linerGlassMedium = Color.white.opacity(0.15)
    static let linerGlassHeavy = Color.white.opacity(0.25)
    static let linerGlassDark = Color.black.opacity(0.2)

    // Gradients
    static let linerGradientPrimary = LinearGradient(
        colors: [.linerPrimary, .linerSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let linerGradientAccent = LinearGradient(
        colors: [.linerAccent, .linerAccentLight],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let linerGradientGlass = LinearGradient(
        colors: [.linerGlassLight, .linerGlassMedium],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let linerGradientBackground = LinearGradient(
        colors: [.linerBackground, .linerBackground.opacity(0.8)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Glass Morphism Modifier

struct GlassMorphism: ViewModifier {
    let intensity: GlassIntensity
    let cornerRadius: CGFloat
    let border: Bool

    enum GlassIntensity {
        case light
        case medium
        case heavy
        case dark

        var material: Material {
            switch self {
            case .light: return .ultraThinMaterial
            case .medium: return .thinMaterial
            case .heavy: return .regularMaterial
            case .dark: return .ultraThickMaterial
            }
        }

        var opacity: Double {
            switch self {
            case .light: return 0.1
            case .medium: return 0.15
            case .heavy: return 0.25
            case .dark: return 0.35
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(intensity.material)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                border ? Color.white.opacity(0.2) : Color.clear,
                                lineWidth: border ? 1 : 0
                            )
                    )
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: intensity == .heavy ? 20 : 10,
                        x: 0,
                        y: intensity == .heavy ? 10 : 5
                    )
            )
    }
}

extension View {
    func glassMorphism(
        intensity: GlassMorphism.GlassIntensity = .medium,
        cornerRadius: CGFloat = 16,
        border: Bool = true
    ) -> some View {
        modifier(GlassMorphism(intensity: intensity, cornerRadius: cornerRadius, border: border))
    }
}

// MARK: - Typography

extension Font {
    static let linerLargeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let linerTitle1 = Font.system(.title, design: .rounded).weight(.bold)
    static let linerTitle2 = Font.system(.title2, design: .rounded).weight(.semibold)
    static let linerTitle3 = Font.system(.title3, design: .rounded).weight(.semibold)
    static let linerHeadline = Font.system(.headline, design: .rounded).weight(.medium)
    static let linerBody = Font.system(.body, design: .rounded)
    static let linerCallout = Font.system(.callout, design: .rounded)
    static let linerSubheadline = Font.system(.subheadline, design: .rounded)
    static let linerFootnote = Font.system(.footnote, design: .rounded)
    static let linerCaption1 = Font.system(.caption, design: .rounded)
    static let linerCaption2 = Font.system(.caption2, design: .rounded)

    // Monospace for time display
    static let linerMonoBody = Font.system(.body, design: .monospaced).weight(.medium)
    static let linerMonoCaption = Font.system(.caption, design: .monospaced).weight(.medium)
}

// MARK: - Spacing

enum LinerSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius

enum LinerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 9999
}

// MARK: - Animation

extension Animation {
    static let linerSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let linerSpringFast = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let linerEaseOut = Animation.easeOut(duration: 0.25)
    static let linerEaseInOut = Animation.easeInOut(duration: 0.3)
}

// MARK: - Shadow

extension View {
    func linerShadow(
        _ style: ShadowStyle = .medium,
        color: Color = .black.opacity(0.1)
    ) -> some View {
        let (radius, x, y) = style.values
        return self.shadow(color: color, radius: radius, x: x, y: y)
    }

    enum ShadowStyle {
        case subtle
        case medium
        case elevated
        case floating

        var values: (CGFloat, CGFloat, CGFloat) {
            switch self {
            case .subtle: return (4, 0, 2)
            case .medium: return (12, 0, 6)
            case .elevated: return (24, 0, 12)
            case .floating: return (40, 0, 20)
            }
        }
    }
}

// MARK: - Blur Background

struct BlurBackground: ViewModifier {
    let style: UIBlurEffect.Style

    func body(content: Content) -> some View {
        content
            .background(
                VisualEffectBlur(blurStyle: style)
            )
    }
}

extension View {
    func blurBackground(style: UIBlurEffect.Style = .systemUltraThinMaterial) -> some View {
        modifier(BlurBackground(style: style))
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    let blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - Haptic Feedback

enum LinerHaptic {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}