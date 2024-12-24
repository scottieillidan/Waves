//
//  SongCoverView.swift
//  Waves
//
//  Created by Adam Miziev on 24/11/24.
//

import SwiftUI

struct SongCoverView: View {

    // MARK: - Properties
    let coverData: Data?
    let size: CGFloat

    // MARK: - Body
    var body: some View {
        if let cover = coverData, let uiImage = UIImage(data: cover) {
            Image(uiImage: uiImage)
                .resizable()
                .frame(width: size, height: size)
                .aspectRatio(contentMode: .fill)
                .clipShape(.rect(cornerRadius: 5))
        } else {
            ZStack {
                Rectangle()
                    .fill(.gray)
                    .frame(width: size, height: size)
                Image(systemName: "music.note")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size / 2)
                    .foregroundStyle(.white)
            }
            .clipShape(.rect(cornerRadius: 5))
        }
    }
}
