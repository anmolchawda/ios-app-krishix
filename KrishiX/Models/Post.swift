import Foundation

public struct Post: Identifiable, Codable, Equatable {
    public var id: String
    public var userId: String
    public var username: String
    public var userDisplayName: String
    public var userAvatarUrl: String
    public var userLocation: String
    public var imageUrl: String
    public var caption: String
    public var cropCategory: String
    public var hashtags: [String]
    public var likesCount: Int
    public var commentsCount: Int
    public var isLiked: Bool
    public var isSaved: Bool
    public var timeAgo: String
    public var isAuthorSubscribed: Bool

    public init(
        id: String = UUID().uuidString,
        userId: String = "demo7477",
        username: String = "demo7477",
        userDisplayName: String = "demo7477",
        userAvatarUrl: String = "",
        userLocation: String = "Durg, Chhattisgarh, India",
        imageUrl: String = "fly_pest",
        caption: String = "which fly is this ?",
        cropCategory: String = "Brinjal",
        hashtags: [String] = ["#brinjal"],
        likesCount: Int = 0,
        commentsCount: Int = 0,
        isLiked: Bool = false,
        isSaved: Bool = false,
        timeAgo: String = "1 MONTH AGO",
        isAuthorSubscribed: Bool = true
    ) {
        self.id = id
        self.userId = userId
        self.username = username
        self.userDisplayName = userDisplayName
        self.userAvatarUrl = userAvatarUrl
        self.userLocation = userLocation
        self.imageUrl = imageUrl
        self.caption = caption
        self.cropCategory = cropCategory
        self.hashtags = hashtags
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.isLiked = isLiked
        self.isSaved = isSaved
        self.timeAgo = timeAgo
        self.isAuthorSubscribed = isAuthorSubscribed
    }
}

public struct Comment: Identifiable, Codable, Equatable {
    public var id: String
    public var postId: String
    public var userName: String
    public var text: String
    public var timeAgo: String
    public var userId: String
    public var isExpert: Bool
    public var userLocation: String

    public init(
        id: String = UUID().uuidString,
        postId: String = "",
        userName: String = "demo7477",
        text: String = "",
        timeAgo: String = "Just now",
        userId: String = "demo7477",
        isExpert: Bool = false,
        userLocation: String = "India"
    ) {
        self.id = id
        self.postId = postId
        self.userName = userName
        self.text = text
        self.timeAgo = timeAgo
        self.userId = userId
        self.isExpert = isExpert
        self.userLocation = userLocation
    }
}
