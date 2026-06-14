# StitchHub Backend Comprehensive Analysis

This document provides a detailed step-by-step breakdown of the StitchHub backend architecture, the APIs used, and how they interact to provide a seamless experience for tailors and customers.

---

## 1. Architecture Overview

StitchHub uses a **Serverless/BaaS (Backend as a Service)** architecture, primarily powered by **Supabase**. This allows for real-time data synchronization, secure authentication, and scalable storage without managing a traditional dedicated server for every task.

### Core Technologies:
*   **Supabase (Primary Backend):** Handles Auth, PostgreSQL Database, Real-time listeners, and File Storage.
*   **Firebase (Push Notifications):** Handles Firebase Cloud Messaging (FCM) for background/killed-state alerts.
*   **Node.js Bridge (Custom API):** A small middleware used to securely send push notifications to Firebase using FCM tokens stored in Supabase.
*   **Google Maps Platform:** Provides location search and mapping capabilities.

---

## 2. Step-by-Step API & Service Usage

### Step 1: Authentication (Supabase Auth)
**File:** `lib/services/auth_service.dart`
*   **Method:** Email and Password authentication.
*   **Process:**
    1.  User signs up; Supabase creates a unique `UID`.
    2.  Metadata (name, user_type) is stored in the Auth session.
    3.  A corresponding profile is created in the `users` (and `tailors` if applicable) table in PostgreSQL.
    4.  Role-based access is managed by checking the `user_type` field.

### Step 2: Real-time Database (PostgreSQL + Supabase Realtime)
**File:** `lib/services/chat_service.dart`, `lib/services/order_service.dart`
*   **Tables:**
    *   `users`: Basic user data and FCM tokens.
    *   `tailors`: Detailed tailor profiles (business name, rating, location).
    *   `orders`: Tracking order lifecycle (Status: pending -> stitching -> completed).
    *   `messages`: Storing chat history.
    *   `measurements`: Storing customer measurements and requests.
    *   `appointments`: Scheduling for measurements or fittings.
*   **Real-time Logic:** The app uses `.stream()` to listen for changes. When a tailor updates an order status, the customer's UI updates instantly without a refresh.

### Step 3: Multi-Layer Notification System
**File:** `lib/services/notification_service.dart`
This is the most complex part of the backend. It uses three layers:
1.  **Supabase Realtime (Foreground):** Listens for new rows in `messages` or `orders`. If the app is open, it shows a local popup.
2.  **Firebase FCM (Background):** When a message is sent, the app calls a custom Node.js endpoint. This endpoint takes the target user's `fcm_token` (from Supabase) and sends a push via Firebase.
3.  **Flutter Local Notifications:** Displays the actual visual alert on the user's device.

### Step 4: File & Media Storage (Supabase Storage)
**Files:** `auth_service.dart`, `chat_service.dart`
*   **Buckets:**
    *   `images`: Stores profile pictures and order/receipt images.
    *   `chat_audios`: Stores voice notes sent in the chat.
*   **Flow:** Files are uploaded locally -> Supabase returns a Public URL -> URL is stored in the PostgreSQL database record.

### Step 5: Location & Mapping APIs
**File:** `lib/services/address_service.dart`
*   **Geolocator:** Retrieves the current GPS coordinates of the user.
*   **Geocoding:** Converts coordinates into human-readable addresses (and vice-versa).
*   **Google Maps SDK:** Visualizes nearby tailors on a map and helps in calculating distances.

---

## 3. Core API Logic Examples

### Flow: Placing an Order
1.  **App -> Supabase:** Insert a new row into the `orders` table.
2.  **Trigger:** `OrderService` calls `NotificationService.sendNewOrderNotification()`.
3.  **NotificationService -> Node.js Bridge:** Sends a POST request with order details.
4.  **Node.js -> Firebase:** Sends the push notification to the tailor's device.
5.  **Supabase Realtime:** Tailor's app (if open) detects the new row and updates the "Active Orders" list automatically.

### Flow: Real-time Chat
1.  **Sender -> Supabase Storage:** (If audio) Upload audio file.
2.  **Sender -> Supabase Database:** Insert message row (text or audio URL).
3.  **Receiver -> Supabase Realtime:** The receiver's stream detects the new message.
4.  **Receiver -> Flutter UI:** Message appears instantly in the chat bubble.

---

## 4. Why this Backend?
*   **No Infrastructure Overhead:** Supabase manages the scaling and database maintenance.
*   **Speed:** Real-time updates make the app feel modern and responsive.
*   **Security:** Supabase Row Level Security (RLS) ensures tailors can only see their orders, and customers can only see theirs.
*   **Reliability:** Combining Supabase (Realtime) with Firebase (Push) ensures notifications reach the user even if the app is closed.
