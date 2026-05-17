import SwiftUI

struct MarkdownViewContainer: UIViewControllerRepresentable {
    let markdown: String

    func makeUIViewController(context: Context) -> MarkdownViewController {
        let controller = MarkdownViewController()
        controller.render(markdown: markdown)
        return controller
    }

    func updateUIViewController(_ uiViewController: MarkdownViewController, context: Context) {
        uiViewController.render(markdown: markdown)
    }
}

