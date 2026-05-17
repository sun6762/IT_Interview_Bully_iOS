# iOS Development Rules

This document defines local development rules for this project without CI enforcement.

## 1. Architecture Rules

- Keep layers explicit:
  - `Presentation`: UI and user interaction only
  - `ViewModels`: state transition and UI-facing orchestration
  - `Domain`: models and repository protocols
  - `Data`: repository implementations and data loading
- Do not call `Data` layer directly from SwiftUI views.
- Keep one primary type per file.

## 2. Swift Code Rules

- Use `final` for concrete classes unless inheritance is required.
- Prefer value types (`struct`, `enum`) for models and states.
- Use `weak self` in escaping closures when self ownership is not required.
- Keep functions focused:
  - warning threshold: 40 lines
  - error threshold: 70 lines
- Keep line length under 120 characters when practical.
- Handle failure paths explicitly. Avoid silent catch blocks.

## 3. Objective-C Code Rules

- Format Objective-C code with `.clang-format`.
- Use nullability annotations (`NS_ASSUME_NONNULL_BEGIN/END`, `nullable`, `nonnull`).
- Use lightweight generics (`NSArray<NSString *> *`) where applicable.
- Prefer `copy` for block and NSString properties.
- Mark overridden or unavailable APIs with explicit macros/attributes.
- Avoid category method name collisions by using a clear prefix.

## 4. Memory & Lifecycle Safety Rules

- Any long-lived closure must justify capture strategy (`[weak self]` or ownership comment).
- Remove observers/timers/display links in lifecycle deinit/cleanup path.
- Delegate references should be `weak` unless ownership is intentional.
- Avoid retaining view/controller inside repository or service layer.
- Use Xcode Memory Graph before merging medium/large features.

## 5. Rendering & Performance Rules

- Avoid rounded corners + masks + shadow on the same layer without profiling.
- If `shouldRasterize = true`, always set `rasterizationScale = UIScreen.main.scale`.
- Keep image decoding off main thread for large assets where possible.
- Avoid creating heavy formatters repeatedly in hot paths.
- Avoid unnecessary view hierarchy depth and repeated layout invalidation.

## 6. Local Enforcement

Install required local tools once:

```bash
./scripts/bootstrap_dev_tools.sh
```

Run before merge:

```bash
./scripts/local_quality_gate.sh
```

Optional pre-commit hook:

```bash
./scripts/install_git_hooks.sh
```

## 7. Review Checklist (Must-pass)

- No obvious retain cycle path in new code.
- No newly introduced offscreen rendering hotspots without reason.
- No cross-layer architectural violation.
- Swift and Objective-C formatting rules pass locally.
- New feature includes at least one test or an explicit testing note.
