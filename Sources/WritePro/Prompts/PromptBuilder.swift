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
        case .general:
            return "Use standard everyday English. No specialized jargon. Appropriate for any general audience."

        case .workEmail:
            return "Use professional office register. Suitable for workplace email: formal but not stiff, friendly but not casual. Avoid slang, contractions are acceptable. Keep a collegial tone."

        case .healthcare:
            return "Use clear, plain language appropriate for patient-facing healthcare communication. Avoid medical jargon where possible; when technical terms are necessary, keep them accurate. Tone should be calm, reassuring, and precise."

        case .business:
            return "Use formal business communication register. Language should reflect a corporate environment: objective, results-oriented, and free of emotional phrasing. Suitable for reports, executive summaries, or client-facing documents."

        case .church:
            return "Use warm, respectful language appropriate for a church or ministry community. Tone should be welcoming, sincere, and encouraging. Avoid overly formal or corporate language; spiritual warmth is appropriate."

        case .immigration:
            return "Use clear, precise language appropriate for immigration and legal documents. Be factual and formal. Avoid ambiguity. Use plain language where possible but maintain the accuracy required in legal or official contexts."
        }
    }
}
