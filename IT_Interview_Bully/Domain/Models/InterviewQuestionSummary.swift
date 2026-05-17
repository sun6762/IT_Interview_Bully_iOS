import Foundation

struct SSInterviewQuestionSummary: Identifiable, Hashable {
    let id: String
    let title: String
    let category: SSInterviewCategory
    let tags: [String]
    let markdownPath: String
}
