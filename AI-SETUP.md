# AI Mentor Setup

This workshop supports 3 AI tools as your mentor. Pick the one you use — copy-paste the command into your terminal.

## Claude Code

Already included in the repo. Just open the project:

```bash
claude
```

Claude reads `CLAUDE.md` automatically.

## Cursor

Already included in the repo. Just open the project:

```bash
cursor .
```

Cursor reads `.cursorrules` automatically.

## GitHub Copilot

Run this command to add Copilot instructions to your local repo:

```bash
git checkout ai-setup -- .github/copilot-instructions.md
```

Then open the project in VS Code — Copilot will read the instructions.

## ChatGPT / Other AI

Open the companion doc for your current branch and paste it into your AI:

```bash
cat docs/$(git branch --show-current)/mentor.md
```

Copy the output and paste it as context. Then paste the student guide:

```bash
cat docs/$(git branch --show-current)/guide-th.md
```

The AI will have enough context to mentor you through the step.

## How It Works

All AI tools do the same thing:

1. **Detect your branch** — knows which step you're on
2. **Load companion docs** — reads the mentor guide + student guide
3. **Respond in Thai** — uses English only for technical terms
4. **Never gives answers** — asks guiding questions until you get it
5. **Tracks progress** — silently logs your questions and independence in `progress.md`

## Verify It Works

After setting up your AI tool, ask it:

> "ฉันอยู่ branch อะไร? ต้องทำอะไรต่อ?"

It should detect your branch, read the companion docs, and guide you in Thai.
