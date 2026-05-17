import SwiftUI

struct QuestionDetailView: View {
    let question: InterviewQuestionSummary
    @ObservedObject var viewModel: QuestionDetailViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                LoadingStateView(title: "Loading markdown content...", systemImageName: "text.alignleft", tintColor: .blue)
            case .empty(let message):
                LoadingStateView(title: message, systemImageName: "doc.text", tintColor: .orange)
            case .error(let message):
                VStack(spacing: 16) {
                    LoadingStateView(title: message, systemImageName: "exclamationmark.bubble", tintColor: .red)
                    Button("Retry") {
                        viewModel.load()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            case .content(let detail):
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(detail.title)
                                .font(.title)
                                .fontWeight(.bold)
                            Text(detail.sourcePath)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        MarkdownViewContainer(markdown: detail.markdownContent)
                            .frame(minHeight: 460)
                            .background(Color(.systemBackground))
                            .cornerRadius(18)
                    }
                    .padding(16)
                }
                .background(Color(.secondarySystemBackground))
            }
        }
        .navigationBarTitle(Text(question.title), displayMode: .inline)
        .onAppear {
            viewModel.loadIfNeeded()
        }
    }
}
