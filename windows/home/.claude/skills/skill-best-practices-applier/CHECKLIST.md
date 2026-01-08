# Skill Quality Checklist

Use this checklist to evaluate skills against best practices.

## Metadata

- [ ] **Name**: Lowercase, hyphens only, max 64 chars, no reserved words (anthropic, claude)
- [ ] **Name pattern**: Uses `noun-verb` pattern (e.g., `skill-creator`, `pr-creator`)
- [ ] **Description**: Non-empty, max 1024 chars, no XML tags
- [ ] **Description content**: Includes WHAT it does AND WHEN to use it
- [ ] **Description keywords**: Contains both English AND Japanese (日本語) keywords
- [ ] **Description voice**: Written in third person (not "I can" or "You can")

## Structure

- [ ] **SKILL.md length**: Under 500 lines
- [ ] **Quick start**: Has concise overview section
- [ ] **Workflow**: Uses checklist format for multi-step tasks
- [ ] **Progressive disclosure**: Complex details in separate files
- [ ] **Reference depth**: All references one level deep from SKILL.md
- [ ] **Table of contents**: Long reference files (100+ lines) have TOC

## Content

- [ ] **Conciseness**: No unnecessary explanations Claude already knows
- [ ] **Terminology**: Consistent terms throughout (not mixing synonyms)
- [ ] **Time-sensitive info**: None, or in "old patterns" section
- [ ] **Examples**: Concrete input/output pairs where helpful

## Paths and Scripts

- [ ] **Path format**: Uses forward slashes only (no backslashes)
- [ ] **Script execution**: Clear "Run:" prefix for commands
- [ ] **Error handling**: Scripts handle errors, don't punt to Claude
- [ ] **Dependencies**: Required packages listed

## Workflows

- [ ] **Clear steps**: Sequential, numbered steps
- [ ] **Decision points**: Conditional workflows guide Claude through choices
- [ ] **Feedback loops**: Validation steps for critical operations
- [ ] **Degrees of freedom**: Appropriate specificity for task fragility

## Anti-patterns to avoid

- [ ] No vague descriptions ("helps with documents")
- [ ] No excessive options without clear defaults
- [ ] No deeply nested file references
- [ ] No magic numbers without justification
- [ ] No assumptions about installed packages
