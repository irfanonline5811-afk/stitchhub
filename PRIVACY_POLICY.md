# StitchHub Privacy Policy 🔒🛡️

*Last Updated: June 8, 2026*

At **StitchHub**, we are committed to protecting your privacy and ensuring your personal information is handled securely. This Privacy Policy explains how we collect, use, disclose, and safeguard your data when you use the StitchHub mobile application and services (the "Platform").

---

## 1. Information We Collect

### A. Personal Data Provided by You
*   **Account Registration**: When registering as a Customer or Tailor, we collect your name, email address, phone number, and password (which is cryptographically hashed).
*   **Tailor Profiles**: Tailors provide additional data, including business names, detailed address information, pricing rates, services offered, and portfolio images.
*   **Digital Measurements**: We store custom measurement metrics (such as chest, waist, shoulder, sleeve, and full length) linked to your account profile to facilitate accurate tailoring.
*   **Media Uploads**: We collect profile pictures, custom dress designs/sketches, and chat media (including audio recordings for voice notes and payment receipt screenshots) that you upload.

### B. Automatically Collected Information
*   **Location Data**: With your explicit permission, we collect real-time **GPS location coordinates** (latitude and longitude). We use this to compute tailor proximity using the Haversine formula and display tailors near you on the map.
*   **Device Info**: We collect technical information such as your mobile device ID, operating system version, and system language settings.
*   **Push Notification Tokens**: We collect Firebase Cloud Messaging (FCM) tokens to deliver push notifications regarding order updates, appointment status changes, and chat messages.

---

## 2. How We Use Your Information
We use the collected data to:
1.  Facilitate tailor-customer matching, search, and scheduling.
2.  Enable real-time communication via text and audio messages.
3.  Process payments securely through our third-party payment gateway (Stripe).
4.  Send transactional SMS alerts (via Twilio) and push notifications.
5.  Maintain database records, manage customer-tailor relations, and improve app functionality.

---

## 3. Data Storage & Security
*   **Cloud Hosting**: Your database records, images, and audio voice notes are stored securely on **Supabase Cloud Storage** and **PostgreSQL** servers.
*   **Security Measures**: We enforce HTTPS encryption, secure database access control policies, and PostgreSQL **Row Level Security (RLS)**, ensuring tailors can only access their customers' measurements and users can only view their own transactions.
*   **Password Encryption**: All passwords are encrypted using Bcrypt prior to storage. We never view or store plain-text passwords.
*   **Payment Details**: Card details are directly processed by **Stripe**. We do not store or process raw credit card numbers on our servers.

---

## 4. Sharing Your Information
We do not sell your personal data. We only share information in the following contexts:
*   **Between Users**: Customers' measurements and order requirements are visible to the selected tailor. Tailors' business names, locations, and portfolios are visible to all customers.
*   **Service Providers**: Data is shared with third-party utilities (like Stripe for payments, Firebase for push notifications, and Twilio for SMS) as necessary to perform platform features.
*   **Legal Compliance**: We may disclose information if required by law, subpoena, or to protect the safety of users or the public.

---

## 5. Your Rights & Choices
*   **Access & Corrections**: You can view your measurements, order status, and profile information directly within the app interface.
*   **Location Permissions**: You can disable location tracking at any time through your device's system settings. Disabling location may limit proximity search features.
*   **Account Deletion**: You can request account deletion in the settings tab. Upon request, all associated personal identifier data will be permanently deleted from our database.

---

## 6. Updates to This Policy
We may update our Privacy Policy periodically. We will notify you of any modifications by posting the updated policy on this page with the revised date at the top.

Contact us at **privacy@stitchhub.com** if you have questions or concerns.
