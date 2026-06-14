# StitchHub - Complete App Analysis, APIs & Algorithms Report 👔

StitchHub aik modern tailor marketplace application hai jo customers aur local tailors ko aapas mein connect karti hai. Is document mein app ki complete details, use hone wali **APIs/Services**, aur core **Algorithms/Design Patterns** ko Roman Urdu aur clear technical language mein categorize kiya gaya hai taake aap isay FYP (Final Year Project) Viva, Report, ya presentation ke liye easily use kar sakein.

---

## 📁 1. StitchHub Kya Hai? (App Overview & Key Features)
StitchHub tailors ki traditional book-keeping (khata) aur customer interaction ko digitalize karta hai. Is app ke **2 main user roles (Personas)** hain:

### A. Customers (Grahak) ke liye:
*   **Tailor Discovery:** Apne qareeb ke tailors ko ratings, services aur distance ke mutabiq search aur filter karna.
*   **Map View:** Google Maps par local tailors ki shops ki locations dekhna.
*   **Digital Measurement Book:** Apne size (chest, waist, shoulder, neck, length, etc.) ko app ke andar save rakhna aur direct order mein attach karna.
*   **Real-time Chat:** Chat service ke zariye tailor se live rabta karna aur design images/audios share karna.
*   **Stripe & Manual Payments:** Secure checkout aur local cash/receipt upload payment proofs ki sahulat.
*   **Order Tracking:** Status updates ko real-time track karna (e.g., Pending -> Cutting -> Stitching -> Ready).

### B. Tailors (Darzi) ke liye:
*   **Digital Storefront Setup:** Shop name, catalog services, prices, working hours aur previous work samples (portfolio) manage karna.
*   **Measurement Directory:** Har customer ka complete measurement record database mein add, edit, aur search karna.
*   **Order Pipeline Dashboard:** Naye orders ko accept/reject karna aur status update karna.
*   **Appointment Management:** physical visit aur measurements ke appointments ko approve/decline karna.

---

## 🛠️ 2. Kaunsi APIs Aur External Services Use Hui Hain? (APIs Used)

StitchHub frontend **Flutter (Dart)** aur backend **Supabase (BaaS)** + **Node.js Express Bridge** ka mix architecture use karta hai. Core APIs ye hain:

| API / Service Name | Purpose (Kis Kaam Aati Hai) | File Reference (Code Location) |
| :--- | :--- | :--- |
| **Supabase Auth API** | Secure user registration, login, session validation aur role management ke liye. | `lib/services/auth_service.dart` |
| **Supabase Database (Postgres API)** | Profile tables, orders, messages, measurements, aur appointments ka normalized data save/retrieve karne ke liye. | `lib/services/` (All services) |
| **Supabase Realtime (Websockets API)** | Database changes par instantly stream karna, jo foreground notifications, chat messages, aur live order status updates ko refresh-free chalata hai. | `lib/services/chat_service.dart`, `lib/services/notification_service.dart` |
| **Supabase Storage API** | Profile pictures, work portfolio samples, and chat voice notes (audio) files upload karne ke liye. | `lib/services/tailor_service.dart`, `lib/services/manual_payment_service.dart` |
| **Firebase Cloud Messaging (FCM API)** | Jab user offline ho ya app background mein ho, to notifications send karne ke liye push notification tokens save aur process karta hai. | `lib/services/notification_service.dart` |
| **Node.js Express Backend API** | Custom API gateway bridge jo notification sending requests (FCM token payload) aur SMS gateways ko process karta hai. | `backend/server.js`, `backend/routes/` |
| **Stripe Payment API** | Customers se credit/debit card ke zariye secure transactions handle karne ke liye. | `lib/services/payment_service.dart` |
| **Twilio SMS API** | User verification (OTP) aur orders ki notification status updates messages (SMS) ke zariye bhejne ke liye. | `backend/config/twilio.js` |
| **Geolocator & Geocoding API** | User ki live GPS coordinates (latitude/longitude) hasil karne aur coordinates ko human-readable address mein convert karne ke liye. | `lib/services/address_service.dart` |
| **Google Maps Flutter API** | Tailors ki locations ko maps par visual pins/markers ke tor par show karne aur navigation facilitate karne ke liye. | `lib/screens/customer/search_tailors_screen.dart` |

---

## 🧮 3. Kaunse Algorithms Aur Design Patterns Use Hue Hain? (Algorithms & Patterns)

StitchHub ko optimization, performance aur clean architecture dene ke liye multiple algorithms aur standards implement kiye gaye hain:

### 1. Haversine Formula (GPS Distance Calculation)
*   **Kahan use hua hai:** `lib/services/tailor_service.dart` (function `_calculateDistance`) aur `lib/providers/location_provider.dart`.
*   **Algorithm Description:** Earth ke spherical curvature ko consider karte hue do points (Latitude, Longitude) ke darmiyan minimum straight-line distance calculate karta hai.
*   **App Logic:** Jab customer tailors search karta hai, to app customer ke current coordinates aur tailor ke shop coordinates ke darmiyan distance (KM mein) calculate kar ke tailors ko **Proximity (Nearest First)** ke mutabiq list karti hai.
*   **Code Snippet:**
    ```dart
    double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
      const double earthRadius = 6371; // Earth radius in KM
      final double dLat = _degreesToRadians(lat2 - lat1);
      final double dLon = _degreesToRadians(lon2 - lon1);
      final double a = (dLat / 2) * (dLat / 2) +
          (dLon / 2) * (dLon / 2) * cos(lat1 * pi / 180) * cos(lat2 * pi / 180);
      final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
      return earthRadius * c;
    }
    ```

### 2. Observer Pattern / Pub-Sub (Real-Time Websocket Listeners)
*   **Kahan use hua hai:** `lib/services/notification_service.dart` aur state management providers mein.
*   **Algorithm Description:** Jab kisi primary resource (Postgres Table) mein change (Insert/Update) ho, to automatically sab listening objects (UI screens) ko trigger notify karta hai without polling.
*   **App Logic:** Supabase Stream listener `onPostgresChanges` event register karta hai. Jab chat table ya orders table mein naya entry insert hoti hai, to database directly event client par push karta hai aur client-side UI instant refresh ho jata hai.

### 3. Cryptographic Password Hashing (BCrypt / SHA-256)
*   **Kahan use hua hai:** Supabase Authentication and Session Handlers.
*   **Algorithm Description:** User passwords ko directly save karne ke bajaye random cryptographic strings (salt + hash) mein convert karta hai jo irreversible hoti hain.
*   **App Logic:** Users ka sensitive login data secure rahta hai. User auth tokens JWT (JSON Web Tokens) ko dynamic signature validation ke sath utilize karte hain.

### 4. Comparison Sort Algorithms (Sorting & Filtering)
*   **Kahan use hua hai:** `lib/providers/tailor_provider.dart` aur tailor listing UI.
*   **Algorithm Description:** Comparison sorting logic (e.g., QuickSort/MergeSort built-in) ko use karke multiple parameters (Rating, Distance, Base Pricing) par data order karta hai.
*   **App Logic:** Tailors ki list ko user-selected preferences ke mutabiq filter aur sort kiya jata hai (e.g., "Highest Rated First" ya "Price: Low to High").

### 5. Local Database Caching (Hive key-value / LRU caching)
*   **Kahan use hua hai:** Hive Local Database (`lib/services/local_storage_service.dart`).
*   **Algorithm Description:** Key-value pairs store karne ke liye binary serialization use karta hai jo dynamic lookup complexity $O(1)$ par kam karti hai.
*   **App Logic:** App last-fetched profiles, preferences aur offline database local screen storage par cache rakhti hai taake internet poor hone par blank screen show na ho (Offline-First approach).

### 6. Singleton Design Pattern
*   **Kahan use hua hai:** `lib/services/notification_service.dart` (static `_instance` implementation).
*   **Algorithm/Pattern Description:** System check karta hai ke kisi class ka lifecycle mein sirf aik single instance hi initialize ho aur global access point coordinate ho.
*   **App Logic:** Memory leaks aur resource exhaustion se bachne ke liye `NotificationService`, `ChatService`, aur `AuthService` ka poori app runtime ke dauran sirf aik hi instance banaya jata hai aur har module se wahi single instance reuse hota hai.

### 7. Symmetric & Asymmetric Encryption (Tokenization)
*   **Kahan use hua hai:** Stripe SDK Checkout integration (`lib/services/payment_service.dart`).
*   **Algorithm Description:** Sensitive credit card information ko encrypted tokens mein replace kar ke send karta hai taake merchant server details capture na kar sake.
*   **App Logic:** Stripe API cards ko secure token mein transform karti hai. StitchHub server sirf token payload save karta hai jo card leakage se system ko fully immune rakhta hai.

### 8. Database Normalization (PostgreSQL Relational Mapping)
*   **Kahan use hua hai:** Supabase Database Tables (Schema Design).
*   **Algorithm/Rule Description:** 1NF, 2NF aur 3NF database design principles jo redundant data aur data anomaly problems ko eliminate karti hain.
*   **App Logic:** StitchHub mein tables ko logically relate kiya gaya hai (e.g., `profiles` aur `tailors` tabls connected hain `user_id` Foreign Key ke zariye). Direct relational constraints lagaye gye hain taake data consistency maintain rahe.

---

## 🎓 Viva/FYP Report Key Points (Viva mein poochay janay wale sawal)

1.  **StitchHub NoSQL (Firebase) ke bajaye SQL (Supabase Postgres) kyun use karta hai?**
    *   *Jawab:* Kyun ke StitchHub aik transaction-based marketplace hai jahan customers, tailors, measurements aur orders ke darmiyan strictly define relations (one-to-many, many-to-many) hote hain. SQL relational constraints, foreign keys aur data normalization ensure karta hai jo e-commerce system ko data corruption se bachata hai.
2.  **App real-time data kaise get karti hai?**
    *   *Jawab:* Supabase Client ke **Websocket Streams** ke zariye. Jab bhi target table (jaise `messages` ya `orders`) par insert ya update dynamic operation hota hai, to client listener instantly trigger hota hai.
3.  **Customer proximity distance calculation kis logic par kaam karti hai?**
    *   *Jawab:* **Haversine Formula** ke calculation mathematical steps par. Ye latitude aur longitude ke radian values ke cosine aur sine angles nikal kar unhein Earth surface radius (6371 KM) se multiply kar ke accurate linear difference nikalta hai.
