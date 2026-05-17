import Foundation
import UIKit

protocol SSMarkdownRenderableView where Self: UIViewController {
    func render(markdown: String)
}
