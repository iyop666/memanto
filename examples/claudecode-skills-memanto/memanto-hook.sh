#!/usr/bin/env bash
# Memanto Hook for Claude Code Skills
# Captures skill execution context and manages cross-skill memory

set -euo pipefail

# Configuration
MOORCHEH_API_KEY="${MOORCHEH_API_KEY:-}"
MEMANTO_AGENT_ID="${MEMANTO_AGENT_ID:-claudecode-engineer}"
MEMANTO_SCOPE_TYPE="${MEMANTO_SCOPE_TYPE:-project}"
MEMANTO_SCOPE_ID="${MEMANTO_SCOPE_ID:-$(basename "$(pwd)")}"
MEMANTO_CONFIDENCE_THRESHOLD="${MEMANTO_CONFIDENCE_THRESHOLD:-0.7}"
MEMANTO_MAX_MEMORIES="${MEMANTO_MAX_MEMORIES:-5}"
MEMANTO_LOG_FILE="${MEMANTO_LOG_FILE:-/tmp/memanto-hook.log}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[Memanto]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[Memanto Warning]${NC} $1" >&2
}

error() {
    echo -e "${RED}[Memanto Error]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[Memanto]${NC} $1" >&2
}

# Check if Memanto is configured
check_config() {
    if [ -z "$MOORCHEH_API_KEY" ]; then
        warn "MOORCHEH_API_KEY not set. Memory features disabled."
        warn "Get your free key at https://moorcheh.ai"
        return 1
    fi
    return 0
}

# Detect current skill name
detect_skill() {
    # Try to detect from various sources
    local skill_name=""
    
    # Check if SKILL.md exists in current directory
    if [ -f "SKILL.md" ]; then
        skill_name=$(grep -m1 "^name:" SKILL.md 2>/dev/null | sed 's/name: *//' || true)
    fi
    
    # Check environment variable
    if [ -z "$skill_name" ] && [ -n "${CLAUDE_SKILL_NAME:-}" ]; then
        skill_name="$CLAUDE_SKILL_NAME"
    fi
    
    # Check for skill marker file
    if [ -z "$skill_name" ] && [ -f ".current-skill" ]; then
        skill_name=$(cat .current-skill 2>/dev/null || true)
    fi
    
    # Default to unknown
    if [ -z "$skill_name" ]; then
        skill_name="unknown"
    fi
    
    echo "$skill_name"
}

# Get relevant file context
get_file_context() {
    local context=""
    
    # Current directory
    context+="Working directory: $(pwd)\n"
    
    # Git branch if in git repo
    if git rev-parse --git-dir > /dev/null 2>&1; then
        context+="Git branch: $(git branch --show-current 2>/dev/null || echo 'unknown')\n"
    fi
    
    # Key files
    for file in CONTEXT.md CLAUDE.md README.md; do
        if [ -f "$file" ]; then
            context+="Has $file\n"
        fi
    done
    
    echo -e "$context"
}

# Query Memanto for relevant memories
query_memories() {
    local skill_name="$1"
    local file_context="$2"
    
    if ! check_config; then
        return 0
    fi
    
    log "Querying memories for skill: $skill_name"
    
    # Build query based on skill type and context
    local query=""
    case "$skill_name" in
        grill-with-docs|improve-codebase-architecture|zoom-out)
            query="architectural decisions, design patterns, system constraints"
            ;;
        tdd|prototype)
            query="testing preferences, code style, framework choices"
            ;;
        triage|diagnose)
            query="known issues, debugging patterns, codebase quirks"
            ;;
        to-issues|to-prd)
            query="project requirements, feature decisions, priorities"
            ;;
        *)
            query="general context, recent decisions, coding preferences"
            ;;
    esac
    
    # Use Python to query Memanto
    python3 << PYTHON
import os
import sys
import json

try:
    from memanto import MemantoClient
    
    client = MemantoClient(
        api_key="${MOORCHEH_API_KEY}",
        agent_id="${MEMANTO_AGENT_ID}",
        scope_type="${MEMANTO_SCOPE_TYPE}",
        scope_id="${MEMANTO_SCOPE_ID}"
    )
    
    # Query for relevant memories
    memories = client.query(
        query="${query} ${file_context}",
        limit=${MEMANTO_MAX_MEMORIES},
        min_confidence=${MEMANTO_CONFIDENCE_THRESHOLD}
    )
    
    if memories:
        print("\\n📋 Relevant Memories:")
        for i, mem in enumerate(memories, 1):
            print(f"\\n{i}. [{mem['type'].upper()}] {mem['title']}")
            print(f"   Confidence: {mem['confidence']*100:.0f}% | Source: {mem.get('source', 'unknown')}")
            # Truncate content for context injection
            content = mem['content'][:200] + "..." if len(mem['content']) > 200 else mem['content']
            print(f"   {content}")
    else:
        print("\\n📋 No relevant memories found.")
        
except ImportError:
    print("\\n⚠️  Memanto not installed. Run: pip install memanto")
except Exception as e:
    print(f"\\n⚠️  Memory query failed: {e}", file=sys.stderr)
PYTHON
}

# Extract and store memories from skill execution
extract_memories() {
    local skill_name="$1"
    local interaction_summary="$2"
    
    if ! check_config; then
        return 0
    fi
    
    log "Extracting memories from skill: $skill_name"
    
    # Use Python to extract and store memories
    python3 << PYTHON
import os
import sys
import json

try:
    from memanto import MemantoClient
    
    client = MemantoClient(
        api_key="${MOORCHEH_API_KEY}",
        agent_id="${MEMANTO_AGENT_ID}",
        scope_type="${MEMANTO_SCOPE_TYPE}",
        scope_id="${MEMANTO_SCOPE_ID}"
    )
    
    # Build extraction prompt
    extraction_prompt = """Analyze this skill execution and extract key memories:

Skill: ${skill_name}
Interaction: ${interaction_summary}

Extract:
1. Architectural decisions made
2. Code style preferences expressed
3. Framework or library choices
4. Codebase patterns discovered
5. Open questions or TODOs
6. Constraints or requirements mentioned

Format as JSON array of memories, each with:
- type: one of [fact, decision, preference, observation, pattern, constraint, question, hypothesis, correction, context, instruction, reference, summary]
- title: concise title (max 100 chars)
- content: detailed content
- tags: array of relevant tags
- confidence: 0.0-1.0
"""
    
    # Extract memories using Memanto's LLM
    memories = client.extract_memories(
        prompt=extraction_prompt,
        source=skill_name
    )
    
    if memories:
        print(f"\\n💾 Stored {len(memories)} memories:")
        for mem in memories:
            print(f"  • [{mem['type']}] {mem['title']}")
    else:
        print("\\n💾 No memories extracted.")
        
except ImportError:
    print("\\n⚠️  Memanto not installed. Run: pip install memanto")
except Exception as e:
    print(f"\\n⚠️  Memory extraction failed: {e}", file=sys.stderr)
PYTHON
}

# Pre-skill hook
pre_skill_hook() {
    local skill_name
    skill_name=$(detect_skill)
    
    log "Pre-skill hook triggered for: $skill_name"
    
    # Get file context
    local file_context
    file_context=$(get_file_context)
    
    # Query and display relevant memories
    query_memories "$skill_name" "$file_context"
}

# Post-skill hook
post_skill_hook() {
    local skill_name
    skill_name=$(detect_skill)
    
    log "Post-skill hook triggered for: $skill_name"
    
    # Read interaction summary from stdin or environment
    local interaction_summary=""
    if [ -p /dev/stdin ]; then
        interaction_summary=$(cat)
    elif [ -n "${CLAUDE_SKILL_SUMMARY:-}" ]; then
        interaction_summary="$CLAUDE_SKILL_SUMMARY"
    fi
    
    if [ -n "$interaction_summary" ]; then
        extract_memories "$skill_name" "$interaction_summary"
    else
        warn "No interaction summary available for memory extraction"
    fi
}

# Main
main() {
    local hook_type="${1:-}"
    
    case "$hook_type" in
        pre|pre_skill)
            pre_skill_hook
            ;;
        post|post_skill)
            post_skill_hook
            ;;
        *)
            echo "Usage: $0 {pre|post}"
            echo ""
            echo "  pre   - Run before skill execution (query memories)"
            echo "  post  - Run after skill execution (extract memories)"
            exit 1
            ;;
    esac
}

main "$@"
