#!/bin/bash

# Ensure script is running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Installing development tools..."

# Update package lists
apt-get update

# Install basic dependencies
apt-get install -y curl wget unzip git apt-transport-https ca-certificates gnupg

# Install Docker
if ! command_exists docker; then
    echo "Installing Docker..."
    # Add Docker's official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list
    
    # Install Docker packages
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    usermod -aG docker $SUDO_USER
fi

# Install AWS CLI
if ! command_exists aws; then
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    ./aws/install
    rm -rf aws awscliv2.zip
fi

# Install Google Cloud SDK
if ! command_exists gcloud; then
    echo "Installing Google Cloud SDK..."
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
    apt-get update && apt-get install -y google-cloud-cli
fi

# Install Terraform
if ! command_exists terraform; then
    echo "Installing Terraform..."
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt-get update && apt-get install -y terraform
fi

# Install PNPM
if ! command_exists pnpm; then
    echo "Installing PNPM..."
    su - $SUDO_USER -c "curl -fsSL https://get.pnpm.io/install.sh | sh -"
    
    # Add PNPM to shell configs if not already present
    PNPM_CONFIG="# pnpm\nexport PNPM_HOME=\"\$HOME/.local/share/pnpm\"\ncase \":\$PATH:\" in\n  *\":\$PNPM_HOME:\"*) ;;\n  *) export PATH=\"\$PNPM_HOME:\$PATH\" ;;\nesac\n# pnpm end"
    
    for RC_FILE in "/home/$SUDO_USER/.bashrc" "/home/$SUDO_USER/.zshrc"; do
        if [ -f "$RC_FILE" ] && ! grep -q "PNPM_HOME" "$RC_FILE"; then
            echo -e "\n$PNPM_CONFIG" >> "$RC_FILE"
        fi
    done
fi

# Install UV (Python package manager)
if ! command_exists uv; then
    echo "Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Install SDKMAN
if ! command_exists sdk; then
    echo "Installing SDKMAN..."
    su - $SUDO_USER -c "curl -s 'https://get.sdkman.io' | bash"
    
    # Add SDKMAN to shell configs if not already present
    SDKMAN_CONFIG="\n#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!\nexport SDKMAN_DIR=\"\$HOME/.sdkman\"\n[[ -s \"\$HOME/.sdkman/bin/sdkman-init.sh\" ]] && source \"\$HOME/.sdkman/bin/sdkman-init.sh\""
    
    for RC_FILE in "/home/$SUDO_USER/.bashrc" "/home/$SUDO_USER/.zshrc"; do
        if [ -f "$RC_FILE" ] && ! grep -q "SDKMAN_DIR" "$RC_FILE"; then
            echo -e "$SDKMAN_CONFIG" >> "$RC_FILE"
        fi
    done
    
    # Source SDKMAN and install tools
    su - $SUDO_USER -c "source '$HOME/.sdkman/bin/sdkman-init.sh' && \
        sdk install maven && \
        sdk install gradle"
fi

echo "Installation complete! Please log out and back in for all changes to take effect." 