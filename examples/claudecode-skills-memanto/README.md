# Memanto + Claude Code Skills: Cross-Skill Memory Bridge

<p align="center">
  <img src="https://raw.githubusercontent.com/moorcheh-ai/memanto/main/assets/memanto-logo.png" alt="Memanto Logo" width="200"/>
</p>

<p align="center">
  <strong>Give your Claude Code skills persistent memory across sessions</strong>
</p>

<p align="center">
  <a href="https://github.com/moorcheh-ai/memanto/stargazers"><img src="https://img.shields.io/github/stars/moorcheh-ai/memanto?style=social" alt="Stars"></a>
  <a href="https://pypi.org/project/memanto/"><img src="https://img.shields.io/pypi/v/memanto" alt="PyPI"></a>
  <a href="https://moorcheh.ai"><img src="https://img.shields.io/badge/API-Free%20Tier-green" alt="Free Tier"></a>
</p>

---

## The Problem

When using [mattpocock/skills](https://github.com/mattpocock/skills), each skill execution is **isolated**. Use `/grill-with-docs` to design an architecture, then `/tdd` to implement it — the second skill has zero context about the first. You end up re-explaining your decisions every time.

## The Solution

**Memanto** acts as a **global memory layer** that persists across all skill executions:

1. **On skill completion**: Automatically extracts and stores architectural decisions, codebase quirks, and coding preferences
2. **On skill start**: Queries relevant memories and injects them as context
3. **Cross-session**: Memories survive across terminal sessions, days, and even different machines

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Claude Code Session                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ /grill-with  │  │    /tdd      │  │  /prototype  │       │
│  │    docs      │  │              │  │              │       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
│         │                 │                 │                │
│         ▼                 ▼                 ▼                │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Memory Hook (memanto_hook.sh)           │    │
│  │  • Captures skill input/output                       │    │
│  │  • Extracts decisions & preferences                  │    │
│  │  • Queries relevant memories                         │    │
│  └─────────────────────────┬───────────────────────────┘    │
│                            │                                 │
└────────────────────────────┼─────────────────────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │    Memanto      │
                    │  (Moorcheh AI)  │
                    │                 │
                    │ • Semantic DB   │
                    │ • Cross-session │
                    │ • Auto-extract  │
                    └─────────────────┘
```

## Quick Start

### 1. Get Your Free API Key

Sign up at [moorcheh.ai](https://moorcheh.ai) and grab your API key (free tier: 100K ops/month).

### 2. Install

```bash
# Install Memanto
pip install memanto

# Clone this example
git clone https://github.com/moorcheh-ai/memanto.git
cd memanto/examples/claudecode-skills-memanto

# Configure
cp .env.example .env
# Edit .env and add your MOORCHEH_API_KEY
```

### 3. Activate the Hook

Add to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "pre_skill": ["bash memanto-hook.sh pre"],
    "post_skill": ["bash memanto-hook.sh post"]
  }
}
```

Or copy the hook to your skills directory:

```bash
cp memanto-hook.sh ~/.claude/skills/
chmod +x ~/.claude/skills/memanto-hook.sh
```

### 4. Use Skills Normally

```bash
# Session 1: Design phase
/grill-with-docs
# → Memanto stores: "Prefers hexagonal architecture", "Uses PostgreSQL for write model"

# Session 2: Implementation phase (different terminal, next day)
/tdd
# → Memanto injects: "Previous decision: hexagonal architecture with PostgreSQL write model"
# → No need to re-explain!
```

## How It Works

### Pre-Skill Hook (Memory Injection)

When a skill starts, the hook:

1. Detects which skill is being executed
2. Queries Memanto for memories relevant to:
   - Current file path
   - Skill type (design, implementation, testing)
   - Recent architectural decisions
3. Injects a concise memory summary into the skill's context

### Post-Skill Hook (Memory Extraction)

When a skill completes, the hook:

1. Captures the interaction summary
2. Uses Memanto's LLM to extract:
   - Architectural decisions
   - Code style preferences
   - Framework choices
   - Codebase quirks discovered
3. Stores these as structured memories with:
   - Confidence scores
   - Tags for easy retrieval
   - Source references

## Memory Types

Memanto stores 13 types of memories:

| Type | Description | Example |
|------|-------------|---------|
| `fact` | Verified technical facts | "Uses React 19 with Server Components" |
| `decision` | Architectural decisions | "Chose hexagonal architecture for domain isolation" |
| `preference` | Coding preferences | "Prefers functional style over OOP" |
| `observation` | Codebase observations | "Legacy auth module uses session-based auth" |
| `pattern` | Recurring patterns | "All API routes follow REST conventions" |
| `constraint` | Project constraints | "Must support IE11 for enterprise clients" |
| `question` | Open questions | "Should we migrate to TypeScript?" |
| `hypothesis` | Unverified assumptions | "Might be a race condition in WebSocket handler" |
| `correction` | Corrections to previous memories | "Actually using MongoDB, not PostgreSQL" |
| `context` | General context | "Team prefers PR-based workflow" |
| `instruction` | Direct instructions | "Always use snake_case for database columns" |
| `reference` | External references | "See docs/architecture.md for system overview" |
| `summary` | Session summaries | "Discussed auth migration strategy, decided on JWT" |

## Example Output

### Memory Stored (after `/grill-with-docs`)

```json
{
  "type": "decision",
  "title": "Architecture: Hexagonal with CQRS",
  "content": "Decided to use hexagonal architecture with CQRS pattern for the ordering module. Command side uses PostgreSQL, query side uses Elasticsearch for fast reads. This enables independent scaling of read/write paths.",
  "tags": ["architecture", "cqrs", "postgresql", "elasticsearch"],
  "confidence": 0.95,
  "source": "grill-with-docs"
}
```

### Memory Retrieved (before `/tdd`)

```
📋 Relevant Memories (3 found):

1. [DECISION] Architecture: Hexagonal with CQRS
   Confidence: 95% | Source: grill-with-docs
   "Hexagonal architecture with CQRS for ordering module..."

2. [PREFERENCE] Testing: Integration over Unit
   Confidence: 85% | Source: previous session
   "Team prefers integration tests for domain logic..."

3. [CONSTRAINT] Database: PostgreSQL Required
   Confidence: 90% | Source: project config
   "Must use PostgreSQL for all write operations..."
```

## Configuration

### Environment Variables

```bash
# Required
MOORCHEH_API_KEY=your_api_key_here

# Optional
MEMANTO_AGENT_ID=claudecode-engineer    # Default agent ID
MEMANTO_SCOPE_TYPE=project              # Memory scope (project/global)
MEMANTO_SCOPE_ID=my-project             # Project-specific scope
MEMANTO_CONFIDENCE_THRESHOLD=0.7        # Min confidence for injection
MEMANTO_MAX_MEMORIES=5                  # Max memories to inject
```

### Customizing Extraction

Edit `memanto-hook.sh` to customize what gets extracted:

```bash
# In the post-skill hook, modify the extraction prompt:
EXTRACTION_PROMPT="Extract the following from this interaction:
1. Any architectural decisions made
2. Code style preferences expressed
3. Framework or library choices
4. Codebase patterns discovered
5. Open questions or TODOs"
```

## Advanced Usage

### Multiple Projects

Each project gets its own memory namespace:

```bash
# Project A
MEMANTO_SCOPE_ID=project-a

# Project B  
MEMANTO_SCOPE_ID=project-b
```

### Team Sharing

Share memories across a team:

```bash
MEMANTO_SCOPE_TYPE=team
MEMANTO_SCOPE_ID=my-team
```

### Memory Cleanup

```bash
# List all memories
python -c "from memanto import MemantoClient; c = MemantoClient(); print(c.list_memories())"

# Delete old memories
python -c "from memanto import MemantoClient; c = MemantoClient(); c.cleanup(days=30)"
```

## Comparison

| Feature | Manual Context | Memanto |
|---------|---------------|---------|
| Cross-session | ❌ | ✅ |
| Automatic extraction | ❌ | ✅ |
| Semantic search | ❌ | ✅ |
| Confidence scoring | ❌ | ✅ |
| Contradiction detection | ❌ | ✅ |
| Zero overhead | ❌ | ✅ |

## Contributing

Contributions welcome! See [CONTRIBUTING.md](../../CONTRIBUTING.md).

## License

MIT License - see [LICENSE](../../LICENSE)

## Acknowledgments

- [mattpocock/skills](https://github.com/mattpocock/skills) for the amazing skill ecosystem
- [Moorcheh AI](https://moorcheh.ai) for the memory infrastructure
- The Claude Code community for feedback and testing

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/iyop666">iyop666</a>
</p>
