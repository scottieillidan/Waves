//
//  FullPlayerView.swift
//  Waves
//
//  Created by Adam Miziev on 26/12/2024.
//

import SwiftUI

struct FullPlayerView: View {
    // MARK: - Properties
    @EnvironmentObject private var vm: ViewModel

    @Binding var isDragging: Bool

    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            /// Cover
            SongCoverView(coverData: vm.currentSong?.coverImage, size: SizeConstant.fullPlayer)

            /// Description
            HStack {
                SongDescription(vm.currentSong)
                Spacer()
            }

            VStack {
                /// Slider
                Slider(value: $vm.currentTime, in: 0...vm.totalTime) { editing in
                    isDragging = editing
                    if !isDragging {
                        vm.seekAudio(time: vm.currentTime)
                    }
                }
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        if !isDragging {
                            vm.updateProgress()
                        }
                    }
                    UISlider.appearance().minimumTrackTintColor = .accent
                    UISlider.appearance().tintColor = .white
                    UISlider.appearance().setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
                }

                /// Duration
                HStack {
                    Text("\(vm.durationFormatted(vm.currentTime))")
                    Spacer()
                    Text("\(vm.durationFormatted(vm.totalTime))")
                }
                .durationFont()

                PlaybackControls()
            }

            Spacer()
        }
        .padding(.horizontal, 40)
        // MARK: - Background
        .background(.darkBG)
    }

    // MARK: - Methods
    func PlaybackControls() -> some View {
        HStack(spacing: 25) {
            CustomButtom(image: "repeat", size: .title3, color: vm.songRepeat ? .accent : .white) {
                vm.songRepeat.toggle()
            }
            HStack(spacing: 40) {
                CustomButtom(image: "backward.fill", size: .title2) {
                    vm.backward()
                }
                CustomButtom(image: vm.isPlaying ? "pause.fill" : "play.fill", size: .title) {
                    vm.playPause()
                }
                CustomButtom(image: "forward.fill", size: .title2) {
                    vm.forward()
                }
            }
            CustomButtom(image: "shuffle", size: .title3, color: vm.songsShuffle ? .accent : .white) {
                vm.songsShuffle.toggle()
            }
        }
    }
}
