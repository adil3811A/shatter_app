# Shatter Secure Authentication & Persistence Flow

This document provides a technical overview of how the authentication, registration, local session persistence, E2E cryptographic key generation, and error-handling flows function in the Shatter application.

---

## Architectural Diagram

The diagram below shows how the UI screens, local persistence services, and remote Firebase services interact:

```mermaid
sequenceFlow
    autonumber
    actor User as User
    participant UI as UI (Login/Register)
    participant AuthServ as AuthService
    participant LocalStore as LocalStorageService
    participant FBAuth as Firebase Auth
    participant Firestore as Cloud Firestore

    %% Registration Flow
    Note over User, Firestore: Registration Flow
    User->>UI: Enter email, username, password
    UI->>AuthServ: register(email, username, password)
    AuthServ->>Firestore: Check if username is available
    Firestore-->>AuthServ: Available (True)
    AuthServ->>FBAuth: Create user with email and password
    FBAuth-->>AuthServ: Returns UID
    Note over AuthServ: Generate E2E Public/Private Keys
    AuthServ->>Firestore: Store metadata & Public Key (users & user_profiles)
    AuthServ->>LocalStore: Cache user session & Private Key
    LocalStore-->>AuthServ: Cached successfully
    AuthServ-->>UI: Registration complete
    UI-->>User: Redirect to ShatterAppShell (via StreamBuilder)

    %% Login Flow
    Note over User, Firestore: Username Login Flow
    User->>UI: Enter username and password
    UI->>AuthServ: login(username, password)
    AuthServ->>Firestore: Resolve email by username
    Firestore-->>AuthServ: Returns email address
    AuthServ->>FBAuth: SignIn with email and password
    FBAuth-->>AuthServ: Returns UID
    AuthServ->>Firestore: Fetch user metadata & profile status
    AuthServ->>LocalStore: Cache user session & recover/generate keys
    AuthServ-->>UI: Sign-in complete
    UI-->>User: Redirect to ShatterAppShell (via StreamBuilder)
```

---

## Detailed Component Flow

### 1. Registration Flow

When a new user registers:
1. **Uniqueness Check**: [AuthService](file:///home/adil/Devlopment/shatter_app/lib/data/services/auth_service.dart#L36-L51) queries Cloud Firestore `users` to verify if the entered username is already taken. If it is, the flow aborts immediately and notifies the user in the UI.
2. **Credential Creation**: The user is registered with Firebase Authentication via `createUserWithEmailAndPassword`.
3. **E2E Key Generation**: A mockup public/private key pair is generated:
   - **Public Key**: Uploaded to Firestore in the `users` and `user_profiles` collections. This allows other chat participants to fetch it for message encryption.
   - **Private Key**: Kept exclusively on the user's device in local secure storage. It is never transmitted to Firestore.
4. **Firestore Profile Setup**: Firestore documents are created under:
   - `users/{uid}`: Contains core credentials configuration (email, username, public_key, timestamps).
   - `user_profiles/{uid}`: Contains public-facing details (displayName, avatarUrl, bio, status, theme).
5. **Local Session Cache**: A [UserSession](file:///home/adil/Devlopment/shatter_app/lib/data/models/user_session.dart) is saved locally.

---

### 2. Login Flow (Username-Based)

Because Firebase Auth natively requires an email to sign in, Shatter performs email resolution behind the scenes:
1. **Email Resolution**: [AuthService](file:///home/adil/Devlopment/shatter_app/lib/data/services/auth_service.dart#L131-L150) queries the Firestore `users` collection to find the document matching the entered username and extracts its `email` field.
2. **Authentication**: Sign-in is completed using the resolved `email` and user-provided `password`.
3. **Session Cache**: Profile configuration is read from Firestore and cached locally.
4. **Key Restoration**: The private key is retrieved from secure storage. If logging in on a new device, a key is generated deterministically from the username (acting as a recovery mockup).

---

### 3. Local Persistence Design

Shatter segregates data storage by sensitivity to ensure secure local caching:

| Category | Storage Medium | Stored Data |
| :--- | :--- | :--- |
| **Sensitive Data** | `FlutterSecureStorage` (Encrypted) | Cryptographic E2E Private Key |
| **Non-Sensitive Data** | `SharedPreferences` (JSON formatted) | Email, Username, User UID, Display Name, Public Key |
| **App Settings** | `SharedPreferences` | Location Sharing Toggle, Active Status, Notifications |

All local services are encapsulated inside the singleton [LocalStorageService](file:///home/adil/Devlopment/shatter_app/lib/data/services/local_storage_service.dart).

---

### 4. Reactive Session Routing

To prevent flickering screens and manual view navigation, routing is reactively synced with Firebase Authentication:
* In [my_app.dart](file:///home/adil/Devlopment/shatter_app/lib/my_app.dart), a `StreamBuilder` listens to `AuthService().authStateChanges`.
* If a valid session user is logged in, it serves `ShatterAppShell`.
* If the user logs out or has no session, it displays the `LoginScreen`.
* Signing out from the profile screen calls `AuthService().logout()`, which clears the Firebase token and clears the local caches, triggering an immediate redirect back to the login screen.

---

### 5. Error Handling System

Authentication errors are processed using the [ErrorHandler](file:///home/adil/Devlopment/shatter_app/lib/utils/error_handler.dart) class:
* Maps `FirebaseAuthException` codes (e.g., `invalid-credential`, `too-many-requests`, `email-already-in-use`) to localized, clean error descriptions.
* Gracefully catches database disruptions or network requests failures, displaying clean warnings in the UI instead of raw error strings.
