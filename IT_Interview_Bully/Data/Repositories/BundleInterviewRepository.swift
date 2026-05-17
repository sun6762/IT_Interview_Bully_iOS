import Combine
import Foundation

final class SSBundleInterviewRepository: SSInterviewRepository {
    private let loader: SSBundleResourceLoader
    // Primary markdown root used by the production app bundle.
    private let markdownRootDirectory: String

    init(loader: SSBundleResourceLoader, markdownRootDirectory: String = "iOS面试资深解答") {
        self.loader = loader
        self.markdownRootDirectory = markdownRootDirectory
    }

    func fetchCategories() -> AnyPublisher<[SSInterviewCategory], Error> {
        deferredResult {
            let questions = try self.fetchQuestionSummaries()
            let uniqueCategories = Dictionary(grouping: questions, by: \.category.id)
                .compactMap { _, grouped in grouped.first?.category }
                .sorted { $0.id.localizedStandardCompare($1.id) == .orderedAscending }
            return uniqueCategories
        }
    }

    func fetchQuestions() -> AnyPublisher<[SSInterviewQuestionSummary], Error> {
        deferredResult {
            try self.fetchQuestionSummaries()
        }
    }

    func fetchQuestionDetail(id: String) -> AnyPublisher<SSInterviewQuestionDetail, Error> {
        deferredResult {
            let questions = try self.fetchQuestionSummaries()
            guard let question = questions.first(where: { $0.id == id }) else {
                throw SSInterviewRepositoryError.missingQuestion(id: id)
            }

            let markdownContent = try self.loader.loadMarkdown(at: question.markdownPath)
            return SSInterviewQuestionDetail(
                id: question.id,
                title: question.title,
                markdownContent: markdownContent,
                sourcePath: question.markdownPath
            )
        }
    }

    private func fetchQuestionSummaries() throws -> [SSInterviewQuestionSummary] {
        // Prefer current packaging path. Keep a legacy fallback for older bundle layouts.
        var markdownDocuments = try loader.loadMarkdownDocuments(in: markdownRootDirectory)
        if markdownDocuments.isEmpty, markdownRootDirectory == "iOS面试资深解答" {
            markdownDocuments = try loader.loadMarkdownDocuments(in: "markdown/iOS面试资深解答")
        }
        guard !markdownDocuments.isEmpty else {
            throw SSInterviewRepositoryError.missingResource(name: "iOS面试资深解答", extension: "directory")
        }
        return mapFromMarkdownDocuments(markdownDocuments)
    }

    private func mapFromMarkdownDocuments(_ documents: [SSBundleMarkdownDocument]) -> [SSInterviewQuestionSummary] {
        // Derive category metadata from folder hierarchy so App Home mirrors file structure.
        let categoryMap = Dictionary(grouping: documents, by: \.categoryPath)
            .mapValues { docs -> SSInterviewCategory in
                let path = docs.first?.categoryPath ?? ""
                let fallback = "未分类"
                let name = path.isEmpty ? fallback : path.components(separatedBy: "/").last ?? fallback
                return SSInterviewCategory(
                    id: path.isEmpty ? "root" : path,
                    title: name,
                    description: "来自目录：\(path.isEmpty ? fallback : path)"
                )
            }

        return documents.map { document in
            let category = categoryMap[document.categoryPath] ?? SSInterviewCategory(id: "root", title: "未分类", description: "")
            let id = document.markdownPath.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: ".md", with: "")
            return SSInterviewQuestionSummary(
                id: id,
                title: document.title,
                category: category,
                tags: [category.title],
                markdownPath: document.markdownPath
            )
        }
    }

    private func deferredResult<T>(_ work: @escaping () throws -> T) -> AnyPublisher<T, Error> {
        Deferred {
            Future { promise in
                do {
                    promise(.success(try work()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
