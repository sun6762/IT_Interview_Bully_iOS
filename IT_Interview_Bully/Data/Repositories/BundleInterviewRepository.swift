import Combine
import Foundation

final class BundleInterviewRepository: InterviewRepository {
    private let loader: BundleResourceLoader

    init(loader: BundleResourceLoader) {
        self.loader = loader
    }

    func fetchCategories() -> AnyPublisher<[InterviewCategory], Error> {
        deferredResult {
            try self.loader.loadIndex().categories
        }
    }

    func fetchQuestions() -> AnyPublisher<[InterviewQuestionSummary], Error> {
        deferredResult {
            let index = try self.loader.loadIndex()
            let categoriesByID = Dictionary(uniqueKeysWithValues: index.categories.map { ($0.id, $0) })

            return try index.questions.map { question in
                guard let category = categoriesByID[question.categoryID] else {
                    throw InterviewRepositoryError.missingCategory(id: question.categoryID)
                }

                return InterviewQuestionSummary(
                    id: question.id,
                    title: question.title,
                    category: category,
                    tags: question.tags,
                    markdownPath: question.markdownPath
                )
            }
        }
    }

    func fetchQuestionDetail(id: String) -> AnyPublisher<InterviewQuestionDetail, Error> {
        deferredResult {
            let questions = try self.fetchQuestionSummaries()
            guard let question = questions.first(where: { $0.id == id }) else {
                throw InterviewRepositoryError.missingQuestion(id: id)
            }

            let markdownContent = try self.loader.loadMarkdown(at: question.markdownPath)
            return InterviewQuestionDetail(
                id: question.id,
                title: question.title,
                markdownContent: markdownContent,
                sourcePath: question.markdownPath
            )
        }
    }

    private func fetchQuestionSummaries() throws -> [InterviewQuestionSummary] {
        let index = try loader.loadIndex()
        let categoriesByID = Dictionary(uniqueKeysWithValues: index.categories.map { ($0.id, $0) })

        return try index.questions.map { question in
            guard let category = categoriesByID[question.categoryID] else {
                throw InterviewRepositoryError.missingCategory(id: question.categoryID)
            }

            return InterviewQuestionSummary(
                id: question.id,
                title: question.title,
                category: category,
                tags: question.tags,
                markdownPath: question.markdownPath
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

