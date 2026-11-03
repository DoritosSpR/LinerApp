import Foundation

public struct Playlist: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let description: String?
    public let artworkURL: URL?
    public let tracks: [Track]
    public let trackCount: Int
    public let totalDuration: TimeInterval
    public let owner: User
    public let isPublic: Bool
    public let isCollaborative: Bool
    public let dateCreated: Date
    public let dateModified: Date
    
    public init(
        id: String,
        title: String,
        description: String? = nil,
        artworkURL: URL? = nil,
        tracks: [Track] = [],
        owner: User,
        isPublic: Bool = false,
        isCollaborative: Bool = false,
        dateCreated: Date = Date(),
        dateModified: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.artworkURL = artworkURL
        self.tracks = tracks
        self.trackCount = tracks.count
        self.totalDuration = tracks.reduce(0) { $0 + ($1.duration ?? 0) }
        self.owner = owner
        self.isPublic = isPublic
        self.isCollaborative = isCollaborative
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
}

public struct User: Identifiable, Codable, Hashable {
    public let id: String
    public let username: String
    public let displayName: String
    public let avatarURL: URL?
    public let followerCount: Int
    public let followingCount: Int
    
    public init(id: String, username: String, displayName: String, avatarURL: URL? = nil, followerCount: Int = 0, followingCount: Int = 0) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.followerCount = followerCount
        self.followingCount = followingCount
    }
}