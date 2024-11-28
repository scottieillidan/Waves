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
                    .fill(.blue)
                    .frame(height: 120)
                
                Circle()
                    .fill(.black.opacity(0.4))
                    .frame(height: 35)
                
                Circle()
                    .fill(.red)
                    .frame(height: 15)
            }
        }
        .padding(.horizontal, 30)
    }
}

#Preview {
    MiniPlayerView()
}
