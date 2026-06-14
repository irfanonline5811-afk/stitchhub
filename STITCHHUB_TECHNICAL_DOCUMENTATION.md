# StitchHub: Complete Technical Documentation (Frontend & Backend)

This document provides a comprehensive analysis of the StitchHub application, covering its backend infrastructure, frontend design, and key technical workflows.

---

## Part 1: Backend Architecture (The Engine)

StitchHub uses a **Serverless-First Architecture**, which ensures scalability, real-time updates, and high security.

### 1. Database & Auth (Supabase)
*   **Supabase** is the primary backend. It handles:
    *   **Authentication:** Secure login/signup and role-based access (Customer vs. Tailor).
    *   **PostgreSQL Database:** Stores all users, tailors, orders, messages, and reviews.
    *   **Real-time Streams:** Automatically pushes updates to the app (e.g., when a new message is received).
    *   **Storage Buckets:** Stores profile images and tailor work samples.

### 2. Notification System (Tri-Layer Architecture)
To ensure reliable delivery, we use three different methods:
1.  **Supabase Realtime:** For instant UI updates when the app is open.
2.  **Firebase Cloud Messaging (FCM):** For background/terminated push notifications.
3.  **Custom Node.js Bridge:** A secure API that triggers FCM notifications via Firebase Admin SDK.

### 3. Location Services & Geolocation
*   **GPS Tracking:** Uses the `geolocator` package to get device coordinates.
*   **Nearby Search:** Uses the **Haversine Formula** (mathematical distance calculation) to find tailors within a specific radius (e.g., 5km, 10km) relative to the user's current location.

---

## Part 2: Frontend Architecture (The Interface)

The frontend is built with **Flutter**, focusing on a premium, user-friendly experience.

### 1. State Management (Provider)
We use the **Provider** pattern to manage data across the app.
*   **Services:** Fetch raw data from Supabase.
*   **Providers:** Process the data and manage loading/error states.
*   **Screens:** Listen to the Providers and update the UI automatically.

### 2. Design System & Theming
*   **Centralized Theme:** All colors, typography, and spacing are defined in `app_theme.dart`.
*   **Premium UI:** Custom gradients, soft shadows (elevations), and glassmorphism-style cards.
*   **Animations:**
    *   **Tween Animations:** For smooth entrance effects.
    *   **Scale/Rotate Transitions:** Used in the logo and buttons to make the app feel interactive.

### 3. Modular Folder Structure
*   `lib/screens/`: Divided by user roles (Auth, Customer, Tailor).
*   `lib/widgets/`: Reusable modern UI components (e.g., `ModernSearchBar`, `ModernButton`).
*   `lib/providers/`: Business logic for every feature.

---

## Part 3: Key Technical Workflows

### 1. Notification Flow
1.  A tailor updates an order status in the app.
2.  The app calls `NotificationService.sendNotification()`.
3.  The request goes to the **Node.js Server**.
4.  The server sends an **FCM message** to the customer's device.
5.  The customer sees a visual popup even if the app is closed.

### 2. Tailor Discovery Flow
1.  The customer opens the "Nearby" search.
2.  `LocationProvider` gets the customer's current Latitude and Longitude.
3.  `TailorService` queries Supabase for all tailors.
4.  The app calculates the distance for each tailor using the **Haversine math logic**.
5.  Only tailors within the selected radius are shown on the screen.

### 3. Order Lifecycle
1.  **Customer:** Places an order -> `OrderProvider` inserts data into Supabase.
2.  **Tailor:** Receives real-time alert -> Accepts/Rejects order.
3.  **Real-time:** The `OrderTimelineScreen` on both sides updates instantly as the status changes (Pending -> Processing -> Completed).

---

## Summary for Supervisor
StitchHub is a robust, full-stack solution. The **Backend** is reliable due to Supabase and a custom Node.js notification bridge, while the **Frontend** is highly professional, featuring modern design principles, multi-language support (Urdu/English), and reactive state management.
