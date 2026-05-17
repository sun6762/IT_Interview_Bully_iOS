import Foundation

struct InterviewQuestionSummary: Identifiable, Hashable {
    let id: String
    let title: String
    let category: InterviewCategory
    let tags: [String]
    let markdownPath: String
}

