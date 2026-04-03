#!/bin/bash

################################################################################
# Setup Scripts - Makes all deployment scripts executable
# ============================================================================
# Run this once to make all scripts executable
# 
# Usage: bash setup-scripts.sh

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}Setting up deployment scripts...${NC}"

# List of scripts to make executable
scripts=(
    "install.sh"
    "deploy.sh"
    "health-check.sh"
    "backup.sh"
    "setup-ssl.sh"
)

for script in "${scripts[@]}"; do
    if [[ -f "$script" ]]; then
        chmod +x "$script"
        echo -e "${GREEN}✓${NC} Made executable: $script"
    fi
done

echo ""
echo -e "${GREEN}All scripts are now executable!${NC}"
echo ""
echo "Next steps:"
echo "1. Run installer: sudo bash install.sh"
echo "2. Check status: bash health-check.sh"
echo "3. Deploy updates: bash deploy.sh"
echo "4. Backup database: bash backup.sh"
echo "5. Setup HTTPS: sudo bash setup-ssl.sh"
