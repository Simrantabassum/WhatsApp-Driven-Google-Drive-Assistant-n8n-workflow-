#!/bin/bash

# WhatsApp-Driven Google Drive Assistant - Setup Script
# This script helps set up the n8n workflow with all required configurations

set -e

echo "🚀 Setting up WhatsApp-Driven Google Drive Assistant"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    print_status "Checking Docker installation..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Docker and Docker Compose are installed"
}

# Check if .env file exists
check_env_file() {
    print_status "Checking environment configuration..."
    
    if [ ! -f ".env" ]; then
        print_warning ".env file not found. Creating from template..."
        if [ -f "env.example" ]; then
            cp env.example .env
            print_success "Created .env file from template"
            print_warning "Please edit .env file with your actual credentials"
        else
            print_error "env.example file not found. Please create .env file manually."
            exit 1
        fi
    else
        print_success ".env file exists"
    fi
}

# Validate environment variables
validate_env() {
    print_status "Validating environment variables..."
    
    # Check required variables
    required_vars=(
        "TWILIO_ACCOUNT_SID"
        "TWILIO_AUTH_TOKEN"
        "TWILIO_PHONE_NUMBER"
        "OPENAI_API_KEY"
        "GOOGLE_CLIENT_ID"
        "GOOGLE_CLIENT_SECRET"
    )
    
    missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" .env || grep -q "^${var}=$" .env || grep -q "^${var}=your_" .env; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        print_warning "The following environment variables need to be configured:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        print_warning "Please edit .env file and add your credentials"
        return 1
    fi
    
    print_success "All required environment variables are configured"
    return 0
}

# Create necessary directories
create_directories() {
    print_status "Creating necessary directories..."
    
    mkdir -p data
    mkdir -p logs
    mkdir -p backups
    
    print_success "Directories created"
}

# Generate encryption key
generate_encryption_key() {
    print_status "Generating encryption key..."
    
    if ! grep -q "^N8N_ENCRYPTION_KEY=" .env || grep -q "^N8N_ENCRYPTION_KEY=your-encryption-key-here" .env; then
        encryption_key=$(openssl rand -hex 32)
        sed -i.bak "s/N8N_ENCRYPTION_KEY=.*/N8N_ENCRYPTION_KEY=$encryption_key/" .env
        print_success "Generated new encryption key"
    else
        print_success "Encryption key already configured"
    fi
}

# Test Docker Compose configuration
test_docker_compose() {
    print_status "Testing Docker Compose configuration..."
    
    if docker-compose config > /dev/null 2>&1; then
        print_success "Docker Compose configuration is valid"
    else
        print_error "Docker Compose configuration is invalid"
        docker-compose config
        exit 1
    fi
}

# Display setup instructions
display_instructions() {
    echo ""
    echo "📋 Setup Instructions"
    echo "===================="
    echo ""
    echo "1. Configure your credentials in .env file:"
    echo "   - Twilio Account SID and Auth Token"
    echo "   - Google OAuth2 Client ID and Secret"
    echo "   - OpenAI API Key"
    echo ""
    echo "2. Start the services:"
    echo "   ./scripts/start.sh"
    echo ""
    echo "3. Access n8n at: http://localhost:5678"
    echo "   Username: admin"
    echo "   Password: (from .env file)"
    echo ""
    echo "4. Import the workflow:"
    echo "   - Go to Workflows in n8n"
    echo "   - Click 'Import from file'"
    echo "   - Select workflow.json"
    echo ""
    echo "5. Configure credentials in n8n:"
    echo "   - Google Drive OAuth2"
    echo "   - Twilio Basic Auth"
    echo "   - OpenAI API"
    echo ""
    echo "6. Activate the workflow"
    echo ""
    echo "7. Configure Twilio webhook:"
    echo "   URL: https://your-domain.com/webhook/whatsapp"
    echo "   Method: POST"
    echo ""
    echo "For detailed instructions, see README.md"
}

# Main setup function
main() {
    check_docker
    check_env_file
    create_directories
    generate_encryption_key
    test_docker_compose
    
    if validate_env; then
        print_success "Setup completed successfully!"
        print_status "You can now start the services with: ./scripts/start.sh"
    else
        print_warning "Setup completed with warnings."
        print_status "Please configure missing environment variables before starting."
    fi
    
    display_instructions
}

# Run main function
main "$@" 