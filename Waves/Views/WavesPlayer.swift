//
//  ContentView.swift
//  Waves
//
//  Created by Adam Miziev on 17/11/24.
//

import SwiftUI

struct WavesPlayer: View {
    // MARK: - Properties
    @StateObject var vm = ViewModel()
    
    @State var showFiles = false
    @State private var showFullPlayer = false
    @State private var isDragging = false
    
    @Namespace private var playerAnimation
    
    private var frameImage: CGFloat {
        showFullPlayer ? 320 : 50
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                BackgroundView()
                
                VStack {
                    // MARK: - List of Songs
                    List {
                        ForEach(vm.songs) {song in
                            SongCellView(song: song, durationFormatted: vm.durationFormatted)
                                .onTapGesture {
                                    vm.playAudio(song: song)
                                }
                        }
                        .onDelete(perform: vm.deleteSong)
                    }
                    .listStyle(.plain)
                    
                    Spacer()
                    
                    // MARK: - Player
                    if vm.currentSong != nil {
                        Player()
                            .frame(height: showFullPlayer ? SizeConstant.fullPlayer : SizeConstant.miniPlayer)
                            .onTapGesture {
                                withAnimation(.spring) {
                                    self.showFullPlayer.toggle()
                                }
                            }
                    }
                }
            }
            // MARK: - Navigation Bar
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFiles.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                }
            }
            
            // MARK: - File's Sheet
            .sheet(isPresented: $showFiles) {
                ImportFileManager(songs: $vm.songs)
            }
        }
        
        
    }
    
    // MARK: - Methods
    private func Player() -> some View {
        VStack {
            /// Mini Player
            HStack {
                /// Cover
                SongCoverView(coverData: vm.currentSong?.coverImage, size: frameImage)
                
                if !showFullPlayer {
                    /// Description
                    VStack(alignment: .leading) {
                        SongDescription()
                    }
                    .matchedGeometryEffect(id: "Description", in: playerAnimation)
                    
                    Spacer()
                    
                    CustomButtom(image: vm.isPlaying ? "pause.fill" : "play.fill", size: .title) {
                        vm.playPause()
                    }
                }
            }
            .padding()
            .background(showFullPlayer ? .clear : .black.opacity(0.3))
            .clipShape(.rect(cornerRadius: 20))
            .padding()
            
            /// Full Player
            if showFullPlayer {
                
                /// Description
                VStack {
                    SongDescription()
                }
                .matchedGeometryEffect(id: "Description", in: playerAnimation)
                .padding(.top)
                
                VStack {
                    /// Duration
                    HStack {
                        Text("\(vm.durationFormatted(vm.currentTime))")
                        Spacer()
                        Text("\(vm.durationFormatted(vm.totalTime))")
                    }
                    .padding()
                    .durationFont()
                    
                    /// Slider
                    Slider(value: $vm.currentTime, in: 0...vm.totalTime) { editing in
                        isDragging = editing
                        if !isDragging {
                            vm.seekAudio(time: vm.currentTime)
                        }
                    }
                    .offset(y: -18)
                    .tint(.white)
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                            if !isDragging {
                                vm.updateProgress()
                            }
                        }
                    }
                    
                    HStack(spacing: 40) {
                        CustomButtom(image: "backward.end.fill", size: .title2) {
                            vm.backward()
                        }
                        CustomButtom(image: vm.isPlaying ? "pause.fill" : "play.fill", size: .title) {
                            vm.playPause()
                        }
                        CustomButtom(image: "forward.end.fill", size: .title2) {
                            vm.forward()
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    @ViewBuilder
    private func SongDescription() -> some View {
        if let currentSong = vm.currentSong {
            Text(currentSong.name)
                .nameFont()
            Text(currentSong.artist ?? "Unknown Artist")
                .artistFont()
        }
    }
    
    private func CustomButtom(image: String, size: Font, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: image)
                .foregroundStyle(.white)
                .font(size)
        }
    }
}


#Preview {
    WavesPlayer()
}
