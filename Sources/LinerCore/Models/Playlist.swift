import Foundation

public struct Playlist: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let description: String?
    public let artworkURL: URL?
    public let trackCount: Int
    public let totalDuration: TimeInterval
    public let owner: User
    public let isPublic: Bool
    public let dateCreated: Date
    public let dateModified: Date
}

public struct User: Identifiable, Codable, Hashable {
    public let id: String
    public let username: String
    public let displayName: String
    public let avatarURL: URL?
    public let followerCount: Int
    public let followingCount: Int
}
