# 🧵 StitchHub: Comprehensive App Guide

Welcome to the **StitchHub** Application Guide. This document explains the full journey of both Customers and Tailors within the app, from the first log in to managing professional tailoring services.

---

## 🔑 1. Authentication Flow (Starters)

### **Splash Screen**
*   **Purpose**: The entry point. It checks if a user is already logged in. If yes, it takes them to their respective Home screen; otherwise, it shows the login options.

### **Account Creation & Login**
*   **Role Selection**: Users choose whether they are a **Customer** or a **Tailor** during registration. This is crucial as it defines their entire app experience.
*   **Fields**: Name, Email, Password, and Role-specific details (Tailors provide business names).
*   **Verification**: Powered by Supabase Auth for security.

---

## 🛍️ 2. The Customer Experience

### **Customer Home Screen**
*   **Dynamic Banners**: Shows latest offers or featured designs.
*   **Categories**: Quick access to different dress types (Shalwar Kameez, Suits, etc.).
*   **Featured Tailors**: Lists top-rated tailors nearby.

### **Tailor Discovery**
*   **Search & Filters**: Find tailors by name or rating.
*   **Tailor Profile**: View a tailor's business details, expertises, past reviews, and total orders completed.

### **Measurements & Appointments**
*   **Request Measurement**: Send a request to a tailor to take your measurements.
*   **Live Notification**: Tailor gets an instant alert when you send this request.
*   **Measurement History**: View your saved measurements anytime to reuse for new orders.

### **Ordering & Payments**
*   **Place Order**: Upload dress photos, select options, and provide instructions.
*   **Order Tracker**: A real-time timeline showing if your dress is "Pending", "Cutting", "Stitching", or "Ready".
*   **Stripe Integration**: Secure payment processing for orders.

---

## ✂️ 3. The Tailor Experience

### **Tailor Dashboard**
*   **Business Overview**: View total earnings, active orders, and pending measurement requests.
*   **Order Management**: Detailed views of every customer's order, including their specific instructions.

### **Appointment Management**
*   **Requests List**: See all incoming measurement requests from customers.
*   **Scheduling**: Confirm dates and times for measurements.

### **Business Profile**
*   **Setup**: Tailors can update their business address, services offered, and profile image.

---

## 💬 4. Real-time Communication (Shared)

### **Chat System**
*   **Live Messaging**: Instant sync between Customer and Tailor (WhatsApp-style).
*   **Optimistic UI**: Messages appear instantly when sent, even before they hit the server.
*   **Edit & Delete**: Long-press any of your messages to fix a mistake or remove it.
*   **Smart Notifications**: Receive a popup alert immediately if you get a message while the app is in the background.

---

## 🔔 5. Global Features

### **Notifications Service**
*   **Real-time Listeners**: The app constantly watches for new orders or messages.
*   **Push Notifications**: Works via Firebase (FCM) to ensure alerts reach you even if your phone is locked.

---

### **Technology Stack Used:**
*   **Frontend**: Flutter (Dart)
*   **Backend & Database**: Supabase (PostgreSQL & Realtime)
*   **State Management**: Provider (for reliable and fast UI updates)
*   **Notifications**: Firebase Cloud Messaging (FCM)
*   **Local Storage**: Hive (for lightning-fast offline data access)

---
*Created by Antigravity AI*
