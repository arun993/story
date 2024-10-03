#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Global variables
GIT_REPO="https://github.com/arun993/typescript-tutorial.git"
PINATA_URL="https://pinata.cloud/"
SPG_COLLECTION_CMD="npm run create-spg-collection"

# Print message in center of terminal
print_center() {
    local msg="$1"
    printf "%*s\n" $((($(tput cols) + ${#msg}) / 2)) "$msg"
}

# Main function
main() {
    # Cleanup existing files and directories
    rm -rf typescript-tutorial

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
    printf "\n"

    read -r -p "Go to $PINATA_URL (and extract JWT from API Key). Enter Pinata JWT: " pinata_jwt
    printf "\n"


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
    printf "\nComplete Task no. 5th and 6th from the Guide\n"

    read -r -p "Have you done these 2 tasks? (y/Y to continue): " confirmation
    if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
        printf "Please complete the required steps before continuing.\n" >&2
        exit 1
    fi
    # Run commercial script 
    timeout 40s npm run commercial || true

    # Next command
    echo "Proceeding to the next command..."

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
