import Combine
import Foundation

protocol SSInterviewRepository {
    func fetchCategories() -> AnyPublisher<[SSInterviewCategory], Error>
    func fetchQuestions() -> AnyPublisher<[SSInterviewQuestionSummary], Error>
    func fetchQuestionDetail(id: String) -> AnyPublisher<SSInterviewQuestionDetail, Error>
}
