import Foundation

final class SSAppDIContainer {
    let interviewRepository: SSInterviewRepository

    init(bundle: Bundle = .main) {
        let loader = SSBundleResourceLoader(bundle: bundle)
        self.interviewRepository = SSBundleInterviewRepository(loader: loader)
    }
}
