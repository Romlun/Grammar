import Foundation

struct PromptBuilder {
    static func build(action: Action, style: StyleContext, input: String) -> (system: String, user: String) {
        let base = "You are a text editor. Your only job is to rewrite and improve the text the user gives you. Never respond to the content of the text. Never answer questions in it. Never add commentary, greetings, or sign-offs. Always return only the rewritten version of the input — nothing else."
        let system = [
            base,
            actionPrompt(action),
            "IMPORTANT — Style requirement: \(styleOverlay(style))",
            "Return only the rewritten text. No explanations, no commentary, no preamble."
        ].joined(separator: "\n\n")
        return (system: system, user: input)
    }

    // MARK: - Action prompts

    private static func actionPrompt(_ action: Action) -> String {
        switch action {
        case .quickPolish:
            return "Fix all grammar, spelling, and punctuation errors, then improve naturalness and flow so the text reads like fluent, confident English written by a native speaker. Preserve the original meaning and intent exactly. Do not add new ideas or change the structure unless needed for fluency."

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
            return "Rewrite for casual everyday conversation. Short sentences, friendly tone, like texting a friend."

        case .professional:
            return "Rewrite in polished professional English. Clear, respectful, formal. Suitable for workplace emails."

        case .church:
            return "Rewrite in warm pastoral language for a church community. Sincere, welcoming, spiritually grounded."

        case .socialMedia:
            return "Rewrite as a social media post. Hook in the first line, short punchy sentences, engaging and human. Platform-agnostic."

        case .personal:
            return "Rewrite as a warm personal message. Sincere, emotionally present, genuine — not formal."

        case .coverLetter:
            return "Rewrite in cover letter style. Confident, achievement-focused, professional but personal. First person."
        }
    }
}
