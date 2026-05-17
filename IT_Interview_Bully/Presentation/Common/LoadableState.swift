import Foundation

enum SSLoadableState<Value> {
    case idle
    case loading
    case empty(message: String)
    case content(Value)
    case error(message: String)
}
