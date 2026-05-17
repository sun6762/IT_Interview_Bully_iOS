import Combine
import Foundation

final class QuestionDetailViewModel: ObservableObject {
    @Published private(set) var state: LoadableState<InterviewQuestionDetail> = .idle

    private let questionID: String
    private let repository: InterviewRepository
    private var cancellables = Set<AnyCancellable>()
    private var hasLoaded = false

    init(questionID: String, repository: InterviewRepository) {
        self.questionID = questionID
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

        repository.fetchQuestionDetail(id: questionID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else {
                    return
                }
                self?.state = .error(message: error.localizedDescription)
            } receiveValue: { [weak self] detail in
                guard let self = self else {
                    return
                }

                if detail.markdownContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.state = .empty(message: "The markdown document is empty.")
                } else {
                    self.state = .content(detail)
                }
            }
            .store(in: &cancellables)
    }
}

