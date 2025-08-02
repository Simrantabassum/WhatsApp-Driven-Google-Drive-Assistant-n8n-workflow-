# Test Scenarios for WhatsApp Drive Assistant

This document outlines comprehensive test scenarios to validate the functionality of the WhatsApp-Driven Google Drive Assistant.

## Test Environment Setup

### Prerequisites
- n8n instance running with workflow imported
- Twilio WhatsApp sandbox configured
- Google Drive connected with test files
- OpenAI API configured
- Test phone number added to WhatsApp sandbox

### Test Data Preparation
```bash
# Create test folders in Google Drive
- /TestDocuments
- /TestArchive
- /TestProject

# Upload test files
- /TestDocuments/sample.txt (text file)
- /TestDocuments/report.pdf (PDF file)
- /TestDocuments/document.docx (Word document)
- /TestProject/README.md (markdown file)
```

## Test Scenarios

### Scenario 1: Basic Command Validation

**Objective:** Verify that basic commands are recognized and processed correctly.

**Test Cases:**

#### 1.1 Help Command
- **Input:** `HELP`
- **Expected Output:** 
  ```
  🤖 WhatsApp Drive Assistant

  Commands:
  • LIST /folder - List files
  • DELETE /file - Delete file
  • MOVE /source /dest - Move file
  • SUMMARY /folder - AI summary
  • HELP - Show this message
  ```
- **Validation:** All commands listed, formatting correct

#### 1.2 Status Command
- **Input:** `STATUS`
- **Expected Output:** `✅ System operational. All services connected.`
- **Validation:** System status reported correctly

#### 1.3 Invalid Command
- **Input:** `INVALID_COMMAND`
- **Expected Output:** `Invalid command. Type HELP for available commands.`
- **Validation:** Graceful error handling

### Scenario 2: File Listing Functionality

**Objective:** Test the LIST command with various folder scenarios.

**Test Cases:**

#### 2.1 List Root Folder
- **Input:** `LIST /`
- **Expected Output:** List of files and folders in root
- **Validation:** Files displayed with icons, sizes, and dates

#### 2.2 List Specific Folder
- **Input:** `LIST /TestDocuments`
- **Expected Output:** List of files in TestDocuments folder
- **Validation:** Only files from specified folder shown

#### 2.3 List Empty Folder
- **Input:** `LIST /EmptyFolder`
- **Expected Output:** `📁 /EmptyFolder\n\nNo files found.`
- **Validation:** Empty state handled gracefully

#### 2.4 List Non-existent Folder
- **Input:** `LIST /NonExistentFolder`
- **Expected Output:** Error message about folder not found
- **Validation:** Error handling for invalid paths

### Scenario 3: File Movement Operations

**Objective:** Test the MOVE command functionality.

**Test Cases:**

#### 3.1 Move File Successfully
- **Input:** `MOVE /TestDocuments/sample.txt /TestArchive`
- **Expected Output:** 
  ```
  ✅ File Moved Successfully

  📁 sample.txt has been moved:

  📍 From: /TestDocuments/sample.txt
  📍 To: /TestArchive
  ```
- **Validation:** File moved, confirmation message sent

#### 3.2 Move Non-existent File
- **Input:** `MOVE /TestDocuments/nonexistent.txt /TestArchive`
- **Expected Output:** Error message about file not found
- **Validation:** Error handling for missing files

#### 3.3 Move to Non-existent Destination
- **Input:** `MOVE /TestDocuments/sample.txt /NonExistentFolder`
- **Expected Output:** Error message about destination not found
- **Validation:** Error handling for invalid destinations

#### 3.4 Move with Missing Arguments
- **Input:** `MOVE /TestDocuments/sample.txt`
- **Expected Output:** Usage instructions for MOVE command
- **Validation:** Helpful error message for missing arguments

### Scenario 4: File Deletion with Safety

**Objective:** Test the DELETE command with confirmation safety features.

**Test Cases:**

#### 4.1 Delete File (First Request)
- **Input:** `DELETE /TestDocuments/sample.txt`
- **Expected Output:** 
  ```
  ⚠️ Delete Confirmation Required

  Are you sure you want to delete:
  *sample.txt*

  Reply with: *CONFIRM DELETE*

  ⚠️ This action cannot be undone!
  ```
- **Validation:** Confirmation required, file not deleted yet

#### 4.2 Confirm Delete
- **Input:** `CONFIRM DELETE`
- **Expected Output:** 
  ```
  ✅ File Deleted Successfully

  🗑️ sample.txt has been permanently deleted from Google Drive.

  📁 Path: /TestDocuments/sample.txt
  ```
- **Validation:** File deleted after confirmation

#### 4.3 Delete Non-existent File
- **Input:** `DELETE /TestDocuments/nonexistent.txt`
- **Expected Output:** Error message about file not found
- **Validation:** Error handling for missing files

#### 4.4 Confirm Delete Without Pending Operation
- **Input:** `CONFIRM DELETE` (without previous delete request)
- **Expected Output:** Error message about no pending delete operation
- **Validation:** Confirmation only works with pending delete

### Scenario 5: AI Summarization

**Objective:** Test the SUMMARY command with different file types.

**Test Cases:**

#### 5.1 Summarize Text File
- **Input:** `SUMMARY /TestDocuments`
- **Expected Output:** AI-generated summary of text files
- **Validation:** Summary is coherent and relevant

#### 5.2 Summarize Mixed File Types
- **Input:** `SUMMARY /TestProject`
- **Expected Output:** Summary of supported file types (PDF, DOCX, TXT)
- **Validation:** Only supported files processed

#### 5.3 Summarize Empty Folder
- **Input:** `SUMMARY /EmptyFolder`
- **Expected Output:** Message about no summarizable files found
- **Validation:** Empty state handled gracefully

#### 5.4 Summarize Large Files
- **Input:** `SUMMARY /LargeFiles` (files > 10MB)
- **Expected Output:** Message about file size limits
- **Validation:** Size limits enforced

### Scenario 6: Error Handling and Edge Cases

**Objective:** Test system behavior with edge cases and errors.

**Test Cases:**

#### 6.1 Network Timeout
- **Setup:** Simulate slow network connection
- **Input:** `LIST /TestDocuments`
- **Expected Output:** Timeout error message
- **Validation:** Graceful timeout handling

#### 6.2 API Rate Limiting
- **Setup:** Send multiple rapid requests
- **Input:** Multiple `LIST` commands in quick succession
- **Expected Output:** Rate limit error or throttling
- **Validation:** Rate limiting enforced

#### 6.3 Invalid File Paths
- **Input:** `LIST /../../etc/passwd`
- **Expected Output:** Security error or path validation error
- **Validation:** Path traversal attacks prevented

#### 6.4 Special Characters in File Names
- **Input:** `LIST /TestDocuments/file with spaces.txt`
- **Expected Output:** Proper handling of special characters
- **Validation:** Unicode and special characters supported

### Scenario 7: Performance Testing

**Objective:** Validate system performance under various loads.

**Test Cases:**

#### 7.1 Response Time
- **Input:** `HELP`
- **Expected Output:** Response within 2 seconds
- **Validation:** Performance meets requirements

#### 7.2 Large File Lists
- **Input:** `LIST /LargeFolder` (50+ files)
- **Expected Output:** Response within 5 seconds
- **Validation:** Large datasets handled efficiently

#### 7.3 Concurrent Requests
- **Setup:** Send 5 simultaneous requests
- **Input:** Multiple different commands
- **Expected Output:** All requests processed successfully
- **Validation:** Concurrency handled properly

### Scenario 8: Security Testing

**Objective:** Validate security features and access controls.

**Test Cases:**

#### 8.1 Unauthorized Access
- **Setup:** Use different phone number not in sandbox
- **Input:** `HELP`
- **Expected Output:** Access denied or no response
- **Validation:** Only authorized numbers can access

#### 8.2 Input Validation
- **Input:** `LIST /'; DROP TABLE users; --`
- **Expected Output:** Input validation error
- **Validation:** SQL injection attempts blocked

#### 8.3 Sensitive Information Exposure
- **Input:** `LIST /`
- **Expected Output:** File names and metadata only
- **Validation:** No sensitive data exposed in responses

### Scenario 9: Integration Testing

**Objective:** Test integration with external services.

**Test Cases:**

#### 9.1 Google Drive API
- **Input:** `LIST /TestDocuments`
- **Expected Output:** Files from Google Drive
- **Validation:** Google Drive integration working

#### 9.2 OpenAI API
- **Input:** `SUMMARY /TestDocuments`
- **Expected Output:** AI-generated summary
- **Validation:** OpenAI integration working

#### 9.3 Twilio API
- **Input:** Any command
- **Expected Output:** Response via WhatsApp
- **Validation:** Twilio integration working

### Scenario 10: Audit and Logging

**Objective:** Validate audit logging functionality.

**Test Cases:**

#### 10.1 Operation Logging
- **Input:** `LIST /TestDocuments`
- **Expected Output:** Operation logged with timestamp and user
- **Validation:** All operations logged

#### 10.2 Error Logging
- **Input:** `LIST /NonExistentFolder`
- **Expected Output:** Error logged with details
- **Validation:** Errors properly logged

#### 10.3 Security Event Logging
- **Input:** Unauthorized access attempt
- **Expected Output:** Security event logged
- **Validation:** Security events tracked

## Test Execution Checklist

### Pre-Test Setup
- [ ] All services running (n8n, Docker)
- [ ] Credentials configured (Twilio, Google, OpenAI)
- [ ] Test data prepared in Google Drive
- [ ] WhatsApp sandbox joined
- [ ] Webhook URL configured

### Test Execution
- [ ] Run all scenarios in order
- [ ] Document any failures or unexpected behavior
- [ ] Verify expected outputs match actual outputs
- [ ] Test error conditions and edge cases
- [ ] Validate performance requirements

### Post-Test Validation
- [ ] All test cases passed
- [ ] Performance benchmarks met
- [ ] Security requirements satisfied
- [ ] Error handling working correctly
- [ ] Audit logs complete and accurate

## Performance Benchmarks

### Response Time Requirements
- HELP command: < 2 seconds
- LIST command: < 5 seconds
- MOVE command: < 10 seconds
- DELETE command: < 3 seconds
- SUMMARY command: < 30 seconds

### Throughput Requirements
- Maximum concurrent requests: 5
- Maximum requests per minute: 60
- Maximum file size for processing: 10MB

### Reliability Requirements
- Uptime: > 99%
- Error rate: < 1%
- Data consistency: 100%

## Reporting

### Test Results Template
```
Test Scenario: [Scenario Name]
Date: [Date]
Tester: [Name]

Results:
- [ ] All test cases passed
- [ ] Performance requirements met
- [ ] Security requirements satisfied
- [ ] Error handling validated

Issues Found:
- [List any issues]

Recommendations:
- [List any recommendations]
```

### Bug Report Template
```
Bug Title: [Brief description]
Severity: [Critical/High/Medium/Low]
Steps to Reproduce:
1. [Step 1]
2. [Step 2]
3. [Step 3]

Expected Result: [What should happen]
Actual Result: [What actually happened]

Environment:
- n8n version: [Version]
- Docker version: [Version]
- OS: [Operating System]

Additional Notes: [Any additional information]
``` 