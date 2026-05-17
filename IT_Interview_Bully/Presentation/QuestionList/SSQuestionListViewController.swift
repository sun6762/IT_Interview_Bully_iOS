import Combine
import SnapKit
import UIKit

final class SSQuestionListViewController: UIViewController {
    private let viewModel: SSQuestionListViewModel
    private let detailViewModelFactory: (SSInterviewQuestionSummary) -> SSQuestionDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    private var currentQuestions: [SSInterviewQuestionSummary] = []

    private let categoryScrollView = UIScrollView()
    private let categoryStackView = UIStackView()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let stateView = SSLoadingStateView()
    private let retryButton = UIButton(type: .system)
    private var categoryIDsByButtonTag: [Int: String?] = [:]

    init(
        viewModel: SSQuestionListViewModel,
        detailViewModelFactory: @escaping (SSInterviewQuestionSummary) -> SSQuestionDetailViewModel
    ) {
        self.viewModel = viewModel
        self.detailViewModelFactory = detailViewModelFactory
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
        title = "IT面吧"
        view.backgroundColor = .systemBackground

        categoryStackView.axis = .horizontal
        categoryStackView.alignment = .fill
        categoryStackView.spacing = 10

        categoryScrollView.showsHorizontalScrollIndicator = false
        categoryScrollView.addSubview(categoryStackView)

        tableView.dataSource = self
        tableView.delegate = self

        retryButton.setTitle("Retry", for: .normal)
        retryButton.backgroundColor = .systemBlue
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.layer.cornerRadius = 10
        retryButton.isHidden = true
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        view.addSubview(categoryScrollView)
        view.addSubview(tableView)
        view.addSubview(stateView)
        view.addSubview(retryButton)

        categoryScrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
        }

        categoryStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            make.height.equalToSuperview().offset(-16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(categoryScrollView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        stateView.snp.makeConstraints { make in
            make.edges.equalTo(tableView)
        }

        retryButton.snp.makeConstraints { make in
            make.centerX.equalTo(stateView.snp.centerX)
            make.top.equalTo(stateView.snp.centerY).offset(42)
            make.height.equalTo(38)
            make.width.equalTo(120)
        }
    }

    private func bindViewModel() {
        // Keep all UI state transitions on main queue for deterministic UIKit updates.
        viewModel.$categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories in
                self?.renderCategoryButtons(categories: categories)
            }
            .store(in: &cancellables)

        viewModel.$selectedCategoryID
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshCategoryButtonStyles()
            }
            .store(in: &cancellables)

        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state: state)
            }
            .store(in: &cancellables)
    }

    private func render(state: SSLoadableState<[SSInterviewQuestionSummary]>) {
        // Single state renderer: loading / empty / error / content.
        retryButton.isHidden = true
        switch state {
        case .idle, .loading:
            stateView.isHidden = false
            stateView.configure(title: "Loading interview topics...", systemImageName: "doc.text.magnifyingglass", tintColor: .systemBlue)
            tableView.isHidden = true
        case .empty(let message):
            stateView.isHidden = false
            stateView.configure(title: message, systemImageName: "tray", tintColor: .systemOrange)
            tableView.isHidden = true
        case .error(let message):
            stateView.isHidden = false
            stateView.configure(title: message, systemImageName: "exclamationmark.triangle", tintColor: .systemRed)
            tableView.isHidden = true
            retryButton.isHidden = false
        case .content(let questions):
            currentQuestions = questions
            tableView.reloadData()
            tableView.isHidden = false
            stateView.isHidden = true
        }
    }

    private func renderCategoryButtons(categories: [SSInterviewCategory]) {
        categoryIDsByButtonTag.removeAll()
        categoryStackView.arrangedSubviews.forEach {
            categoryStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        categoryStackView.addArrangedSubview(makeCategoryButton(title: "All", id: nil))
        categories.forEach { category in
            categoryStackView.addArrangedSubview(makeCategoryButton(title: category.title, id: category.id))
        }
        refreshCategoryButtonStyles()
    }

    private func makeCategoryButton(title: String, id: String?) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 14
        button.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        button.tag = categoryIDsByButtonTag.count + 1
        categoryIDsByButtonTag[button.tag] = id
        button.accessibilityIdentifier = id ?? "all"
        button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        return button
    }

    private func refreshCategoryButtonStyles() {
        categoryStackView.arrangedSubviews.compactMap { $0 as? UIButton }.forEach { button in
            let buttonID = button.accessibilityIdentifier == "all" ? nil : button.accessibilityIdentifier
            let isSelected = viewModel.selectedCategoryID == buttonID
            button.backgroundColor = isSelected ? .systemBlue : UIColor.systemBlue.withAlphaComponent(0.12)
            button.setTitleColor(isSelected ? .white : .systemBlue, for: .normal)
        }
    }

    @objc private func retryTapped() {
        viewModel.load()
    }

    @objc private func categoryButtonTapped(_ sender: UIButton) {
        let id = categoryIDsByButtonTag[sender.tag] ?? nil
        viewModel.selectCategory(id: id)
    }
}

extension SSQuestionListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentQuestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "question_cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "question_cell")
        let question = currentQuestions[indexPath.row]
        cell.textLabel?.text = question.title
        cell.detailTextLabel?.text = question.category.title
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let question = currentQuestions[indexPath.row]
        let viewModel = detailViewModelFactory(question)
        let detailVC = SSQuestionDetailViewController(question: question, viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
