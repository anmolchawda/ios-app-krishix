# KrishiX iOS (Native SwiftUI + XcodeGen)

Native iOS client for **KrishiX** — an advanced agricultural platform combining AI crop disease pathology diagnosis, real-time APMC Mandi commodity rates with 7-day candlestick charts, hyper-local weather alerts & foliar spray advisories, regional disease outbreak radar, and a vibrant farmer community.

---

## 🌟 Key Features

1. **Authentication & DPDP Compliance**
   - Clean, high-resolution brand identity with dark/light mode toggle.
   - Phone number authentication with simulated instant SMS notification (`849201`) for seamless field testing.
   - Interactive, in-app modal viewers for **Terms of Service** and **Privacy Policy** complying with India's **Digital Personal Data Protection (DPDP) Act 2023**.
   - Multi-language support across **12 Indian languages** (English, Hindi, Bhojpuri, Marathi, Gujarati, Punjabi, Tamil, Telugu, Kannada, Malayalam, Odia, Bengali).

2. **Community Feed**
   - Direct integration with Firebase community posts.
   - Real post feed featuring farmer discussions (e.g. `demo7477` pest identification in Durg, Chhattisgarh).
   - Zero-gap trending hashtags strip (`#tomato`, `#brinjal`, `#earlyblight`, `#mandirates`).
   - Floating Action Button (`+`) to create community posts with native `PhotosPicker` and camera upload.

3. **AI Doctor & Pathology Diagnosis**
   - Real iOS Camera & Photo Library picker.
   - Animated Chain-of-Thought reasoning steps (tissue scanning, ICAR spore morphology matching, CIB&RC active chemical cross-referencing).
   - Diagnostic output with confidence percentage, registered chemical solutions (e.g. Propiconazole 25% EC, Tebuconazole), and organic alternatives (NSKE 5%, Trichoderma viride).
   - Scan history ledger and top-up scan balance.

4. **APMC Mandi Intelligence**
   - Cascading State, District, and Market Yard selectors covering all major agricultural states.
   - **7-Day Price Chart**: Daily candlestick bars with modal price markers, Government MSP reference line, and arrival tonnage.

5. **Hyper-Local Weather & Spray Advisory**
   - Live district autocomplete search dropdown.
   - Real-time temperature, condition, humidity, wind speed, and rain probability.
   - Foliar & chemical spray window advisory banner.
   - 6-hour forecast chips.

6. **Crop Science & Tank-Mix Engine**
   - Database of CIB&RC active ingredients, FRAC/IRAC resistance codes, and approved dosages.
   - Interactive **Tank-Mix Compatibility Engine** to test chemical combinations for precipitation or phytotoxicity risks.

7. **Regional Disease Outbreak Radar**
   - Radius surveillance selector (15 km, 30 km, 50 km, 100 km).
   - Visual radar scanner HUD with real-time farm outbreak alerts and one-tap AI Doctor consultation.

8. **Profile & Profile Settings**
   - Verified profile view with holdings, produce specialization (`vegetable export`), and followers.
   - Profile settings with non-changeable username security, DPDP compliance banner, and phone lock.

---

## 🛠️ Build & Architecture

- **UI Framework:** 100% Native SwiftUI (iOS 16.0+).
- **Project Generator:** [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`project.yml`) — no bulky `.xcodeproj` checked into Git.
- **Backend SDK:** Official Firebase iOS SDK via Swift Package Manager (`FirebaseAuth`, `FirebaseFirestore`, `FirebaseStorage`, `FirebaseFunctions`).
- **CI/CD:** Automated GitHub Actions workflow (`.github/workflows/build-ipa.yml`) running on macOS 14 runners that compiles and packages an unsigned `KrishiX.ipa` in ~1–2 minutes.

### Sideloading Instructions (via Sideloadly)
1. Download the latest `KrishiX.ipa` from the GitHub Actions **Artifacts** tab.
2. Open **Sideloadly** on Windows or Mac.
3. Connect your iPhone via USB.
4. Drag and drop `KrishiX.ipa` into Sideloadly, enter your Apple ID, and click **Start**.
5. On your iPhone, navigate to **Settings > General > VPN & Device Management** and trust your Developer certificate.
