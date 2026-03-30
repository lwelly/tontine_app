# Firestore Setup Guide

## 📋 Prerequisites
- Firebase project already created (`tontine-app-eb2ed`)
- Flutter app configured with Firebase

## 🔥 Deploy Firestore Security Rules

1. **Install Firebase CLI** (if not already installed):
```bash
npm install -g firebase-tools
```

2. **Login to Firebase**:
```bash
firebase login
```

3. **Deploy Firestore Rules**:
```bash
firebase deploy --only firestore:rules
```

## 📊 Database Structure

The app uses the following Firestore collections:

### `users/{userId}`
```json
{
  "uid": "string",
  "email": "string", 
  "displayName": "string",
  "createdAt": "timestamp",
  "lastLogin": "timestamp"
}
```

### `groups/{groupId}`
```json
{
  "groupName": "string",
  "monthlyAmount": "number",
  "members": ["string"],
  "creatorId": "string",
  "status": "active|completed|paused",
  "currentTurn": "number",
  "createdAt": "timestamp",
  "totalMembers": "number"
}
```

### `payments/{paymentId}`
```json
{
  "groupId": "string",
  "userId": "string", 
  "amount": "number",
  "month": "string",
  "timestamp": "timestamp",
  "status": "paid"
}
```

### `beneficiary_order/{orderId}`
```json
{
  "groupId": "string",
  "userId": "string",
  "position": "number"
}
```

### `monthly_beneficiaries/{beneficiaryId}`
```json
{
  "groupId": "string",
  "month": "string",
  "userId": "string",
  "createdAt": "timestamp"
}
```

### `notifications/{notificationId}`
```json
{
  "userId": "string",
  "type": "payment_due|beneficiary|payment_delay",
  "message": "string",
  "groupId": "string",
  "timestamp": "timestamp",
  "isRead": "boolean"
}
```

## 🚀 Quick Start

1. **Enable Firestore** in Firebase Console:
   - Go to Firebase Console → Build → Firestore Database
   - Click "Create database"
   - Choose "Start in test mode" (we'll deploy secure rules)
   - Select a location

2. **Deploy Security Rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

## 🔒 Security Features

- Users can only access their own data
- Group members can only see groups they belong to
- Payment records are restricted to group members
- Notifications are private to each user

## 🧪 Testing

The app includes sample data creation. To test:
1. Register/login as a user
2. The app will automatically create user documents
3. You can create groups and record payments
4. All data is secured by Firestore rules

## 📱 App Features

- ✅ User authentication
- ✅ Group management  
- ✅ Payment tracking
- ✅ Automatic beneficiary selection
- ✅ Notifications system
- ✅ Arabic RTL interface
- ✅ Real-time updates

Your Firestore is now ready for the tontine app! 🎉
