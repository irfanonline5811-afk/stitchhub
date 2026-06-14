# StitchHub Algorithms Documentation

Below is a detailed breakdown of the key algorithms and computational logic implemented in your StitchHub application.

## 1. Haversine Formula (Distance Calculation)
**Kahan use hua hai (Where is it used):** `LocationProvider.dart` aur `Search/Discovery` features mein.
**Kya karta hai (What it does):** Ye algorithm Earth ki spherical shape ko consider karte hue do GPS coordinates (Latitude aur Longitude) ke darmiyan straight-line distance calculate karta hai. 
**App mein kaam:** Jab ek Customer "nearby tailors" search karta hai, toh yeh formula Customer ki current location aur Tailor ki shop location ke darmiyan exact distance (kilometers mein) nikalta hai.

## 2. Observer Pattern / Pub-Sub Algorithm (Real-time Sync)
**Kahan use hua hai (Where is it used):** Chat System (Supabase Websockets) aur State Management (Provider).
**Kya karta hai (What it does):** Ye ek design pattern/algorithm hai jo real-time data push karne ke liye use hota hai. 
**App mein kaam:** Jab koi Customer Tailor ko message bhejta hai, toh app ko refresh nahi karna parta. Observer pattern directly UI ko notify karta hai aur message screen par show ho jata hai. Unread count bhi instantly update ho jata hai.

## 3. Cryptographic Hashing Algorithm (Bcrypt / SHA-256)
**Kahan use hua hai (Where is it used):** Authentication (Supabase Auth).
**Kya karta hai (What it does):** User ke passwords ko securely hash/encrypt karta hai taki database mein plain text mein password save na ho.
**App mein kaam:** Jab koi user Sign Up karta hai, toh unka password encrypt hoke Supabase PostgreSQL database mein save hota hai. JWT (JSON Web Tokens) bhi HMAC/SHA-256 ka use karte hain session manage karne ke liye.

## 4. Sorting & Filtering Algorithms (Linear / Comparison Sort)
**Kahan use hua hai (Where is it used):** Discovery Board (`search_tailors_screen.dart`, `tailor_provider.dart`).
**Kya karta hai (What it does):** Tailors ki list ko specific criteria par arrange karta hai.
**App mein kaam:** Tailors ko distance (nearest first), ratings (highest rated), aur price (low to high) ke hisaab se filter aur sort karne ka mechanism.

## 5. Token Bucket / Exponential Backoff Algorithm (Retry Logic)
**Kahan use hua hai (Where is it used):** API Calls aur Firebase Cloud Messaging (FCM).
**Kya karta hai (What it does):** Agar internet connection slow hai ya fail ho jaye toh ye algorithm fix interval par retry karta hai aur request server par overload nahi karta.
**App mein kaam:** Message bhejne ya order place karne mein agar error aye toh retry mechanism implement hota hai without freezing the app.

## 6. Local Caching Algorithm (LRU / Key-Value Mapping)
**Kahan use hua hai (Where is it used):** Hive (Local Database).
**Kya karta hai (What it does):** Most frequently used data ko temporarily mobile ke andar store karta hai.
**App mein kaam:** App ko offline show karne ke liye ya fast loading (Offline-first approach) ke liye use hota hai, toh app load hote waqt last loaded data foran show kardeti hai.

---

## 7. Encryption & Tokenization Logic (Payment Gateways)
**Kahan use hua hai (Where is it used):** Stripe Payments in `payment_service.dart`.
**Kya karta hai (What it does):** Ye logic user ke card details ko plain text mein save karne ke bjai usay ek secure "Token" mein convert karti hai.
**App mein kaam:** Jab koi customer payment karta hai, toh card details Stripe server pe directly jati hain (Symmetric/Asymmetric Encryption ke zariye), aur app ko sirf ek secure Token milta hai. Is wajah se app fully secure rehti hai.

## 8. Database Normalization (1NF, 2NF, 3NF Rules)
**Kahan use hua hai (Where is it used):** PostgreSQL Database.
**Kya karta hai (What it does):** Ye Data Structure ke rules hain jo database me data duplication/redundancy ko khatam karte hain.
**App mein kaam:** Customers, Tailors, Orders, aur Measurements ki alag alag tables hain, aur inko **Foreign Keys** ke zariye jora gaya hai (`JOIN` queries). Normalization na hoti toh data miss-match ho sakta tha.

## 9. Singleton Design Pattern
**Kahan use hua hai (Where is it used):** Flutter Services (`chat_service.dart`, `auth_service.dart`).
**Kya karta hai (What it does):** Ye restrict karta hai ke kisi bhi class ka poori app mein sirf 1 hi Object (instance) bane.
**App mein kaam:** Memory bachane ke liye (RAM optimization), app bar bar naya database connection ya API client nahi banati. Ek baar connection banta hai aur wahi poori app me use hota hai.

## 10. Service-Oriented Architecture (Microservices approach)
**Kahan use hua hai (Where is it used):** Node.js Backend (`server.js`) for Push Notifications.
**App mein kaam:** Push Notifications bhejne ka kaam Flutter app seedha apne oopar lene ke bjai Node.js Express server per outsource kar deti hai (via REST APIs). Is se app light-weight rehti hai aur mobile ki battery zaya nahi hoti.

---

### Viva/Report ke liye Tip (Pro Tip for FYP Viva)
Agar apse FYP defense mein poochein ke isme konsa main algorithm hai, toh ap **Haversine Algorithm (for GPS distance)** aur **Websocket/Pub-Sub Architecture (for Real-time Chat)** ka reference dein, ye technically sabse strong point hain apki mobile app ke! Par agar panel Architecture ya Security ka puche to unhen **Bcrypt Hashing**, **Singleton Pattern** aur **Normalized PostgreSQL** ka hawala den. Ye apka FYP bohot professional show karega!
