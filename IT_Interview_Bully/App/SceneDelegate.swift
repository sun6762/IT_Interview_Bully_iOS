import SwiftUI
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let container = AppDIContainer()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let rootView = QuestionListView(
            viewModel: QuestionListViewModel(repository: container.interviewRepository),
            detailViewModelFactory: { [container] summary in
                QuestionDetailViewModel(questionID: summary.id, repository: container.interviewRepository)
            }
        )

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: rootView)
        window.makeKeyAndVisible()
        self.window = window
    }
}
