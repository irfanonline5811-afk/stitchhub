# StitchHub Frontend Comprehensive Analysis

This document provides a detailed breakdown of the StitchHub frontend architecture, UI design philosophy, and state management logic.

---

## 1. Frontend Tech Stack & Architecture

StitchHub is built using **Flutter**, ensuring a high-performance, cross-platform experience (Android & iOS) with a single codebase.

### Core Technologies:
*   **Framework:** Flutter (Material 3 inspired).
*   **State Management:** **Provider** (ChangeNotifier).
*   **Theming:** Custom Centralized Design System (`app_theme.dart`).
*   **Multi-language:** Custom JSON-based localization (`LanguageProvider`).
*   **Networking:** Integration with Supabase via Service-Provider-Screen pattern.

---

## 2. Design Philosophy: "Modern & Premium"

The UI is designed to look like a high-end marketplace app, focusing on trust and ease of use.

### Key Visual Elements:
*   **Color Palette:** A professional **"Forest Green"** (`#2E7D32`) theme symbolizing craftsmanship and quality.
*   **Custom Components:** Instead of standard Flutter widgets, we use `ModernUIComponents`:
    *   **ModernCards:** Glassmorphism and soft shadows for a premium feel.
    *   **ModernButtons:** Gradient backgrounds and subtle animations.
    *   **AnimatedFadeIn:** Smooth entrance animations for list items and screens.
*   **Responsive Layouts:** The app uses `Flexible`, `Expanded`, and `LayoutBuilder` to ensure it looks great on all screen sizes.

---

## 3. Modular Structure (Folder Breakdown)

### `lib/theme/`
Contains the entire design system (colors, spacing, typography, gradients). If we want to change the app's look, we only change it here.

### `lib/widgets/`
Reusable UI blocks like `ModernSearchBar`, `ModernFilterChip`, and `ModernEmptyState`. This keeps the screens clean and easy to maintain.

### `lib/providers/`
The "Brain" of the frontend. Every major feature has a provider (e.g., `ChatProvider`, `OrderProvider`) that:
1.  Calls the backend service.
2.  Handles loading/error states.
3.  Notifies the UI to rebuild when data changes.

### `lib/screens/`
Separated into three main flows:
1.  **Auth Flow:** Login, Signup, and Tailor Setup.
2.  **Customer Flow:** Home, Search, Tailor Details, Ordering, Chat.
3.  **Tailor Flow:** Dashboard, Order Management, Measurement Requests, Profile.

---

## 4. Advanced Frontend Features

### 1. Multi-language Support (Urdu/English)
The `LanguageProvider` allows users to switch the entire app's language in real-time. All text strings are mapped to keys, making it easy to add more languages later.

### 2. Real-time Reactive UI
Because we use `Provider` + Supabase Streams, the UI is **reactive**. 
*   **Example:** If a tailor marks an order as 'Completed', the customer's `OrderTimelineScreen` updates instantly without the user having to refresh or pull-to-refresh.

### 3. Dynamic Search & Filters
The `SearchTailorsScreen` features:
*   **Debounced Search:** It waits for the user to stop typing before searching to save API calls.
*   **Complex Filtering:** Interactive sliders for radius/rating and chips for service types.

### 4. Interactive Feedback
*   **Custom Dialogs:** For ratings, city selection, and confirmations.
*   **Snackbars:** Styled to match the theme for success/error messages.

---

## 5. Why this Frontend?
*   **Maintainability:** By separating UI from Logic, we can fix bugs without breaking the design.
*   **User Experience:** Smooth animations and a consistent theme make the app feel "Pro".
*   **Performance:** Optimized builds and efficient state management ensure zero lag during navigation.
