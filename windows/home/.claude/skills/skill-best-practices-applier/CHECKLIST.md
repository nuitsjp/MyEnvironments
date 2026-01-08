# Skill Quality Checklist

Use this checklist to evaluate skills against best practices.

## Metadata (frontmatter)

- [ ] **name**: Lowercase, hyphens only, max 64 chars, no reserved words (anthropic, claude)
- [ ] **name pattern**: Uses `verb-noun` pattern (e.g., `creating-issues`, `starting-issues`)
- [ ] **description**: Non-empty, max 1024 chars, no XML tags
- [ ] **description content**: Starts with Japanese summary, then "Use when..." with English/Japanese keywords
- [ ] **description voice**: Written in third person (not "I can" or "You can")
- [ ] **allowed-tools**: Only tools actually needed

## SKILL.md Structure (minimize load tokens)

- [ ] **Minimal content**: Only frontmatter + 1-line summary + dynamic commands + resource links
- [ ] **Dynamic commands**: Use `!` prefix for context needed at load time (e.g., `!`git remote -v``)
- [ ] **Resource links**: Use markdown links `[file.md](file.md)` (NOT `@file.md` which causes static load)
- [ ] **Under 30 lines**: Aim for minimal SKILL.md to reduce default load tokens

## Separate Files (on-demand loading)

- [ ] **workflow.md**: Detailed step-by-step procedures
- [ ] **Reference files**: Additional context (CHECKLIST.md, examples.md, etc.)
- [ ] **One level deep**: All references directly from SKILL.md (no nested references)
- [ ] **TOC for long files**: Files over 100 lines should have table of contents

## Content Guidelines

- [ ] **Conciseness**: No explanations Claude already knows
- [ ] **Terminology**: Consistent terms throughout
- [ ] **Concrete examples**: Input/output pairs where helpful
- [ ] **Clear commands**: Use "Run:" prefix for executable commands

## Workflow Best Practices

- [ ] **Checklist format**: Copy-paste checklist at top of workflow
- [ ] **Sequential steps**: Numbered, clear progression
- [ ] **Decision points**: Guide through conditional choices
- [ ] **Next actions**: Offer follow-up skills where appropriate

## Anti-patterns to Avoid

- [ ] No vague descriptions ("helps with documents")
- [ ] No `@file.md` syntax (causes static loading)
- [ ] No deeply nested file references
- [ ] No excessive content in SKILL.md
- [ ] No assumptions about installed packages
