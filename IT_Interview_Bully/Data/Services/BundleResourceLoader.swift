import Foundation

final class BundleResourceLoader {
    private let bundle: Bundle
    private let decoder: JSONDecoder
    private let indexResourceName: String

    init(bundle: Bundle, decoder: JSONDecoder = JSONDecoder(), indexResourceName: String = "interview_index") {
        self.bundle = bundle
        self.decoder = decoder
        self.indexResourceName = indexResourceName
    }

    func loadIndex() throws -> InterviewIndex {
        let data = try data(named: indexResourceName, withExtension: "json")
        do {
            return try decoder.decode(InterviewIndex.self, from: data)
        } catch {
            throw InterviewRepositoryError.invalidIndexData
        }
    }

    func loadMarkdown(at relativePath: String) throws -> String {
        let normalizedPath = relativePath.replacingOccurrences(of: "\\", with: "/")
        let resourceBasePath = normalizedPath.hasPrefix("Resources/") ? String(normalizedPath.dropFirst("Resources/".count)) : normalizedPath
        let nsPath = resourceBasePath as NSString
        let directory = nsPath.deletingLastPathComponent
        let fileName = nsPath.lastPathComponent as NSString
        let name = fileName.deletingPathExtension
        let fileExtension = fileName.pathExtension

        let url = bundle.url(forResource: name, withExtension: fileExtension, subdirectory: directory.isEmpty ? nil : directory)
            ?? bundle.url(forResource: name, withExtension: fileExtension)

        guard let url else {
            throw InterviewRepositoryError.invalidMarkdownPath(path: relativePath)
        }

        return try String(contentsOf: url, encoding: .utf8)
    }

    private func data(named name: String, withExtension fileExtension: String) throws -> Data {
        guard let url = bundle.url(forResource: name, withExtension: fileExtension) else {
            throw InterviewRepositoryError.missingResource(name: name, extension: fileExtension)
        }
        return try Data(contentsOf: url)
    }
}
