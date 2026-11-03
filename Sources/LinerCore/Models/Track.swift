import Foundation

struct Track: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let artist: Artist
    let album: Album?
    let duration: TimeInterval
    let artworkURL: URL?
    let audioURL: URL?
    let source: TrackSource
    let lyrics: Lyrics?
    let playCount: Int
    let isFavorite: Bool
    let dateAdded: Date

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

enum TrackSource: String, Codable {
    case local
    case youtube
    case soundcloud
    case bandcamp
    case appleMusic = "apple_music"
}

struct Artist: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let artworkURL: URL?
    let genres: [String]
}

struct Album: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let artist: Artist
    let artworkURL: URL?
    let releaseDate: Date?
    let trackCount: Int
}

struct Lyrics: Codable, Hashable {
    let synced: [SyncedLine]?
    let plain: String?
    let language: String?

    var hasSyncedLyrics: Bool {
        synced != nil && !(synced?.isEmpty ?? true)
    }
}

struct SyncedLine: Identifiable, Codable, Hashable {
    let id = UUID()
    let time: TimeInterval
    let text: String
    let syllables: [Syllable]?

    var formattedTime: String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

struct Syllable: Codable, Hashable {
    let text: String
    let startTime: TimeInterval
    let endTime: TimeInterval
}