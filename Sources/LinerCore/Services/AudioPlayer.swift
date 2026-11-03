import Foundation; import AVFoundation; import MediaPlayer; import Combine; import UIKit

@MainActor public final class AudioPlayer: ObservableObject {
    public static let shared = AudioPlayer()
    @Published public private(set) var currentTrack: Track?
    @Published public private(set) var isPlaying = false
    @Published public private(set) var currentTime: TimeInterval = 0
    @Published public private(set) var duration: TimeInterval = 0
    @Published public private(set) var playbackState: PlaybackState = .stopped
    @Published public private(set) var shuffleEnabled = false
    @Published public private(set) var repeatMode: RepeatMode = .off
    private var player: AVPlayer?; private nonisolated(unsafe) var timeObserver: Any?
    private var currentQueue: [Track] = []; private var currentIndex: Int = 0
    
    private init() { setupAudioSession(); setupRemoteCommands(); setupNowPlayingInfo() }
    deinit { if let observer = timeObserver { player?.removeTimeObserver(observer) } }
    
    private func setupAudioSession() {
        do { let s = AVAudioSession.sharedInstance(); try s.setCategory(.playback, mode: .default, options: [.allowBluetoothA2DP, .allowAirPlay]); try s.setActive(true) }
        catch { print("Audio session setup failed: \(error)") }
    }
    private func setupRemoteCommands() {
        let cc = MPRemoteCommandCenter.shared()
        cc.playCommand.addTarget { [weak self] _ in Task { @MainActor in self?.play() }; return .success }
        cc.pauseCommand.addTarget { [weak self] _ in Task { @MainActor in self?.pause() }; return .success }
        cc.nextTrackCommand.addTarget { [weak self] _ in Task { @MainActor in self?.nextTrack() }; return .success }
        cc.previousTrackCommand.addTarget { [weak self] _ in Task { @MainActor in self?.previousTrack() }; return .success }
        cc.changePlaybackPositionCommand.addTarget { [weak self] e in guard let self = self, let e = e as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }; Task { @MainActor in self.seek(to: e.positionTime) }; return .success }
    }
    private func setupNowPlayingInfo() { var i = [String:Any](); i[MPNowPlayingInfoPropertyPlaybackRate] = 1.0; MPNowPlayingInfoCenter.default().nowPlayingInfo = i }
    private func updateNowPlayingInfo() {
        guard let t = currentTrack else { return }
        var n = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        n[MPMediaItemPropertyTitle] = currentTrack?.title; n[MPMediaItemPropertyArtist] = currentTrack?.artist.name
        n[MPMediaItemPropertyPlaybackDuration] = duration; n[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        n[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        if let url = currentTrack?.artworkURL, let d = try? Data(contentsOf: url), let img = UIImage(data: d) { n[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: img.size) { _ in img } }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = n
    }
    func load(track: Track, queue: [Track], startIndex: Int = 0) {
        currentQueue = queue; currentIndex = startIndex; currentTrack = track
        guard let url = track.audioURL else { print("Audio URL nil"); return }
        let pi = AVPlayerItem(url: url); player = AVPlayer(playerItem: pi)
        let int = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: int, queue: .main) { [weak self] t in Task { @MainActor in guard let s = self else { return }; s.currentTime = t.seconds; s.updateNowPlayingInfo() } }
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: pi, queue: .main) { [weak self] _ in Task { @MainActor in self?.nextTrack() } }
        play()
    }
    func play() { player?.play(); isPlaying = true; playbackState = .playing; updateNowPlayingInfo() }
    func pause() { player?.pause(); isPlaying = false; playbackState = .paused; updateNowPlayingInfo() }
    func togglePlayPause() { isPlaying ? pause() : play() }
    func seek(to t: TimeInterval) { let ct = CMTime(seconds: t, preferredTimescale: CMTimeScale(NSEC_PER_SEC)); player?.seek(to: ct) { [weak self] _ in Task { @MainActor in guard let s = self else { return }; s.currentTime = t } } }
    func nextTrack() { guard currentIndex + 1 < currentQueue.count else { return }; currentIndex += 1; load(track: currentQueue[currentIndex], queue: currentQueue, startIndex: currentIndex) }
    func previousTrack() { guard currentIndex - 1 >= 0 else { return }; currentIndex -= 1; load(track: currentQueue[currentIndex], queue: currentQueue, startIndex: currentIndex) }
    func toggleShuffle() { shuffleEnabled.toggle() }
    func toggleRepeatMode() { switch repeatMode { case .off: repeatMode = .queue; case .queue: repeatMode = .track; case .track: repeatMode = .off } }
    @Published public private(set) var shuffleEnabled = false; @Published public private(set) var repeatMode: RepeatMode = .off
    private var player: AVPlayer?; private nonisolated(unsafe) var timeObserver: Any?
    private var currentQueue: [Track] = []; private var currentIndex: Int = 0
}
public enum PlaybackState { case playing, paused, stopped }
public enum RepeatMode { case off, queue, track }