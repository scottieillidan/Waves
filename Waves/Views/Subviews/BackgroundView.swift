//
//  BackgroundView.swift
//  Waves
//
//  Created by Adam Miziev on 17/11/24.
//

import SwiftUI

struct BackgroundView: View {
    // MARK: - Body
    var body: some View {
        LinearGradient(
            colors: [.topBackground, .bottomBackground],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}
