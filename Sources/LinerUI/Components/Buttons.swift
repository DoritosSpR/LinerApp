import SwiftUI

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    let fullWidth: Bool

    init(
        _ title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.fullWidth = fullWidth
        self.action = action
    }

    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                LinerHaptic.light()
                action()
            }
        }) {
            HStack(spacing: LinerSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .linerTextInverse))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.linerBody.weight(.semibold))
                }
                Text(title)
                    .font(.linerHeadline)
            }
            .foregroundColor(.linerTextInverse)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, LinerSpacing.lg)
            .padding(.vertical, LinerSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: LinerRadius.full)
                    .fill(
                        isDisabled
                        ? Color.linerPrimary.opacity(0.5)
                        : Color.linerGradientPrimary
                    )
            )
            .opacity(isDisabled ? 0.7 : 1.0)
            .scaleEffect(isLoading ? 0.98 : 1.0)
            .animation(.linerSpringFast, value: isLoading)
        }
        .disabled(isLoading || isDisabled)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    let fullWidth: Bool
    let variant: Variant

    enum Variant {
        case outline
        case ghost
        case glass
    }

    init(
        _ title: String,
        icon: String? = nil,
        variant: Variant = .outline,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.fullWidth = fullWidth
        self.action = action
    }

    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                LinerHaptic.light()
                action()
            }
        }) {
            HStack(spacing: LinerSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: variant == .glass ? .linerTextInverse : .linerPrimary))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.linerBody.weight(.semibold))
                }
                Text(title)
                    .font(.linerHeadline)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, LinerSpacing.lg)
            .padding(.vertical, LinerSpacing.md)
            .background(backgroundView)
            .overlay(overlayView)
        }
        .disabled(isLoading || isDisabled)
        .buttonStyle(PlainButtonStyle())
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    private var foregroundColor: Color {
        switch variant {
        case .outline: return isDisabled ? .linerTextTertiary : .linerPrimary
        case .ghost: return isDisabled ? .linerTextTertiary : .linerTextPrimary
        case .glass: return isDisabled ? .linerTextTertiary.opacity(0.5) : .linerTextInverse
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch variant {
        case .outline:
            Color.clear
        case .ghost:
            Color.clear
        case .glass:
            RoundedRectangle(cornerRadius: LinerRadius.full)
                .fill(Color.linerGlassMedium)
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        switch variant {
        case .outline:
            RoundedRectangle(cornerRadius: LinerRadius.full)
                .stroke(
                    isDisabled ? Color.linerBorder : Color.linerPrimary,
                    lineWidth: 2
                )
        case .ghost:
            Color.clear
        case .glass:
            RoundedRectangle(cornerRadius: LinerRadius.full)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        }
    }
}

// MARK: - Icon Button

struct IconButton: View {
    let icon: String
    let action: () -> Void
    let size: Size
    let variant: Variant
    let isDisabled: Bool
    let accessibilityLabel: String

    enum Size {
        case small
        case medium
        case large

        var dimension: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 44
            case .large: return 56
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 22
            case .large: return 28
            }
        }
    }

    enum Variant {
        case primary
        case secondary
        case glass
        case plain
    }

    init(
        icon: String,
        size: Size = .medium,
        variant: Variant = .glass,
        isDisabled: Bool = false,
        accessibilityLabel: String = "",
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.variant = variant
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    var body: some View {
        Button(action: {
            if !isDisabled {
                LinerHaptic.light()
                action()
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(foregroundColor)
                .frame(width: size.dimension, height: size.dimension)
                .background(backgroundView)
                .overlay(overlayView)
        }
        .disabled(isDisabled)
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(accessibilityLabel.isEmpty ? icon : accessibilityLabel)
        .opacity(isDisabled ? 0.4 : 1.0)
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary: return .linerTextInverse
        case .secondary: return .linerPrimary
        case .glass: return .linerTextPrimary
        case .plain: return .linerTextPrimary
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch variant {
        case .primary:
            Circle().fill(Color.linerGradientPrimary)
        case .secondary:
            Circle().fill(Color.linerPrimary.opacity(0.1))
        case .glass:
            Circle().fill(Color.linerGlassMedium)
        case .plain:
            Color.clear
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        if variant == .glass {
            Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
        }
    }
}

// MARK: - Playback Button

struct PlaybackButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void
    let isActive: Bool
    let variant: Variant

    enum Variant {
        case primary
        case secondary
        case glass
    }

    init(
        icon: String,
        size: CGFloat = 56,
        variant: Variant = .primary,
        isActive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.variant = variant
        self.isActive = isActive
        self.action = action
    }

    var body: some View {
        Button(action: {
            LinerHaptic.medium()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.45, weight: .medium))
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size)
                .background(backgroundView)
                .overlay(overlayView)
                .scaleEffect(isActive ? 0.95 : 1.0)
                .animation(.linerSpringFast, value: isActive)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary: return .linerTextInverse
        case .secondary: return .linerPrimary
        case .glass: return .linerTextPrimary
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch variant {
        case .primary:
            Circle().fill(Color.linerGradientPrimary)
        case .secondary:
            Circle().fill(Color.linerPrimary.opacity(0.15))
        case .glass:
            Circle().fill(Color.linerGlassHeavy)
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        if variant == .glass {
            Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
        }
    }
}

// MARK: - Toggle Button

struct ToggleButton: View {
    let title: String
    let icon: String?
    let isOn: Binding<Bool>
    let variant: Variant

    enum Variant {
        case primary
        case glass
    }

    init(
        _ title: String,
        icon: String? = nil,
        isOn: Binding<Bool>,
        variant: Variant = .glass
    ) {
        self.title = title
        self.icon = icon
        self.isOn = isOn
        self.variant = variant
    }

    var body: some View {
        Button(action: {
            LinerHaptic.selection()
            isOn.wrappedValue.toggle()
        }) {
            HStack(spacing: LinerSpacing.sm) {
                if let icon = icon {
                    Image(systemName: isOn.wrappedValue ? "\(icon).fill" : icon)
                        .font(.linerBody.weight(.semibold))
                }
                Text(title)
                    .font(.linerHeadline)
            }
            .foregroundColor(isOn.wrappedValue ? .linerTextInverse : .linerTextPrimary)
            .padding(.horizontal, LinerSpacing.lg)
            .padding(.vertical, LinerSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: LinerRadius.full)
                    .fill(
                        isOn.wrappedValue
                        ? Color.linerGradientPrimary
                        : (variant == .glass ? Color.linerGlassMedium : Color.linerSurface)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: LinerRadius.full)
                    .stroke(
                        isOn.wrappedValue ? Color.clear : Color.linerBorder,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.linerSpring, value: isOn.wrappedValue)
    }
}