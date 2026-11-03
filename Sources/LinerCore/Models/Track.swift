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
    public let playCount: Int
    public let source: TrackSource
    
    public init(
        id: String,
        title: String,
        artist: Artist,
        album: Album? = nil,
        duration: TimeInterval? = nil,
        artworkURL: URL? = nil,
        audioURL: URL? = nil,
        lyrics: Lyrics? = nil,
        trackNumber: Int? = nil,
        discNumber: Int? = nil,
        isExplicit: Bool = false,
        isFavorite: Bool = false,
        dateAdded: Date = Date(),
        playCount: Int = 0,
        source: TrackSource = .local
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.artworkURL = artworkURL
        self.audioURL = audioURL
        self.lyrics = lyrics
        self.trackNumber = trackNumber
        self.discNumber = discNumber
        self.isExplicit = isExplicit
        self.isFavorite = isFavorite
        self.dateAdded = dateAdded
        self.playCount = playCount
        self.source = source
    }
}

public enum TrackSource: String, Codable, Hashable {
    case local, streaming, cloud
}

public struct Artist: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let artworkURL: URL?
    public let genres: [String]
    public let biography: String?
    
    public init(id: String, name: String, artworkURL: URL? = nil, genres: [String] = [], biography: String? = nil) {
        self.id = id
        self.name = name
        self.artworkURL = artworkURL
        self.genres = genres
        self.biography = biography
    }
}

public struct Album: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let artist: Artist
    public let artworkURL: URL?
    public let releaseDate: Date?
    public let trackCount: Int
    public let genre: String?
    
    public init(id: String, title: String, artist: Artist, artworkURL: URL? = nil, releaseDate: Date? = nil, trackCount: Int = 0, genre: String? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.releaseDate = releaseDate
        self.trackCount = trackCount
        self.genre = genre
    }
}

public struct Lyrics: Codable, Hashable {
    public let lines: [SyncedLine]
    public let isSynced: Bool
    public let plain: String?
    
    public init(lines: [SyncedLine] = [], isSynced: Bool = false, plain: String? = nil) {
        self.lines = lines
        self.isSynced = isSynced
        self.plain = plain
    }
    
    public init(synced: [SyncedLine]) {
        self.lines = synced
        self.isSynced = true
        self.plain = nil
    }
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