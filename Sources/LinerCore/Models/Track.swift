import Foundation

public struct Track: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let artist: Artist
    public let album: Album?
    public let duration: TimeInterval?
    public let artworkURL: URL?
    public let audioURL: URL?
    public let lyrics: Lyrics?
    public let trackNumber: Int?
    public let discNumber: Int?
    public let isExplicit: Bool
    public let isFavorite: Bool
    public let dateAdded: Date
}

public struct Artist: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let artworkURL: URL?
    public let genres: [String]
    public let biography: String?
}

public struct Album: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let artist: Artist
    public let artworkURL: URL?
    public let releaseDate: Date?
    public let trackCount: Int
    public let genre: String?
}

public struct Lyrics: Codable, Hashable {
    public let lines: [SyncedLine]
    public let isSynced: Bool
}

public struct SyncedLine: Identifiable, Codable, Hashable {
    public let id: UUID
    public let time: TimeInterval
    public let text: String
    public let syllables: [Syllable]?
    
    public init(id: UUID = UUID(), time: TimeInterval, text: String, syllables: [Syllable]? = nil) {
        self.id = id
        self.time = time
        self.text = text
        self.syllables = syllables
    }
}

public struct Syllable: Codable, Hashable {
    public let text: String
    public let startTime: TimeInterval
    public let duration: TimeInterval
}
