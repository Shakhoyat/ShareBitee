Copy everything below this line and save it as `PLAN.md` in ShareBitee:

---

```markdown
# Implementation Plan: ShareBite — Hyperlocal Food Sharing iOS App

## Overview
ShareBite is a hyperlocal food-sharing app where users post surplus food for neighbors to claim. It uses Firebase Auth for login, Firestore for all data, and a card-based SwiftUI interface with tab navigation. Every feature maps directly to taught lab concepts.

---

# PHASE 1 — Allowed Concepts List

## Lab 1: Introduction to Swift
- Variables & Constants (`var`, `let`)
- Data types (`String`, `Int`, `Bool`, `Double`)
- Optionals & optional binding (`if let`, `guard let`, `?`, `!`)
- Arrays & Dictionaries
- Structs & Classes
- Functions & closures
- Control flow (`if/else`, `for-in`, ternary operator)

## Lab 2: Introduction to SwiftUI Elements
- `VStack`, `HStack` layout primitives
- `Text` with modifiers (`.font`, `.fontWeight`, `.foregroundColor`, `.padding`)
- `Image(systemName:)` — SF Symbols ⭐
- `Image("asset")` with `.resizable()`, `.aspectRatio()`, `.frame()`, `.clipShape()`
- `Button` with custom label closures
- `@State` & `.toggle()`
- `NavigationStack` ⭐
- `NavigationLink` (value-based)
- `.navigationDestination(isPresented:)`
- `.navigationTitle()`
- Conditional rendering via ternary in modifiers ⭐
- `.cornerRadius()`, `.background()`, `.opacity()`
- `PreviewProvider` / `#Preview`

## Lab 3: JSON Parsing & Networking
- `Codable` / `Decodable` protocol on structs ⭐
- `Identifiable` protocol
- `JSONDecoder`
- `Bundle.main.decode()` generic extension ⭐
- `URLSession.shared.dataTask` async networking
- `@StateObject` + `ObservableObject` ViewModel ⭐⭐
- `@Published` properties
- `DispatchQueue.main.async`
- `List` + `ForEach` ⭐
- `AsyncImage(url:)` with placeholder
- `ProgressView`
- Error state handling (`isLoading`, `errorMessage`) ⭐
- `ScrollView`
- `Link(destination:)`
- `NavigationView` + `NavigationLink` master-detail
- `.listStyle(PlainListStyle())`

## Lab 4: Firebase + SwiftUI
- Firebase SDK via SPM
- `FirebaseApp.configure()` in `@main` App struct
- Firebase Authentication (email/password) ⭐⭐
- Firestore read/write ⭐⭐
- Keychain Sharing capability
- GoogleService-Info.plist

## Lab 5: Property Wrappers
- `@State` — local view state
- `@Binding` — child-to-parent communication ⭐
- `@ObservedObject` — injected ViewModel
- `@StateObject` — owning ViewModel
- `@EnvironmentObject` — global shared state ⭐⭐
- `ObservableObject` + `@Published`
- `TextField` + `.textFieldStyle(.roundedBorder)`
- `Toggle`
- `.buttonStyle(.borderedProminent)`
- `.disabled()` modifier
- `.controlSize(.large)`
- `.navigationBarTitleDisplayMode(.inline)`

> ⭐ = Impressive when used creatively | ⭐⭐ = High-impact differentiator

---

# PHASE 2 — Project Plan: ShareBite

## Hard Constraints
- Firebase: Auth + Firestore ONLY (free tier)
- Beginner-to-intermediate Swift — clean, readable, no over-engineering
- No MapKit/location — replaced by simple neighborhood text field in Firestore
- No emoji in UI — SF Symbols only via `Image(systemName:)`

## Firestore Data Model

### Collection: `users`
```
users/{uid}
├── displayName: String
├── email: String
├── rating: Double
├── ratingCount: Int
├── joinedDate: String
└── neighborhood: String
```

### Collection: `foodPosts`
```
foodPosts/{autoID}
├── title: String
├── description: String
├── category: String        // "Cooked Meal" | "Groceries" | "Baked Goods" | "Beverages" | "Other"
├── dietaryTags: [String]   // ["Vegetarian", "Halal", "Nut-Free"]
├── totalQuantity: Int
├── availableQuantity: Int  // decrements on each booking
├── neighborhood: String
├── status: String          // "available" | "partially_claimed" | "fully_claimed"
├── postedBy: String        // uid
├── posterName: String
├── posterEmail: String
├── likeCount: Int
├── likedBy: [String]       // array of uids (prevents double-like)
├── createdAt: String
└── expiresAt: String
```

### Collection: `bookings`
```
bookings/{autoID}
├── foodPostId: String
├── foodTitle: String
├── requestedBy: String     // uid
├── requesterName: String
├── quantity: Int
├── status: String          // "pending" | "confirmed" | "completed" | "cancelled"
├── createdAt: String
└── posterUid: String
```

> Smart Food Count Logic: On booking, read `availableQuantity`, validate `requestedQuantity <= availableQuantity`, write booking doc and decrement `availableQuantity` with `.updateData()`. If `availableQuantity` reaches 0, set `status = "fully_claimed"`. Home feed query filters `availableQuantity > 0`.

---

## Tab Bar Structure

| Tab | Icon (SF Symbol) | Label | View |
|-----|-----------------|-------|------|
| 1 | `house` | Home | `HomeFeedView` |
| 2 | `plus.circle` | Share | `PostFoodView` |
| 3 | `list.clipboard` | My Posts | `MyPostsView` |
| 4 | `hand.raised` | Bookings | `MyBookingsView` |
| 5 | `person.circle` | Profile | `ProfileView` |

---

## Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| ShareGreen | `#4CAF50` | Primary actions, available badge |
| ShareOrange | `#FF9800` | Partially claimed badge, accents |
| ShareRed | `#E53935` | Fully claimed, sign out, destructive |
| ShareCream | `#FFF8E1` | Card backgrounds |
| ShareBrown | `#5D4037` | Secondary text |

Define in `Assets.xcassets` as Color Sets. Reference with `Color("ShareGreen")`.

---

## Feature 1: Authentication Flow

**Screens:** `LoginView` → `SignUpView` ↔ `LoginView` → `MainTabView`

**Navigation:** Conditional root — `if authVM.isLoggedIn { MainTabView() } else { LoginView() }`

**Taught concepts:**
- `@EnvironmentObject` for global auth state (Lab 5) ⭐⭐
- `@StateObject` / `ObservableObject` / `@Published` for `AuthViewModel` (Lab 3 & 5) ⭐⭐
- `TextField` + `.textFieldStyle(.roundedBorder)` (Lab 5)
- `.disabled()` when fields empty (Lab 5) ⭐
- `.buttonStyle(.borderedProminent)` (Lab 5)
- `NavigationStack` + `NavigationLink` (Lab 2)
- Firebase Auth email/password (Lab 4) ⭐⭐
- Firestore write on sign-up (Lab 4)
- `ProgressView` loading state (Lab 3)
- Error state display (Lab 3)

**AuthViewModel skeleton:**
```swift
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: UserModel?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    func signIn(email: String, password: String) { }
    func signUp(email: String, password: String, displayName: String) { }
    func signOut() { }
    func listenToAuthState() { }
}
```

---

## Feature 2: Home Feed

**Screens:** `HomeFeedView` (Tab 1) → push to `FoodDetailView`

**Firestore query:** `foodPosts` where `availableQuantity > 0` ordered by `createdAt` descending

**Taught concepts:**
- `List` + `ForEach` (Lab 3) ⭐
- `NavigationStack` + `NavigationLink` (Lab 2 & 3)
- `@StateObject` with `FoodFeedViewModel` (Lab 3 & 5) ⭐⭐
- `@Published` for reactive feed (Lab 3)
- `ProgressView` loading state (Lab 3)
- Error handling pattern (Lab 3) ⭐
- SF Symbols for category icons (Lab 2) ⭐
- Ternary conditional for status badge color (Lab 2) ⭐
- Card styling with `.cornerRadius()`, `.background()`, `.padding()` (Lab 2)
- `Identifiable` on `FoodPost` model (Lab 3)

**Food Card layout:**
```
[fork.knife icon] Cooked Meal         [mappin icon] Dhanmondi
Homemade Pasta (3 servings left)
Vegetarian · Nut-Free
[heart icon] 12    [clock icon] Expires in 5h
Posted by Shifat
```

---

## Feature 3: Post Food

**Screens:** `PostFoodView` (Tab 2)

**Firestore write:** Add new doc to `foodPosts` collection

**Taught concepts:**
- Multiple `TextField` inputs (Lab 5) ⭐
- `@State` for every form field (Lab 2 & 5)
- `Toggle` for dietary tags (Lab 5) ⭐
- `.disabled()` on Submit when required fields empty (Lab 5) ⭐
- `.buttonStyle(.borderedProminent)` + `.controlSize(.large)` (Lab 5)
- `@EnvironmentObject` to access current user (Lab 5) ⭐⭐
- Firestore `.addDocument()` (Lab 4) ⭐⭐
- `ProgressView` during submission (Lab 3)

**Form fields:**
- Title (TextField)
- Description (TextField)
- Category (HStack of Buttons — selected gets `.borderedProminent`, others `.bordered`)
- Quantity (Stepper)
- Dietary Tags (row of Toggles: Vegetarian, Halal, Vegan, Nut-Free, Gluten-Free)
- Neighborhood (TextField)
- Hours until expiry (Stepper, default 24)

---

## Feature 4: Food Detail View + Like + Book

**Screens:** `FoodDetailView` (pushed from HomeFeed)

**Taught concepts:**
- `ScrollView` (Lab 3) ⭐
- Passing data struct to child view (Lab 3) ⭐
- `@State` for like toggle — heart pattern from Lab 2 ⭐⭐
- Ternary conditional for `heart.fill` vs `heart` (Lab 2) ⭐
- `@EnvironmentObject` for auth context (Lab 5)
- Firestore read + update (Lab 4)
- `@ObservedObject` for detail ViewModel (Lab 5)
- SF Symbols (Lab 2) ⭐

**Like button (direct Lab 2 pattern):**
```swift
Button {
    isLiked.toggle()
    detailVM.toggleLike(postId: post.id, userId: authVM.currentUser.uid)
} label: {
    HStack {
        Image(systemName: isLiked ? "heart.fill" : "heart")
        Text("\(post.likeCount)")
    }
    .foregroundColor(isLiked ? .red : .gray)
}
```

**Smart booking:**
```swift
Stepper("Servings: \(requestedQuantity)",
        value: $requestedQuantity, in: 1...post.availableQuantity)

Button("Request Pickup") { detailVM.bookFood(...) }
    .disabled(post.availableQuantity == 0)
    .buttonStyle(.borderedProminent)
```

On booking: write `bookings` doc + decrement `foodPosts.availableQuantity` + update `status` if zero.
Poster contact (name + email) revealed only after booking confirmed — conditional rendering.

---

## Feature 5: My Posts

**Screens:** `MyPostsView` (Tab 3)

**Firestore query:** `foodPosts` where `postedBy == currentUser.uid`

**Taught concepts:**
- `List` with swipe-to-delete (Lab 3)
- Firestore query with filter (Lab 4) ⭐
- Firestore `.deleteDocument()` (Lab 4)
- `@StateObject` with `MyPostsViewModel` (Lab 3 & 5) ⭐
- `@EnvironmentObject` for uid (Lab 5)
- `ForEach` with `Identifiable` (Lab 3)
- Status badge with ternary color: green/orange/red (Lab 2) ⭐
- Delete confirmation with `@State var showDeleteAlert = false` (Lab 2)

---

## Feature 6: My Bookings

**Screens:** `MyBookingsView` (Tab 4)

**Firestore query:** `bookings` where `requestedBy == currentUser.uid`

**Taught concepts:**
- `List` + `ForEach` (Lab 3)
- `@StateObject` + `ObservableObject` (Lab 3 & 5)
- Conditional rendering — show contact only if `status == "confirmed"` (Lab 2 ternary)
- `@State` for expand/collapse (Lab 2)
- SF Symbols for status icons (Lab 2) ⭐

---

## Feature 7: Profile + Rating

**Screens:** `ProfileView` (Tab 5)

**Firestore:** Read `users/{uid}`. After completed booking, claimer rates poster:
`newRating = ((oldRating * ratingCount) + newScore) / (ratingCount + 1)`

**Taught concepts:**
- `@EnvironmentObject` for user data (Lab 5) ⭐⭐
- `VStack` / `HStack` layout (Lab 2)
- SF Symbol `star.fill` for rating (Lab 2) ⭐
- Ternary color: green > 4.0, orange > 3.0, red otherwise (Lab 2) ⭐
- `Button("Sign Out")` (Lab 4 + Lab 5)
- `.buttonStyle(.borderedProminent)` with `.tint(.red)` (Lab 5)
- Firestore read/update (Lab 4)

---

## App File Structure

```
ShareBiteBD/
├── ShareBiteBDApp.swift
├── MainTabView.swift
├── Models/
│   ├── UserModel.swift
│   ├── FoodPost.swift
│   └── Booking.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── FoodFeedViewModel.swift
│   ├── PostFoodViewModel.swift
│   ├── FoodDetailViewModel.swift
│   ├── MyPostsViewModel.swift
│   ├── MyBookingsViewModel.swift
│   └── ProfileViewModel.swift
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── SignUpView.swift
│   ├── Home/
│   │   ├── HomeFeedView.swift
│   │   └── FoodCardView.swift
│   ├── Detail/
│   │   └── FoodDetailView.swift
│   ├── Post/
│   │   └── PostFoodView.swift
│   ├── MyPosts/
│   │   └── MyPostsView.swift
│   ├── Bookings/
│   │   └── MyBookingsView.swift
│   ├── Profile/
│   │   └── ProfileView.swift
│   └── Components/
│       ├── TagPillView.swift
│       ├── StatusBadgeView.swift
│       └── RatingView.swift
└── Assets.xcassets/
```

---

# PHASE 3 — Team Distribution

| Member | Owns | Key Concepts They Demonstrate | Files / Views |
|--------|------|-------------------------------|---------------|
| Lead (Me) | Auth Flow + App Shell + Home Feed + Data Models | `@EnvironmentObject` global auth, `@StateObject`/`ObservableObject`/`@Published` ViewModel pattern, Firebase Auth, `NavigationStack`, `TabView`, `List`/`ForEach`, `ProgressView`, Firestore snapshot listener, `Identifiable`/`Codable` models, conditional root view | ShareBiteBDApp.swift, `MainTabView.swift`, `Models/`, `AuthViewModel.swift`, `FoodFeedViewModel.swift`, `LoginView.swift`, `SignUpView.swift`, `HomeFeedView.swift`, `FoodCardView.swift`, `TagPillView.swift`, `StatusBadgeView.swift` |
| Member 2 | Post Food + My Posts | `@State` for form fields, `TextField`, `Toggle` for dietary tags, `.disabled()` form validation, `@EnvironmentObject` for current user, Firestore `.addDocument()` + `.deleteDocument()`, `@Binding` in sub-components, ternary status badges | `PostFoodView.swift`, `PostFoodViewModel.swift`, `MyPostsView.swift`, `MyPostsViewModel.swift` |
| Member 3 | Food Detail (Like + Book) + Bookings + Profile/Rating | `@State` like toggle (heart pattern), `@ObservedObject`, `ScrollView`, Firestore read + update (like count, quantity decrement, rating), `Stepper`, smart food count, SF Symbols, contact reveal with conditional rendering, star rating display, sign out | `FoodDetailView.swift`, `FoodDetailViewModel.swift`, `MyBookingsView.swift`, `MyBookingsViewModel.swift`, `ProfileView.swift`, `ProfileViewModel.swift`, `RatingView.swift` |

### Demo Verbal Explanations

**Lead:** "I built the authentication system using Firebase Auth and `@EnvironmentObject` so every screen knows if the user is logged in. I also built the home feed using a ViewModel with `@StateObject` that listens to Firestore in real-time and displays food cards in a `List`. I defined all data models as `Codable` and `Identifiable` structs."

**Member 2:** "I built the food posting form using `@State` for each field, `TextField` for inputs, and `Toggle` for dietary tags. I used `.disabled()` to prevent submission when fields are empty. For My Posts, I query Firestore filtered by user ID and support swipe-to-delete. I used conditional colors to show each post's availability status."

**Member 3:** "I built the detail view with a `ScrollView` layout and the like button using the `@State` toggle pattern — same as the Lab 2 heart example. My smart food quantity system uses a `Stepper` capped at available quantity that writes to Firestore and decrements availability. I also built the profile with star rating display and sign-out."

---

# Demo Talking Points

1. **Problem and Solution** — Food waste is a global problem. ShareBite lets neighbors share surplus food before it goes to waste — one tap to post, one tap to claim.

2. **Technical Architecture** — Firebase Auth for secure login and Firestore for all data, entirely on the free tier. ViewModel pattern with `@StateObject`, `ObservableObject`, and `@Published` keeps the UI reactive. `@EnvironmentObject` makes auth state accessible everywhere.

3. **Smart Food Count** — When someone books 2 of 5 servings, the count drops to 3 automatically. When it hits zero, the listing shows as fully claimed. No Cloud Functions needed — clean Firestore reads and writes.

4. **UI Polish** — Apple Human Interface Guidelines throughout: large titles, SF Symbols on every screen, a warm food-friendly color palette, card-based layouts, and proper loading and error states.

5. **Every taught concept used with purpose** — `@State`, `@Binding`, `@ObservedObject`, `@StateObject`, and `@EnvironmentObject` each used where they make sense. The like button is the Lab 2 heart pattern. The feed is the Lab 3 news list pattern. Data models are `Codable` and `Identifiable`. Everything maps back to what we learned, applied to a real product.
