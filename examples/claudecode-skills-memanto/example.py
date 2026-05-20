"""
Example: Using Memanto with Claude Code Skills

This script demonstrates how to use the Memanto Skill Bridge
to persist context across different skill executions.
"""

import os
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from memanto_skill_bridge import MemantoSkillBridge


def example_grill_with_docs():
    """Example: After using /grill-with-docs skill."""
    
    bridge = MemantoSkillBridge()
    
    print("=== After /grill-with-docs ===\n")
    
    # Simulate storing architectural decisions
    decisions = [
        {
            "type": "decision",
            "title": "Architecture: Hexagonal with CQRS",
            "content": "Decided to use hexagonal architecture with CQRS pattern for the ordering module. "
                      "Command side uses PostgreSQL, query side uses Elasticsearch for fast reads.",
            "tags": ["architecture", "cqrs", "postgresql", "elasticsearch"],
            "confidence": 0.95,
        },
        {
            "type": "preference",
            "title": "Testing: Integration over Unit",
            "content": "Team prefers integration tests for domain logic. Unit tests only for complex algorithms.",
            "tags": ["testing", "preferences"],
            "confidence": 0.85,
        },
        {
            "type": "constraint",
            "title": "Database: PostgreSQL Required",
            "content": "Must use PostgreSQL for all write operations due to existing infrastructure.",
            "tags": ["database", "postgresql", "constraint"],
            "confidence": 0.90,
        },
    ]
    
    print("Storing memories from grill-with-docs session...")
    for decision in decisions:
        result = bridge.store_memory(
            memory_type=decision["type"],
            title=decision["title"],
            content=decision["content"],
            tags=decision["tags"],
            confidence=decision["confidence"],
            source="grill-with-docs",
        )
        if result:
            print(f"  ✓ Stored: {decision['title']}")
        else:
            print(f"  ✗ Failed to store: {decision['title']}")
    
    print()


def example_tdd():
    """Example: Before using /tdd skill."""
    
    bridge = MemantoSkillBridge()
    
    print("=== Before /tdd ===\n")
    
    # Query relevant memories
    print("Querying memories for TDD session...")
    memories = bridge.query_memories(skill_name="tdd")
    
    if memories:
        print("\nFound relevant memories:")
        for i, mem in enumerate(memories, 1):
            title = mem.get("title", "untitled")
            confidence = mem.get("confidence", 0.0)
            content = mem.get("content", "")
            print(f"\n{i}. [{mem.get('type', 'unknown').upper()}] {title}")
            print(f"   Confidence: {confidence*100:.0f}%")
            print(f"   {content[:100]}...")
    else:
        print("No memories found.")
    
    print()


def example_prototype():
    """Example: Before using /prototype skill."""
    
    bridge = MemantoSkillBridge()
    
    print("=== Before /prototype ===\n")
    
    # Query memories
    print("Querying memories for prototype session...")
    memories = bridge.query_memories(skill_name="prototype")
    
    if memories:
        # Format for context injection
        context = bridge.format_memories_for_context(memories)
        print(context)
    else:
        print("No memories found.")
    
    print()


def main():
    """Run examples."""
    
    # Check for API key
    if not os.getenv("MOORCHEH_API_KEY"):
        print("Warning: MOORCHEH_API_KEY not set.")
        print("   Get your free key at https://moorcheh.ai")
        print("   Then set: export MOORCHEH_API_KEY=your_key")
        print()
        print("   Running in demo mode (no actual API calls)...")
        print()
    
    print("Memanto + Claude Code Skills Integration Example")
    print("=" * 50)
    print()
    
    # Run examples
    example_grill_with_docs()
    example_tdd()
    example_prototype()
    
    print("=" * 50)
    print("Done! Memories persist across skill executions.")
    print("Try running different skills in different sessions.")


if __name__ == "__main__":
    main()
