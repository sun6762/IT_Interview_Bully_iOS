import Highlightr
import MarkdownView
import SnapKit
import UIKit

final class SSMarkdownViewController: UIViewController, SSMarkdownRenderableView {
    private let markdownView = MarkdownView()
    private let highlightr = Highlightr()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        markdownView.isOpaque = false
        markdownView.backgroundColor = .clear
        markdownView.layer.cornerRadius = 14
        markdownView.clipsToBounds = true
        view.addSubview(markdownView)
        markdownView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Keep the highlighting engine instantiated so the scaffold is ready
        // for future custom fenced-code rendering without changing DI shape.
        highlightr?.setTheme(to: "atom-one-light")
    }

    func render(markdown: String) {
        loadViewIfNeeded()
        markdownView.load(markdown: markdown)
    }
}
