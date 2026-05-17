import Highlightr
import MarkdownView
import UIKit

final class MarkdownViewController: UIViewController, MarkdownRenderableView {
    private let markdownView = MarkdownView()
    private let highlightr = Highlightr()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        markdownView.translatesAutoresizingMaskIntoConstraints = false
        markdownView.isOpaque = false
        markdownView.backgroundColor = .clear
        markdownView.layer.cornerRadius = 14
        markdownView.clipsToBounds = true
        view.addSubview(markdownView)

        NSLayoutConstraint.activate([
            markdownView.topAnchor.constraint(equalTo: view.topAnchor),
            markdownView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            markdownView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            markdownView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Keep the highlighting engine instantiated so the scaffold is ready
        // for future custom fenced-code rendering without changing DI shape.
        highlightr?.setTheme(to: "atom-one-light")
    }

    func render(markdown: String) {
        loadViewIfNeeded()
        markdownView.load(markdown: markdown)
    }
}
