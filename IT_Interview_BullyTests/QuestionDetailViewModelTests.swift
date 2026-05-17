import Combine
import XCTest
@testable import IT_Interview_Bully

final class SSQuestionDetailViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testLoadTransitionsToContentForValidMarkdown() {
        let repository = makeRepository()
        let questionID = fetchFirstQuestionID(from: repository)
        let viewModel = SSQuestionDetailViewModel(questionID: questionID, repository: repository)
        let expectation = expectation(description: "Receives terminal state")

        viewModel.$state
            .sink { state in
                if case .content(let detail) = state {
                    XCTAssertFalse(detail.id.isEmpty)
                    expectation.fulfill()
                } else if case .error(let message) = state {
                    XCTFail("Expected content, got error: \(message)")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.load()

        wait(for: [expectation], timeout: 1.0)
    }

    private func makeRepository() -> SSInterviewRepository {
        let loader = SSBundleResourceLoader(bundle: Bundle(for: Self.self), indexResourceName: "test_interview_index")
        return SSBundleInterviewRepository(loader: loader, markdownRootDirectory: "")
    }

    private func fetchFirstQuestionID(from repository: SSInterviewRepository) -> String {
        let expectation = expectation(description: "Fetch first question id")
        var questionID: String?
        repository.fetchQuestions()
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, got error: \(error)")
                }
            } receiveValue: { questions in
                questionID = questions.first?.id
                expectation.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1.0)
        return questionID ?? ""
    }
}
