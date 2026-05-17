# Code Style

Canonical reference moved to:
- `docs/DEVELOPMENT_RULES.md`
- `docs/PERFORMANCE_PLAYBOOK.md`

## Swift

- Use `final` for concrete classes unless inheritance is required.
- Keep one primary type per file.
- Group files by responsibility: `App`, `Presentation`, `ViewModels`, `Domain`, `Data`, `Resources`.
- Prefer `struct` for immutable models and `enum` for finite state.
- Keep view logic in SwiftUI views and state transitions in `ViewModel`.
- Keep data loading in `Repository` and `Service` layers.

## Formatting

- Use 4 spaces for indentation.
- Keep line length under 120 characters when practical.
- Add blank lines between logical blocks, not after every statement.
- Use explicit access control when the boundary matters.

## Naming

- Types use `UpperCamelCase`.
- Properties, methods, and enum cases use `lowerCamelCase`.
- Suffix view models with `ViewModel` and repositories with `Repository`.
- Name Markdown resource files by topic, not by page order.

## Project Structure

- Put UIKit bridge code under `Presentation/Common/Markdown`.
- Put resource fixtures for tests under `IT_Interview_BullyTests/Fixtures`.
- Keep sample content under `Resources/markdown`.

## Objective-C

- Follow `.clang-format`.
- Use nullability annotations and lightweight generics.
- Prefer explicit ownership attributes on properties.

## Performance

- Avoid potential retain cycles in closures/delegates/timers.
- Watch offscreen rendering hotspots (`cornerRadius + masksToBounds + shadow`).
- Profile with Instruments before merging rendering-heavy changes.
