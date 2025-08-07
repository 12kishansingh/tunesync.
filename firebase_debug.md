# Firebase Permission Debugging Guide

## Current Issue
You're getting a "permission-denied" error when searching for users, even after updating Firestore rules.

## Debugging Steps

### 1. Check Authentication Status
- Look at the authentication status indicator in the app
- Verify the user is properly signed in
- Check the console logs for authentication details

### 2. Test Firestore Access
- Use the "Test Access" button in the app
- Check console logs for detailed error messages
- This will help identify if it's an authentication or rules issue

### 3. Verify Firestore Rules Deployment
Run these commands in your terminal:

```bash
# Check if Firebase CLI is installed
firebase --version

# Login to Firebase
firebase login

# Check current project
firebase projects:list

# Set the correct project
firebase use tunesync-f277f

# Deploy rules
firebase deploy --only firestore:rules

# Check rules status
firebase firestore:rules:get
```

### 4. Check Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `tunesync-f277f`
3. Go to Firestore Database → Rules
4. Verify the rules are updated with:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
         allow read: if request.auth != null && 
           (resource.data.keys().hasAll(['name', 'email', 'avatar', 'isOnline']));
       }
       // ... rest of rules
     }
   }
   ```

### 5. Check User Data Structure
Ensure your users collection has documents with this structure:
```json
{
  "name": "User Name",
  "email": "user@example.com", 
  "avatar": "👤",
  "isOnline": true
}
```

### 6. Alternative Test Rules (Temporary)
If the issue persists, try these more permissive rules temporarily:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 7. Check Network and Cache
- Clear app cache and restart
- Check internet connection
- Try on different network if possible

## Common Issues and Solutions

### Issue: Rules not deployed
**Solution**: Deploy rules using Firebase CLI or console

### Issue: User not authenticated
**Solution**: Sign out and sign back in

### Issue: Token expired
**Solution**: The app should automatically refresh tokens

### Issue: Wrong project
**Solution**: Verify you're using the correct Firebase project

## Next Steps
1. Run the app and check the authentication status indicator
2. Use the "Test Access" button to verify Firestore access
3. Check console logs for detailed error messages
4. Follow the debugging steps above
5. Let me know what the test results show 