# StitchHub Data Compliance & Privacy Framework 🛡️⚖️

This document outlines how the **StitchHub** platform implements security standards, privacy regulations (such as GDPR, CCPA, and regional Data Protection Acts), and app store safety guidelines (Google Play Data Safety & Apple App Store Privacy).

---

## 1. Data Minimization & Privacy by Design
StitchHub implements the principle of data minimization—only collecting and processing data that is strictly necessary for service fulfillment:
*   **Essential Profile Fields**: We only require name, email, phone number (for SMS tracking), and user type during registration.
*   **Measurement Vault Focus**: Tailoring metrics are limited to essential fit categories (chest, waist, shoulder, sleeve, etc.). Secondary/excessive sizing fields (like Hip measurements) have been deliberately omitted to keep user records minimal and secure.
*   **Role-Based Access**: Customers have read-only access to their measurements, protecting the accuracy of the record. Only the designated tailor can modify or delete measurement metrics.

---

## 2. Right to Erasure (Account Deletion)
In compliance with international privacy laws (e.g., GDPR Article 17), StitchHub provides a direct, user-initiated account deletion flow:
*   **Location**: Settings → Privacy → Delete Account.
*   **Process**: When a user clicks "Delete", the app sends a deletion query to the database.
*   **Cascade Effect**: The user's rows in `users` and `tailors` are deleted. Foreign key constraints with `ON DELETE CASCADE` ensure that corresponding user files, cached messages, and measurements are erased from PostgreSQL tables, preventing data retention.

---

## 3. Location Data Consent & Calculations
Location tracking is sensitive and requires high standards of compliance:
*   **Explicit Consent**: The app requests location access dynamically via Flutter's `permission_handler` and `geolocator` packages.
*   **No Active Background Tracking**: Location is only retrieved in the foreground when a customer searches for nearby tailors.
*   **Mathematical Processing (Haversine)**: Distance is computed programmatically on the client/database side using the Haversine formula (degrees to radians spherical projection). Exact GPS coordinates are never exposed directly to other users; only the calculated distance (in kilometers) is displayed.

---

## 4. Payment Security (PCI DSS Compliance)
StitchHub does not process, handle, or store credit card details directly, achieving high compliance standards:
*   **Stripe SDK Integration**: User card details are processed directly within Stripe's hosted inputs.
*   **Tokenization**: The platform receives a secure payment intent token rather than card numbers.
*   **Manual Transfers Verification**: For non-card payments, bank transfer screenshots uploaded to Supabase Storage buckets are private and restricted to the respective customer and tailor transactions.

---

## 5. Row Level Security (RLS) in PostgreSQL
To prevent database injection and cross-user data leakage, the PostgreSQL database implements Row Level Security:
*   **Authentication Validation**: Every query is validated using the user's JWT (JSON Web Token) issued by Supabase Auth.
*   **Isolation Policies**:
    *   *Orders Table*: A user can only select/update rows where `customer_id` or `tailor_id` matches their verified `auth.uid()`.
    *   *Messages Table*: Chat logs are only accessible to the sender and recipient IDs matching the user session.
    *   *Measurements Table*: Read access is granted to the customer and tailor, but write/delete policies are restricted strictly to the tailor.

---

## 6. App Store Compliance Checklist

| Requirement | StitchHub Implementation | Status |
|-------------|--------------------------|--------|
| **Account Deletion Link** | In-app settings button with confirmation modal. | ✅ Active |
| **Privacy Policy Link** | Available in-app and hosted on repository root. | ✅ Active |
| **Data Encryption** | Enforced HTTPS for API endpoints and database channels. | ✅ Active |
| **Location Disclosure** | Disclosure popups requesting location permission in foreground. | ✅ Active |
