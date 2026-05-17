import Combine
import Foundation

protocol InterviewRepository {
    func fetchCategories() -> AnyPublisher<[InterviewCategory], Error>
    func fetchQuestions() -> AnyPublisher<[InterviewQuestionSummary], Error>
    func fetchQuestionDetail(id: String) -> AnyPublisher<InterviewQuestionDetail, Error>
}

