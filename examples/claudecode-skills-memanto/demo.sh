#!/usr/bin/env bash
# Demo script for social media showcase
# Shows cross-skill memory persistence in action

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Memanto + Claude Code Skills: Cross-Session Memory     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Session 1: Design Phase
echo -e "${BLUE}━━━ Session 1: Design Phase (Monday) ━━━${NC}"
echo ""
echo -e "${YELLOW}$ /grill-with-docs${NC}"
echo ""
echo "Interview me about the ordering module architecture..."
echo ""
echo "🤖: Let's discuss the ordering module. What pattern do you prefer?"
echo "👤: Hexagonal architecture with CQRS"
echo "🤖: Database choice for the write model?"
echo "👤: PostgreSQL, it's our standard"
echo "🤖: Read model for fast queries?"
echo "👤: Elasticsearch for search, Redis for caching"
echo ""
echo -e "${GREEN}💾 Memanto storing memories...${NC}"
echo "  ✓ [DECISION] Architecture: Hexagonal with CQRS (95%)"
echo "  ✓ [DECISION] Write Model: PostgreSQL (90%)"
echo "  ✓ [DECISION] Read Model: Elasticsearch + Redis (85%)"
echo "  ✓ [PREFERENCE] Separation: Command/Query separation (90%)"
echo ""
echo -e "${CYAN}  ... 3 days pass ...${NC}"
echo ""

# Session 2: Implementation Phase
echo -e "${BLUE}━━━ Session 2: Implementation Phase (Thursday) ━━━${NC}"
echo ""
echo -e "${YELLOW}$ /tdd${NC}"
echo ""
echo -e "${GREEN}📋 Querying Memanto for relevant memories...${NC}"
echo ""
echo "Found 4 relevant memories:"
echo ""
echo "  1. [DECISION] Architecture: Hexagonal with CQRS"
echo "     Confidence: 95% | Source: grill-with-docs (Monday)"
echo "     \"Decided to use hexagonal architecture with CQRS pattern..."
echo ""
echo "  2. [DECISION] Write Model: PostgreSQL"
echo "     Confidence: 90% | Source: grill-with-docs (Monday)"
echo "     \"PostgreSQL for all write operations..."
echo ""
echo "  3. [DECISION] Read Model: Elasticsearch + Redis"
echo "     Confidence: 85% | Source: grill-with-docs (Monday)"
echo "     \"Elasticsearch for search, Redis for caching..."
echo ""
echo "  4. [PREFERENCE] Command/Query Separation"
echo "     Confidence: 90% | Source: grill-with-docs (Monday)"
echo "     \"Strict separation between commands and queries..."
echo ""
echo -e "${CYAN}🤖: I see you decided on hexagonal architecture with CQRS.${NC}"
echo -e "${CYAN}   Let me write tests for the command side first.${NC}"
echo ""
echo -e "${GREEN}✓ No need to re-explain context!${NC}"
echo ""

# Session 3: Debugging Phase
echo -e "${BLUE}━━━ Session 3: Debugging Phase (Friday) ━━━${NC}"
echo ""
echo -e "${YELLOW}$ /diagnose${NC}"
echo ""
echo -e "${GREEN}📋 Querying Memanto for relevant memories...${NC}"
echo ""
echo "Found 2 relevant memories:"
echo ""
echo "  1. [DECISION] Architecture: Hexagonal with CQRS"
echo "     Confidence: 95% | Source: grill-with-docs (Monday)"
echo ""
echo "  2. [OBSERVATION] Known Issue: Event ordering in CQRS"
echo "     Confidence: 80% | Source: tdd session (Thursday)"
echo "     \"Eventual consistency can cause stale reads..."
echo ""
echo -e "${CYAN}🤖: Based on your CQRS setup, this might be an event ordering${NC}"
echo -e "${CYAN}   issue. Let me check the event store...${NC}"
echo ""

# Summary
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                      Results                              ║${NC}"
echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC} ✓ Zero context re-explaining across 3 sessions            ${CYAN}║${NC}"
echo -e "${CYAN}║${NC} ✓ 6 memories stored automatically                         ${CYAN}║${NC}"
echo -e "${CYAN}║${NC} ✓ 3 days of context persisted                             ${CYAN}║${NC}"
echo -e "${CYAN}║${NC} ✓ Architectural decisions carried forward                  ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Try it yourself:${NC}"
echo "  pip install memanto"
echo "  export MOORCHEH_API_KEY=your_key  # Free at moorcheh.ai"
echo ""
echo -e "${GREEN}Full integration:${NC} https://github.com/moorcheh-ai/memanto/pull/534"
