//
//  ViewModel.swift
//  Waves
//
//  Created by Adam Miziev on 17/11/24.
//

import Foundation
import AVFAudio

class ViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    
    // MARK: - Properties
    @Published var songs: [SongModel] = []
    @Published var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var currentIndex: Int?
    @Published var currentTime: TimeInterval = 0.0
    @Published var totalTime: TimeInterval = 0.0
    
    var currentSong: SongModel? {
        guard let songIndex = currentIndex, songs.indices.contains(songIndex) else {
            return nil
        }
        return songs[songIndex]
    }
    
    // MARK: - Methods
    
    func playAudio(song: SongModel) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
            self.audioPlayer = try AVAudioPlayer(data: song.data)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.play()
            self.isPlaying = true
            self.totalTime = self.audioPlayer?.duration ?? 0.0
            self.currentTime = 0.0
            if let index = songs.firstIndex(where: { $0.id == song.id }) {
                currentIndex = index
            }
        } catch {
            print("Error in playAudio(): \(error.localizedDescription)")
        }
    }
    
    func playPause() {
        if self.isPlaying {
            self.audioPlayer?.pause()
        } else {
            self.audioPlayer?.play()
        }
        
        self.isPlaying.toggle()
    }
    
    func forward() {
        guard let songIndex = currentIndex else { return }
        let nextIndex = songIndex + 1 < songs.count ? songIndex + 1 : 0
        playAudio(song: songs[nextIndex])
    }
    
    func backward() {
        guard let songIndex = currentIndex else { return }
        let previousIndex = songIndex > 0 ? songIndex - 1 : songs.count - 1
        playAudio(song: songs[previousIndex])
    }
    
    func stopAudio() {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        self.currentIndex = nil
        self.isPlaying = false
    }
    
    func seekAudio(time: TimeInterval) {
        self.audioPlayer?.currentTime = time
    }
    
    func updateProgress() {
        guard let player = self.audioPlayer else { return }
        self.currentTime = player.currentTime
    }
    
    func durationFormatted(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? ""
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            forward()
        }
    }
    
    func deleteSong(offsets: IndexSet) {
        if let first = offsets.first {
            stopAudio()
            songs.remove(at: first)
        }
    }
}
