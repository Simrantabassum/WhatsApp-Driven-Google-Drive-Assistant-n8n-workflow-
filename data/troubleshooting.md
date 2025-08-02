# Troubleshooting Guide

This guide helps you resolve common issues when setting up and running the WhatsApp-Driven Google Drive Assistant.

## Quick Diagnostic Commands

```bash
# Check service status
./scripts/start.sh status

# View logs
./scripts/start.sh logs

# Check Docker containers
docker-compose ps

# Check n8n health
curl http://localhost:5678/healthz
```

## Common Issues and Solutions

### 1. Docker Issues

#### Problem: Docker not running
**Symptoms:**
- Error: "Cannot connect to the Docker daemon"
- Services fail to start

**Solution:**
```bash
# Start Docker Desktop (Windows/Mac)
# Or start Docker service (Linux)
sudo systemctl start docker

# Verify Docker is running
docker info
```

#### Problem: Port already in use
**Symptoms:**
- Error: "Port 5678 is already in use"
- n8n fails to start

**Solution:**
```bash
# Find process using port 5678
lsof -i :5678

# Kill the process
kill -9 <PID>

# Or change port in docker-compose.yml
```

#### Problem: Docker Compose not found
**Symptoms:**
- Error: "docker-compose: command not found"

**Solution:**
```bash
# Install Docker Compose
# For newer Docker versions, use:
docker compose up -d

# For older versions, install separately:
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Environment Configuration Issues

#### Problem: Missing .env file
**Symptoms:**
- Error: ".env file not found"
- Services fail to start

**Solution:**
```bash
# Copy from template
cp env.example .env

# Edit with your credentials
nano .env
```

#### Problem: Invalid environment variables
**Symptoms:**
- Services start but fail to connect
- Authentication errors

**Solution:**
```bash
# Validate environment file
./scripts/setup.sh

# Check specific variables
grep -E "^(TWILIO_|GOOGLE_|OPENAI_|N8N_)" .env
```

### 3. Twilio Issues

#### Problem: WhatsApp webhook not receiving messages
**Symptoms:**
- Messages sent to WhatsApp number not processed
- No response from assistant

**Solutions:**

1. **Check webhook URL:**
   ```bash
   # Verify webhook is accessible
   curl -X POST http://localhost:5678/webhook/whatsapp
   ```

2. **Check Twilio configuration:**
   - Verify webhook URL in Twilio Console
   - Ensure HTTP method is POST
   - Check if sandbox is properly joined

3. **Check n8n logs:**
   ```bash
   ./scripts/start.sh logs
   ```

4. **Test webhook manually:**
   ```bash
   curl -X POST http://localhost:5678/webhook/whatsapp \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "From=whatsapp:+1234567890&Body=HELP"
   ```

#### Problem: Twilio authentication fails
**Symptoms:**
- Error: "Authentication failed"
- 401 Unauthorized errors

**Solution:**
1. Verify Account SID and Auth Token in .env
2. Check Twilio credentials in n8n
3. Ensure credentials are not expired

### 4. Google Drive Issues

#### Problem: OAuth2 authentication fails
**Symptoms:**
- Error: "Invalid credentials"
- Cannot access Google Drive

**Solutions:**

1. **Check OAuth2 configuration:**
   - Verify Client ID and Secret
   - Ensure redirect URI matches exactly
   - Check if scopes are properly configured

2. **Re-authenticate in n8n:**
   - Go to Credentials in n8n
   - Click "Connect" on Google Drive credential
   - Follow OAuth2 flow

3. **Check Google Cloud Console:**
   - Verify APIs are enabled
   - Check OAuth consent screen
   - Ensure project has billing enabled

#### Problem: Cannot find files/folders
**Symptoms:**
- Error: "Folder not found"
- Empty file lists

**Solutions:**

1. **Check folder path:**
   - Use exact folder names
   - Check for typos
   - Verify folder exists in your Drive

2. **Check permissions:**
   - Ensure OAuth2 has proper scopes
   - Verify account has access to folders

3. **Test with root folder:**
   ```bash
   # Try listing root folder
   LIST /
   ```

### 5. OpenAI Issues

#### Problem: API key authentication fails
**Symptoms:**
- Error: "Invalid API key"
- Summarization fails

**Solutions:**

1. **Verify API key:**
   - Check key starts with `sk-`
   - Ensure no extra spaces or characters
   - Verify key is active in OpenAI dashboard

2. **Check account status:**
   - Verify account has credits
   - Check for any account restrictions

3. **Test API directly:**
   ```bash
   curl https://api.openai.com/v1/chat/completions \
     -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model":"gpt-4o-mini","messages":[{"role":"user","content":"Hello"}]}'
   ```

#### Problem: Model not found
**Symptoms:**
- Error: "Model not found"
- Invalid model name

**Solution:**
- Use correct model name: `gpt-4o-mini` or `gpt-4o`
- Check model availability in your region
- Verify model name in .env file

### 6. n8n Issues

#### Problem: Cannot access n8n interface
**Symptoms:**
- Browser shows "Connection refused"
- Cannot log in

**Solutions:**

1. **Check if n8n is running:**
   ```bash
   docker-compose ps
   ```

2. **Check port configuration:**
   ```bash
   # Verify port 5678 is accessible
   curl http://localhost:5678
   ```

3. **Check logs for errors:**
   ```bash
   ./scripts/start.sh logs
   ```

#### Problem: Workflow not activating
**Symptoms:**
- Workflow shows as inactive
- Webhook not responding

**Solutions:**

1. **Check workflow status:**
   - Ensure workflow is activated
   - Check for validation errors

2. **Verify webhook node:**
   - Check webhook URL is correct
   - Ensure webhook is enabled

3. **Check credentials:**
   - Verify all required credentials are configured
   - Test each credential individually

#### Problem: Workflow execution fails
**Symptoms:**
- Workflow runs but fails
- Error messages in execution logs

**Solutions:**

1. **Check execution logs:**
   - Go to Executions in n8n
   - Click on failed execution
   - Review error details

2. **Test individual nodes:**
   - Click "Execute Node" on each node
   - Check for specific errors

3. **Verify data flow:**
   - Check data format between nodes
   - Ensure required fields are present

### 7. Network and Connectivity Issues

#### Problem: Cannot expose to internet
**Symptoms:**
- ngrok not working
- External access fails

**Solutions:**

1. **Check ngrok configuration:**
   ```bash
   # Check ngrok logs
   docker-compose logs ngrok
   
   # Verify ngrok URL
   curl http://localhost:4040/api/tunnels
   ```

2. **Configure ngrok auth token:**
   ```bash
   # Add to .env file
   NGROK_AUTHTOKEN=your_ngrok_auth_token
   ```

3. **Use alternative tunneling:**
   - Cloudflare Tunnel
   - LocalTunnel
   - SSH tunneling

#### Problem: SSL/TLS issues
**Symptoms:**
- HTTPS errors
- Certificate warnings

**Solutions:**

1. **For development:**
   - Use HTTP for local testing
   - Accept self-signed certificates

2. **For production:**
   - Use proper SSL certificates
   - Configure reverse proxy (nginx)
   - Use Let's Encrypt for free certificates

### 8. Performance Issues

#### Problem: Slow response times
**Symptoms:**
- Long delays in WhatsApp responses
- Timeout errors

**Solutions:**

1. **Check resource usage:**
   ```bash
   # Monitor Docker resources
   docker stats
   
   # Check system resources
   top
   ```

2. **Optimize workflow:**
   - Reduce unnecessary API calls
   - Use caching where possible
   - Optimize file processing

3. **Scale resources:**
   - Increase Docker memory limits
   - Use more powerful server
   - Consider load balancing

#### Problem: Memory issues
**Symptoms:**
- Out of memory errors
- Container crashes

**Solutions:**

1. **Increase Docker memory:**
   ```yaml
   # In docker-compose.yml
   services:
     n8n:
       deploy:
         resources:
           limits:
             memory: 2G
   ```

2. **Optimize n8n settings:**
   - Reduce concurrent executions
   - Limit file processing size
   - Use streaming for large files

### 9. Security Issues

#### Problem: Unauthorized access
**Symptoms:**
- Unknown users accessing n8n
- Security warnings

**Solutions:**

1. **Change default credentials:**
   ```bash
   # Update .env file
   N8N_BASIC_AUTH_PASSWORD=your_strong_password
   ```

2. **Enable additional security:**
   - Use environment-specific passwords
   - Enable IP whitelisting
   - Use VPN for access

3. **Monitor access logs:**
   ```bash
   # Check n8n access logs
   docker-compose logs n8n | grep "login"
   ```

### 10. Data and Backup Issues

#### Problem: Data loss
**Symptoms:**
- Workflows missing
- Credentials lost

**Solutions:**

1. **Backup n8n data:**
   ```bash
   # Backup data directory
   tar -czf n8n-backup-$(date +%Y%m%d).tar.gz data/
   ```

2. **Export workflows:**
   - Export workflows from n8n interface
   - Save workflow.json files

3. **Backup environment:**
   ```bash
   # Backup configuration
   cp .env .env.backup
   ```

## Getting Help

### Before Asking for Help

1. **Check this troubleshooting guide**
2. **Review n8n documentation**
3. **Check logs for specific errors**
4. **Test with minimal configuration**

### When Creating Issues

Include the following information:

1. **Environment details:**
   - Operating system
   - Docker version
   - n8n version

2. **Error messages:**
   - Full error text
   - Stack traces
   - Log excerpts

3. **Steps to reproduce:**
   - Exact commands run
   - Configuration used
   - Expected vs actual behavior

4. **Relevant files:**
   - .env file (with sensitive data removed)
   - docker-compose.yml
   - Workflow configuration

### Useful Commands for Debugging

```bash
# Check all container logs
docker-compose logs

# Check specific service logs
docker-compose logs n8n

# Follow logs in real-time
docker-compose logs -f n8n

# Check container status
docker-compose ps

# Restart specific service
docker-compose restart n8n

# Rebuild containers
docker-compose build --no-cache

# Clean up everything
docker-compose down -v
docker system prune -f
```

## Prevention Tips

1. **Regular backups:**
   - Backup workflows regularly
   - Save configuration files
   - Document customizations

2. **Monitor health:**
   - Set up health checks
   - Monitor resource usage
   - Watch for errors

3. **Keep updated:**
   - Update Docker images regularly
   - Keep dependencies current
   - Monitor security advisories

4. **Test changes:**
   - Test in development first
   - Use staging environment
   - Validate before production 