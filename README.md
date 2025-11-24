NutriChef - Smart Recipe & Meal Planning Application

A professional web application providing access to 365,000+ recipes with complete nutritional information, dietary filtering, and meal planning capabilities powered by the Spoonacular API.

📋 Table of Contents

Project Structure

Features

Quick Start

API Key Setup

Local Development

Deployment

Configuration

Testing

Troubleshooting

API Documentation

📁 Project Structure

nutrichef/
├── index.html                 # Main HTML file
├── css/
│   └── style.css             # All styles (modern, responsive)
├── js/
│   ├── config.js             # API configuration
│   └── app.js                # Main application logic
├── config/
│   ├── nginx-site.conf       # Nginx server configuration
│   └── haproxy.cfg           # HAProxy load balancer config
├── scripts/
│   └── deploy.sh             # Automated deployment script
├── .gitignore                # Git ignore file
└── README.md                 # This file


✨ Features

Core Functionality

365,000+ Recipes: Access comprehensive recipe database

Nutritional Data: Complete macro/micronutrient information

Smart Filtering: 
  - 25+ cuisines (Italian, Chinese, Mexican, etc.)
  - 6 dietary preferences (Vegan, Vegetarian, Gluten-Free, Dairy-Free, Keto, Paleo)
  - Cooking time filtering

Interactive Sorting: By popularity, time, health score, or calories

Real-time Search: Filter recipes instantly

Detailed Recipe View: Ingredients, step-by-step instructions, nutrition breakdown

User Experience

Professional, modern design with gradient animations

Fully responsive (mobile, tablet, desktop)

Smooth transitions and hover effects

Modal recipe details

Loading states and error handling

Keyboard navigation (ESC to close modals)

🚀 Quick Start

1. Get API Key (5 minutes)

Visit: https://spoonacular.com/food-api

Click "Get Started" → Choose FREE plan

Sign up and verify email

Copy API key from console (32 characters)

2. Setup Project

# Clone or download repository
cd nutrichef

# Configure API key in js/config.js
# Replace 'YOUR_SPOONACULAR_API_KEY' with your actual key


3. Run Locally

# Option 1: Python
python3 -m http.server 8000

# Option 2: Node.js
npx http-server -p 8000

# Option 3: Double-click index.html

# Visit: http://localhost:8000


4. Test Application

Search: "pasta"

Cuisine: "Italian"

Dietary: Check "Vegetarian"

Click "Discover Recipes"

Click any recipe card for details

🔑 API Key Setup

Obtaining Your Key

Free Tier Includes:

150 API calls per day

All endpoints access

Complete nutritional data

No credit card required

Steps:

Go to https://spoonacular.com/food-api

Sign up for free account

Verify email (check spam folder)

Navigate to "My Console" → "Profile"

Copy your 32-character API key

Example Key Format:

1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d


Installing the Key

File: js/config.js  
Line: 3

// BEFORE
const API_KEY = 'YOUR_SPOONACULAR_API_KEY';

// AFTER (with your actual key)
const API_KEY = '1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d';


⚠️ Important: Never commit your API key to public repositories!

For Submission

In the assignment comment section, include:

SPOONACULAR_API_KEY=your_actual_32_character_key_here


💻 Local Development

Requirements

Modern browser (Chrome, Firefox, Safari, Edge)

Text editor (VS Code recommended)

HTTP server (Python, Node.js, or Live Server)

File Structure Explained

index.html

Main HTML structure

Semantic markup

Navigation, search form, results section

Recipe modal

Footer

css/style.css

CSS variables for theming

Responsive grid layouts

Animations and transitions

Mobile-first design

Cross-browser compatibility

js/config.js

API key storage

API endpoints configuration

App settings

js/app.js

Event handlers

API calls

DOM manipulation

Recipe display logic

Modal management

Development Workflow

Edit files in your text editor

Refresh browser to see changes

Use browser DevTools (F12) for debugging

Check console for errors

Test responsive design (Ctrl+Shift+M in Chrome)

🌐 Deployment

Architecture

Internet → Load Balancer (HAProxy) → Web01 (Nginx)
                                    → Web02 (Nginx)


Server Information

Web01 (6615-web-01): 18.205.161.238

Web02 (6615-web-02): 52.90.56.75

Load Balancer (6615-lb-01): 44.211.210.132

Deploy to Web01

# SSH into server
ssh ubuntu@18.205.161.238

# Install Nginx
sudo apt update && sudo apt install nginx -y

# Create application directory
sudo mkdir -p /var/www/nutrichef
sudo chown -R $USER:$USER /var/www/nutrichef

# Exit to copy files
exit

# Copy files from local machine
scp index.html ubuntu@18.205.161.238:/var/www/nutrichef/
scp css/style.css ubuntu@18.205.161.238:/var/www/nutrichef/css/
scp js/config.js ubuntu@18.205.161.238:/var/www/nutrichef/js/
scp js/app.js ubuntu@18.205.161.238:/var/www/nutrichef/js/

# Copy Nginx config
scp config/nginx-site.conf ubuntu@18.205.161.238:/tmp/

# SSH back and configure
ssh ubuntu@18.205.161.238
sudo mv /tmp/nginx-site.conf /etc/nginx/sites-available/nutrichef
sudo ln -s /etc/nginx/sites-available/nutrichef /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
exit


Deploy to Web02

Repeat the same steps but use:

ssh ubuntu@52.90.56.75


Configure Load Balancer

# SSH into load balancer
ssh ubuntu@44.211.210.132

# Install HAProxy
sudo apt update && sudo apt install haproxy -y

# Copy configuration
scp config/haproxy.cfg ubuntu@44.211.210.132:/tmp/

# Apply configuration
ssh ubuntu@44.211.210.132
sudo mv /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg
sudo systemctl restart haproxy
sudo systemctl enable haproxy
exit


Verify Deployment

# Test individual servers
curl -I [http://18.205.161.238](http://18.205.161.238)
curl -I [http://52.90.56.75](http://52.90.56.75)

# Test load balancer
curl -I [http://44.211.210.132](http://44.211.210.132)

# View HAProxy stats
# Open browser: [http://44.211.210.132:8080/haproxy?stats](http://44.211.210.132:8080/haproxy?stats)
# Username: admin, Password: nutrichef2024


Automated Deployment

Use the provided deployment script:

chmod +x scripts/deploy.sh
./scripts/deploy.sh


⚙️ Configuration

Nginx Configuration (config/nginx-site.conf)

server {
    listen 80;
    server_name _;
    root /var/www/nutrichef;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Gzip compression enabled
    # Security headers added
    # Static asset caching configured
}


HAProxy Configuration (config/haproxy.cfg)

frontend nutrichef_frontend
    bind *:80
    default_backend nutrichef_servers

backend nutrichef_servers
    balance roundrobin
    option httpchk GET /
    server web01 18.205.161.238:80 check
    server web02 52.90.56.75:80 check

listen stats
    bind *:8080
    stats enable
    stats uri /haproxy?stats
    stats auth admin:nutrichef2024


🧪 Testing

Functional Testing

Test 1: Basic Search

Query: pasta
Expected: 12 pasta recipes displayed


Test 2: Filtered Search

Query: chicken
Cuisine: Asian
Time: 30 minutes
Dietary: Gluten Free
Expected: Quick Asian chicken recipes


Test 3: Sorting

Change sort dropdown
Expected: Cards reorder appropriately


Test 4: Recipe Details

Click any recipe card
Expected: Modal with ingredients, instructions, nutrition


Load Balancer Testing

# Test traffic distribution
for i in {1..10}; do
    curl -s [http://44.211.210.132](http://44.211.210.132) | head -n 1
done

# Monitor server logs
ssh ubuntu@18.205.161.238
sudo tail -f /var/log/nginx/access.log


Failover Testing

# Stop Web01
ssh ubuntu@18.205.161.238
sudo systemctl stop nginx
exit

# Verify load balancer still works
curl -I [http://44.211.210.132](http://44.211.210.132)

# Check HAProxy stats (Web01 should be DOWN, Web02 UP)

# Restart Web01
ssh ubuntu@18.205.161.238
sudo systemctl start nginx


🐛 Troubleshooting

API Key Issues

Problem: 401 Unauthorized  
Solution: 

Verify API key is correct (32 characters)

Check for typos

Ensure email is verified

Wait 10 minutes after registration

Problem: 402 Payment Required  
Solution: Daily quota exceeded, wait until midnight UTC

Deployment Issues

Problem: 404 Not Found on server  
Solution:

# Check file location
ssh ubuntu@18.205.161.238
ls -la /var/www/nutrichef/

# Verify Nginx config
sudo nginx -t

# Check logs
sudo tail -f /var/log/nginx/error.log


Problem: HAProxy shows servers DOWN  
Solution:

# Test servers directly
curl -I [http://18.205.161.238](http://18.205.161.238)

# Restart HAProxy
ssh ubuntu@44.211.210.132
sudo systemctl restart haproxy


Application Issues

Problem: No results displayed  
Solution:

Open browser console (F12)

Check for API errors

Verify API key in config.js

Try broader search terms

Problem: Slow loading  
Solution:

Reduce number of results in config.js

Check network connection

Clear browser cache

📚 API Documentation

Spoonacular API

Base URL: https://api.spoonacular.com

Endpoints Used

1. Complex Recipe Search

GET /recipes/complexSearch


Parameters:

apiKey (required): Your API key

query (required): Search term

cuisine: Cuisine type

diet: Dietary restriction

maxReadyTime: Max cooking time

number: Results count (default: 10)

addRecipeInformation: true/false

addRecipeNutrition: true/false

Example:

const url = `https://api.spoonacular.com/recipes/complexSearch?apiKey=YOUR_KEY&query=pasta&cuisine=italian&diet=vegetarian&maxReadyTime=45&number=12&addRecipeInformation=true&addRecipeNutrition=true`;


2. Get Recipe Information

GET /recipes/{id}/information


Parameters:

apiKey (required): Your API key

id (required): Recipe ID

includeNutrition: true/false

Rate Limits

Free Tier: 150 calls/day

Resets: Midnight UTC

Per request: No limit

Error Codes

200: Success

401: Invalid API key

402: Quota exceeded

404: Recipe not found

429: Rate limit exceeded

Official Resources

Documentation: https://spoonacular.com/food-api/docs

Console: https://spoonacular.com/food-api/console

Pricing: https://spoonacular.com/food-api/pricing

📊 Project Requirements Met

✅ Functionality

Uses Spoonacular API (complex food/nutrition data)

Provides genuine value (meal planning, dietary needs)

Not a gimmick (solves real health/time/budget problems)

Advanced user interaction (sort, filter, search, modal views)

✅ Deployment

Deployed to Web01 (18.205.161.238)

Deployed to Web02 (52.90.56.75)

HAProxy load balancer configured (44.211.210.132)

Round-robin distribution with health checks

Failover tested and working

✅ User Experience

Professional, modern design

Fully responsive (mobile, tablet, desktop)

Intuitive navigation

Clear data presentation

Fast loading times

✅ Documentation

Comprehensive README

Clear setup instructions

Deployment guide

API documentation

Troubleshooting section

✅ Code Quality

Separated HTML, CSS, JavaScript

Clean, readable code

Proper error handling

Modern best practices

Security considerations

100% original work

🔒 Security & Best Practices

API Key Security

Never commit API keys to GitHub

Use .gitignore to exclude config files

For production: use environment variables or backend proxy

.gitignore

# API Keys
js/config.js
*.env
secrets.json

# OS Files
.DS_Store
Thumbs.db

# Logs
*.log

# Dependencies
node_modules/


Production Recommendations

Implement backend API proxy

Enable HTTPS/SSL

Add rate limiting

Implement caching (Redis)

Use CDN for static assets

🙏 Credits

API: Spoonacular Food & Nutrition API (https://spoonacular.com)  
Web Server: Nginx (https://nginx.org)  
Load Balancer: HAProxy (http://www.haproxy.org)  
Icons: Unicode Emoji

📝 License & Academic Integrity

This project is created for educational purposes. All code is original work written specifically for the Summative.

Student: [Nnamdi]  
Course: [Web Infrastructure]  
Institution: [African Leadership University]  
Date: [24/11/25]

📞 Support

For questions or issues:

Review this documentation

Check troubleshooting section

Verify API key configuration

Test with sample searches

Check browser console for errors

🚀 Quick Reference Commands

# Local Development
python3 -m http.server 8000

# Deploy Web01
scp -r * ubuntu@18.205.161.238:/var/www/nutrichef/

# Deploy Web02
scp -r * ubuntu@52.90.56.75:/var/www/nutrichef/

# Test Servers
curl -I [http://18.205.161.238](http://18.205.161.238)
curl -I [http://52.90.56.75](http://52.90.56.75)
curl -I [http://44.211.210.132](http://44.211.210.132)

# View Logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/haproxy.log

# Restart Services
sudo systemctl restart nginx
sudo systemctl restart haproxy


Made by Chibueze Nnamdi Onugha
