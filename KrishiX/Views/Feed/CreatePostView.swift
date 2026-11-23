import SwiftUI
import PhotosUI

public struct CreatePostView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var firebase = FirebaseManager.shared
    
    @State private var caption: String = ""
    @State private var selectedCrop: String = "Brinjal"
    @State private var hashtag: String = "#brinjal"
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isPosting: Bool = false
    
    let cropOptions = ["Brinjal", "Tomato", "Wheat", "Soybean", "Paddy (Dhan)", "Cotton", "Chilli"]
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Photo")) {
                    if let img = selectedImage {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 220)
                                .cornerRadius(12)
                            
                            Button(action: { selectedImage = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                            }
                            .padding(8)
                        }
                    } else {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            HStack {
                                Image(systemName: "photo.badge.plus")
                                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                                    .font(.system(size: 20))
                                Text("Select Crop Photo from Gallery")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color(red: 0.13, green: 0.55, blue: 0.28))
                            }
                            .padding(.vertical, 8)
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let img = UIImage(data: data) {
                                    await MainActor.run {
                                        self.selectedImage = img
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Caption & Crop Details")) {
                    TextField("What's happening in your field? (e.g., which fly is this ?)", text: $caption, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Crop Category", selection: $selectedCrop) {
                        ForEach(cropOptions, id: \.self) { crop in
                            Text(crop).tag(crop)
                        }
                    }
                    
                    TextField("Hashtags (e.g. #brinjal, #pest)", text: $hashtag)
                }
                
                Section {
                    Button(action: submitPost) {
                        HStack {
                            Spacer()
                            if isPosting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Post to KrishiX Community")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(caption.isEmpty ? Color.gray.opacity(0.5) : Color(red: 0.13, green: 0.55, blue: 0.28))
                        .cornerRadius(10)
                    }
                    .disabled(caption.isEmpty || isPosting)
                }
            }
            .navigationTitle("Create Post")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func submitPost() {
        guard !caption.isEmpty else { return }
        isPosting = true
        
        let tags = hashtag
            .components(separatedBy: " ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { $0.hasPrefix("#") ? $0 : "#\($0)" }
        
        let newPost = Post(
            id: UUID().uuidString,
            userId: firebase.currentUser?.id ?? "farmer_01",
            username: firebase.currentUser?.username ?? "99side",
            userDisplayName: firebase.currentUser?.displayName ?? "99side",
            userLocation: firebase.currentUser?.location ?? "Mumbai, Maharashtra",
            imageUrl: selectedImage != nil ? "custom_upload" : "",
            caption: caption,
            cropCategory: selectedCrop,
            hashtags: tags.isEmpty ? ["#\(selectedCrop.lowercased())"] : tags,
            likesCount: 0,
            commentsCount: 0,
            isLiked: false,
            isSaved: false,
            timeAgo: "Just now",
            isAuthorSubscribed: true
        )
        
        firebase.communityPosts.insert(newPost, at: 0)
        isPosting = false
        presentationMode.wrappedValue.dismiss()
    }
}
