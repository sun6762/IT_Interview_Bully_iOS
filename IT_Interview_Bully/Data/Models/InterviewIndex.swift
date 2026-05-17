import Foundation

struct SSInterviewIndex: Decodable {
    let categories: [SSInterviewCategory]
    let questions: [SSInterviewQuestionRecord]
}

struct SSInterviewQuestionRecord: Decodable {
    let id: String
    let title: String
    let categoryID: String
    let tags: [String]
    let markdownPath: String
}
