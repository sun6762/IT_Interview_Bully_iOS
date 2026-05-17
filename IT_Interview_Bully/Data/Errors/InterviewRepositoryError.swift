import Foundation

enum InterviewRepositoryError: LocalizedError {
    case missingResource(name: String, extension: String)
    case invalidIndexData
    case missingCategory(id: String)
    case missingQuestion(id: String)
    case invalidMarkdownPath(path: String)

    var errorDescription: String? {
        switch self {
        case .missingResource(let name, let extensionName):
            return "Could not find resource \(name).\(extensionName) in the bundle."
        case .invalidIndexData:
            return "The interview index data is invalid."
        case .missingCategory(let id):
            return "Could not map question to category: \(id)."
        case .missingQuestion(let id):
            return "Could not find a question with id \(id)."
        case .invalidMarkdownPath(let path):
            return "Could not load markdown file at path \(path)."
        }
    }
}

