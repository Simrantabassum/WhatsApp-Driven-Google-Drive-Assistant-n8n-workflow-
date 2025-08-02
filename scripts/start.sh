#!/bin/bash

# WhatsApp-Driven Google Drive Assistant - Start Script
# This script starts the n8n workflow services

set -e

echo "🚀 Starting WhatsApp-Driven Google Drive Assistant"
echo "================================================="

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

# Check if .env file exists
check_env_file() {
    if [ ! -f ".env" ]; then
        print_error ".env file not found. Please run ./scripts/setup.sh first."
        exit 1
    fi
}

# Check if Docker is running
check_docker_running() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Start services
start_services() {
    print_status "Starting n8n services..."
    
    # Stop any existing containers
    print_status "Stopping existing containers..."
    docker-compose down --remove-orphans
    
    # Start services
    print_status "Starting services with Docker Compose..."
    docker-compose up -d
    
    print_success "Services started successfully!"
}

# Wait for n8n to be ready
wait_for_n8n() {
    print_status "Waiting for n8n to be ready..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:5678/healthz > /dev/null 2>&1; then
            print_success "n8n is ready!"
            return 0
        fi
        
        print_status "Attempt $attempt/$max_attempts - Waiting for n8n..."
        sleep 10
        ((attempt++))
    done
    
    print_warning "n8n may still be starting up. Please check manually at http://localhost:5678"
    return 1
}

# Display status
display_status() {
    echo ""
    echo "📊 Service Status"
    echo "================"
    echo ""
    
    # Check if containers are running
    if docker-compose ps | grep -q "Up"; then
        print_success "Services are running:"
        docker-compose ps
    else
        print_error "Services are not running properly"
        docker-compose ps
    fi
    
    echo ""
    echo "🌐 Access Information"
    echo "==================="
    echo "n8n Interface: http://localhost:5678"
    echo "Username: admin"
    echo "Password: (check .env file)"
    echo ""
    echo "📱 WhatsApp Webhook: http://localhost:5678/webhook/whatsapp"
    echo ""
    echo "📋 Next Steps:"
    echo "1. Open n8n at http://localhost:5678"
    echo "2. Import workflow.json"
    echo "3. Configure credentials"
    echo "4. Activate the workflow"
    echo "5. Configure Twilio webhook"
    echo ""
    echo "📖 For detailed instructions, see README.md"
}

# Stop services
stop_services() {
    print_status "Stopping services..."
    docker-compose down
    print_success "Services stopped"
}

# Show logs
show_logs() {
    print_status "Showing n8n logs..."
    docker-compose logs -f n8n
}

# Main function
main() {
    case "${1:-start}" in
        "start")
            check_env_file
            check_docker_running
            start_services
            wait_for_n8n
            display_status
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            stop_services
            sleep 2
            start_services
            wait_for_n8n
            display_status
            ;;
        "logs")
            show_logs
            ;;
        "status")
            display_status
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  start   - Start the services (default)"
            echo "  stop    - Stop the services"
            echo "  restart - Restart the services"
            echo "  logs    - Show n8n logs"
            echo "  status  - Show service status"
            echo "  help    - Show this help message"
            ;;
        *)
            print_error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 