# Performance & Leak Playbook

## 1. Memory Leak Prevention Baseline

- Verify closures in:
  - async callbacks
  - publisher/subscriber chains
  - timer/display link callbacks
- Verify ownership in:
  - delegate relationships
  - view model to view/controller references
  - notification observers

### Quick Commands

```bash
./scripts/performance_guard.sh
```

This script is heuristic-only and does not replace Instruments.

## 2. Instruments Checklist

Use this sequence for medium/large changes:

1. Launch with `Product > Profile`
2. Run `Leaks` for at least one full user flow
3. Run `Allocations` and repeat push/pop flow 3 times
4. Confirm object count stabilizes after pop/dismiss
5. Capture one screenshot of suspicious retaining chain if found

## 3. Offscreen Rendering Checklist

Review these patterns in changed views:

- `cornerRadius + masksToBounds + shadow*`
- frequent `clipsToBounds` on complex hierarchies
- nested blur/vibrancy layers
- heavy gradient layers in scrolling containers

When optimization is needed:

- precompose static effects
- use plain backgrounds when possible
- cache rendered content intentionally and profile before/after

## 4. Runtime Hotspots Checklist

- Repeated formatter creation inside `cellForRow`/`body` recomposition
- Main-thread JSON parsing for large payloads
- Synchronous disk I/O on main thread
- Unbounded image size rendering

## 5. Merge Gate for Performance-sensitive PRs

- `local_quality_gate.sh` passes
- no unresolved leak suspicion
- if touching rendering-heavy screen: provide before/after observation note

