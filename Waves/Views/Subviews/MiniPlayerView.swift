//
//  MiniPlayerView.swift
//  Waves
//
//  Created by Adam Miziev on 25/11/24.
//

import SwiftUI

struct MiniPlayerView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.red)
                .frame(height: 80)
                .overlay(alignment: .leading, content: {
                    VStack(alignment: .leading) {
                        Text("Lana Del Rey")
                        Text("A&W")
                    }
                    .offset(x: 40)
                })
                .padding(.leading, 90)
                
            ZStack {
                Circle()
                    .stroke(lineWidth: 80)
                    .fill(.linearGradient(colors: [.topBackground, .bottomBackground], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 40)
                
                Circle()
                    .stroke(lineWidth: 10)
                    .fill(.black.opacity(0.4))
                    .frame(height: 30)
            }
            .padding(.leading, 40)
        }
        .padding(.horizontal, 30)
    }
}

#Preview {
    MiniPlayerView()
}
