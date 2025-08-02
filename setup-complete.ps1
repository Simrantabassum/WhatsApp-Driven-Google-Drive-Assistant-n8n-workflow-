# WhatsApp Drive Assistant - Setup Completion Script
Write-Host "🚀 WhatsApp Drive Assistant - Setup Completion" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

# Check if n8n is running
Write-Host "📊 Checking n8n service status..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5678/healthz" -Method GET -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ n8n is running and healthy!" -ForegroundColor Green
    } else {
        Write-Host "❌ n8n is not responding properly" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Cannot connect to n8n. Make sure the container is running." -ForegroundColor Red
    Write-Host "   Run: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🌐 Access Information:" -ForegroundColor Cyan
Write-Host "   n8n Interface: http://localhost:5678" -ForegroundColor White
Write-Host "   Username: admin" -ForegroundColor White
Write-Host "   Password: admin123" -ForegroundColor White
Write-Host ""

Write-Host "📋 Next Steps to Complete Setup:" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. 📥 Import Workflow:" -ForegroundColor Yellow
Write-Host "   - Open http://localhost:5678 in your browser" -ForegroundColor White
Write-Host "   - Login with admin/admin123" -ForegroundColor White
Write-Host "   - Go to Workflows → Import from file" -ForegroundColor White
Write-Host "   - Select the workflow.json file from this directory" -ForegroundColor White
Write-Host ""

Write-Host "2. 🔑 Configure Credentials:" -ForegroundColor Yellow
Write-Host "   - Go to Credentials → Add Credential" -ForegroundColor White
Write-Host "   - Set up Google Drive OAuth2 API:" -ForegroundColor White
Write-Host "     * Client ID: Your Google Client ID" -ForegroundColor Gray
Write-Host "     * Client Secret: Your Google Client Secret" -ForegroundColor Gray
Write-Host "     * Scopes: https://www.googleapis.com/auth/drive" -ForegroundColor Gray
Write-Host "   - Set up HTTP Basic Auth (for Twilio):" -ForegroundColor White
Write-Host "     * Username: Your Twilio Account SID" -ForegroundColor Gray
Write-Host "     * Password: Your Twilio Auth Token" -ForegroundColor Gray
Write-Host "   - Set up OpenAI API:" -ForegroundColor White
Write-Host "     * API Key: Your OpenAI API Key" -ForegroundColor Gray
Write-Host ""

Write-Host "3. ⚙️ Update Workflow Credentials:" -ForegroundColor Yellow
Write-Host "   - Open the imported workflow" -ForegroundColor White
Write-Host "   - For each node that requires credentials:" -ForegroundColor White
Write-Host "     * Click on the node" -ForegroundColor Gray
Write-Host "     * In the credentials section, select your configured credential" -ForegroundColor Gray
Write-Host "     * Save the node" -ForegroundColor Gray
Write-Host ""

Write-Host "4. 🚀 Activate Workflow:" -ForegroundColor Yellow
Write-Host "   - Click the Activate button in the workflow" -ForegroundColor White
Write-Host "   - The webhook will then be available at:" -ForegroundColor White
Write-Host "     http://localhost:5678/webhook/whatsapp" -ForegroundColor Gray
Write-Host ""

Write-Host "5. 📱 Configure Twilio Webhook:" -ForegroundColor Yellow
Write-Host "   - In Twilio Console, set webhook URL to:" -ForegroundColor White
Write-Host "     http://localhost:5678/webhook/whatsapp" -ForegroundColor Gray
Write-Host "   - Method: POST" -ForegroundColor Gray
Write-Host ""

Write-Host "6. 🧪 Test the Setup:" -ForegroundColor Yellow
Write-Host "   - Send HELP to your Twilio WhatsApp number" -ForegroundColor White
Write-Host "   - You should receive a response with available commands" -ForegroundColor White
Write-Host ""

Write-Host "📁 Configuration Files:" -ForegroundColor Cyan
Write-Host "   - .env - Environment variables (update with your credentials)" -ForegroundColor White
Write-Host "   - workflow.json - n8n workflow configuration" -ForegroundColor White
Write-Host "   - docker-compose.yml - Docker configuration" -ForegroundColor White
Write-Host ""

Write-Host "🔧 Useful Commands:" -ForegroundColor Cyan
Write-Host "   - Check status: docker-compose ps" -ForegroundColor White
Write-Host "   - View logs: docker-compose logs n8n" -ForegroundColor White
Write-Host "   - Stop services: docker-compose down" -ForegroundColor White
Write-Host "   - Restart services: docker-compose restart" -ForegroundColor White
Write-Host ""

Write-Host "📖 Documentation:" -ForegroundColor Cyan
Write-Host "   - README.md - Complete project documentation" -ForegroundColor White
Write-Host "   - docs/setup-guide.md - Detailed setup instructions" -ForegroundColor White
Write-Host "   - docs/troubleshooting.md - Common issues and solutions" -ForegroundColor White
Write-Host ""

Write-Host "🎉 Setup is ready! Follow the steps above to complete the configuration." -ForegroundColor Green
Write-Host ""

# Test webhook endpoint
Write-Host "🧪 Testing webhook endpoint..." -ForegroundColor Yellow
try {
    $webhookResponse = Invoke-WebRequest -Uri "http://localhost:5678/webhook/whatsapp" -Method POST -ContentType "application/x-www-form-urlencoded" -Body "From=whatsapp:+1234567890&Body=HELP" -TimeoutSec 10
    Write-Host "✅ Webhook endpoint is accessible" -ForegroundColor Green
    Write-Host "   Note: You'll see a 404 error until the workflow is imported and activated" -ForegroundColor Yellow
} catch {
    Write-Host "⚠️ Webhook endpoint test failed (this is normal before workflow activation)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Setup is ready! Open http://localhost:5678 in your browser to continue." -ForegroundColor Green 