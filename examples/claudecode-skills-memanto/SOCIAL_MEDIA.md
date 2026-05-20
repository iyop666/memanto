# Social Media Posts for Memanto + Claude Code Skills Bounty

## Reddit Post (r/ClaudeAI)

### Title:
I gave my Claude Code skills persistent memory across sessions — no more re-explaining context

### Body:

**The Problem:**

If you use [mattpocock/skills](https://github.com/mattpocock/skills) (the 96K star repo with engineering skills like `/grill-with-docs`, `/tdd`, `/prototype`), you've probably hit this frustration:

Use `/grill-with-docs` to stress-test your architecture design. Close terminal. Next day, open new terminal, run `/tdd` to implement. The TDD skill has ZERO context about yesterday's design decisions. You end up re-explaining everything.

**The Solution:**

I built an integration with [Memanto](https://github.com/moorcheh-ai/memanto) that gives your skills **persistent memory across sessions**.

Here's what happens:

1. **After `/grill-with-docs`**: Memanto automatically extracts your architectural decisions, stores them with confidence scores

2. **Before `/tdd`**: Memanto queries relevant memories and injects them into context

3. **Result**: The TDD skill already knows you chose hexagonal architecture with CQRS, prefers integration tests, and uses PostgreSQL

**Demo:**

```text
Session 1: /grill-with-docs
> "Let's discuss the ordering module architecture..."
> [Decides: Hexagonal + CQRS, PostgreSQL write model, Elasticsearch reads]
> [Memanto stores 3 memories automatically]

Session 2: /tdd (next day, different terminal)
> 📋 Relevant Memories:
> 1. [DECISION] Architecture: Hexagonal with CQRS (95% confidence)
> 2. [PREFERENCE] Testing: Integration over Unit (85% confidence)  
> 3. [CONSTRAINT] Database: PostgreSQL Required (90% confidence)
> 
> No need to re-explain anything!
```

**How it works:**

- Lightweight bash hook that intercepts skill lifecycle
- Uses Memanto's semantic search to find relevant memories
- Extracts decisions using LLM (Moorcheh AI backend)
- Memories persist across sessions, machines, even team members

**Try it:**

```bash
pip install memanto
export MOORCHEH_API_KEY=your_key  # Free at moorcheh.ai
```

Full integration: [PR #534](https://github.com/moorcheh-ai/memanto/pull/534)

**What do you think?** Would this save you time context-switching between skills?

---

## X/Twitter Thread

### Tweet 1:
I gave my Claude Code skills persistent memory 🧠

Use /grill-with-docs to design architecture → /tdd to implement → no context re-explaining

Memanto stores your decisions automatically and injects them into the next skill.

PR: https://github.com/moorcheh-ai/memanto/pull/534

🧵 Here's how it works:

### Tweet 2:
The problem with @mattpocock/skills (96K ⭐):

Each skill runs in isolation. Design in one session, implement in another — context lost.

You end up re-explaining your hexagonal architecture choice every. single. time.

### Tweet 3:
The fix: Memanto as a global memory layer

After /grill-with-docs:
→ Extracts: "Hexagonal + CQRS, PostgreSQL write model"
→ Stores with 95% confidence score

Before /tdd:
→ Queries: "What architecture decisions were made?"
→ Injects into context automatically

### Tweet 4:
Zero repeated instructions.

The skill already knows:
✓ Your architectural choices
✓ Testing preferences  
✓ Framework decisions
✓ Codebase quirks

All from previous sessions. No manual context needed.

### Tweet 5:
Built with:
• Bash hook for skill lifecycle
• Python bridge for programmatic access
• Memanto semantic search
• Moorcheh AI backend (free tier: 100K ops/month)

Try it: pip install memanto

Full code: https://github.com/moorcheh-ai/memanto/pull/534

`#ClaudeAI` `#DevTools` `#AI`

### Tweet 6:
This is the future of AI-assisted development:

Not just context within a session, but across sessions. Across days. Across team members.

Your AI should remember your decisions. You shouldn't have to.

`#Memanto` `#ClaudeCode`

---

## GitHub PR Reactions Prompt

Hey! If you think cross-skill memory persistence would save you time, I'd appreciate a 👍 on the PR:

https://github.com/moorcheh-ai/memanto/pull/534

The bounty scores based on:
• Technical merit (60%)
• Social engagement (40%)

Every reaction helps! 🙏

---

## r/LocalLLaMA Cross-post

### Title:
Built cross-session memory for Claude Code skills using semantic search — thoughts on approach?

### Body:

I've been working on solving context fragmentation in AI coding assistants. The core problem: when you use different "skills" (like /tdd, /design, /prototype), each runs in isolation with zero memory of previous sessions.

My approach uses Memanto (Moorcheh AI's memory system) as a persistent layer:

1. **Extraction**: After each skill, LLM extracts key decisions/constraints
2. **Storage**: Structured memories with confidence scores and semantic tags
3. **Retrieval**: On next skill start, semantic search finds relevant memories
4. **Injection**: Memories appended to skill context

Key design choices:
- 13 memory types (fact, decision, preference, constraint, etc.)
- Confidence scoring (0.0-1.0) for trust levels
- Contradiction detection when new info conflicts with old
- Namespace isolation per project/team

Technical details in the PR: https://github.com/moorcheh-ai/memanto/pull/534

Questions for the community:
1. What's the right balance between memory injection and context window limits?
2. Should memories decay over time or persist forever?
3. How do you handle conflicting memories from different sessions?

---

## LinkedIn Post

🧠 **Just shipped: Cross-session memory for AI coding assistants**

Ever used Claude Code's engineering skills (/tdd, /grill-with-docs, /prototype) and wished they remembered your previous decisions?

I built an integration with Memanto that solves this:

✅ After design session → memories extracted automatically
✅ Before implementation → relevant context injected
✅ Zero repeated instructions across sessions

The result? Your AI assistant remembers your architectural choices, testing preferences, and framework decisions — without you re-explaining every time.

This is the future of AI-assisted development: persistent context that survives across sessions, days, and team members.

Check out the PR: https://github.com/moorcheh-ai/memanto/pull/534

`#AI` `#DevTools` `#ClaudeAI` `#SoftwareEngineering` `#Productivity`

---

## Posting Schedule

### Day 1 (Today):
- [ ] Post Reddit r/ClaudeAI
- [ ] Post X thread
- [ ] React to own PR with 👍

### Day 2:
- [ ] Cross-post to r/LocalLLaMA
- [ ] Share on LinkedIn
- [ ] Engage with comments

### Day 3:
- [ ] Follow up on Reddit comments
- [ ] Quote-tweet with demo GIF
- [ ] Reply to PR feedback

### Ongoing:
- [ ] Monitor engagement metrics
- [ ] Respond to questions
- [ ] Track scoring formula:
  - Reddit Upvotes x 4
  - Reddit Comments x 3
  - X Bookmarks x 5
  - X Retweets x 3
  - GitHub PR Reactions x 2
