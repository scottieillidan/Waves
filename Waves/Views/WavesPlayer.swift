//
//  ContentView.swift
//  Waves
//
//  Created by Adam Miziev on 17/11/24.
//

import SwiftUI
import RealmSwift

struct WavesPlayer: View {
    // MARK: - Properties
    @StateObject private var vm = ViewModel()

    @ObservedResults(SongModel.self) private var songs

    @State private var showFiles = false
    @State private var showFullPlayer = false
    @State private var isDragging = false

    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // MARK: - List of Songs
                List {
                    ForEach(songs) {song in
                        let url = vm.getSongFileURL(song)!
                        Button {
                            vm.playAudio(song: song)
                        } label: {
                            SongCellView(song: song, durationFormatted: vm.durationFormatted)
                                .environmentObject(vm)
                        }
                        .contextMenu {
                            /// Edit Metadata.
                            NavigationLink {
                                EditSongMetadata(song: song)
                                    .environmentObject(vm)
                            } label: {
                                Label("Edit Metadata", systemImage: "square.and.pencil")
                            }

                            /// Share.
                            ShareLink(
                                "Share",
                                item: url
                            )
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .onDelete { offsets in
                        if vm.isPlaying {
                            if vm.currentIndex == offsets.first! {
                                vm.stopAudio()
                            } else if offsets.first! < vm.currentIndex! {
                                vm.currentIndex! -= 1
                            }
                        }
                        vm.deleteSongFile(atOffsets: offsets)
                        $songs.remove(atOffsets: offsets)
                    }
                }
                .listStyle(.plain)
                .padding(.bottom, 30)
                .padding(.bottom, vm.currentSong != nil ? SizeConstant.miniPlayer + 10 : 0)
                .scrollIndicators(.hidden)

                Spacer()

                // MARK: - Player
                if vm.currentSong != nil && !showFullPlayer {
                    Button {
                        withAnimation {
                            showFullPlayer.toggle()
                        }
                    } label: {
                        MiniPlayer()
                    }
                }
            }
            .ignoresSafeArea(edges: Edge.Set(.bottom))
            // MARK: - Background
            .background(.darkBG)
            // MARK: - Navigation Bar
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFiles.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                         Menu {
                             Text("Waves: \(appVersion)")
                             Text("MZA (2025)")
                         } label: {
                             Image(systemName: "info.circle.fill")
                                 .font(.title2)
                         }
                      }
            }
            // MARK: - File's Sheet
            .sheet(isPresented: $showFiles) {
                ImportFileManager()
            }
            // MARK: - Full Player
            .sheet(isPresented: $showFullPlayer) {
                FullPlayerView(isDragging: $isDragging)
                    .environmentObject(vm)
            }
        }
    }

    // MARK: - Methods
    private func MiniPlayer() -> some View {
        /// Mini Player
        HStack {
            /// Cover
            SongCoverView(coverData: vm.currentSong?.coverImage, size: SizeConstant.miniPlayer)

            /// Description
            SongDescription(vm.currentSong)

            Spacer()

            CustomButtom(image: vm.isPlaying ? "pause.fill" : "play.fill", size: .title) {
                vm.playPause()
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(.ultraThinMaterial)
        .frame(height: SizeConstant.miniPlayer)
        .padding(.vertical, 30)
    }
}
