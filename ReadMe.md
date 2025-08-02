# Aztec Sequencer Node Setup

This guide provides instructions for setting up an Aztec sequencer node using the provided `install_aztec_sequencer.sh` script. The script automates the installation of dependencies, configuration of the node, and registration as an L1 validator on the Aztec alpha-testnet.

## Prerequisites

Ensure your system meets the following requirements:
- **Operating System**: Linux or macOS
- **CPU**: 8 cores
- **RAM**: 16 GiB
- **Storage**: 1 TB SSD
- **Network**: 25 Mbps up/down
- **Sepolia ETH**: At least 0.01 Sepolia ETH for gas costs (obtain from a faucet like [Sepolia PoW Faucet](https://sepolia-faucet.pk910.de/) or the Aztec Discord community)
- **External IP**: Obtain your public IP by running `curl api.ipify.org`
- **Port Forwarding**: Forward TCP/UDP port 40400 (or your chosen port) to your local machine's IP on your router

## Installation Steps

1. **Clone or Download the Script**
   Download the `install_aztec_sequencer.sh` script to your machine.

2. **Make the Script Executable**
   ```bash
   chmod +x install_aztec_sequencer.sh

   Run the Script
Execute the script with:bash

./install_aztec_sequencer.sh

The script will:

Check system requirements (CPU, RAM, storage)
Install Docker if not already installed
Prompt for configuration variables (e.g., L1 RPC URLs, private keys, IP address)
Install the Aztec CLI and update to the latest testnet version
Start the sequencer node with archiver functionality
Register your node as an L1 validator

Provide Configuration Variables

When prompted, 
enter the following:
L1 RPC URLs: Comma-separated URLs for Ethereum execution clients (e.g., Alchemy, Infura)
L1 Consensus RPC URLs: Comma-separated URLs for consensus clients (e.g., Quicknode, dRPC)
Validator Private Key: A funded Sepolia ETH private key (0x<hex value>)
Coinbase Address: Ethereum address to receive block rewards (0x<eth address>)
P2P IP Address: Your external IP (run curl api.ipify.org to find it)
P2P Port: Default is 40400, or specify your own
Private Key for Validator Registration: Can reuse the validator private key
Attester Address: Typically the same as the coinbase address
Proposer EOA Address: Typically the same as the coinbase address

Port Forwarding

Ensure your router forwards TCP/UDP port 40400 (or your chosen port) to your machine's local IP. Check your router's advanced network settings for port forwarding options.
Monitor the Node
After the script completes, your node should be running. Check the logs for any errors. If the validator registration fails due to a quota, try again after the timestamp provided in the error message.

Troubleshooting

Docker Connectivity: 

If using a local Ethereum client, use host.docker.internal for L1 RPC URLs or set network_mode: host in a Docker Compose setup (Linux only).
Validator Quota Filled: The testnet limits validator registration. If you see ValidatorQuotaFilledUntil, wait until the specified timestamp and retry.
Network Issues: Ensure port 40400 (or your chosen port) is open and forwarded. Use curl ipv4.icanhazip.com to verify your public IP.
Logs: Check Docker logs for the Aztec container (docker logs <container_id>) for debugging.

Additional Resources

Aztec CLI Reference: Run aztec help start or aztec help add-l1-validator for parameter details.
Community Support: Join the Aztec Discord for help.
Faucet: Obtain Sepolia ETH from Sepolia PoW Faucet.

Advanced Configuration: 

Refer to the Aztec documentation for Docker Compose setups or environment variable configurations.

Notes

The script assumes a clean setup. 
If you have an existing Aztec installation, it will update to the latest testnet version.
Ensure your Ethereum account has sufficient Sepolia ETH for gas costs.
For production environments, consider using a dedicated Ethereum private key for security.

Happy sequencing!

---

### Instructions for Use

1. **Save the Files**:
   - Save the bash script as `install_aztec_sequencer.sh`.
   - Save the README as `README.md` in the same directory.

2. **Make the Script Executable**:
   ```bash
   chmod +x install_aztec_sequencer.sh

Run the Script:bash

./install_aztec_sequencer.sh

Follow the README:

Refer to the README for detailed instructions, 
troubleshooting tips, 
and additional resources.

Ensure you have Sepolia ETH and your public IP before running the script.
Forward the P2P port (default: 40400) on your router if needed.

