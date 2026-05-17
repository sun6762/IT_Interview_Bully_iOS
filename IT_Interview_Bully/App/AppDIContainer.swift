import Foundation

final class AppDIContainer {
    let interviewRepository: InterviewRepository

    init(bundle: Bundle = .main) {
        let loader = BundleResourceLoader(bundle: bundle)
        self.interviewRepository = BundleInterviewRepository(loader: loader)
    }
}

