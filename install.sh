#!/bin/bash

# Aztec Sequencer Node Installation Script
# This script installs and configures an Aztec sequencer node on Linux or macOS.

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
DEFAULT_P2P_PORT="40400"
NETWORK="alpha-testnet"
STAKING_ASSET_HANDLER="0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2"
L1_CHAIN_ID="11155111"

# Function to check system requirements
check_requirements() {
    echo -e "${YELLOW}Checking system requirements...${NC}"
    
    # Check OS
    if [[ "$OSTYPE" != "linux-gnu"* && "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}Error: This script supports Linux or macOS only.${NC}"
        exit 1
    fi

    # Check CPU cores
    CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null)
    if [ "$CPU_CORES" -lt 8 ]; then
        echo -e "${RED}Error: At least 8 CPU cores are required. Found: $CPU_CORES${NC}"
        exit 1
    fi

    # Check RAM
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        RAM_GIB=$(free -g | awk '/^Mem:/{print $2}')
    else
        RAM_GIB=$(($(sysctl -n hw.memsize) / 1024 / 1024 / 1024))
    fi
    if [ "$RAM_GIB" -lt 16 ]; then
        echo -e "${RED}Error: At least 16 GiB of RAM is required. Found: $RAM_GIB GiB${NC}"
        exit 1
    fi

    # Check storage
    STORAGE_GIB=$(df -h . | awk 'NR==2 {print $4}' | grep -o '[0-9]\+')
    if [ "$STORAGE_GIB" -lt 1000 ]; then
        echo -e "${RED}Error: At least 1 TB of SSD storage is required. Found: $STORAGE_GIB GiB${NC}"
        exit 1
    fi

    # Check network speed (basic check)
    if ! command -v curl &>/dev/null; then
        echo -e "${YELLOW}Installing curl for network check...${NC}"
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get update && sudo apt-get install -y curl
        else
            brew install curl || true
        fi
    fi

    echo -e "${GREEN}System requirements met.${NC}"
}

# Function to install Docker
install_docker() {
    if ! command -v docker &>/dev/null; then
        echo -e "${YELLOW}Installing Docker...${NC}"
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get update
            sudo apt-get install -y docker.io
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker "$USER"
        else
            brew install --cask docker || true
            echo -e "${YELLOW}Please start Docker Desktop manually if not already running.${NC}"
        fi
    else
        echo -e "${GREEN}Docker is already installed.${NC}"
    fi
}

# Function to prompt for variables
prompt_for_variables() {
    echo -e "${YELLOW}Please provide the following configuration values:${NC}"

    read -p "Enter L1 RPC URLs (comma-separated, e.g., https://eth-sepolia.g.alchemy.com/v2/your-key): " ETHEREUM_HOSTS
    read -p "Enter L1 Consensus RPC URLs (comma-separated, e.g., https://example.com): " L1_CONSENSUS_HOST_URLS
    read -p "Enter Validator Private Key (0x<hex value>, funded with Sepolia ETH): " VALIDATOR_PRIVATE_KEY
    read -p "Enter Coinbase Address (0x<eth address> for block rewards): " COINBASE
    read -p "Enter P2P IP Address (your external IP, run 'curl api.ipify.org' to find it): " P2P_IP
    read -p "Enter P2P Port (default: $DEFAULT_P2P_PORT): " P2P_PORT
    P2P_PORT=${P2P_PORT:-$DEFAULT_P2P_PORT}
    read -p "Enter Private Key for L1 Validator Registration (0x<hex value>, can reuse validator key): " PRIVATE_KEY
    read -p "Enter Attester Address (0x<eth address>, typically same as coinbase): " ATTESTER
    read -p "Enter Proposer EOA Address (0x<eth address>, typically same as coinbase): " PROPOSER_EOA
}

# Function to install Aztec CLI
install_aztec() {
    echo -e "${YELLOW}Installing Aztec CLI...${NC}"
    if ! command -v aztec &>/dev/null; then
        bash -i <(curl -s https://install.aztec.network)
        aztec-up -v latest
    else
        echo -e "${GREEN}Aztec CLI is already installed. Updating to latest testnet version...${NC}"
        aztec-up -v latest
    fi
}

# Function to start the sequencer
start_sequencer() {
    echo -e "${YELLOW}Starting Aztec sequencer node...${NC}"
    aztec start --node --archiver --sequencer \
        --network "$NETWORK" \
        --l1-rpc-urls "$ETHEREUM_HOSTS" \
        --l1-consensus-host-urls "$L1_CONSENSUS_HOST_URLS" \
        --sequencer.validatorPrivateKey "$VALIDATOR_PRIVATE_KEY" \
        --sequencer.coinbase "$COINBASE" \
        --p2p.p2pIp "$P2P_IP" \
        --p2p.p2pPort "$P2P_PORT" || {
        echo -e "${RED}Failed to start sequencer. Check logs for details.${NC}"
        exit 1
    }
}

# Function to register as validator
register_validator() {
    echo -e "${YELLOW}Registering as L1 validator...${NC}"
    aztec add-l1-validator \
        --staking-asset-handler "$STAKING_ASSET_HANDLER" \
        --l1-rpc-urls "$ETHEREUM_HOSTS" \
        --l1-chain-id "$L1_CHAIN_ID" \
        --private-key "$PRIVATE_KEY" \
        --attester "$ATTESTER" \
        --proposer-eoa "$PROPOSER_EOA" || {
        echo -e "${RED}Validator registration failed. Check if the validator quota is filled or try again later.${NC}"
        echo -e "${YELLOW}Run 'aztec add-l1-validator --help' for more details.${NC}"
    }
}

# Main execution
echo -e "${GREEN}Aztec Sequencer Node Installation Script${NC}"

# Check system requirements
check_requirements

# Install Docker
install_docker

# Prompt for variables
prompt_for_variables

# Install Aztec CLI
install_aztec

# Start sequencer
start_sequencer

# Register as validator
register_validator

echo -e "${GREEN}Setup complete! Your Aztec sequencer node is running.${NC}"
echo -e "${YELLOW}Join the Aztec Discord for community support: https://discord.gg/aztec${NC}"
echo -e "${YELLOW}Ensure port $P2P_PORT is forwarded on your router for P2P connectivity.${NC}"
