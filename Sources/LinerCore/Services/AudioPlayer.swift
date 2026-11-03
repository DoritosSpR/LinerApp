import Foundation
import AVFoundation
import MediaPlayer
import Combine

@MainActor final class AudioPlayer: ObservableObject {
    static let shared = AudioPlayer()

    @Published private(set) var currentTrack: Track?
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var playbackState: PlaybackState = .stopped
    @Published private(set) var queue: [Track] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var repeatMode: RepeatMode = .off
    @Published private(set) var shuffleEnabled = false

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    private let audioSession = AVAudioSession.sharedInstance()

    enum PlaybackState {
        case stopped
        case playing
        case paused
        case buffering
        case failed(Error)
    }

    enum RepeatMode: Int, CaseIterable {
        case off = 0
        case queue = 1
        case track = 2
    }

    private init() {
        setupAudioSession()
        setupRemoteCommandCenter()
        setupNotifications()
    }

    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNext()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPrevious()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self, let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self.seek(to: event.positionTime)
            return .success
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: audioSession
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: audioSession
        )
    }

    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            pause()
        case .ended:
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    play()
                }
            }
        @unknown default:
            break
        }
    }

    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

        if reason == .oldDeviceUnavailable {
            pause()
        }
    }

    func load(track: Track, queue: [Track] = [], startIndex: Int = 0) {
        self.currentTrack = track
        self.queue = queue.isEmpty ? [track] : queue
        self.currentIndex = startIndex

        guard let audioURL = track.audioURL else {
            playbackState = .failed(NSError(domain: "AudioPlayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "No audio URL"]))
            return
        }

        let playerItem = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: playerItem)

        setupTimeObserver()
        observePlayerItem(playerItem)

        playbackState = .buffering
        updateNowPlayingInfo()
    }

    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
            self?.updateNowPlayingInfo()
        }
    }

    private func observePlayerItem(_ item: AVPlayerItem) {
        item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    self?.duration = item.duration.seconds
                    self?.playbackState = .playing
                    self?.isPlaying = true
                case .failed:
                    self?.playbackState = .failed(item.error ?? NSError(domain: "AudioPlayer", code: -1))
                default:
                    break
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleTrackEnded()
            }
            .store(in: &cancellables)
    }

    private func handleTrackEnded() {
        switch repeatMode {
        case .track:
            seek(to: 0)
            play()
        case .queue, .off:
            playNext()
        }
    }

    func play() {
        player?.play()
        isPlaying = true
        playbackState = .playing
        updateNowPlayingInfo()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        playbackState = .paused
        updateNowPlayingInfo()
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime) { [weak self] _ in
            self?.currentTime = time
            self?.updateNowPlayingInfo()
        }
    }

    func playNext() {
        guard !queue.isEmpty else { return }

        let nextIndex: Int
        if shuffleEnabled {
            nextIndex = Int.random(in: 0..<queue.count)
        } else {
            nextIndex = (currentIndex + 1) % queue.count
        }

        if nextIndex < queue.count {
            currentIndex = nextIndex
            load(track: queue[nextIndex], queue: queue, startIndex: nextIndex)
        }
    }

    func playPrevious() {
        guard !queue.isEmpty else { return }

        let previousIndex: Int
        if shuffleEnabled {
            previousIndex = Int.random(in: 0..<queue.count)
        } else {
            previousIndex = (currentIndex - 1 + queue.count) % queue.count
        }

        if previousIndex < queue.count {
            currentIndex = previousIndex
            load(track: queue[previousIndex], queue: queue, startIndex: previousIndex)
        }
    }

    func setQueue(_ tracks: [Track], startIndex: Int = 0) {
        queue = tracks
        currentIndex = startIndex
        if startIndex < tracks.count {
            load(track: tracks[startIndex], queue: tracks, startIndex: startIndex)
        }
    }

    func toggleRepeatMode() {
        let allCases = RepeatMode.allCases
        let currentIndex = allCases.firstIndex(of: repeatMode) ?? 0
        let nextIndex = (currentIndex + 1) % allCases.count
        repeatMode = allCases[nextIndex]
    }

    func toggleShuffle() {
        shuffleEnabled.toggle()
    }

    private func updateNowPlayingInfo() {
        guard let track = currentTrack else { return }

        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist.name
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        if let album = track.album {
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album.title
        }

        if let artworkURL = track.artworkURL {
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: artworkURL),
                   let image = UIImage(data: data) {
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
    }
}

import UIKit