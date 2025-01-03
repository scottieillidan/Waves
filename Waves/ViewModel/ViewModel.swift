//
//  ViewModel.swift
//  Waves
//
//  Created by Adam Miziev on 17/11/24.
//

import AVFAudio
import RealmSwift
import ID3TagEditor
import MediaPlayer

final class ViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {

    // MARK: - Properties
    @ObservedResults(SongModel.self) private var songs
    @Published var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var currentIndex: Int?
    @Published var currentTime: TimeInterval = 0.0
    @Published var totalTime: TimeInterval = 0.0

    @Published var songRepeat = false
    @Published var songsShuffle = false

    private let fileManager = FileManager.default
    private let audioSession = AVAudioSession.sharedInstance()
    private let remoteControlCenter = MPRemoteCommandCenter.shared()

    var currentSong: SongModel? {
        guard let songIndex = currentIndex, songs.indices.contains(songIndex) else {
            return nil
        }
        return songs[songIndex]
    }

    // MARK: - Methods
    override init() {
        super.init()
        activateAudioSession()
        setupNotifications()
        setupRemoteControlCenter()
    }

    deinit {
        removeObservers()
        deactivateAudioSession()
    }

    // MARK: - Audio Interruption
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

    // MARK: - Audio Session
    func activateAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error in activateAudioSession(): \(error.localizedDescription)")
        }
    }

    func deactivateAudioSession() {
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error in deactivateAudioSession(): \(error.localizedDescription)")
        }
    }

    // MARK: - Audio Player
    func playAudio(song: SongModel) {
        do {
            let fileURL = getSongFileURL(song)!
            self.audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.play()
            self.isPlaying = true
            self.totalTime = song.duration ?? 0.0
            self.currentTime = 0.0
            if let index = songs.firstIndex(where: { $0.id == song.id }) {
                currentIndex = index
            }
            setupNowPlayingInfo()
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
        guard let songIndex = self.currentIndex else { return }
        if self.currentTime <= 5 {
            let previousIndex = songIndex > 0 ? songIndex - 1 : songs.count - 1
            playAudio(song: songs[previousIndex])
        } else {
            seekAudio(time: 0.0)
        }

    }

    func stopAudio() {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        self.currentIndex = nil
        self.isPlaying = false
        disableRemoteControlCenter()
    }

    func seekAudio(time: TimeInterval) {
        self.audioPlayer?.currentTime = time
        self.currentTime = time
        updateNowPlayingInfo()
    }

    func updateProgress() {
        guard let player = self.audioPlayer else { return }
        self.currentTime = player.currentTime
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            if let songIndex = self.currentIndex, self.songRepeat {
                playAudio(song: songs[songIndex])
            } else {
                forward()
            }
        }
    }

    func deleteSongFile(atOffsets offsets: IndexSet) {
        if let index = offsets.first {
            guard let documentDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let fileURL = documentDirectoryURL.appendingPathComponent(songs[index].fileName)
            do {
                try fileManager.removeItem(atPath: fileURL.path)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func getSongFileURL(_ song: SongModel) -> URL? {
        guard let documentDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentDirectoryURL.appendingPathComponent(song.fileName)
        return fileURL
    }

    // MARK: - MPRemoteCommand
    private func setupRemoteControlCenter() {

        remoteControlCenter.playCommand.addTarget { [weak self] _ in
            self?.updateProgress()
            self?.updateNowPlayingInfo()
            self?.playPause()
            return .success
        }

        remoteControlCenter.pauseCommand.addTarget { [weak self] _ in
            self?.updateProgress()
            self?.updateNowPlayingInfo()
            self?.playPause()
            return .success
        }

        remoteControlCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.forward()
            return .success
        }

        remoteControlCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.backward()
            return .success
        }

        remoteControlCenter.changePlaybackPositionCommand.addTarget(handler: {(event) in

            if let changePlaybackPositionCommandEvent = event as? MPChangePlaybackPositionCommandEvent {
                let positionTime = changePlaybackPositionCommandEvent.positionTime
                self.seekAudio(time: positionTime)
                if let song = self.currentSong, Int(song.duration!) == Int(positionTime) {
                    if let songIndex = self.currentIndex, self.songRepeat {
                        self.playAudio(song: self.songs[songIndex])
                    } else {
                        self.forward()
                    }
                }
            }

            return .success
        })
    }

    private func disableRemoteControlCenter() {
//        remoteControlCenter.togglePlayPauseCommand.removeTarget(nil)
//        remoteControlCenter.nextTrackCommand.removeTarget(nil)
//        remoteControlCenter.previousTrackCommand.removeTarget(nil)
//        remoteControlCenter.changePlaybackPositionCommand.removeTarget(nil)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    private func setupNowPlayingInfo() {
        guard let song = self.currentSong else { return }

        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: song.title,
            MPMediaItemPropertyArtist: song.artist ?? "Unknown Artist" as CFString,
            MPMediaItemPropertyAlbumTitle: song.album ?? "Unknown Album" as CFString,
            MPMediaItemPropertyPlaybackDuration: song.duration as Any,

            MPNowPlayingInfoPropertyPlaybackRate: 1.0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: self.currentTime
        ]

        let artwork = (song.coverImage != nil ? UIImage(data: song.coverImage!) : UIImage(named: "Waves"))!

        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 300, height: 300), requestHandler: { (_) -> UIImage in
            return artwork
        })

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

    }

    private func updateNowPlayingInfo() {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime as AnyObject
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    // MARK: - Formatters
    func durationFormatted(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? ""
    }

    func creationDateFormatted(_ creationDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy 'at' HH:mm"
        return formatter.string(from: creationDate)
    }

    // MARK: - Song Metadata
    func editMetaData(from newSong: SongModel, to oldSong: SongModel) {
        Task {
            await updateSongMetadata(from: newSong, to: oldSong)
        }

        let oldFileURL = getSongFileURL(oldSong)!
        let fileURL = getSongFileURL(newSong)!

        do {
            let audioData = try Data(contentsOf: fileURL)
            let id3TagEditor = ID3TagEditor()
            let id3Tag = ID32v2TagBuilder()
                .title(frame: ID3FrameWithStringContent(content: newSong.title))
                .album(frame: ID3FrameWithStringContent(content: newSong.album!))
                .artist(frame: ID3FrameWithStringContent(content: newSong.artist!))
                .attachedPicture(pictureType: .frontCover,
                                 frame: ID3FrameAttachedPicture(picture: newSong.coverImage!,
                                                                type: .frontCover, format: .jpeg))
                .build()

            let newAudioData: Data = try id3TagEditor.write(tag: id3Tag, mp3: audioData)

            if fileManager.fileExists(atPath: oldFileURL.path) {
                try fileManager.removeItem(atPath: oldFileURL.path)
                fileManager.createFile(atPath: fileURL.path, contents: newAudioData)
            }
        } catch {
            print("Error in editMetaData(): \(error.localizedDescription)")
        }
    }

    func updateSongMetadata(from newSong: SongModel, to oldSong: SongModel) async {
        do {
            if let currentSong = try await Realm().object(ofType: SongModel.self, forPrimaryKey: oldSong.id) {
                try await Realm().write {
                    currentSong.title = newSong.title
                    currentSong.album = newSong.album
                    currentSong.artist = newSong.artist
                    currentSong.duration = newSong.duration
                    currentSong.coverImage = newSong.coverImage
                    currentSong.fileName = newSong.fileName
                    currentSong.fileExtension = newSong.fileExtension
                    currentSong.size = newSong.size
                    currentSong.creationDate = newSong.creationDate
                }
            }
        } catch {
            print("Error in updateSongMetadata(): \(error.localizedDescription)")
        }
    }
}
