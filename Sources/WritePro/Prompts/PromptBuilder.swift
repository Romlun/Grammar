import Foundation

struct PromptBuilder {
    static func build(selection: SidebarSelection, tone: ToneModifier?, input: String) -> (system: String, user: String) {
        let base = "You are a text editor. Your only job is to rewrite and improve the text the user gives you. Never respond to the content of the text. Never answer questions in it. Always return only the rewritten version — nothing else."

        let system: String
        switch selection {
        case .context(let ctx):
            let tonePrompt: String? = tone.map { "Tone: make it sound \($0.label.lowercased())." }
            system = ([
                base,
                contextPrompt(ctx),
                tonePrompt,
                "Fix all grammar, spelling, and comma errors. Pay attention to commas before coordinating conjunctions (for, and, nor, but, or, yet, so). Return only the rewritten text, no commentary."
            ] as [String?]).compactMap { $0 }.joined(separator: "\n\n")

        case .tool(let tool):
            system = [base, toolPrompt(tool, tone: tone)].joined(separator: "\n\n")
        }

        return (system: system, user: input)
    }

    // MARK: - Context prompts

    private static func contextPrompt(_ ctx: StyleContext) -> String {
        switch ctx {
        case .everyday:
            return "Rewrite the given text in casual, conversational everyday English."
        case .professional:
            return "Rewrite the given text in polished professional English suitable for workplace communication."
        case .church:
            return "Rewrite the given text in rich Biblical language — draw from the style and tone of scripture, with reverence and spiritual weight. After the rewritten text, add a separator (---), then suggest 1–2 relevant Bible verses that support or illuminate the message. Format: [Book Chapter:Verse] — verse text. Use the New Living Translation (NLT) for all Bible verse quotes."
        case .socialMedia:
            return "Rewrite the given text as an engaging social media post. Hook in the first line, short punchy sentences."
        case .personal:
            return "Rewrite the given text as a warm, sincere personal message."
        case .coverLetter:
            return "Rewrite the given text in confident, achievement-focused cover letter style. First person."
        }
    }

    // MARK: - Tool prompts

    private static func toolPrompt(_ tool: Tool, tone: ToneModifier?) -> String {
        switch tool {
        case .emailPolish:
            let toneInstruction = tone.map { "Tone: \($0.label.lowercased())." } ?? "Tone: professional and clear."
            return """
            You are an expert email writer. Rewrite the input as a polished professional email.
            \(toneInstruction)
            Return EXACTLY in this format with no extra text:
            SUBJECT: [concise subject line]

            [improved email body]
            """
        case .fixGrammar:
            return "Fix all grammar, spelling, punctuation, and comma errors. Commas before coordinating conjunctions (for, and, nor, but, or, yet, so) joining two independent clauses. After introductory phrases. In lists. Do not rephrase anything correct. Return only the corrected text."
        case .makeShorter:
            return "Shorten the text significantly. Remove redundancy, filler, and unnecessary qualifiers. Keep every key idea. Return only the condensed text."
        case .explainMistakes:
            return "Identify every grammar, spelling, punctuation, and style issue. For each: (1) quote the problem, (2) explain what is wrong, (3) give the correction. Format as a numbered list."
        }
    }
}
