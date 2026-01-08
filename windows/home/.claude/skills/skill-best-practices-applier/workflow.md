# Skill Best Practices Workflow

```
- [ ] Step 1: Select skill to improve
- [ ] Step 2: Analyze current structure
- [ ] Step 3: Check against checklist
- [ ] Step 4: Report findings
- [ ] Step 5: Apply improvements
```

## Step 1: Select skill to improve

- If `$1` is provided: Use that skill path
- Otherwise: Use `AskUserQuestion` to select from available skills in `.claude/skills/`

## Step 2: Analyze current structure

Read the skill's files and note:
- Current SKILL.md line count
- Whether workflow is separated
- Reference syntax used (`@` vs markdown links)

## Step 3: Check against checklist

Evaluate against [CHECKLIST.md](CHECKLIST.md), focusing on:

**Critical items**:
- SKILL.md under 30 lines
- Markdown links (not `@` syntax)
- Workflow in separate file
- Bilingual description

## Step 4: Report findings

Present to user:
- Current line count vs target (<30 lines)
- Items that pass
- Items needing improvement (with specific fixes)

## Step 5: Apply improvements

Use `AskUserQuestion` to confirm, then:
1. Create workflow.md if needed
2. Simplify SKILL.md to minimal structure
3. Convert `@` references to markdown links
4. Update description with bilingual keywords
