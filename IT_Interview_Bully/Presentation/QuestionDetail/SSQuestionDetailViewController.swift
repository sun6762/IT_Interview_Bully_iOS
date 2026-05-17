import Combine
import SnapKit
import UIKit

final class SSQuestionDetailViewController: UIViewController {
    private let question: SSInterviewQuestionSummary
    private let viewModel: SSQuestionDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    private let stateView = SSLoadingStateView()
    private let retryButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let sourcePathLabel = UILabel()
    private let markdownContainer = UIView()
    private let markdownViewController = SSMarkdownViewController()

    init(question: SSInterviewQuestionSummary, viewModel: SSQuestionDetailViewModel) {
        self.question = question
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadIfNeeded()
    }

    private func setupUI() {
        title = question.title
        view.backgroundColor = .secondarySystemBackground

        retryButton.setTitle("Retry", for: .normal)
        retryButton.backgroundColor = .systemBlue
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.layer.cornerRadius = 10
        retryButton.isHidden = true
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        sourcePathLabel.font = .preferredFont(forTextStyle: .footnote)
        sourcePathLabel.textColor = .secondaryLabel
        sourcePathLabel.numberOfLines = 0

        markdownContainer.backgroundColor = .systemBackground
        markdownContainer.layer.cornerRadius = 18
        markdownContainer.layer.masksToBounds = true

        view.addSubview(scrollView)
        view.addSubview(stateView)
        view.addSubview(retryButton)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(sourcePathLabel)
        contentView.addSubview(markdownContainer)

        addChild(markdownViewController)
        markdownContainer.addSubview(markdownViewController.view)
        markdownViewController.didMove(toParent: self)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        sourcePathLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        markdownContainer.snp.makeConstraints { make in
            make.top.equalTo(sourcePathLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(460)
            make.bottom.equalToSuperview().inset(18)
        }

        markdownViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stateView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
        }

        retryButton.snp.makeConstraints { make in
            make.centerX.equalTo(stateView.snp.centerX)
            make.top.equalTo(stateView.snp.centerY).offset(42)
            make.height.equalTo(38)
            make.width.equalTo(120)
        }

        scrollView.isHidden = true
    }

    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state: state)
            }
            .store(in: &cancellables)
    }

    private func render(state: SSLoadableState<SSInterviewQuestionDetail>) {
        retryButton.isHidden = true
        switch state {
        case .idle, .loading:
            stateView.isHidden = false
            stateView.configure(title: "Loading markdown content...", systemImageName: "text.alignleft", tintColor: .systemBlue)
            scrollView.isHidden = true
        case .empty(let message):
            stateView.isHidden = false
            stateView.configure(title: message, systemImageName: "doc.text", tintColor: .systemOrange)
            scrollView.isHidden = true
        case .error(let message):
            stateView.isHidden = false
            stateView.configure(title: message, systemImageName: "exclamationmark.bubble", tintColor: .systemRed)
            retryButton.isHidden = false
            scrollView.isHidden = true
        case .content(let detail):
            titleLabel.text = detail.title
            sourcePathLabel.text = detail.sourcePath
            markdownViewController.render(markdown: detail.markdownContent)
            scrollView.isHidden = false
            stateView.isHidden = true
        }
    }

    @objc private func retryTapped() {
        viewModel.load()
    }
}
