# IT面吧（IT_Interview_Bully_iOS）

一个基于 **UIKit + Combine + MVVM** 的 iOS 面试题学习 App。  
题库内容来自项目内 Markdown 文件，支持按目录分组展示与详情阅读。

## 快速开始

### 环境要求

- Xcode 15+
- CocoaPods
- iOS 13.0+

### 运行步骤

1. 安装依赖：

   ```bash
   pod install
   ```

2. 使用 `IT_Interview_Bully.xcworkspace` 打开项目。
3. 选择模拟器并运行 `IT_Interview_Bully` target。

## App 简单使用

1. 首页按题库目录自动展示分类与题目列表。
2. 点击任意题目进入详情页，阅读对应 Markdown 内容（含代码块）。
3. 顶部分类可快速筛选专题题目。

## 知识库位置

题库核心目录：

`IT_Interview_Bully/Resources/markdown/iOS面试资深解答`

当前实现会从该目录读取内容并展示到首页。

## 如何补充题目与答案（给 iOS 开发者）

### 最简流程

1. 在 `iOS面试资深解答` 下按专题建目录（例如 `7.网络`、`8.架构设计`）。
2. 在目录内新增 `.md` 文件（一个文件可对应一个问题，或一个专题的多问题）。
3. 重新运行 App，首页会自动按目录结构加载新内容。

### 推荐写法（稳定渲染）

文件名即题目，例如：`7.1 HTTPS 握手过程.md`  
文档结构建议如下：

~~~md
# 7.1 HTTPS 握手过程

## Q1. HTTPS 握手核心流程？
先给结论，再分步骤说明。

### 代码示例
```swift
func example() {
    print("Hello HTTPS")
}
```

### 追问点
- 追问 1
- 追问 2

### 反问点
- 反问 1
- 反问 2
~~~

### 注意事项

- 文件编码使用 UTF-8。
- 保持 `.md` 扩展名。
- 尽量避免重名文件（便于定位与维护）。

## 项目结构（简版）

- `IT_Interview_Bully/App`：应用入口、DI 组装
- `IT_Interview_Bully/Presentation`：UIKit 页面与组件
- `IT_Interview_Bully/ViewModels`：MVVM 视图模型（Combine 状态流）
- `IT_Interview_Bully/Data`：本地 Markdown 读取与仓储实现
- `IT_Interview_Bully/Resources/markdown`：题库 Markdown 资源

## 常见问题

### 新加了 Markdown，但首页没显示？

请检查：

1. 文件是否放在 `iOS面试资深解答` 目录内。
2. 是否是 `.md` 文件。
3. 是否重新 Build/Run 了最新工程。

---

欢迎直接提 PR 持续补充题库内容，一起把这套 iOS 面试知识库做成团队可复用的学习资产。
