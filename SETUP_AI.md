# Setting up Gemini AI for Chat

## Get Your API Key

1. **Go to Google AI Studio**: https://aistudio.google.com/app/apikey
2. **Click "Create API Key"** (you'll need a Google account)
3. **Copy your API key**

## Configure the API Key

### Method 1: Environment Variable (Development)
```bash
export GOOGLE_API_KEY="your-gemini-api-key-here"
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000
```

### Method 2: Update the Code (Quick Test)
In `lib/src/services/ai_service.dart`, update the createChatView method:

```dart
return LlmChatView(
  provider: FirebaseProvider(
    model: FirebaseAI.googleAI(apiKey: 'your-gemini-api-key-here').generativeModel(
      model: 'gemini-2.0-flash',
    ),
  ),
  welcomeMessage: 'Hello! I\'m your AI companion. How can I help you today?',
);
```

### Method 3: Firebase Remote Config (Production - Recommended)
1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project: `flutter-chat-e4f96`
3. Navigate to **Remote Config**
4. Add a parameter:
   - **Name**: `gemini_api_key`
   - **Value**: Your Gemini API key
5. **Publish** the changes

Then update the code to use Remote Config value.

## Available Gemini Models
- `gemini-2.0-flash` - Fast, efficient (currently configured)
- `gemini-1.5-flash` - Previous generation, still fast
- `gemini-1.5-pro` - More capable, slower

## Security Notes
⚠️ **NEVER** commit API keys to Git
⚠️ For production, use Firebase Remote Config or secure backend
⚠️ The API key will be visible in client-side code if hardcoded

## Test Your Setup
1. Open the app at http://localhost:5000
2. Login with your account
3. Navigate to the Chat screen
4. Try sending a message
5. You should receive AI responses!

## Troubleshooting
- **Error: API key not found**: Make sure environment variable is set
- **Error: Invalid API key**: Check if key is copied correctly
- **Error: Quota exceeded**: Free tier has limits, upgrade if needed