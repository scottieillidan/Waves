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
            HStack(spacing: 0) {
                Text(currentSong.artist ?? "Unknown Artist")
                    .bodyFont()
                if let album = currentSong.album, album != "" {
                    Text("\(" - " + album)")
                        .bodyFont()
                }
            }
        }
    }
}
