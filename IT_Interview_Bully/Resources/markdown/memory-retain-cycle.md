# 循环引用排查方法

循环引用通常来自两个对象之间都持有强引用。

## 常见场景

- `delegate` 没有用 `weak`
- `closure` 捕获了 `self`
- 定时器、`CADisplayLink`、`NotificationCenter` 没有正确释放

## 示例代码

```swift
final class InterviewViewModel {
    var onUpdate: (() -> Void)?

    func start() {
        onUpdate = { [weak self] in
            self?.refresh()
        }
    }

    private func refresh() {}
}
```

## 排查手段

1. 使用 Xcode Memory Graph 看对象引用链。
2. 使用 Instruments 的 Leaks/Allocations 观察释放情况。
3. 对生命周期关键点打日志，确认 `deinit` 是否执行。

