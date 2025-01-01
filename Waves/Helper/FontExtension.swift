//
//  FontExtension.swift
//  Waves
//
//  Created by Adam Miziev on 17/11/24.
//

import SwiftUI

struct DurationFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .light, design: .rounded))
    }
}

extension View {
    func durationFont() -> some View {
        self
            .modifier(DurationFontModifier())
    }
}

extension Text {
    func titleFont(isSelected: Bool = false) -> some View {
        self
            .foregroundStyle(isSelected ? .accent : .white)
            .font(
                .system(
                    size: 16,
                    weight: .semibold
                )
            )
            .lineLimit(1)
    }

    func bodyFont(isSelected: Bool = false) -> some View {
        self
            .foregroundStyle(isSelected ? .accent : .white)
            .font(
                .system(
                    size: 14,
                    weight: .light
                )
            )
            .lineLimit(1)
    }
}

struct FontExtension: View {
    var body: some View {
        Text("Name Font")
            .titleFont()
        Text("Artist Font")
            .bodyFont()
        HStack {
            Text("00:00")
            Spacer()
            Text("03:27")
        }
        .durationFont()
    }
}

#Preview {
    FontExtension()
}
