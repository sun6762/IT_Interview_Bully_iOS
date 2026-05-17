import Combine
import Foundation

final class QuestionListViewModel: ObservableObject {
    @Published private(set) var state: LoadableState<[InterviewQuestionSummary]> = .idle
    @Published private(set) var categories: [InterviewCategory] = []
    @Published private(set) var selectedCategoryID: String?

    private let repository: InterviewRepository
    private var cancellables = Set<AnyCancellable>()
    private var hasLoaded = false
    private var allQuestions: [InterviewQuestionSummary] = []

    init(repository: InterviewRepository) {
        self.repository = repository
    }

    func loadIfNeeded() {
        guard !hasLoaded else {
            return
        }
        load()
    }

    func load() {
        hasLoaded = true
        state = .loading

        Publishers.Zip(repository.fetchCategories(), repository.fetchQuestions())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else {
                    return
                }
                self?.state = .error(message: error.localizedDescription)
            } receiveValue: { [weak self] categories, questions in
                guard let self = self else {
                    return
                }

                self.categories = categories
                self.allQuestions = questions
                self.applyFilter()
            }
            .store(in: &cancellables)
    }

    func selectCategory(id: String?) {
        selectedCategoryID = id
        applyFilter()
    }

    private func applyFilter() {
        let filteredQuestions = allQuestions.filter { question in
            guard let selectedCategoryID else {
                return true
            }
            return question.category.id == selectedCategoryID
        }

        if filteredQuestions.isEmpty {
            state = .empty(message: "No interview questions are available for this category yet.")
        } else {
            state = .content(filteredQuestions)
        }
    }
}

