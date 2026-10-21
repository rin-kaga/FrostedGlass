//
//  FrostedGlass.swift
//  FrostedGlass
//
//  Created by Rin on 21.10.2026.
//

import SwiftUI
import AppKit

// MARK: - Passthrough Native Visual Effect View
public final class PassthroughVisualEffectView: NSVisualEffectView {
    public override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
}

// MARK: - Native Frosted Glass (NSVisualEffectView Bridge)
public struct FrostedGlassBackground: NSViewRepresentable {
    public var material: NSVisualEffectView.Material
    public var blendingMode: NSVisualEffectView.BlendingMode
    public var state: NSVisualEffectView.State
    public var appearance: NSAppearance?

    public init(
        material: NSVisualEffectView.Material = .hudWindow,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        state: NSVisualEffectView.State = .active,
        appearance: NSAppearance? = NSAppearance(named: .darkAqua)
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.state = state
        self.appearance = appearance
    }

    public func makeNSView(context: Context) -> PassthroughVisualEffectView {
        let view = PassthroughVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        view.appearance = appearance
        return view
    }

    public func updateNSView(_ nsView: PassthroughVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
        nsView.appearance = appearance
    }
}

// MARK: - Window Configurator
public final class PassthroughWindowView: NSView {
    public override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
}

public struct WindowConfigurator: NSViewRepresentable {
    public var isMovableByWindowBackground: Bool

    public init(isMovableByWindowBackground: Bool = true) {
        self.isMovableByWindowBackground = isMovableByWindowBackground
    }

    public func makeNSView(context: Context) -> PassthroughWindowView {
        let view = PassthroughWindowView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.isOpaque = false
            window.backgroundColor = .clear
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.styleMask.insert(.fullSizeContentView)
            window.isMovableByWindowBackground = isMovableByWindowBackground
            window.hasShadow = true

            window.contentView?.wantsLayer = true
            window.contentView?.layer?.backgroundColor = .clear
        }
        return view
    }

    public func updateNSView(_ nsView: PassthroughWindowView, context: Context) {}
}

// MARK: - Container View: FrostedGlassWindow
public struct FrostedGlassWindow<Content: View>: View {
    private let material: NSVisualEffectView.Material
    private let tintColor: Color
    private let tintOpacity: Double
    private let cornerRadius: CGFloat
    private let showBorder: Bool
    private let isMovableByBackground: Bool
    private let content: Content

    public init(
        material: NSVisualEffectView.Material = .hudWindow,
        tintColor: Color = .black,
        tintOpacity: Double = 0.15,
        cornerRadius: CGFloat = 18,
        showBorder: Bool = true,
        isMovableByBackground: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.material = material
        self.tintColor = tintColor
        self.tintOpacity = tintOpacity
        self.cornerRadius = cornerRadius
        self.showBorder = showBorder
        self.isMovableByBackground = isMovableByBackground
        self.content = content()
    }

    public var body: some View {
        ZStack {
            // 1. Native Desktop Vibrancy / Frosted Glass
            FrostedGlassBackground(material: material)
                .allowsHitTesting(false)

            // 2. Acrylic Tint Overlay
            tintColor
                .opacity(tintOpacity)
                .allowsHitTesting(false)

            // 3. Highlight Border
            if showBorder {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.18),
                                Color.white.opacity(0.06),
                                Color.white.opacity(0.03),
                                Color.white.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)
            }

            // 4. User Content
            content
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .ignoresSafeArea()
        .background(
            WindowConfigurator(isMovableByWindowBackground: isMovableByBackground)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
        )
    }
}

// MARK: - ViewModifier Extension
public struct FrostedGlassWindowModifier: ViewModifier {
    public var material: NSVisualEffectView.Material
    public var tintColor: Color
    public var tintOpacity: Double
    public var cornerRadius: CGFloat
    public var showBorder: Bool
    public var isMovableByBackground: Bool

    public func body(content: Content) -> some View {
        FrostedGlassWindow(
            material: material,
            tintColor: tintColor,
            tintOpacity: tintOpacity,
            cornerRadius: cornerRadius,
            showBorder: showBorder,
            isMovableByBackground: isMovableByBackground
        ) {
            content
        }
    }
}

extension View {
    /// Applies a modern macOS frosted glass acrylic background and configures the host NSWindow.
    public func frostedGlassWindow(
        material: NSVisualEffectView.Material = .hudWindow,
        tintColor: Color = .black,
        tintOpacity: Double = 0.15,
        cornerRadius: CGFloat = 18,
        showBorder: Bool = true,
        isMovableByBackground: Bool = true
    ) -> some View {
        modifier(
            FrostedGlassWindowModifier(
                material: material,
                tintColor: tintColor,
                tintOpacity: tintOpacity,
                cornerRadius: cornerRadius,
                showBorder: showBorder,
                isMovableByBackground: isMovableByBackground
            )
        )
    }
}
