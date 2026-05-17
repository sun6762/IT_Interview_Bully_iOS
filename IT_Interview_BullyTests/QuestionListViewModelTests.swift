import Combine
import XCTest
@testable import IT_Interview_Bully

final class SSQuestionListViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testLoadTransitionsToContent() {
        let viewModel = SSQuestionListViewModel(repository: makeRepository())
        let expectation = expectation(description: "Receives content state")

        viewModel.$state
            .dropFirst(2)
            .sink { state in
                if case .content(let questions) = state {
                    XCTAssertEqual(questions.count, 1)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.load()
        wait(for: [expectation], timeout: 1.0)
    }

    func testSelectCategoryFiltersResults() {
        let viewModel = SSQuestionListViewModel(repository: makeRepository())
        let loadedExpectation = expectation(description: "Loaded categories")
        let filteredExpectation = expectation(description: "Receives filtered content")
        var observedContentCount: Int?
        var selectedID: String = ""

        viewModel.$state
            .sink { state in
                if case .content(let questions) = state {
                    observedContentCount = questions.count
                    if viewModel.selectedCategoryID == selectedID, !selectedID.isEmpty {
                        filteredExpectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)

        viewModel.$categories
            .sink { categories in
                if let firstID = categories.first?.id, !firstID.isEmpty {
                    selectedID = firstID
                    loadedExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.load()
        wait(for: [loadedExpectation], timeout: 1.0)
        viewModel.selectCategory(id: selectedID)
        wait(for: [filteredExpectation], timeout: 1.0)
        XCTAssertEqual(observedContentCount, 1)
    }

    private func makeRepository() -> SSInterviewRepository {
        let loader = SSBundleResourceLoader(bundle: Bundle(for: Self.self), indexResourceName: "test_interview_index")
        return SSBundleInterviewRepository(loader: loader, markdownRootDirectory: "")
    }
}
