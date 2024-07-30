# Mental Health Tracker App

## Overview

The Mental Health Tracker App is designed to help users monitor their daily mental health status. The app provides a comprehensive dashboard where users can visualize their mood data both graphically and in list format. Additionally, the app features a "Get Help" function, integrated with OpenAI, to offer tips and advice during times of need.

## Features

### 1. Splash & Sign Up/Sign In
- **Splash Screen Animation:** Created using Procreate, the splash screen animation is a result of months of meticulous design work.
- **Authentication:** Users can sign up with their email and password. Firebase handles authentication and storage. If incorrect credentials are used during login, appropriate error messages are displayed.

https://github.com/nethra-viswanathan/MentalHealthApp/blob/main/Splash+Login.gif?raw=true

### 2. Mood Tracking Feature
- **Entry:** Users can select the date for their mood entry (future dates are restricted).
- **Mood Representation:** Users choose an emoji that best represents their mood and can provide additional details via a textbox.
- **Data Storage:** Entries are stored in Firebase, and a success popup is displayed upon successful submission.

<Add Gif of App>

### 3. Dashboard
- **Mood Visualization:** Moods are displayed in both list and graph formats.
  - **List Format:** Users can click on items to view full descriptions.
  - **Graph Format:** Monthly mood trends are graphically represented, with statistics showing the frequency of different moods.
- **Navigation:** Initially displays the current month’s data, with options to view previous months.

<Add Gif of App>

### 4. Get Help
- **Support:** Users who cannot immediately access mental health professionals can describe their feelings in the app.
- **Assistance:** The app, using OpenAI, provides suggestions on how users can improve their mood until professional help is available.

<Add Gif of App>

