//
//  DiskVisualStyle.swift
//  112DiskWatch
//

import SwiftUI

enum DiskVisualStyle {
    static let screenTopGlow = Color.diskNormal.opacity(0.14)
    static let screenDeep = Color(red: 0.04, green: 0.04, blue: 0.04)

    static var screenGradient: LinearGradient {
        LinearGradient(
            colors: [
                screenTopGlow,
                Color.diskBackground,
                screenDeep
            ],
            startPoint: .topLeading,
            endPoint: .bottom
        )
    }

    static var ambientRadial: RadialGradient {
        RadialGradient(
            colors: [Color.diskNormal.opacity(0.22), Color.clear],
            center: .topTrailing,
            startRadius: 20,
            endRadius: 380
        )
    }

    static func panelFill(accent: Color = .diskNormal) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.11),
                Color.white.opacity(0.03),
                accent.opacity(0.07)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func panelStroke(accent: Color = .diskNormal) -> LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.16), accent.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func primaryButtonFill() -> LinearGradient {
        LinearGradient(
            colors: [Color.diskNormal, Color.diskNormal.opacity(0.75)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func dangerPanelFill() -> LinearGradient {
        LinearGradient(
            colors: [
                Color.diskDanger.opacity(0.35),
                Color.diskDanger.opacity(0.12),
                Color.diskBackground.opacity(0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct DiskScreenBackdrop: View {
    var body: some View {
        ZStack {
            DiskVisualStyle.screenGradient
            DiskVisualStyle.ambientRadial
                .blendMode(.plusLighter)
                .opacity(0.5)
        }
        .ignoresSafeArea()
    }
}

extension View {
    /// Full-screen depth background (gradient + soft radial glow).
    func diskScreenBackdrop() -> some View {
        background(DiskScreenBackdrop())
    }

    /// Raised glass panel: gradient fill, rim light, dual shadow (depth + accent glow).
    func diskElevatedPanel(cornerRadius: CGFloat = 16, accent: Color = .diskNormal) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DiskVisualStyle.panelFill(accent: accent))
                    .shadow(color: Color.black.opacity(0.5), radius: 14, x: 0, y: 8)
                    .shadow(color: accent.opacity(0.18), radius: 22, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(DiskVisualStyle.panelStroke(accent: accent), lineWidth: 1)
            )
    }

    /// Softer inset surface (lists, secondary blocks).
    func diskInsetPanel(cornerRadius: CGFloat = 14, accent: Color = .diskNormal.opacity(0.5)) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.06),
                                Color.black.opacity(0.25)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), accent.opacity(0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }

    func diskPrimaryButtonShape(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DiskVisualStyle.primaryButtonFill())
                    .shadow(color: Color.diskNormal.opacity(0.45), radius: 12, x: 0, y: 6)
                    .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
    }

    func diskOutlinedButtonShape(cornerRadius: CGFloat = 12, color: Color = .diskDanger) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), Color.black.opacity(0.35)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(0.9), color.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
    }

    /// Secondary CTA (outline / glass).
    func diskGlassButton(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.diskNormal.opacity(0.22), Color.diskNormal.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(DiskVisualStyle.panelStroke(accent: .diskNormal), lineWidth: 1)
            )
    }

    func diskDangerBanner(cornerRadius: CGFloat = 14) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DiskVisualStyle.dangerPanelFill())
                    .shadow(color: Color.diskDanger.opacity(0.4), radius: 16, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.diskDanger.opacity(0.85), Color.diskDanger.opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}
