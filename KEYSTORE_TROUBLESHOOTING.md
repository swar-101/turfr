# Keystore Troubleshooting Guide

## The Problem
Build failed with error: "Failed to read key turfr from store "D:\keys\turfr-key.jks": Cannot recover key"

## Most Common Causes & Solutions

### 1. Verify Keystore File Exists
Run the verification script: `verify_keystore.bat`

### 2. Check Key Alias
The error suggests the alias "turfr" might not exist in your keystore. Common issues:
- Alias name is case-sensitive
- Alias might be different than expected

### 3. Password Issues
- Store password might be incorrect
- Key password might be incorrect
- Special characters in passwords might need escaping

## Step-by-Step Fix

### Option 1: Verify Current Keystore
1. Open Command Prompt as Administrator
2. Run: `keytool -list -v -keystore "D:\keys\turfr-key.jks"`
3. Enter store password: `Bo++l31ozEng3`
4. Look for the actual alias name in the output

### Option 2: Create New Keystore (if verification fails)
If your keystore is corrupted or passwords don't work, create a new one:

```bash
keytool -genkey -v -keystore D:\keys\turfr-key.jks -alias turfr -keyalg RSA -keysize 2048 -validity 10000
```

### Option 3: Test with Debug Build First
Try building a debug version to isolate the signing issue:
```bash
flutter build apk --debug
```

## Quick Fixes to Try

1. **Escape Special Characters**: Your passwords contain special characters that might need escaping
2. **Check File Permissions**: Ensure the keystore file is readable
3. **Verify Path**: Use forward slashes in the path (already correct in your file)

## Next Steps
1. Run the verification script first
2. If keystore is accessible, check the actual alias name
3. Update key.properties with correct information
4. Rebuild the app
