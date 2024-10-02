#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Global variables
GIT_REPO="https://github.com/arun993/typescript-tutorial.git"
PINATA_URL="https://pinata.cloud/"
CONTRACT1_URL="https://testnet.storyscan.xyz/address/0x91f6F05B08c16769d3c85867548615d270C42fC7?tab=write_contract#40c10f19"
CONTRACT2_URL="https://testnet.storyscan.xyz/address/0x91f6F05B08c16769d3c85867548615d270C42fC7?tab=write_contract#095ea7b3"
SPG_COLLECTION_CMD="npm run create-spg-collection"

# Print message in center of terminal
print_center() {
    local msg="$1"
    printf "%*s\n" $((($(tput cols) + ${#msg}) / 2)) "$msg"
}

# Main function
main() {
    # Run external script via curl
    curl -s https://raw.githubusercontent.com/arun993/mylogo/refs/heads/main/logo.sh | bash

    sleep 3

    # Print starting message
    print_center "Script is starting.. [PLEASE USE BURNER WALLET]"
    sleep 3

    # Clone repository and navigate
    if ! git clone "$GIT_REPO"; then
        printf "Failed to clone the repository\n" >&2
        exit 1
    fi
    cd typescript-tutorial || { printf "Directory not found\n" >&2; exit 1; }

    # Take user input for .env file
    read -r -p "Enter your Wallet Private Key: " wallet_private_key
    read -r -p "Go to $PINATA_URL (and extract JWT from API Key). Enter Pinata JWT: " pinata_jwt

    # Create .env file
    {
        printf "WALLET_PRIVATE_KEY=%s\n" "$wallet_private_key"
        printf "PINATA_JWT=%s\n" "$pinata_jwt"
    } > .env

    # Install dependencies
    npm install

    # Run non-commercial script
    npm run non-commercial

    # Instructions to perform actions on testnet
    printf "\nDo these 2 tasks (NEED SOME $IP ON TESTNET):\n\n"
    printf "Go to: %s\n" "$CONTRACT1_URL"
    printf "Connect your wallet\n"
    printf "address = your metamask address\n"
    printf "unit256 = 10\n"
    printf "Press write\n\n"
    printf "Then go to: %s\n" "$CONTRACT2_URL"
    printf "Connect your wallet\n"
    printf "spender address = 0x4074CEC2B3427f983D14d0C5E962a06B7162Ab92\n"
    printf "unit256 = 1\n"
    printf "Press write\n\n"

    read -r -p "Have you done these 2 steps? (y/Y to continue): " confirmation
    if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
        printf "Please complete the required steps before continuing.\n" >&2
        exit 1
    fi

    # Run commercial script
    npm run commercial

    # Create SPG collection and get NFT contract address
    nft_contract_address=$($SPG_COLLECTION_CMD | grep -oE '0x[a-fA-F0-9]{40}')
    if [[ -z "$nft_contract_address" ]]; then
        printf "Failed to create SPG collection or extract contract address.\n" >&2
        exit 1
    fi

    printf "NFT CONTRACT ADDRESS: %s\n" "$nft_contract_address"
    printf "Please save this address.\n"

    # Append NFT contract address to .env file
    printf "NFT_CONTRACT_ADDRESS=%s\n" "$nft_contract_address" >> .env

    # Run metadata script and display output
    npm run metadata

    printf "Done You have succefully registered IP on the blockchain...\n"
}

main "$@"
