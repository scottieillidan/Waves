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
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(.rect(cornerRadius: SizeConstant.cornerRadius))
        } else {
            Image("Waves")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(.rect(cornerRadius: SizeConstant.cornerRadius))
        }
    }
}
