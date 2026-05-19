---
status: review
artifact: mesh avatar 3x1 cover candidates
source_avatars:
  - assets/mesh-alex-avatar.png
  - assets/mesh-ivanov-avatar.jpg
contact_sheet: assets/mesh-avatar-format-contact-sheet.png
format: 1800x600 PNG + SVG
created_by: CODEX
created_at: 2026-05-19
---

# mesh avatar cover candidates · 3:1

Задача: отдельный сет для второго поста про mesh. Не event-cover и не robot-poster, а визуальный артефакт про сам процесс: два агента/голоса, две карточки с аватарками, линии данных, реальные counters из текущего run.

## процесс

1. Взял текущие аватарки `alex-avatar.png` и `ivanov-avatar.jpg`, положил локальные копии рядом с SVG в `assets/`.
2. Прочитал `paragraphs/index.json`, чтобы взять текущую telemetry: paragraph count, split SHAPER/IVANOV, latest/next.
3. Собрал 5 вариантов в одном стиле: white surface, thin frames, large black type, red data-lines, avatar cards.
4. Отрендерил PNG и contact sheet для согласования.

## варианты

| № | Файл | Роль |
|---|---|---|
| 01 | `assets/mesh-avatar-format-01-communication-graph-3x1.png` | главный mesh-cover: два агента, две линии обмена, Murmur + Git |
| 02 | `assets/mesh-avatar-format-02-revision-line-3x1.png` | revision loop: цепочка c1–c12, raw text collapsed, reactions visible |
| 03 | `assets/mesh-avatar-format-03-data-stack-3x1.png` | stack-cover: murmur + git + netlify как слои системы |
| 04 | `assets/mesh-avatar-format-04-sidecar-review-3x1.png` | sidecar-review: комментарии рядом с paragraph, не в чате |
| 05 | `assets/mesh-avatar-format-05-live-telemetry-3x1.png` | live telemetry: два агента и один public artifact |

## recommendation

Для второго поста про mesh я бы выбирал **01** как самый понятный public cover.

Если хочется более продуктово и конкретно — **02**.

Если нужен технический стек без лишней поэзии — **03**.
