import SwiftUI

struct PrimaryButton: View {
    let title: String; let icon: String?; let fullWidth: Bool; let isLoading: Bool; let isDisabled: Bool; let action: () -> Void
    init(_ title: String, icon: String? = nil, fullWidth: Bool = true, isLoading: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) { self.title = title; self.icon = icon; self.fullWidth = fullWidth; self.isLoading = isLoading; self.isDisabled = isDisabled; self.action = action }
    var body: some View {
        Button(action: { if !isLoading && !isDisabled { UIImpactFeedbackGenerator(style: .light).impactOccurred(); action() } }) {
            HStack(spacing: LinerSpacing.sm) {
                if isLoading { ProgressView().tint(.linerTextInverse) } else if let icon = icon { Image(systemName: icon) }
                Text(title).font(.linerSubheadline.weight(.semibold))
            }
            .foregroundColor(.linerTextInverse)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.vertical, LinerSpacing.md)
            .background(isDisabled ? Color.linerPrimary.opacity(0.5) : Color.linerGradientPrimary)
            .clipShape(RoundedRectangle(cornerRadius: LinerRadius.full))
            .opacity(isDisabled ? 0.7 : 1.0).scaleEffect(isLoading ? 0.98 : 1.0).animation(.linerSpringFast, value: isLoading)
        }.disabled(isLoading || isDisabled).buttonStyle(PlainButtonStyle())
    }
}

struct SecondaryButton: View {
    let title: String; let icon: String?; let fullWidth: Bool; let isLoading: Bool; let isDisabled: Bool; let action: () -> Void
    init(_ title: String, icon: String? = nil, fullWidth: Bool = true, isLoading: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) { self.title = title; self.icon = icon; self.fullWidth = fullWidth; self.isLoading = isLoading; self.isDisabled = isDisabled; self.action = action }
    var body: some View {
        Button(action: { if !isLoading && !isDisabled { UIImpactFeedbackGenerator(style: .light).impactOccurred(); action() } }) {
            HStack(spacing: LinerSpacing.sm) { if isLoading { ProgressView().tint(.linerPrimary) } else if let icon = icon { Image(systemName: icon) }; Text(title).font(.linerSubheadline.weight(.medium)) }
            .foregroundColor(.linerPrimary).frame(maxWidth: fullWidth ? .infinity : nil).padding(.vertical, LinerSpacing.md)
            .background(Color.linerSurface).overlay(RoundedRectangle(cornerRadius: LinerRadius.full).stroke(Color.linerPrimary, lineWidth: 1.5)).clipShape(RoundedRectangle(cornerRadius: LinerRadius.full))
            .opacity(isDisabled ? 0.5 : 1.0).animation(.linerSpringFast, value: isLoading)
        }.disabled(isLoading || isDisabled).buttonStyle(PlainButtonStyle())
    }
}

struct IconButton: View {
    let systemName: String; let size: CGFloat; let variant: Variant; let isActive: Bool; let action: () -> Void
    enum Variant { case primary, secondary, glass, plain }
    init(_ systemName: String, size: CGFloat = 24, variant: Variant = .primary, isActive: Bool = false, action: @escaping () -> Void) { self.systemName = systemName; self.size = size; self.variant = variant; self.isActive = isActive; self.action = action }
    var body: some View {
        Button(action: { UIImpactFeedbackGenerator(style: .light).impactOccurred(); action() }) {
            Image(systemName: systemName).font(.system(size: size, weight: .medium)).foregroundColor(iconColor)
                .frame(width: 44, height: 44).background(background).clipShape(Circle())
        }.buttonStyle(PlainButtonStyle())
    }
    private var iconColor: Color {
        switch variant {
        case .primary: return isActive ? .linerTextInverse : .linerPrimary
        case .secondary: return isActive ? .linerPrimary : .linerTextSecondary
        case .glass: return isActive ? .linerPrimary : .linerTextPrimary
        case .plain: return .linerTextSecondary
        }
    }
    private var background: some View {
        switch variant {
        case .primary: return Circle().fill(isActive ? Color.linerPrimary : Color.linerSurface)
        case .secondary: return Circle().fill(Color.linerSurface).overlay(Circle().stroke(Color.linerBorder, lineWidth: 1))
        case .glass: return Circle().fill(Color.linerGlassMedium)
        case .plain: return Circle().fill(Color.clear)
        }
    }
}

struct PlaybackButton: View {
    let systemName: String; let size: CGFloat; let variant: IconButton.Variant; let isLoading: Bool; let isDisabled: Bool; let action: () -> Void
    init(_ systemName: String, size: CGFloat = 44, variant: IconButton.Variant = .primary, isLoading: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) { self.systemName = systemName; self.size = size; self.variant = variant; self.isLoading = isLoading; self.isDisabled = isDisabled; self.action = action }
    var body: some View {
        Button(action: { if !isLoading && !isDisabled { UIImpactFeedbackGenerator(style: .medium).impactOccurred(); action() } }) {
            if isLoading { ProgressView().tint(.linerTextInverse).frame(width: size, height: size) } else { Image(systemName: systemName).font(.system(size: size * 0.5, weight: .medium)).foregroundColor(.linerTextInverse) }
        }.frame(width: size, height: size).background(Color.linerPrimary).clipShape(Circle()).opacity(isDisabled ? 0.5 : 1.0).scaleEffect(isLoading ? 0.9 : 1.0).animation(.linerSpringFast, value: isLoading).disabled(isLoading || isDisabled).buttonStyle(PlainButtonStyle())
    }
}

struct ToggleButton: View {
    @Binding var isOn: Bool; let systemName: String; let activeName: String?; let action: () -> Void
    init(isOn: Binding<Bool>, systemName: String, activeName: String? = nil, action: @escaping () -> Void = {}) { self._isOn = isOn; self.systemName = systemName; self.activeName = activeName; self.action = action }
    var body: some View {
        Button(action: { UIImpactFeedbackGenerator(style: .selection).selectionChanged(); action(); isOn.toggle() }) {
            Image(systemName: isOn ? (activeName ?? systemName) : systemName).font(.linerSubheadline).foregroundColor(isOn ? .linerPrimary : .linerTextTertiary)
                .frame(width: 40, height: 40).background(Circle().fill(isOn ? Color.linerPrimary.opacity(0.15) : Color.linerSurface)).overlay(Circle().stroke(isOn ? Color.linerPrimary : Color.linerBorder, lineWidth: isOn ? 0 : 1)).scaleEffect(isOn ? 1.1 : 1.0).animation(.linerSpringFast, value: isOn)
        }.buttonStyle(PlainButtonStyle())
    }
}
