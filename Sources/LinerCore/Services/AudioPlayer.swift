import Foundation
import AVFoundation
import MediaPlayer
import Combine
import UIKit

@MainActor
public public final class AudioPlayer: ObservableObject {
    public static let shared = AudioPlayer()
    
    @Published public private(set) var currentTrack: Track?
    @Published public private(set) var isPlaying = false
    @Published public private(set) var currentTime: TimeInterval = 0
    @Published public private(set) var duration: TimeInterval = 0
    @Published public private(set) var playbackState: PlaybackState = .stopped
    @Published public private(set) var shuffleEnabled = false
    @Published public private(set) var repeatMode: RepeatMode = .off
    
    private var player: AVPlayer?
    private nonisolated(unsafe) var timeObserver: Any?
    private var currentQueue: [Track] = []
    private var currentIndex: Int = 0
    
    private init() {
        setupAudioSession()
        setupRemoteCommands()
        setupNowPlayingInfo()
    }
    
    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
    }
    
    // MARK: - Audio Session
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetoothA2DP, .allowAirPlay])
            try audioSession.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    // MARK: - Remote Commands
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.play() }
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.pause() }
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.nextTrack() }
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.previousTrack() }
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self, let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            Task { @MainActor in self.seek(to: event.positionTime) }
            return .success
        }
    }
    
    // MARK: - Now Playing Info
    private func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateNowPlayingInfo() {
        guard let track = currentTrack else { return }
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist.name
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        if let artworkURL = track.artworkURL, let data = try? Data(contentsOf: artworkURL), let image = UIImage(data: data) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - Playback Control
    func load(track: Track, queue: [Track], startIndex: Int = 0) {
        currentQueue = queue
        currentIndex = startIndex
        currentTrack = track
        
        guard let audioURL = track.audioURL else {
            print("Audio URL is nil for track: \(track.title)")
            return
        }
        
        let playerItem = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: playerItem)
        
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                guard let self = self else { return }
                self.currentTime = time.seconds
                self.updateNowPlayingInfo()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.nextTrack() }
        }
        
        play()
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
        isPlaying ? pause() : play()
    }
    
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.currentTime = time
            }
        }
    }
    
    func nextTrack() {
        guard currentIndex + 1 < currentQueue.count else { return }
        currentIndex += 1
        load(track: currentQueue[currentIndex], queue: currentQueue, startIndex: currentIndex)
    }
    
    func previousTrack() {
        guard currentIndex - 1 >= 0 else { return }
        currentIndex -= 1
        load(track: currentQueue[currentIndex], queue: currentQueue, startIndex: currentIndex)
    }
    
    func toggleShuffle() {
        shuffleEnabled.toggle()
    }
    
    func toggleRepeatMode() {
        switch repeatMode {
        case .off: repeatMode = .queue
        case .queue: repeatMode = .track
        case .track: repeatMode = .off
        }
    }
}

public enum PlaybackState {
    case playing, paused, stopped
}

public enum RepeatMode {
    case off, queue, track
}