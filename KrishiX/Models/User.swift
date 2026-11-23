import Foundation

public struct User: Identifiable, Codable, Equatable {
    public var id: String
    public var username: String
    public var displayName: String
    public var fullName: String
    public var email: String
    public var phoneNumber: String
    public var avatarUrl: String
    public var bio: String
    public var location: String
    public var produce: [String]
    public var landSizeAcres: Double
    public var followersCount: Int
    public var followingCount: Int
    public var postCount: Int
    public var profileSetupComplete: Bool
    public var isSubscribed: Bool

    public init(
        id: String = "farmer_01",
        username: String = "99side",
        displayName: String = "99side",
        fullName: String = "99side",
        email: String = "farmer@krishix.in",
        phoneNumber: String = "+91 9999999999",
        avatarUrl: String = "",
        bio: String = "Progressive farmer using KrishiX AI.",
        location: String = "Mumbai, Maharashtra",
        produce: [String] = ["vegetable export"],
        landSizeAcres: Double = 5.0,
        followersCount: Int = 142,
        followingCount: Int = 38,
        postCount: Int = 4,
        profileSetupComplete: Bool = true,
        isSubscribed: Bool = true
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        self.avatarUrl = avatarUrl
        self.bio = bio
        self.location = location
        self.produce = produce
        self.landSizeAcres = landSizeAcres
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.postCount = postCount
        self.profileSetupComplete = profileSetupComplete
        self.isSubscribed = isSubscribed
    }
}
typealias Boolean = Bool
