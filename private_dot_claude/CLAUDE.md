# Global Instructions

## Workflow Design

### 1. Plan Mode First
- Always start in Plan mode for tasks involving 3+ steps or architectural decisions
- If things go wrong mid-task, stop immediately and re-plan instead of pushing through
- Use Plan mode for verification steps, not just implementation
- Write detailed specifications before implementation to reduce ambiguity

### 2. Sub-Agent Strategy
- Actively use sub-agents to keep the main context window clean
- Delegate research, investigation, and parallel analysis to sub-agents
- For complex problems, invest more compute by deploying sub-agents
- Assign one task per sub-agent for focused execution

### 3. Self-Improvement Loop
- When corrected by the user, always record the pattern in `tasks/lessons.md`
- Write rules for yourself to avoid repeating the same mistakes
- Continuously refine rules until the error rate drops
- Review project-relevant lessons at the start of each session

### 4. Verify Before Completing
- Never mark a task as complete until you can prove it works
- Diff against the main branch when needed to confirm your changes
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, and demonstrate correct behavior

### 5. Pursue Elegance (With Balance)
- Before making significant changes, pause and ask: "Is there a more elegant way?"
- If a fix feels hacky, step back and implement an elegant solution using everything you know
- Skip this process for simple, obvious fixes (do not over-engineer)
- Self-review your work before presenting it

### 6. Autonomous Bug Fixing
- When given a bug report, go fix it without hand-holding
- Read logs, errors, and failing tests to resolve issues independently
- Minimize context-switching for the user
- Proactively fix failing CI tests without being asked

---

## Task Management

1. **Plan first**: Write the plan as checkable items in `tasks/todo.md`
2. **Confirm the plan**: Get confirmation before starting implementation
3. **Track progress**: Mark items as completed as you go
4. **Explain changes**: Provide a high-level summary at each step
5. **Document results**: Add a review section to `tasks/todo.md`
6. **Record learnings**: Update `tasks/lessons.md` after receiving corrections

---

## Core Principles

- **Simplicity first**: Keep every change as simple as possible. Minimize the code affected.
- **No shortcuts**: Find the root cause. Avoid temporary fixes. Maintain senior engineer standards.
- **Minimize impact**: Limit changes to only what is necessary. Do not introduce new bugs.
