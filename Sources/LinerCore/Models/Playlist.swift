import Foundation

public struct Playlist: Identifiable, Codable, Hashable {
    public let id: String
    let title: String
    let description: String?
    let artworkURL: URL?
    let tracks: [Track]
    let owner: User?
    let isPublic: Bool
    let isCollaborative: Bool
    let trackCount: Int
    let totalDuration: TimeInterval
    let dateCreated: Date
    let dateModified: Date

    var formattedDuration: String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

public struct User: Identifiable, Codable, Hashable {
    public let id: String
    let username: String
    let displayName: String
    let avatarURL: URL?
    let isVerified: Bool
}