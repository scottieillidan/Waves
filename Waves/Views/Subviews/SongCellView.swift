//
//  SongCellView.swift
//  Waves
//
//  Created by Adam Miziev on 17/11/24.
//

import SwiftUI

struct SongCellView: View {
    // MARK: - Properties
    @EnvironmentObject var vm: ViewModel
    let song: SongModel
    let durationFormatted: (TimeInterval) -> String

    // MARK: - Body
    var body: some View {
        HStack {
            /// Cover
            SongCoverView(coverData: song.coverImage, size: 60)

            /// Description
            VStack(alignment: .leading) {
                Text(song.title)
                    .titleFont(isSelected: vm.currentSong?.id == song.id)
                Text(song.artist ?? "Unknown artist")
                    .bodyFont(isSelected: vm.currentSong?.id == song.id)
            }

            Spacer()

            if let currentSong = vm.currentSong, currentSong.id == song.id {
                MiniWavesView(isPlaying: $vm.isPlaying)
            } else {
                /// Duration
                if let duration = song.duration {
                    Text(durationFormatted(duration))
                        .bodyFont()
                }
            }
        }
    }
}
