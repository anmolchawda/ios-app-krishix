import Foundation

public struct SafetyCheckResult {
    public let isApproved: Bool
    public let message: String
    public let violationType: String

    public init(isApproved: Bool, message: String, violationType: String = "") {
        self.isApproved = isApproved
        self.message = message
        self.violationType = violationType
    }
}

public class ContentSafetyManager {
    public static let shared = ContentSafetyManager()

    // Comprehensive list of NSFW / 18+ / Adult / Nudity / Explicit keywords across English, Hindi, Hinglish, and regional slang
    // Directly synced from KrishiX Android ContentSafetyManager.kt
    private let nsfwKeywords: [String] = [
        // English Adult & Nudity
        "porn", "porno", "pornography", "nsfw", "nude", "nudity", "naked", "sex", "sexy", "sexual",
        "erotic", "xxx", "bikini", "lingerie", "boobs", "breast", "penis", "vagina", "dick", "pussy",
        "escort", "call girl", "strip club", "stripper", "masturbat", "orgasm", "fetish", "cleavage",
        "playboy", "onlyfans", "hentai", "kamagra", "viagra", "condom", "dildo", "cum", "sperm",
        "bhabhi sexy", "dating sex", "night service", "horny", "lust", "seduce",
        
        // Hindi & Hinglish Explicit
        "chudai", "chuda", "chod", "chodo", "nanga", "nangi", "lund", "chut", "chooth", "gaand",
        "randi", "bhosdike", "bhosdi", "mms video", "sexy ladki", "hot girl sexy", "jism", "sambhog",
        "ashleel", "kamvasna", "sex video", "nude pic", "nangi photo", "khula badan", "suhagraat leak",
        
        // Gambling & Illicit Drugs / Weapons
        "satta", "matka", "casino", "gambling", "betting app", "win real cash 18+", "teen patti real money",
        "charas", "ganja smoking", "cocaine", "heroin", "weapon for sale", "pistol for sale", "desi katta"
    ]

    public func checkTextContainsExplicitContent(_ text: String) -> Bool {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        
        let cleaned = text.lowercased()
            .replacingOccurrences(of: "[^a-zA-Z0-9\\s]", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)

        for keyword in nsfwKeywords {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: cleaned.utf16.count)
                if regex.firstMatch(in: cleaned, options: [], range: range) != nil {
                    return true
                }
            }
            if cleaned.contains(keyword) {
                return true
            }
        }
        return false
    }

    public func evaluatePostSafety(caption: String, hashtags: [String]) -> SafetyCheckResult {
        let combined = "\(caption) \(hashtags.joined(separator: " "))".trimmingCharacters(in: .whitespacesAndNewlines)
        if checkTextContainsExplicitContent(combined) {
            return SafetyCheckResult(
                isApproved: false,
                message: "Content Security Alert (Strict Policy Block): Your post contains 18+, sexually explicit, adult, or inappropriate words. KrishiX maintains a strict zero-tolerance community safety protocol.",
                violationType: "NSFW_TEXT"
            )
        }
        return SafetyCheckResult(isApproved: true, message: "Approved")
    }
}
