import SwiftUI

public struct FeedView: View {
    public var onOpenDrawer: () -> Void
    
    @ObservedObject private var firebase = FirebaseManager.shared
    @ObservedObject private var translation = TranslationManager.shared
    
    @State private var selectedHashtag: String? = nil
    @State private var showCreatePost: Bool = false
    @State private var commentText: [String: String] = [:]
    @State private var showCommentsForPostId: String? = nil
    
    let trendingTags = ["#tomato", "#brinjal", "#earlyblight", "#lateblight", "#mandirates", "#wheat", "#fertilizer"]
    
    public init(onOpenDrawer: @escaping () -> Void) {
        self.onOpenDrawer = onOpenDrawer
    }
    
    var filteredPosts: [Post] {
        if let tag = selectedHashtag {
            return firebase.communityPosts.filter { post in
                post.hashtags.contains(where: { $0.caseInsensitiveCompare(tag) == .orderedSame }) ||
                post.caption.localizedCaseInsensitiveContains(tag)
            }
        }
        return firebase.communityPosts
    }
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Top Bar with Prominent Brand Logo
                KrishiTopBar(onOpenDrawer: onOpenDrawer, showBackButton: false)
                
                // Trending Hashtags - ZERO GAP (Requirement 6)
                trendingHashtagsStrip
                
                // Posts Count Sub-bar (Matching Video frame_13_39.9s.jpg: "All Posts (1)" & "📍 Durg, Chhattisgarh, India")
                HStack {
                    Text(selectedHashtag == nil ? "All Posts (\(filteredPosts.count))" : "Filtered by \(selectedHashtag!) (\(filteredPosts.count))")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.35, green: 0.38, blue: 0.42))
                    
                    Spacer()
                    
                    if selectedHashtag != nil {
                        Button(action: { selectedHashtag = nil }) {
                            Text(translation.getString("clearFilter"))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                        }
                    } else {
                        HStack(spacing: 4) {
                            Text("📍")
                                .font(.system(size: 11))
                            Text(firebase.currentUser?.location ?? "Durg, Chhattisgarh, India")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.7) : Color(red: 0.4, green: 0.43, blue: 0.46))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.16) : Color(red: 0.96, green: 0.97, blue: 0.98))
                
                // Community Posts Feed
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPosts) { post in
                            postCard(post: post)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.bottom, 60)
                }
                .background(firebase.isDarkTheme ? Color(red: 0.09, green: 0.10, blue: 0.12) : Color(red: 0.94, green: 0.95, blue: 0.96))
            }
            
            // Floating Action Button (+) Mint-green circle
            Button(action: { showCreatePost = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color(red: 0.13, green: 0.55, blue: 0.28))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView()
        }
    }
    
    // MARK: - Trending Hashtags Strip (ZERO GAP directly under top bar)
    private var trendingHashtagsStrip: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 13))
                Text(translation.getString("trendingHashtags"))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.2, green: 0.22, blue: 0.25))
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(trendingTags, id: \.self) { tag in
                        Button(action: {
                            if selectedHashtag == tag {
                                selectedHashtag = nil
                            } else {
                                selectedHashtag = tag
                            }
                        }) {
                            Text(tag)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(selectedHashtag == tag ? .white : Color(red: 0.13, green: 0.55, blue: 0.28))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    selectedHashtag == tag ?
                                    Color(red: 0.13, green: 0.55, blue: 0.28) :
                                    (firebase.isDarkTheme ? Color(red: 0.18, green: 0.20, blue: 0.24) : Color.white)
                                )
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 0.13, green: 0.55, blue: 0.28).opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .background(firebase.isDarkTheme ? Color(red: 0.12, green: 0.13, blue: 0.15) : Color.white)
    }
    
    // MARK: - Post Card
    private func postCard(post: Post) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Post Author Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.13, green: 0.55, blue: 0.28))
                        .frame(width: 40, height: 40)
                    Text(String(post.username.prefix(1)).uppercased())
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(post.username)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.12, green: 0.15, blue: 0.18))
                        
                        if post.isAuthorSubscribed {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                .font(.system(size: 13))
                        }
                    }
                    
                    HStack(spacing: 6) {
                        Text(post.userLocation)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        
                        Text(post.timeAgo)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding(14)
            
            // Post Image (if present)
            if !post.imageUrl.isEmpty {
                if post.imageUrl.hasPrefix("http") {
                    AsyncImage(url: URL(string: post.imageUrl)) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable()
                                .scaledToFill()
                                .frame(maxHeight: 280)
                                .clipped()
                        case .failure:
                            postImageFallback
                        case .empty:
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding(40)
                                Spacer()
                            }
                        @unknown default:
                            postImageFallback
                        }
                    }
                } else if let localImg = UIImage(named: post.imageUrl) {
                    Image(uiImage: localImg)
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: 280)
                        .clipped()
                } else {
                    postImageFallback
                }
            }
            
            // Post Caption & Hashtags
            VStack(alignment: .leading, spacing: 8) {
                Text(post.caption)
                    .font(.system(size: 14))
                    .foregroundColor(firebase.isDarkTheme ? .white : Color(red: 0.15, green: 0.18, blue: 0.22))
                    .lineSpacing(2)
                
                if !post.hashtags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(post.hashtags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, post.imageUrl.isEmpty ? 4 : 10)
            .padding(.bottom, 12)
            
            Divider()
            
            // Actions: Like, Comment, Save
            HStack(spacing: 20) {
                Button(action: {
                    firebase.toggleLike(postId: post.id)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(post.isLiked ? .red : (firebase.isDarkTheme ? .white.opacity(0.8) : Color(red: 0.35, green: 0.38, blue: 0.42)))
                        
                        Text("\(post.likesCount)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.35, green: 0.38, blue: 0.42))
                    }
                }
                
                Button(action: {
                    withAnimation {
                        showCommentsForPostId = (showCommentsForPostId == post.id) ? nil : post.id
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 18))
                            .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.8) : Color(red: 0.35, green: 0.38, blue: 0.42))
                        
                        Text("\(post.commentsCount)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(firebase.isDarkTheme ? .white.opacity(0.85) : Color(red: 0.35, green: 0.38, blue: 0.42))
                    }
                }
                
                Spacer()
                
                Button(action: {
                    firebase.toggleSave(postId: post.id)
                }) {
                    Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18))
                        .foregroundColor(post.isSaved ? Color(red: 0.13, green: 0.55, blue: 0.28) : (firebase.isDarkTheme ? .white.opacity(0.8) : Color(red: 0.35, green: 0.38, blue: 0.42)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(firebase.isDarkTheme ? Color(red: 0.13, green: 0.14, blue: 0.17) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal, 12)
    }
    
    private var postImageFallback: some View {
        ZStack {
            Color(red: 0.92, green: 0.95, blue: 0.93)
            VStack(spacing: 6) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                Text("Crop Diagnostic Photo")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
            }
        }
        .frame(height: 180)
    }
}
