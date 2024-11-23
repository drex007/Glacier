#!/bin/bash

# Define color codes
INFO='\033[0;36m'   # Cyan
BANNER='\033[0;35m' # Magenta
WARNING='\033[0;33m'
ERROR='\033[0;31m'
SUCCESS='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'        # No Color

# Display social details and channel information
echo "==================================="
echo -e "${BANNER}           CryptonodeHindi       ${NC}"
echo "==================================="
echo -e "${YELLOW}Telegram: https://t.me/cryptonodehindi${NC}"
echo -e "${YELLOW}Twitter: @CryptonodeHindi${NC}"
echo -e "${YELLOW}YouTube: https://www.youtube.com/@CryptonodesHindi${NC}"
echo -e "${YELLOW}Medium: https://medium.com/@cryptonodehindi${NC}"
echo "==================================="

# Update the package list
sudo apt update

# Check if Docker is installed, if not, install Docker
if ! command -v docker &> /dev/null; then
    echo -e "${WARNING}Docker not found. Installing Docker...${NC}"
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    echo -e "${SUCCESS}Docker installed successfully.${NC}"
else
    echo -e "${SUCCESS}Docker is already installed.${NC}"
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${INFO}Installing Docker Compose...${NC}"
    VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
    sudo curl -L "https://github.com/docker/compose/releases/download/$VER/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${SUCCESS}Docker Compose installed successfully. Version: $(docker-compose --version)${NC}"
else
    echo -e "${SUCCESS}Docker Compose is already installed.${NC}"
fi

# Ask user for the list of private keys
echo -e "${INFO}Make sure to claim the Faucet before starting the containers.${NC}"
echo -e "${YELLOW}Enter the private keys (comma-separated) for each instance.${NC}"
read -p "Enter your EVM PRIVATE KEYS: " PRIVATE_KEYS

# Split the keys into a list
IFS=',' read -r -a KEYS <<< "$PRIVATE_KEYS"

if [ ${#KEYS[@]} -eq 0 ]; then
    echo -e "${ERROR}At least one Private Key is required to proceed. Exiting.${NC}"
    exit 1
fi

# Run the Docker container for each key
for i in "${!KEYS[@]}"; do
    KEY=${KEYS[$i]}
    CONTAINER_NAME="glacier-verifier-$((i + 1))"

    # Check if a container with the same name already exists
    if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
        TIMESTAMP=$(date +%Y%m%d%H%M%S)
        NEW_NAME="${CONTAINER_NAME}-old-$TIMESTAMP"
        echo -e "${WARNING}Container with name $CONTAINER_NAME already exists. Renaming it to $NEW_NAME...${NC}"
        docker rename "$CONTAINER_NAME" "$NEW_NAME"
    fi

    echo -e "${INFO}Starting container for key $((i + 1)) with name $CONTAINER_NAME...${NC}"
    docker run -d -e PRIVATE_KEY="$KEY" --name "$CONTAINER_NAME" docker.io/glaciernetwork/glacier-verifier:v0.0.1

    if [ $? -eq 0 ]; then
        echo -e "${SUCCESS}Container $CONTAINER_NAME started successfully.${NC}"
    else
        echo -e "${ERROR}Failed to start container $CONTAINER_NAME.${NC}"
    fi
done

# Display thank you message
echo "==================================="
echo -e "${BANNER}           CryptonodeHindi       ${NC}"
echo "==================================="
echo -e "${SUCCESS}    Thanks for using this script!${NC}"
echo "==================================="
echo -e "${YELLOW}Twitter: @CryptonodeHindi${NC}"
echo -e "${YELLOW}YouTube: https://www.youtube.com/@CryptonodesHindi${NC}"
echo -e "${YELLOW}Medium: https://medium.com/@cryptonodehindi${NC}"
echo -e "${YELLOW}Join our Telegram for any support: https://t.me/cryptonodehindi${NC}"
echo "==================================="
