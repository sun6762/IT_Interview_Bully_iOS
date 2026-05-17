# Method Swizzling 的原理和边界

Method Swizzling 本质上是交换两个 `SEL` 对应的 `IMP`。

## 面试回答思路

1. 说明它依赖 Objective-C Runtime。
2. 解释 `class_getInstanceMethod`、`method_exchangeImplementations` 的作用。
3. 强调它通常用于埋点、兼容修复，而不是常规业务逻辑。

## 示例代码

```swift
import ObjectiveC.runtime

func swizzleExample() {
    guard
        let originalMethod = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.viewDidAppear(_:))),
        let swizzledMethod = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.ib_viewDidAppear(_:)))
    else {
        return
    }

    method_exchangeImplementations(originalMethod, swizzledMethod)
}
```

## 风险点

- 影响全局行为，排查问题成本高。
- 多方同时 swizzle 同一方法时可能互相覆盖。
- 不适用于 Swift 纯值类型方法。

