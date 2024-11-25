//
//  SongCellView.swift
//  Waves
//
//  Created by Adam Miziev on 17/11/24.
//

import SwiftUI

struct SongCellView: View {
    // MARK: - Properties
    let song: SongModel
    let durationFormatted: (TimeInterval) -> String
    
    // MARK: - Body
    var body: some View {
        HStack {
            /// Cover
            SongCoverView(coverData: song.coverImage, size: 60)
            
            /// Description
            VStack(alignment: .leading) {
                Text(song.name)
                    .nameFont()
                Text(song.artist ?? "Unknown artist")
                    .artistFont()
            }
            
            Spacer()
            
            /// Duration
            if let duration = song.duration {
                Text(durationFormatted(duration))
                    .artistFont()
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    WavesPlayer()
}
