# Agent memory map

This folder is the durable brain for agents working on **flutter_data_kit**.
It is not user documentation.

| File | Read when |
| --- | --- |
| [package.md](package.md) | Starting a task: layout, public API |
| [invariants.md](invariants.md) | Changing mappers, PagedList, exports |
| [decisions.md](decisions.md) | Architecture trade-offs |
| [tasks/](tasks/) | Build / follow-up task order |

## Truth order

1. **Code** in `lib/` and `packages/*/lib/`
2. **This folder**
3. `CHANGELOG.md`
4. `README.md` (humans only)

When code and spec disagree, **fix the spec** after confirming the code is intentional.

## Consumer apps

Agents **using** this package should load `skills/flutter-data-kit/`.
