#!/bin/bash

# ===== NutriChef Deployment Script =====
# Automated deployment to Web01, Web02, and Load Balancer

set -e  # Exit on error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Server Configuration
WEB01_IP="54.90.50.233"
WEB02_IP="100.26.232.98"
LB_IP="54.236.50.227"
SSH_USER="ubuntu"
APP_DIR="/var/www/nutrichef"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   NutriChef Deployment Script         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

# Check if files exist
echo -e "${YELLOW}→ Checking files...${NC}"
if [ ! -f "index.html" ] || [ ! -f "css/style.css" ] || [ ! -f "js/app.js" ]; then
    echo -e "${RED}✗ Error: Required files not found!${NC}"
    echo -e "  Make sure you're in the project root directory"
    exit 1
fi
echo -e "${GREEN}✓ All files found${NC}\n"

# Function to deploy to a web server
deploy_to_server() {
    local SERVER_IP=$1
    local SERVER_NAME=$2
    
    echo -e "${BLUE}→ Deploying to ${SERVER_NAME} (${SERVER_IP})...${NC}"
    
    # Create directory structure
    ssh ${SSH_USER}@${SERVER_IP} << 'ENDSSH'
        sudo mkdir -p /var/www/nutrichef/{css,js}
        sudo chown -R $USER:$USER /var/www/nutrichef
ENDSSH
    
    # Copy files
    echo "  Copying files..."
    scp index.html ${SSH_USER}@${SERVER_IP}:${APP_DIR}/
    scp css/style.css ${SSH_USER}@${SERVER_IP}:${APP_DIR}/css/
    scp js/config.js ${SSH_USER}@${SERVER_IP}:${APP_DIR}/js/
    scp js/app.js ${SSH_USER}@${SERVER_IP}:${APP_DIR}/js/
    
    # Configure Nginx
    echo "  Configuring Nginx..."
    scp config/nginx-site.conf ${SSH_USER}@${SERVER_IP}:/tmp/
    
    ssh ${SSH_USER}@${SERVER_IP} << 'ENDSSH'
        # Install Nginx if needed
        if ! command -v nginx &> /dev/null; then
            sudo apt update && sudo apt install nginx -y
        fi
        
        # Configure Nginx
        sudo mv /tmp/nginx-site.conf /etc/nginx/sites-available/nutrichef
        sudo ln -sf /etc/nginx/sites-available/nutrichef /etc/nginx/sites-enabled/
        sudo rm -f /etc/nginx/sites-enabled/default
        
        # Test and restart
        sudo nginx -t
        sudo systemctl restart nginx
        sudo systemctl enable nginx
ENDSSH
    
    echo -e "${GREEN}✓ ${SERVER_NAME} deployment complete${NC}\n"
}

# Deploy to Web01
deploy_to_server ${WEB01_IP} "Web01"

# Deploy to Web02
deploy_to_server ${WEB02_IP} "Web02"

# Configure Load Balancer
echo -e "${BLUE}→ Configuring Load Balancer (${LB_IP})...${NC}"

scp config/haproxy.cfg ${SSH_USER}@${LB_IP}:/tmp/

ssh ${SSH_USER}@${LB_IP} << 'ENDSSH'
    # Install HAProxy if needed
    if ! command -v haproxy &> /dev/null; then
        sudo apt update && sudo apt install haproxy -y
    fi
    
    # Backup existing config
    sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.backup
    
    # Install new config
    sudo mv /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg
    
    # Test and restart
    sudo haproxy -c -f /etc/haproxy/haproxy.cfg
    sudo systemctl restart haproxy
    sudo systemctl enable haproxy
ENDSSH

echo -e "${GREEN}✓ Load balancer configuration complete${NC}\n"

# Test Deployment
echo -e "${BLUE}→ Testing deployment...${NC}"

# Test Web01
echo -n "  Testing Web01... "
if curl -s -o /dev/null -w "%{http_code}" http://${WEB01_IP} | grep -q "200"; then
    echo -e "${GREEN}✓ OK${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi

# Test Web02
echo -n "  Testing Web02... "
if curl -s -o /dev/null -w "%{http_code}" http://${WEB02_IP} | grep -q "200"; then
    echo -e "${GREEN}✓ OK${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi

# Test Load Balancer
echo -n "  Testing Load Balancer... "
if curl -s -o /dev/null -w "%{http_code}" http://${LB_IP} | grep -q "200"; then
    echo -e "${GREEN}✓ OK${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi

# Summary
echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Deployment Complete!                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

echo -e "${GREEN}Access your application at:${NC}"
echo -e "  Web01:         http://${WEB01_IP}"
echo -e "  Web02:         http://${WEB02_IP}"
echo -e "  Load Balancer: http://${LB_IP}"
echo -e "\n${GREEN}HAProxy Statistics:${NC}"
echo -e "  URL:      http://${LB_IP}:8080/haproxy?stats"
echo -e "  Username: admin"
echo -e "  Password: nutrichef2024"
echo -e "\n${YELLOW}Monitor logs with:${NC}"
echo -e "  ssh ${SSH_USER}@${WEB01_IP} 'sudo tail -f /var/log/nginx/access.log'"
echo -e "  ssh ${SSH_USER}@${LB_IP} 'sudo tail -f /var/log/haproxy.log'"
