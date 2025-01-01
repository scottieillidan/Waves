//
//  MiniWaves.swift
//  Waves
//
//  Created by Adam Miziev on 28/12/2024.
//

import SwiftUI

struct MiniWavesView: View {
    @State private var startAnimation = false
    @Binding var isPlaying: Bool

    var body: some View {
        var animation: Animation {
            isPlaying ? .linear(duration: 0.5).repeatForever() : .default
        }

        HStack(spacing: 3) {
            bar(low: isPlaying ? 0.2 : 0.25)
                .animation(animation.speed(1.7), value: startAnimation)
            bar(low: isPlaying ? 0.4 : 0.25)
                .animation(animation.speed(1.5), value: startAnimation)
            bar(low: isPlaying ? 0.3 : 0.25)
                .animation(animation.speed(1.2), value: startAnimation)
            bar(low: isPlaying ? 0.5 : 0.25)
                .animation(animation.speed(1.0), value: startAnimation)
            bar(low: isPlaying ? 0.3 : 0.25)
                .animation(animation.speed(1.7), value: startAnimation)
            bar(low: isPlaying ? 0.5 : 0.25)
                .animation(animation.speed(1.0), value: startAnimation)
        }
        .frame(width: 20)
        .padding(.horizontal, 8.5)
        .onAppear {
            startAnimation = true
        }
        .onChange(of: isPlaying) { newValue in
            startAnimation = newValue
        }
    }

    func bar(low: CGFloat = 0.0, high: CGFloat = 1.0) -> some View {
        VStack(spacing: 0) {
            barLine(low: low, high: high)
            barLine(low: low, high: high)
                .offset(y: 1.5)
                .rotationEffect(.degrees(180))
        }
    }

    func barLine(height: CGFloat = 10, low: CGFloat, high: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.accent.gradient)
            .frame(height: (startAnimation ? high : low) * height)
            .frame(height: height, alignment: .bottom)
    }
}
