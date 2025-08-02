# Detailed Setup Guide

This guide provides step-by-step instructions for setting up the WhatsApp-Driven Google Drive Assistant.

## Prerequisites

Before starting, ensure you have:

- Docker and Docker Compose installed
- A Twilio account
- A Google Cloud Project
- An OpenAI API account
- Basic knowledge of command line operations

## Step 1: Clone and Prepare

```bash
# Clone the repository
git clone <your-repo-url>
cd task-2

# Make scripts executable
chmod +x scripts/*.sh

# Run the setup script
./scripts/setup.sh
```

## Step 2: Configure Twilio WhatsApp

### 2.1 Create Twilio Account

1. Go to [twilio.com](https://www.twilio.com) and sign up
2. Verify your account (required for WhatsApp)
3. Note your Account SID and Auth Token from the Console

### 2.2 Enable WhatsApp Sandbox

1. In Twilio Console, go to **Messaging** → **Try it out** → **Send a WhatsApp message**
2. Follow the instructions to join your sandbox:
   - Send the provided code to the WhatsApp number
   - Wait for confirmation
3. Note your WhatsApp number (format: `whatsapp:+14155238886`)

### 2.3 Configure Webhook

1. In Twilio Console, go to **Messaging** → **Settings** → **WhatsApp Sandbox Settings**
2. Set the webhook URL to: `https://your-domain.com/webhook/whatsapp`
3. Set the HTTP method to: `POST`
4. Save the configuration

## Step 3: Configure Google Drive API

### 3.1 Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select an existing one
3. Enable billing (required for API usage)

### 3.2 Enable APIs

1. Go to **APIs & Services** → **Library**
2. Search for and enable these APIs:
   - Google Drive API
   - Google Sheets API (for audit logging)

### 3.3 Create OAuth2 Credentials

1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth 2.0 Client IDs**
3. Configure the OAuth consent screen:
   - User Type: External
   - App name: WhatsApp Drive Assistant
   - User support email: your email
   - Developer contact information: your email
4. Create OAuth 2.0 Client ID:
   - Application type: Web application
   - Name: n8n WhatsApp Assistant
   - Authorized redirect URIs: `http://localhost:5678/callback`
5. Download the credentials JSON file

### 3.4 Configure Scopes

The following scopes are required:
- `https://www.googleapis.com/auth/drive` - Full access to Google Drive
- `https://www.googleapis.com/auth/spreadsheets` - Access to Google Sheets for audit logging

## Step 4: Configure OpenAI

### 4.1 Get API Key

1. Go to [platform.openai.com](https://platform.openai.com)
2. Sign up or log in
3. Go to **API Keys** section
4. Create a new API key
5. Copy the key (it starts with `sk-`)

### 4.2 Choose Model

Recommended models:
- `gpt-4o-mini` - Cost-effective, good for summaries
- `gpt-4o` - Higher quality, more expensive

## Step 5: Configure Environment Variables

Edit the `.env` file with your credentials:

```env
# Twilio Configuration
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=whatsapp:+14155238886

# Google Drive Configuration
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_REDIRECT_URI=http://localhost:5678/callback

# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key
OPENAI_MODEL=gpt-4o-mini

# n8n Configuration
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_secure_password
```

## Step 6: Start Services

```bash
# Start the services
./scripts/start.sh

# Check status
./scripts/start.sh status
```

## Step 7: Configure n8n

### 7.1 Access n8n

1. Open your browser and go to `http://localhost:5678`
2. Log in with:
   - Username: `admin`
   - Password: (from your .env file)

### 7.2 Import Workflow

1. In n8n, go to **Workflows**
2. Click **Import from file**
3. Select the `workflow.json` file
4. The workflow will be imported with all nodes

### 7.3 Configure Credentials

#### Google Drive OAuth2
1. Go to **Credentials** → **Add Credential**
2. Select **Google Drive OAuth2 API**
3. Configure:
   - Client ID: Your Google Client ID
   - Client Secret: Your Google Client Secret
   - Scopes: `https://www.googleapis.com/auth/drive`
4. Click **Save**
5. Click **Connect** and authorize with your Google account

#### Twilio Basic Auth
1. Go to **Credentials** → **Add Credential**
2. Select **HTTP Basic Auth**
3. Configure:
   - Username: Your Twilio Account SID
   - Password: Your Twilio Auth Token
4. Click **Save**

#### OpenAI API
1. Go to **Credentials** → **Add Credential**
2. Select **OpenAI API**
3. Configure:
   - API Key: Your OpenAI API Key
4. Click **Save**

### 7.4 Update Workflow Credentials

1. Open the imported workflow
2. For each node that requires credentials:
   - Click on the node
   - In the credentials section, select your configured credential
   - Save the node

### 7.5 Activate Workflow

1. Click the **Activate** button in the workflow
2. The workflow is now ready to receive webhooks

## Step 8: Test the Setup

### 8.1 Test WhatsApp Connection

1. Send a message to your Twilio WhatsApp number: `HELP`
2. You should receive a response with available commands

### 8.2 Test Google Drive Integration

1. Send: `LIST /Documents`
2. You should see a list of files in your Documents folder

### 8.3 Test AI Summarization

1. Upload a text file to Google Drive
2. Send: `SUMMARY /Documents`
3. You should receive an AI-generated summary

## Step 9: Production Deployment

### 9.1 Expose to Internet

For production use, you need to expose your n8n instance to the internet:

#### Option A: Using ngrok (for testing)
```bash
# Start ngrok
docker-compose --profile expose up -d

# Get the public URL
docker-compose logs ngrok
```

#### Option B: Using a domain (for production)
1. Configure your domain to point to your server
2. Set up SSL certificates
3. Update the webhook URL in Twilio

### 9.2 Update Webhook URL

1. In Twilio Console, update the webhook URL to your public domain
2. Test the connection

### 9.3 Security Considerations

- Use strong passwords
- Enable SSL/TLS
- Configure firewall rules
- Regularly update dependencies
- Monitor logs for suspicious activity

## Troubleshooting

### Common Issues

1. **Webhook not receiving messages**
   - Check if n8n is accessible from internet
   - Verify webhook URL in Twilio
   - Check n8n logs for errors

2. **Google Drive authentication fails**
   - Verify OAuth2 credentials
   - Check redirect URI matches exactly
   - Ensure required scopes are enabled

3. **OpenAI API errors**
   - Verify API key is correct
   - Check account has sufficient credits
   - Verify model name is correct

### Debug Mode

Enable debug logging in n8n:
1. Go to Settings → Logs
2. Set log level to "debug"
3. Check execution logs for detailed information

### Getting Help

If you encounter issues:
1. Check the troubleshooting section
2. Review n8n documentation
3. Check the logs: `./scripts/start.sh logs`
4. Create an issue in the repository

## Next Steps

After successful setup:
1. Customize the workflow for your needs
2. Add additional commands
3. Configure audit logging
4. Set up monitoring and alerts
5. Create backup procedures 