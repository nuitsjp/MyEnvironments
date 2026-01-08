---
name: issue-creator
description: Creates GitHub Issues interactively. Use when creating an issue, reporting a bug, requesting a feature, or improving documentation.
allowed-tools: Bash(git remote:*), Bash(gh issue create:*), AskUserQuestion, Skill
---

# Issue Creator

## Quick start

Select issue type, gather information, and run `gh issue create`.

## Repository info

!`git remote -v`

## Workflow

Copy this checklist and track progress:

```
- [ ] Step 1: Select issue type
- [ ] Step 2: Gather information
- [ ] Step 3: Create issue
- [ ] Step 4: Offer next action
```

### Step 1: Select issue type

Use `AskUserQuestion` to ask which type:
- **bug**: Bug report (errors, unexpected behavior)
- **enhancement**: Feature request (new features, improvements)
- **documentation**: Docs (typos, missing info)
- **question**: Questions (usage, design)

### Step 2: Gather information

Use `AskUserQuestion` to collect info based on type:

| Type | Required info |
|------|---------------|
| bug | Title, steps to reproduce, expected vs actual behavior |
| enhancement | Title, purpose, proposed solution |
| documentation | Title, target page, current problem, improvement |
| question | Title, details, context |

### Step 3: Create issue

Run: `gh issue create --title "title" --body "body" --label "type"`

Display the created issue URL.

### Step 4: Offer next action

Use `AskUserQuestion` to ask "Start working on this issue?":
- **Yes**: Use `Skill` tool to invoke `issue-starter` with the issue number
- **No**: Done
