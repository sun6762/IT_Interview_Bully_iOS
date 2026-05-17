import UIKit

final class SSSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let container = SSAppDIContainer()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let viewModel = SSQuestionListViewModel(repository: container.interviewRepository)
        let rootViewController = SSQuestionListViewController(
            viewModel: viewModel,
            detailViewModelFactory: { [container] summary in
                SSQuestionDetailViewModel(questionID: summary.id, repository: container.interviewRepository)
            }
        )

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: rootViewController)
        window.makeKeyAndVisible()
        self.window = window
    }
}
