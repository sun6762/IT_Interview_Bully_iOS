import Foundation

struct InterviewIndex: Decodable {
    let categories: [InterviewCategory]
    let questions: [InterviewQuestionRecord]
}

struct InterviewQuestionRecord: Decodable {
    let id: String
    let title: String
    let categoryID: String
    let tags: [String]
    let markdownPath: String
}

