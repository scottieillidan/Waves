//
//  SongDescription.swift
//  Waves
//
//  Created by Adam Miziev on 26/12/2024.
//

import SwiftUI

@ViewBuilder
func SongDescription(_ song: SongModel?, alignment: HorizontalAlignment = .leading, spacing: CGFloat = 5) -> some View {
    if let currentSong = song {
        VStack(alignment: alignment, spacing: spacing) {
            Text(currentSong.title)
                .titleFont()
            if let artist = currentSong.artist {
                HStack(spacing: 0) {
                    Text(artist)
                        .bodyFont()
                    if let album = currentSong.album {
                        Text("\(" - " + album)")
                            .bodyFont()
                    }
                }
            }

        }
    }
}
