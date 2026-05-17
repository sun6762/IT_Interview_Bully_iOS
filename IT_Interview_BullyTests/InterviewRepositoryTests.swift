import Combine
import XCTest
@testable import IT_Interview_Bully

final class InterviewRepositoryTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testFetchQuestionsMapsIndexIntoDomainModels() {
        let repository = makeRepository()
        let expectation = expectation(description: "Fetches mapped questions")
        var receivedQuestions: [InterviewQuestionSummary] = []

        repository.fetchQuestions()
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, got error: \(error)")
                }
            } receiveValue: { questions in
                receivedQuestions = questions
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedQuestions.count, 1)
        XCTAssertEqual(receivedQuestions.first?.category.id, "runtime")
        XCTAssertEqual(receivedQuestions.first?.markdownPath, "markdown/sample-question.md")
    }

    func testFetchQuestionDetailLoadsMarkdownContent() {
        let repository = makeRepository()
        let expectation = expectation(description: "Loads markdown")
        var receivedDetail: InterviewQuestionDetail?

        repository.fetchQuestionDetail(id: "sample")
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, got error: \(error)")
                }
            } receiveValue: { detail in
                receivedDetail = detail
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedDetail?.title, "Sample Question")
        XCTAssertTrue(receivedDetail?.markdownContent.contains("```swift") == true)
    }

    func testMissingMarkdownPathReturnsError() {
        let repository = makeRepository(indexName: "invalid_interview_index")
        let expectation = expectation(description: "Returns missing markdown error")

        repository.fetchQuestionDetail(id: "broken")
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTAssertTrue(error.localizedDescription.contains("missing-file.md"))
                    expectation.fulfill()
                }
            } receiveValue: { _ in
                XCTFail("Expected failure for missing markdown file")
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    private func makeRepository(indexName: String = "test_interview_index") -> InterviewRepository {
        let bundle = Bundle(for: Self.self)
        let loader = BundleResourceLoader(bundle: bundle, decoder: JSONDecoder(), indexResourceName: indexName)
        return BundleInterviewRepository(loader: loader)
    }
}
