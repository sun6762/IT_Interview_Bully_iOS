import Combine
import XCTest
@testable import IT_Interview_Bully

final class QuestionDetailViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testLoadTransitionsToContentForValidMarkdown() {
        let repository = makeRepository()
        let viewModel = QuestionDetailViewModel(questionID: "sample", repository: repository)
        let expectation = expectation(description: "Receives content state")

        viewModel.$state
            .dropFirst(2)
            .sink { state in
                if case .content(let detail) = state {
                    XCTAssertEqual(detail.id, "sample")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.load()

        wait(for: [expectation], timeout: 1.0)
    }

    private func makeRepository() -> InterviewRepository {
        let loader = BundleResourceLoader(bundle: Bundle(for: Self.self), indexResourceName: "test_interview_index")
        return BundleInterviewRepository(loader: loader)
    }
}
