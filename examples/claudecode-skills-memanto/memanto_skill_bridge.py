"""
Memanto + Claude Code Skills Integration

This module provides cross-skill memory persistence for Claude Code skills.
"""

import os
import json
import subprocess
from typing import Optional, List, Dict, Any
from pathlib import Path


class MemantoSkillBridge:
    """
    Bridge between Claude Code skills and Memanto memory system.
    
    Captures skill execution context and manages cross-skill memory.
    """
    
    def __init__(
        self,
        api_key: Optional[str] = None,
        agent_id: str = "claudecode-engineer",
        scope_type: str = "project",
        scope_id: Optional[str] = None,
        confidence_threshold: float = 0.7,
        max_memories: int = 5,
    ):
        self.api_key = api_key or os.getenv("MOORCHEH_API_KEY")
        self.agent_id = agent_id
        self.scope_type = scope_type
        self.scope_id = scope_id or self._detect_project_id()
        self.confidence_threshold = confidence_threshold
        self.max_memories = max_memories
        self._client = None
    
    def _detect_project_id(self) -> str:
        """Detect project ID from current directory."""
        cwd = Path.cwd()
        
        # Try git repo name
        try:
            result = subprocess.run(
                ["git", "rev-parse", "--show-toplevel"],
                capture_output=True, text=True, cwd=cwd
            )
            if result.returncode == 0:
                return Path(result.stdout.strip()).name
        except:
            pass
        
        # Fall back to directory name
        return cwd.name
    
    @property
    def client(self):
        """Lazy initialization of Memanto client."""
        if self._client is None:
            if not self.api_key:
                raise ValueError(
                    "MOORCHEH_API_KEY not set. "
                    "Get your free key at https://moorcheh.ai"
                )
            from memanto import MemantoClient
            self._client = MemantoClient(
                api_key=self.api_key,
                agent_id=self.agent_id,
                scope_type=self.scope_type,
                scope_id=self.scope_id,
            )
        return self._client
    
    def detect_skill(self) -> str:
        """Detect current skill name."""
        # Check SKILL.md in current directory
        skill_file = Path("SKILL.md")
        if skill_file.exists():
            for line in skill_file.read_text().splitlines():
                if line.startswith("name:"):
                    return line.split(":", 1)[1].strip()
        
        # Check environment
        if skill_name := os.getenv("CLAUDE_SKILL_NAME"):
            return skill_name
        
        # Check marker file
        marker = Path(".current-skill")
        if marker.exists():
            return marker.read_text().strip()
        
        return "unknown"
    
    def get_file_context(self) -> Dict[str, Any]:
        """Get current file context."""
        context = {
            "working_directory": str(Path.cwd()),
            "has_context_md": Path("CONTEXT.md").exists(),
            "has_claude_md": Path("CLAUDE.md").exists(),
            "has_readme": Path("README.md").exists(),
        }
        
        # Git info
        try:
            result = subprocess.run(
                ["git", "branch", "--show-current"],
                capture_output=True, text=True
            )
            if result.returncode == 0:
                context["git_branch"] = result.stdout.strip()
        except:
            pass
        
        return context
    
    def query_memories(
        self,
        query: Optional[str] = None,
        skill_name: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """
        Query relevant memories for current context.
        
        Args:
            query: Custom query string
            skill_name: Skill name for context-aware query
            
        Returns:
            List of relevant memories
        """
        skill = skill_name or self.detect_skill()
        
        # Build context-aware query
        if not query:
            file_context = self.get_file_context()
            query = self._build_query(skill, file_context)
        
        try:
            memories = self.client.query(
                query=query,
                limit=self.max_memories,
                min_confidence=self.confidence_threshold,
            )
            return memories or []
        except Exception as e:
            print(f"⚠️  Memory query failed: {e}")
            return []
    
    def _build_query(self, skill: str, context: Dict) -> str:
        """Build query based on skill type and context."""
        skill_queries = {
            "grill-with-docs": "architectural decisions, design patterns, system constraints",
            "improve-codebase-architecture": "architecture, patterns, refactoring decisions",
            "zoom-out": "high-level design, system overview, strategic decisions",
            "tdd": "testing preferences, code style, test patterns",
            "prototype": "implementation choices, framework decisions, quick decisions",
            "triage": "known issues, bug patterns, debugging context",
            "diagnose": "error patterns, debugging approaches, root causes",
            "to-issues": "requirements, feature decisions, priorities",
            "to-prd": "product decisions, user requirements, scope",
        }
        
        base_query = skill_queries.get(skill, "general context, decisions, preferences")
        
        # Add file context
        context_parts = []
        if context.get("git_branch"):
            context_parts.append(f"branch: {context['git_branch']}")
        
        if context_parts:
            return f"{base_query} ({', '.join(context_parts)})"
        return base_query
    
    def store_memory(
        self,
        memory_type: str,
        title: str,
        content: str,
        tags: Optional[List[str]] = None,
        confidence: float = 0.8,
        source: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Store a memory.
        
        Args:
            memory_type: Type of memory (fact, decision, preference, etc.)
            title: Memory title
            content: Memory content
            tags: Optional tags
            confidence: Confidence score (0.0-1.0)
            source: Source of memory (e.g., skill name)
            
        Returns:
            Stored memory record
        """
        from memanto.app.core import MemoryRecord
        
        record = MemoryRecord(
            type=memory_type,
            title=title,
            content=content,
            scope_type=self.scope_type,
            scope_id=self.scope_id,
            actor_id=self.agent_id,
            source="claude_code_skill",
            source_ref=source or self.detect_skill(),
            confidence=confidence,
            tags=tags or [],
        )
        
        try:
            result = self.client.store(record)
            return result
        except Exception as e:
            print(f"⚠️  Memory storage failed: {e}")
            return {}
    
    def extract_and_store(
        self,
        interaction_summary: str,
        skill_name: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """
        Extract memories from interaction and store them.
        
        Args:
            interaction_summary: Summary of skill interaction
            skill_name: Skill name
            
        Returns:
            List of stored memories
        """
        skill = skill_name or self.detect_skill()
        
        extraction_prompt = f"""Analyze this skill execution and extract key memories:

Skill: {skill}
Interaction: {interaction_summary}

Extract:
1. Architectural decisions made
2. Code style preferences expressed
3. Framework or library choices
4. Codebase patterns discovered
5. Open questions or TODOs
6. Constraints or requirements mentioned

Return as JSON array of memories, each with:
- type: one of [fact, decision, preference, observation, pattern, constraint, question, hypothesis, correction, context, instruction, reference, summary]
- title: concise title (max 100 chars)
- content: detailed content
- tags: array of relevant tags
- confidence: 0.0-1.0
"""
        
        try:
            memories = self.client.extract_memories(
                prompt=extraction_prompt,
                source=skill,
            )
            return memories or []
        except Exception as e:
            print(f"⚠️  Memory extraction failed: {e}")
            return []
    
    def format_memories_for_context(self, memories: List[Dict]) -> str:
        """Format memories for context injection."""
        if not memories:
            return ""
        
        lines = ["📋 Relevant Memories:"]
        for i, mem in enumerate(memories, 1):
            lines.append(f"\n{i}. [{mem['type'].upper()}] {mem['title']}")
            lines.append(f"   Confidence: {mem['confidence']*100:.0f}% | Source: {mem.get('source', 'unknown')}")
            
            # Truncate content
            content = mem['content']
            if len(content) > 200:
                content = content[:200] + "..."
            lines.append(f"   {content}")
        
        return "\n".join(lines)


# Convenience functions
def query_memories(query: Optional[str] = None) -> List[Dict]:
    """Query memories using default configuration."""
    bridge = MemantoSkillBridge()
    return bridge.query_memories(query)


def store_memory(
    memory_type: str,
    title: str,
    content: str,
    **kwargs,
) -> Dict:
    """Store a memory using default configuration."""
    bridge = MemantoSkillBridge()
    return bridge.store_memory(memory_type, title, content, **kwargs)


def get_context_for_skill(skill_name: Optional[str] = None) -> str:
    """Get formatted memory context for a skill."""
    bridge = MemantoSkillBridge()
    memories = bridge.query_memories(skill_name=skill_name)
    return bridge.format_memories_for_context(memories)
