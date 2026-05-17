import Combine
import XCTest
@testable import IT_Interview_Bully

final class SSInterviewRepositoryTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testFetchQuestionsMapsIndexIntoDomainModels() {
        let repository = makeRepository()
        let expectation = expectation(description: "Fetches mapped questions")
        var receivedQuestions: [SSInterviewQuestionSummary] = []

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
        XCTAssertNotNil(receivedQuestions.first?.category.id)
        XCTAssertTrue(receivedQuestions.first?.markdownPath.contains("sample-question.md") == true)
    }

    func testFetchQuestionDetailLoadsMarkdownContent() {
        let repository = makeRepository()
        let firstQuestionID = fetchFirstQuestionID(from: repository)
        let expectation = expectation(description: "Loads markdown")
        var receivedDetail: SSInterviewQuestionDetail?

        repository.fetchQuestionDetail(id: firstQuestionID)
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
        XCTAssertNotNil(receivedDetail?.title)
        XCTAssertTrue(receivedDetail?.markdownContent.contains("```swift") == true)
    }

    func testMissingMarkdownDirectoryReturnsError() {
        let repository = makeRepository(markdownRootDirectory: "not_exist_markdown_directory")
        let expectation = expectation(description: "Returns missing markdown directory error")

        repository.fetchQuestions()
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTAssertTrue(error.localizedDescription.contains("not_exist_markdown_directory"))
                    expectation.fulfill()
                }
            } receiveValue: { _ in
                XCTFail("Expected failure for missing markdown directory")
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    private func makeRepository(
        indexName: String = "test_interview_index",
        markdownRootDirectory: String = ""
    ) -> SSInterviewRepository {
        let bundle = Bundle(for: Self.self)
        let loader = SSBundleResourceLoader(bundle: bundle, decoder: JSONDecoder(), indexResourceName: indexName)
        return SSBundleInterviewRepository(loader: loader, markdownRootDirectory: markdownRootDirectory)
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
