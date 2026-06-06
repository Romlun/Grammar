import Foundation

actor GrammarCheckService {
    static let shared = GrammarCheckService()
    private var checkTask: Task<Void, Never>?

    private init() {}

    func scheduleCheck(text: String, apiKey: String) async -> [GrammarMistake] {
        checkTask?.cancel()
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        if Task.isCancelled { return [] }
        return await check(text: text, apiKey: apiKey)
    }

    private func check(text: String, apiKey: String) async -> [GrammarMistake] {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }

        let systemPrompt = """
        You are a grammar checker. Analyze the text and return ONLY a JSON array of mistakes.
        Each mistake: {"phrase": "exact text from input", "issue": "short explanation", "suggestion": "corrected version"}.
        Only include clear grammar, spelling, or punctuation errors. Ignore style preferences.
        If no mistakes, return [].
        Return ONLY the JSON array, no other text.
        """

        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("prompt-caching-2024-07-31", forHTTPHeaderField: "anthropic-beta")

        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 1024,
            "system": [
                [
                    "type": "text",
                    "text": systemPrompt,
                    "cache_control": ["type": "ephemeral"]
                ]
            ],
            "messages": [["role": "user", "content": text]]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return [] }
        request.httpBody = httpBody

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let responseText = content.first?["text"] as? String,
              let mistakesData = responseText.data(using: .utf8),
              let mistakesJSON = try? JSONSerialization.jsonObject(with: mistakesData) as? [[String: String]]
        else { return [] }

        return mistakesJSON.compactMap { dict in
            guard let phrase = dict["phrase"],
                  let issue = dict["issue"],
                  let suggestion = dict["suggestion"] else { return nil }
            return GrammarMistake(phrase: phrase, issue: issue, suggestion: suggestion)
        }
    }
}
