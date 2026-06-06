import Foundation

struct PromptBuilder {
    static func build(action: Action, style: StyleContext, input: String) -> (system: String, user: String) {
        let system = [actionPrompt(action), styleOverlay(style), "Return only the result text, no commentary."]
            .joined(separator: "\n\n")
        return (system: system, user: input)
    }

    // MARK: - Action prompts

    private static func actionPrompt(_ action: Action) -> String {
        switch action {
        case .fixGrammar:
            return "You are a grammar correction assistant. Fix all spelling, punctuation, and grammatical errors in the user's text. Preserve the original meaning, tone, and structure as closely as possible. Only correct errors — do not rephrase or rewrite."

        case .makeProfessional:
            return "You are a professional writing assistant. Rewrite the user's text to sound polished, confident, and suitable for a professional context. Use clear, precise language. Eliminate casual phrasing, slang, and informal contractions."

        case .makeNatural:
            return "You are a fluency editor. Rewrite the user's text so it reads like natural, idiomatic English spoken by a native speaker. Smooth out awkward phrasing, unnatural word order, and overly formal constructions while keeping the meaning intact."

        case .makeShorter:
            return "You are a conciseness editor. Condense the user's text by removing redundant words, unnecessary filler, and overly long constructions. Keep every key idea. The result should be noticeably shorter without losing meaning."

        case .makePolite:
            return "You are a tone editor focused on politeness. Rewrite the user's text to be courteous, considerate, and respectful. Soften any bluntness or abruptness. Use diplomatic phrasing while preserving the original intent."

        case .makeConfident:
            return "You are a tone editor focused on assertiveness. Rewrite the user's text to sound direct, decisive, and self-assured. Remove hedging language, unnecessary qualifiers, and apologetic phrasing. The result should feel authoritative."

        case .explainMistakes:
            return "You are a grammar teacher. Identify and explain every grammatical, spelling, and punctuation mistake in the user's text. For each mistake, state what it is, why it is wrong, and the correct form. Format your response as a numbered list."
        }
    }

    // MARK: - Style overlays

    private static func styleOverlay(_ style: StyleContext) -> String {
        switch style {
        case .everyday:
            return "Use casual, natural, conversational English. Friendly and warm, like texting a close friend. Short sentences are fine. No stiffness."

        case .professional:
            return "Use polished workplace English. Clear, respectful, and direct. Suitable for emails, reports, and formal communication. Avoid slang."

        case .church:
            return "Use warm, pastoral English appropriate for a church or Christian ministry community. Sincere, welcoming, and spiritually grounded. Avoid corporate language."

        case .socialMedia:
            return "Write for social media. Be engaging, punchy, and human. Hook the reader in the first line. Use short paragraphs. Conversational but purposeful. Suitable for LinkedIn, Instagram, or X."

        case .personal:
            return "Use warm, sincere, emotionally present language. Suitable for personal letters, thank-you notes, apologies, or heartfelt messages. Genuine — not performative."

        case .coverLetter:
            return "Use confident, professional English appropriate for job applications. Achievement-focused, specific, and persuasive. Formal but not stiff. First person."
        }
    }
}
