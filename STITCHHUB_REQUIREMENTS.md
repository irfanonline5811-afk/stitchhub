# 📜 StitchHub: Software Requirements Specification (SRS)

This document outlines the **Functional** and **Non-Functional Requirements** of the **StitchHub** application.

---

## 🛠️ 1. Functional Requirements (What the app DOES)

Functional requirements define the core actions a user can perform within the app.

### **Common Features (Both Roles)**
*   **Authentication**: Users can Register and Login as either a Customer or a Tailor.
*   **Real-time Chat**: Users can communicate via instant messaging, with the ability to **Edit** and **Delete** messages.
*   **Push Notifications**: Instant alerts for new messages, orders, and appointments via Firebase (FCM).
*   **Profile Management**: Update name, profile picture, and account settings.

### **Customer-Specific Features**
*   **Tailor Discovery**: Search and filter tailors based on categories and ratings.
*   **Measurement Management**: Send measurement requests to tailors and view history.
*   **Order Placement**: Create and track dress stitching orders with specific instructions.
*   **Order Tracking**: View a live timeline of order progress (Cutting, Stitching, Done).
*   **Stripe Payments**: Pay for tailoring services securely within the app.

### **Tailor-Specific Features**
*   **Dashboard**: Monitor daily/monthly earnings, active orders, and pending appointments.
*   **Order Fulfillment**: Manage and update the status of customer orders.
*   **Appointment Scheduling**: Receive and confirm measurement appointment requests.
*   **Business Profile**: Edit details like business name, address, and expertises.

---

## ⚡ 2. Non-Functional Requirements (How the app BEHAVES)

Non-functional requirements describe the quality and constraints of the system.

### **Performance**
*   **Real-time Sync**: Chat and status updates must happen within **under 1 second** using Supabase Realtime.
*   **Fast Loading**: The app must load lists (Tailors, Orders) quickly through optimized database queries.

### **Security**
*   **User Privacy**: No user (including other tailors) should see private chat messages between a specific customer and tailor.
*   **Authentication Security**: Use industry-standard Supabase Auth with secure JWT tokens.

### **Reliability & Availability**
*   **Offline Support**: Use **Hive** database to store historical data (Orders, Measurements) so users can view it without internet.
*   **High Availability**: The backend must ensure 99.9% uptime for business continuity.

### **Scalability**
*   The architecture should support thousands of active users and hundreds of concurrent chat sessions.

### **Usability**
*   **Intuitive UI**: Premium, modern interface with glassmorphism and smooth animations for better user engagement.
*   **Responsiveness**: The app must adapt its layout correctly on different screen sizes (phones/tablets).

---
*Created by Antigravity AI*
