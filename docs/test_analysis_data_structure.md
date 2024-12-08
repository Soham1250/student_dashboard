# Test Interface to Analysis Screen - Data Structure Documentation

## Overview
This document outlines the data structure that is passed from the Universal Test Interface to the Test Analysis screen. This information needs to be processed and stored by the backend for test analysis and progress tracking.

## Data Structure

The main data object passed to the analysis screen contains the following key components:

### 1. User Information
```json
{
    "username": "string",
    "testType": "string"  // e.g., "Topic-wise" or "Full-length"
}
```

### 2. Analysis Data
```json
{
    "correctAnswers": [
        // Array of question objects (see Processed Question structure below)
    ],
    "incorrectAnswers": [
        // Array of question objects (see Processed Question structure below)
    ],
    "markedReviewUnanswered": [
        // Questions marked for review but not answered
    ],
    "markedReviewAnswered": [
        // Questions marked for review and answered
    ],
    "timeAnalysis": {
        "perQuestion": {
            "questionIndex": "timeInSeconds"  // e.g., "0": 45
        },
        "totalTime": "integer"  // Total time spent on test in seconds
    },
    "confidenceAnalysis": {
        "questionIndex": "confidenceScore"  // e.g., "0": 85.0
    }
}
```

### 3. Processed Questions
Array of question objects, each containing:
```json
{
    "index": "integer",          // Original question index in test
    "question": "string",        // Question text (HTML tags removed)
    "options": [                 // Array of 4 options
        "string",               // Option A
        "string",               // Option B
        "string",               // Option C
        "string"                // Option D
    ],
    "userAnswer": "string|null", // User's selected answer (null if unanswered)
    "correctAnswer": "string",   // Correct answer
    "markedForReview": "boolean",// Whether question was marked for review
    "timeSpent": "integer",      // Time spent on question in seconds
    "confidence": "float",       // Confidence score (0-100)
    "answerHistory": [           // Array of all answers selected by user
        "string"                // In chronological order
    ],
    "isCorrect": "boolean"       // Whether final answer was correct
}
```

## Example

Here's a sample of how the data might look for a single question:

```json
{
    "username": "john_doe",
    "testType": "Topic-wise",
    "analysisData": {
        "correctAnswers": [
            {
                "index": 0,
                "question": "What is the capital of France?",
                "options": ["London", "Paris", "Berlin", "Madrid"],
                "userAnswer": "Paris",
                "correctAnswer": "Paris",
                "markedForReview": false,
                "timeSpent": 45,
                "confidence": 85.0,
                "answerHistory": ["Berlin", "Paris"],
                "isCorrect": true
            }
        ],
        "timeAnalysis": {
            "perQuestion": {
                "0": 45
            },
            "totalTime": 180
        },
        "confidenceAnalysis": {
            "0": 85.0
        }
    }
}
```

## Important Notes

1. **Text Processing**:
   - All question text and options have HTML tags removed
   - HTML entities are decoded
   - Extra whitespace is cleaned up

2. **Time Tracking**:
   - All time values are in seconds
   - `timeSpent` is accumulated throughout the test
   - `totalTime` includes time spent on all questions

3. **Confidence Calculation**:
   - Scores range from 0 to 100
   - Factors affecting confidence:
     - Time spent on question
     - Number of answer changes
     - Whether marked for review

4. **Answer History**:
   - Maintains chronological order of all answer changes
   - Useful for analyzing user decision patterns

## Backend Requirements

The backend should:
1. Store all this data for historical analysis
2. Process and return analytics based on:
   - Time spent per question
   - Confidence patterns
   - Answer change patterns
   - Review marking patterns
   - Accuracy rates
   - Question-wise performance

## API Endpoint Suggestion

Consider creating an endpoint like:
```
POST /api/test-analysis
```
That accepts this entire data structure and returns a success/failure response.
