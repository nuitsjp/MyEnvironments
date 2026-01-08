---
name: skill-best-practices-applier
description: Applies best practices to Skills (スキルにベストプラクティスを適用). Use when improving skills (スキル改善), reviewing skill quality (品質レビュー), or refactoring skills (リファクタリング).
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion, WebFetch
---

# Skill Best Practices Applier

## Quick start

Fetch latest best practices, analyze a skill, and apply improvements.

## Workflow

Copy this checklist and track progress:

```
- [ ] Step 1: Fetch best practices
- [ ] Step 2: Select skill to improve
- [ ] Step 3: Analyze against checklist
- [ ] Step 4: Report findings
- [ ] Step 5: Apply improvements
```

### Step 1: Fetch best practices

Fetch the latest best practices from official documentation:

```
WebFetch: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md
```

### Step 2: Select skill to improve

- If `$1` is provided: Use that skill path
- Otherwise: Use `AskUserQuestion` to select from available skills

### Step 3: Analyze against checklist

Read the skill's SKILL.md and check against [CHECKLIST.md](CHECKLIST.md).

**Important**: Also verify the description includes:
- Keywords in both English AND Japanese (日本語)
- WHAT it does + WHEN to use it (in both languages)

### Step 4: Report findings

Present findings to user:
- Items that pass
- Items that need improvement (with specific suggestions)
- Missing bilingual keywords in description

### Step 5: Apply improvements

Use `AskUserQuestion` to ask "Apply these improvements?":
- **Yes**: Edit the SKILL.md to fix issues
- **No**: Done
