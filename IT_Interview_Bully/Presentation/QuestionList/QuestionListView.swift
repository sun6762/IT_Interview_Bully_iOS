import SwiftUI

struct QuestionListView: View {
    @ObservedObject var viewModel: QuestionListViewModel
    let detailViewModelFactory: (InterviewQuestionSummary) -> QuestionDetailViewModel

    var body: some View {
        NavigationView {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    LoadingStateView(title: "Loading interview topics...", systemImageName: "doc.text.magnifyingglass", tintColor: .blue)
                case .empty(let message):
                    LoadingStateView(title: message, systemImageName: "tray", tintColor: .orange)
                case .error(let message):
                    VStack(spacing: 16) {
                        LoadingStateView(title: message, systemImageName: "exclamationmark.triangle", tintColor: .red)
                        Button("Retry") {
                            viewModel.load()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                case .content(let questions):
                    VStack(spacing: 0) {
                        categoryBar
                        List(questions) { question in
                            NavigationLink(
                                destination: QuestionDetailView(
                                    question: question,
                                    viewModel: detailViewModelFactory(question)
                                )
                            ) {
                                QuestionRowView(question: question)
                            }
                        }
                        .listStyle(GroupedListStyle())
                    }
                    .background(Color(.secondarySystemBackground))
                }
            }
            .navigationBarTitle("Interview Bully", displayMode: .large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.loadIfNeeded()
        }
    }

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                categoryButton(title: "All", isSelected: viewModel.selectedCategoryID == nil) {
                    viewModel.selectCategory(id: nil)
                }

                ForEach(viewModel.categories) { category in
                    categoryButton(title: category.title, isSelected: viewModel.selectedCategoryID == category.id) {
                        viewModel.selectCategory(id: category.id)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }

    private func categoryButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.blue.opacity(0.12))
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct QuestionRowView: View {
    let question: InterviewQuestionSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question.title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(question.category.title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if !question.tags.isEmpty {
                Text(question.tags.map { "#\($0)" }.joined(separator: "  "))
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}

