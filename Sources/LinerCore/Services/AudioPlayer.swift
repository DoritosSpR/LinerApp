import Foundation
import AVFoundation
import MediaPlayer
import Combine

@MainActor
final class AudioPlayer: ObservableObject {
    static let shared = AudioPlayer()
    
    @Published private(set) var currentTrack: Track?
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var playbackState: PlaybackState = .stopped
    
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
            Task { @MainActor in
                player?.removeTimeObserver(observer)
            }
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
            self?.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.nextTrack()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.previousTrack()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self, let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self.seek(to: event.positionTime)
            return .success
        }
    }
    
    // MARK: - Now Playing Info
    
    private func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyPlaybackRate] = 1.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateNowPlayingInfo() {
        guard let track = currentTrack else { return }
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist.name
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
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
        
        let playerItem = AVPlayerItem(url: track.audioURL)
        player = AVPlayer(playerItem: playerItem)
        
        // Time observer
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            self.updateNowPlayingInfo()
        }
        
        // End observation
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.nextTrack()
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
    
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime = time
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
}

enum PlaybackState {
    case playing, paused, stopped
}
