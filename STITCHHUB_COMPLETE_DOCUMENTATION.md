# StitchHub: Complete Project Documentation

## 1. Project Overview
**Project Name:** StitchHub
**Purpose:** A modern marketplace application designed to connect customers with local tailors. It digitizes the traditional tailoring experience by offering online tailoring orders, digital measurement management, appointment scheduling, and real-time communication.
**Target Audience:** Customers looking for custom tailoring services, and Tailors looking to digitize their business and reach more clients.

---

## 2. System Architecture & Tech Stack

### Frontend (Mobile Application)
* **Framework:** Flutter (Dart)
* **Design Pattern:** Provider Pattern (State Management)
* **UI/UX Aesthetics:** Modern Glassmorphism, Material 3, Dark/Light mode support, Custom Gradients (Green Theme).
* **Key Packages Used:**
  * `provider` (State Management)
  * `geolocator` & `google_maps_flutter` (Location & Maps)
  * `hive` & `hive_flutter` (Local Offline Caching)
  * `flutter_stripe` (Payments Integration)

### Backend (Cloud & Database)
* **Primary BackendaaS:** Supabase
* **Database:** PostgreSQL (Relational Database)
* **Authentication:** Supabase Auth (JWT securely linked to Postgres)
* **Storage:** Supabase Storage Bucket (For Profile and Portfolio Images)
* **Push Notifications:** Firebase Cloud Messaging (FCM) via Node.js backend (`server.js`)
* **Real-time Engine:** Supabase Websockets for Live Chat.

---

## 3. Database Schema (PostgreSQL Tables)
Being a relational database, the data is properly normalized to prevent duplication.

1. **profiles/users:** Stores ID, Name, Phone, Email, Address, and User Role (`customer` or `tailor`).
2. **tailors:** Linked to the user profile via Foreign Key. Stores shop name, catalog items, pricing (PKR), latitude/longitude for maps.
3. **measurements:** Stores digitized customer measurements (shoulder, chest, waist, length, etc.).
4. **orders:** The core table connecting Customer ID, Tailor ID, Measurement ID, Total Price, and Order Status (Pending, Processing, Completed).
5. **messages:** Chat functionality storing Sender ID, Receiver ID, Content, Status (Read/Unread), and Timestamp.
6. **appointments:** For physical shop visits, storing date, time, and tailor-customer links.
7. **reviews:** Customer feedback and ratings (1 to 5 stars) for completed orders.

---

## 4. Modules & Functionalities

### 4.1. Core Module (Common to All Users)
* **Authentication:** Secure Email/Password Sign Up and Log In. Role-based login routes users to their respective dashboards.
* **Real-Time Chat Engine:** Instant messaging between customer and tailor. Features unread message badges that auto-clear upon reading.
* **Push Notifications:** Alerts for new orders, status updates, and messages, even when the app is minimized.

### 4.2. Customer Module
* **Discovery Board:** Browse nearby tailors, view their portfolios, and read reviews.
* **Geolocator/Maps:** View tailor locations on Google Maps to find the closest options.
* **Digital Wardrobe (Measurements):** Customers can input and save their exact body measurements to use for online orders.
* **Order Placement:** Select a tailor, attach saved measurements, and place an order.
* **Live Order Tracking:** See real-time updates of the order status.
* **Favorites:** Bookmark favorite tailors for quick access.
* **Ratings & Reviews:** Rate tailors post-completion to help other users.

### 4.3. Tailor Module (Vendor Dashboard)
* **Virtual Shop Setup:** Setup shop profile, upload portfolio images, and set base stitching prices in PKR.
* **Order Management System:** Accept/Reject incoming orders. Update the timeline (e.g., "Fabric Received", "Cutting", "Stitching", "Ready").
* **Measurement Depository:** View the attached customer measurements for precise stitching. Tailors can also manually add walk-in customer measurements.
* **Appointment Management:** Review and approve physical shop visit requests from customers.
* **Earnings Analytics:** Track total completed orders and revenue generated.

---

## 5. Key Technical Highlights (For Presentations/Viva)

1. **Why PostgreSQL over NoSQL (Firebase)?**
   * StitchHub is an e-commerce-style platform. Orders, Tailors, and Customers have strict relationships. PostgreSQL (SQL) handles these relationships via Foreign Keys and Joins much better than NoSQL, preventing data inconsistency.
2. **Real-time Synchronization:**
   * Supabase stream subscriptions are used for the chat module. As soon as a row is inserted in the `messages` table, the UI updates instantly without an API refresh call.
3. **Local Caching (Offline First approach):**
   * Using `Hive`, certain data is cached locally on the device so the app feels incredibly fast and doesn't load blank screens on poor internet connections.
4. **Unread Message Badges Optimization:**
   * Implemented localized state updates for unread chat counts. When a user opens a chat, the counter resets locally matching the server, ensuring an immediate UI response.

---

## 6. Future Scope
* Integration of Live Video Call measurements.
* AI-based fabric recommendation system.
* Courier service API integration for fabric pick-up and delivery.
order