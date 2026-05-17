import Foundation
import UIKit

protocol MarkdownRenderableView where Self: UIViewController {
    func render(markdown: String)
}

