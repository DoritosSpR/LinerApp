import SwiftUI

// MARK: - Colors (usan Asset Catalog)
extension Color {
    static let linerPrimary = Color("LinerPrimary")
    static let linerSecondary = Color("LinerSecondary")
    static let linerAccent = Color("LinerAccent")
    static let linerAccentLight = Color("LinerAccentLight")
    static let linerBackground = Color("LinerBackground")
    static let linerSurface = Color("LinerSurface")
    static let linerSurfaceElevated = Color("LinerSurfaceElevated")
    static let linerSurfaceOverlay = Color("LinerSurfaceOverlay")
    static let linerTextPrimary = Color("LinerTextPrimary")
    static let linerTextSecondary = Color("LinerTextSecondary")
    static let linerTextTertiary = Color("LinerTextTertiary")
    static let linerTextInverse = Color("LinerTextInverse")
    static let linerBorder = Color("LinerBorder")
    static let linerBorderFocus = Color("LinerBorderFocus")
    static let linerError = Color("LinerError")
    static let linerSuccess = Color("LinerSuccess")
    static let linerWarning = Color("LinerWarning")
    static let linerGlassLight = Color.white.opacity(0.08)
    static let linerGlassMedium = Color.white.opacity(0.15)
    static let linerGlassHeavy = Color.white.opacity(0.25)
    static let linerGradientPrimary = LinearGradient(colors: [.linerPrimary, .linerAccent], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let linerGradientSurface = LinearGradient(colors: [.linerSurface, .linerSurfaceElevated], startPoint: .top, endPoint: .bottom)
}

// MARK: - GlassMorphism
struct GlassMorphism: ViewModifier {
    enum Intensity { case light, medium, heavy }
    let intensity: Intensity
    func body(content: Content) -> some View {
        content.background(intensity == .light ? .ultraThinMaterial : intensity == .medium ? .thinMaterial : .regularMaterial)
    }
}
extension View { func glassMorphism(_ intensity: GlassMorphism.Intensity = .medium) -> some View { modifier(GlassMorphism(intensity: intensity)) } }

// MARK: - Typography
extension Font {
    static let linerLargeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let linerTitle1 = Font.system(.title, design: .rounded).weight(.bold)
    static let linerTitle2 = Font.system(.title2, design: .rounded).weight(.semibold)
    static let linerTitle3 = Font.system(.title3, design: .rounded).weight(.semibold)
    static let linerHeadline = Font.system(.headline, design: .rounded).weight(.semibold)
    static let linerSubheadline = Font.system(.subheadline, design: .rounded).weight(.medium)
    static let linerBody = Font.system(.body, design: .rounded)
    static let linerCallout = Font.system(.callout, design: .rounded)
    static let linerCaption1 = Font.system(.caption, design: .rounded)
    static let linerCaption2 = Font.system(.caption2, design: .rounded)
    static let linerMonoCaption = Font.system(.caption, design: .monospaced)
    static func linerWeighted(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font { Font.system(style, design: .rounded).weight(weight) }
}

// MARK: - Spacing
struct LinerSpacing { static let xxs: CGFloat = 2; static let xs: CGFloat = 4; static let sm: CGFloat = 8; static let md: CGFloat = 16; static let lg: CGFloat = 24; static let xl: CGFloat = 32; static let xxl: CGFloat = 48; static let xxxl: CGFloat = 64 }

// MARK: - Radius
struct LinerRadius { static let xs: CGFloat = 4; static let sm: CGFloat = 8; static let md: CGFloat = 12; static let lg: CGFloat = 16; static let xl: CGFloat = 24; static let xxl: CGFloat = 32; static let full: CGFloat = 9999 }

// MARK: - Animation
extension Animation {
    static let linerSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let linerSpringFast = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let linerEaseOut = Animation.easeOut(duration: 0.2)
    static let linerQuick = Animation.easeInOut(duration: 0.15)
}

// MARK: - Shadow
struct LinerShadow { let color: Color; let radius: CGFloat; let x: CGFloat; let y: CGFloat
    static let small = LinerShadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    static let medium = LinerShadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    static let large = LinerShadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
}
extension View { func linerShadow(_ shadow: LinerShadow = .medium) -> some View { self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y) } }

// MARK: - Haptics
enum LinerHaptic { static func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }; static func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }; static func heavy() { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }; static func selection() { UISelectionFeedbackGenerator().selectionChanged() } }

// MARK: - Gradient
extension Color { static let linerGradientPrimary = LinearGradient(colors: [.linerPrimary, .linerAccent], startPoint: .topLeading, endPoint: .bottomTrailing) }
