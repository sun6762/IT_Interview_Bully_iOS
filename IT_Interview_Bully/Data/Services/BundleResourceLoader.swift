import Foundation

struct SSBundleMarkdownDocument {
    let title: String
    let markdownPath: String
    let categoryPath: String
}

final class SSBundleResourceLoader {
    private let bundle: Bundle
    private let decoder: JSONDecoder
    private let indexResourceName: String

    init(bundle: Bundle, decoder: JSONDecoder = JSONDecoder(), indexResourceName: String = "interview_index") {
        self.bundle = bundle
        self.decoder = decoder
        self.indexResourceName = indexResourceName
    }

    func loadIndex() throws -> SSInterviewIndex {
        let data = try data(named: indexResourceName, withExtension: "json")
        do {
            return try decoder.decode(SSInterviewIndex.self, from: data)
        } catch {
            throw SSInterviewRepositoryError.invalidIndexData
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

        let resolvedURL: URL?
        if let url {
            resolvedURL = url
        } else {
            // Fallback scan handles cases where Xcode flattens or relocates resource folders.
            let candidates = bundle.urls(forResourcesWithExtension: fileExtension, subdirectory: nil) ?? []
            resolvedURL = candidates.first(where: { $0.path.hasSuffix(resourceBasePath) })
                ?? candidates.first(where: { $0.lastPathComponent == fileName as String })
        }

        guard let resolvedURL else {
            throw SSInterviewRepositoryError.invalidMarkdownPath(path: relativePath)
        }

        return try String(contentsOf: resolvedURL, encoding: .utf8)
    }

    func loadMarkdownDocuments(in relativeDirectory: String) throws -> [SSBundleMarkdownDocument] {
        let normalizedRoot = relativeDirectory.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        var documents: [SSBundleMarkdownDocument] = []
        // Fast path: directory is preserved as-is in bundle.
        if let exactRootURL = bundle.url(forResource: normalizedRoot, withExtension: nil),
           FileManager.default.fileExists(atPath: exactRootURL.path) {
            documents.append(contentsOf: collectMarkdownDocuments(from: exactRootURL, normalizedRoot: normalizedRoot))
        }

        if documents.isEmpty, let resourceRoot = bundle.resourceURL,
           let enumerator = FileManager.default.enumerator(
               at: resourceRoot,
               includingPropertiesForKeys: [.isRegularFileKey, .nameKey],
               options: [.skipsHiddenFiles]
           ) {
            // Slow path: recursively locate markdown files under the requested folder marker.
            let marker = "/" + normalizedRoot + "/"
            for case let fileURL as URL in enumerator {
                guard fileURL.pathExtension.lowercased() == "md" else { continue }
                guard fileURL.lastPathComponent.lowercased() != "readme.md" else { continue }
                let fullPath = fileURL.path
                guard let range = fullPath.range(of: marker) else { continue }

                let relativeToRoot = String(fullPath[range.upperBound...])
                let categoryPath = (relativeToRoot as NSString).deletingLastPathComponent
                let title = fileURL.deletingPathExtension().lastPathComponent
                let markdownPath = normalizedRoot + "/" + relativeToRoot

                documents.append(
                    SSBundleMarkdownDocument(
                        title: title,
                        markdownPath: markdownPath,
                        categoryPath: categoryPath
                    )
                )
            }
        }

        return documents.sorted { $0.markdownPath.localizedStandardCompare($1.markdownPath) == .orderedAscending }
    }

    private func collectMarkdownDocuments(from rootURL: URL, normalizedRoot: String) -> [SSBundleMarkdownDocument] {
        guard let enumerator = FileManager.default.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.isRegularFileKey, .nameKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var results: [SSBundleMarkdownDocument] = []
        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension.lowercased() == "md" else { continue }
            guard fileURL.lastPathComponent.lowercased() != "readme.md" else { continue }

            let relativeToRoot = fileURL.path.replacingOccurrences(of: rootURL.path + "/", with: "")
            let categoryPath = (relativeToRoot as NSString).deletingLastPathComponent
            let title = fileURL.deletingPathExtension().lastPathComponent
            let markdownPath = normalizedRoot + "/" + relativeToRoot
            results.append(
                SSBundleMarkdownDocument(
                    title: title,
                    markdownPath: markdownPath,
                    categoryPath: categoryPath
                )
            )
        }
        return results
    }

    private func data(named name: String, withExtension fileExtension: String) throws -> Data {
        guard let url = bundle.url(forResource: name, withExtension: fileExtension) else {
            throw SSInterviewRepositoryError.missingResource(name: name, extension: fileExtension)
        }
        return try Data(contentsOf: url)
    }
}
