# Half Read

English | [简体中文](README.md)

A Flutter-based text summarization application that uses the Gemini API to generate text summaries.

## Features

- **Text Summarization**: Input text and quickly generate concise summaries
- **Adjustable Reasoning Depth**: Supports low/medium/high reasoning depths to adjust summary quality based on needs
- **Split-screen Reading Mode**: Supports side-by-side display of original text and summary
- **Light/Dark Theme**: Automatically adapts to system theme settings
- **API Key Management**: Securely stores Gemini API keys

## Technical Implementation

- Uses **Provider** for state management
- Communicates with Gemini API via **HTTP** requests
- Uses **SharedPreferences** to store API keys
- Adopts **Material Design 3** design language
- Supports Chinese interface

## Project Structure

```
lib/
├── models/         # Data models
├── providers/      # State management
├── screens/        # Screens
├── services/       # API services
├── widgets/        # UI components
└── main.dart       # Application entry point
```

## API Integration

The application uses the Gemini API (gemini-2.5-flash-preview-04-17) for text summarization through the following endpoint:
```
https://zym9863-gemini.deno.dev/v1/chat/completions
```

## Usage Instructions

1. When launching the app for the first time, you need to set up your Gemini API key
2. Enter the text you want to summarize in the input field
3. Select an appropriate reasoning depth (low/medium/high)
4. Click the "Generate Summary" button
5. View the generated summary
6. You can use split-screen mode to view the original text and summary simultaneously

## Development Environment

- Flutter 3.x
- Dart 3.x
- Supports Android, iOS, Web, and desktop platforms
