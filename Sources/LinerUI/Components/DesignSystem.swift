import SwiftUI

// MARK: - Colors

extension Color {
    // Colores del asset catalog (usan Bundle.main)
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
    
    // Gradientes
    static let linerGradientPrimary = LinearGradient(
        colors: [.linerPrimary, .linerAccent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let linerGradientSurface = LinearGradient(
        colors: [.linerSurface, .linerSurfaceElevated],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - GlassMorphism

struct GlassMorphism: ViewModifier {
    let intensity: Intensity
    
    enum Intensity {
        case light, medium, heavy
        
        var material: Material {
            switch self {
            case .light: return .ultraThinMaterial
            case .medium: return .thinMaterial
            case .heavy: return .regularMaterial
            }
        }
        
        var opacity: Double {
            switch self {
            case .light: return 0.1
            case .medium: return 0.2
            case .heavy: return 0.3
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(intensity.material)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.white.opacity(intensity.opacity), lineWidth: 0.5)
            )
    }
}

extension View {
    func glassMorphism(intensity: GlassMorphism.Intensity = .medium) -> some View {
        modifier(GlassMorphism(intensity: intensity))
    }
}

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
}

extension Font {
    static func linerWeighted(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        Font.system(style, design: .rounded).weight(weight)
    }
}

// MARK: - Spacing

struct LinerSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Radius

struct LinerRadius {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let full: CGFloat = 9999
}

// MARK: - Animation

struct LinerAnimation {
    static let quick = Animation.easeInOut(duration: 0.15)
    static let standard = Animation.easeInOut(duration: 0.25)
    static let slow = Animation.easeInOut(duration: 0.4)
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
}

extension Animation {
    static let linerSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let linerQuick = Animation.easeInOut(duration: 0.15)
}

// MARK: - Shadow

struct LinerShadow {
    static let small = Shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    static let medium = Shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    static let large = Shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    func linerShadow(_ shadow: LinerShadow = .medium) -> some View {
        shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
