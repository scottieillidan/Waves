//
//  ViewModel.swift
//  Waves
//
//  Created by Adam Miziev on 17/11/24.
//

import Foundation
import AVFAudio
import RealmSwift
import ID3TagEditor

final class ViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {

    // MARK: - Properties
    @ObservedResults(SongModel.self) private var songs
    @Published var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var currentIndex: Int?
    @Published var currentTime: TimeInterval = 0.0
    @Published var totalTime: TimeInterval = 0.0

    private let fileManager = FileManager.default
    private let audioSession = AVAudioSession.sharedInstance()

    var currentSong: SongModel? {
        guard let songIndex = currentIndex, songs.indices.contains(songIndex) else {
            return nil
        }
        return songs[songIndex]
    }

    override init() {
        super.init()
        activateAudioSession()
        setupNotifications()
    }

    deinit {
        removeObservers()
        deactivateAudioSession()
    }

    func setupNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(handleInterruption),
                       name: AVAudioSession.interruptionNotification,
                       object: audioSession)
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            self.isPlaying = false
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                self.playPause()
            }
        default: ()
        }
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Methods
    func activateAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error in startAudioSession: \(error.localizedDescription)")
        }
    }

    func deactivateAudioSession() {
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error in endAudioSession: \(error.localizedDescription)")
        }
    }

    func playAudio(song: SongModel) {
        do {
            if let url = URL(string: song.url) {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                self.audioPlayer?.delegate = self
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.play()
                self.isPlaying = true
                self.totalTime = song.duration ?? 0.0
                self.currentTime = 0.0
                if let index = songs.firstIndex(where: { $0.id == song.id }) {
                    currentIndex = index
                }
            }
        } catch {
            print("Error in playAudio(): \(error)")
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

    func deleteSongFile(atOffsets offsets: IndexSet) {
        if let index = offsets.first {
            do {
                try fileManager.removeItem(atPath: songs[index].path)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    // MetaData
    func editMetaData(oldSong: SongModel, newSong: SongModel) {
        Task {
            let currentSong = try await Realm().object(ofType: SongModel.self, forPrimaryKey: oldSong.id) ?? oldSong
            try await Realm().write {
                currentSong.name = newSong.name
                currentSong.album = newSong.album
                currentSong.artist = newSong.artist
                currentSong.url = newSong.url
                currentSong.path = newSong.path
                currentSong.coverImage = newSong.coverImage
                currentSong.duration = newSong.duration
            }
        }
        do {
            let mp3 = try Data(contentsOf: URL(string: newSong.url)!)
            let id3TagEditor = ID3TagEditor()
            let id3Tag = ID32v2TagBuilder()
                .title(frame: ID3FrameWithStringContent(content: newSong.name))
                .album(frame: ID3FrameWithStringContent(content: newSong.album ?? "Uknown Album"))
                .artist(frame: ID3FrameWithStringContent(content: newSong.artist ?? "Uknown Artist"))
                .attachedPicture(pictureType: .frontCover,
                                 frame: ID3FrameAttachedPicture(picture: newSong.coverImage!,
                                                                type: .frontCover, format: .jpeg))
                .build()

             let newMp3: Data = try id3TagEditor.write(tag: id3Tag, mp3: mp3)

            if fileManager.fileExists(atPath: oldSong.path) {
                try fileManager.removeItem(atPath: oldSong.path)
                fileManager.createFile(atPath: newSong.path, contents: newMp3)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
