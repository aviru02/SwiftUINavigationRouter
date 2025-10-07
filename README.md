# SwiftUIRouter

A powerful, type-safe, and generic navigation router for SwiftUI applications.

[![Swift Version](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%2016%2B-lightgrey.svg)](https://www.apple.com)

## Features

✨ **Type-Safe Navigation** - Compile-time guarantees for all navigation operations  
🎯 **Fully Generic** - Works with any destination type without boilerplate  
🔄 **Powerful API** - Navigate forward, backward, to root, or to specific screens  
📦 **Easy Integration** - Simple setup with minimal code  
🎨 **SwiftUI Native** - Built on NavigationStack and @Environment  
🚀 **Production Ready** - Comprehensive test coverage and documentation  
📱 **iOS 16+ Support** - Compatible with modern iOS versions  

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
  - [Basic Navigation](#basic-navigation)
  - [Advanced Navigation](#advanced-navigation)
  - [Passing Data](#passing-data)
  - [Query Methods](#query-methods)
- [API Reference](#api-reference)
- [Examples](#examples)
- [Requirements](#requirements)

## Installation

### Swift Package Manager

Add SwiftUIRouter to your project using SPM:

1. In Xcode, go to **File → Add Packages...**
2. Enter the repository URL: `https://github.com/aviru02/SwiftUINavigationRouter.git`
3. Select the version you want to use
4. Click **Add Package**

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/aviru02/SwiftUINavigationRouter.git", from: "1.0.0")
]
```

## Quick Start

### 1. Define Your Destinations

Create an enum conforming to `Routable`:

```swift
import SwiftUIRouter

enum AppDestination: Routable {
    case home
    case profile(user: User)
    case settings
    
    @ViewBuilder
    func createDestinationView() -> some View {
        switch self {
        case .home:
            HomeView()
        case .profile(let user):
            ProfileView(user: user)
        case .settings:
            SettingsView()
        }
    }
}
```

### 2. Setup Navigation

Use `RouterContainerView` to create your navigation container:

```swift
struct ContentView: View {
    var body: some View {
        RouterContainerView<AppDestination, HomeView> {
            HomeView()
        }
    }
}
```

Or you can also use the below approach for `RouterContainerView` to create your navigation container:

```swift
enum AuthDestination: Routable {
    case login
    case signup
    case forgotPassword
    case profile(user: User)
    case settings(theme: String)
    
    @ViewBuilder
    func createDestinationView() -> some View {
        switch self {
        case .login:
            LoginView()
        case .signup:
            SignupView()
        case .forgotPassword:
            ForgotPasswordView()
        case .profile(let user):
            ProfileView(user: user)
        case .settings(let theme):
            SettingsView(theme: theme)
        }
    }
}

typealias AuthRouter = Router<AuthDestination>

struct AuthRootNavigationView: View {
    @State private var router = AuthRouter()
    
    var body: some View {
        RouterContainerView(router: router) {
            AuthenticationHomeView()
        }
    }
}
```

### 3. Navigate in Your Views

Access the router using `@RouterEnvironment`:

```swift
struct HomeView: View {
    @RouterEnvironment<AppDestination> var router
    
    var body: some View {
        VStack {
            Button("Go to Profile") {
                router?.navigate(to: .profile(user: currentUser))
            }
            
            Button("Go to Settings") {
                router?.navigate(to: .settings)
            }
        }
        .navigationTitle("Home")
    }
}
```

That's it! 🎉

## Usage

### Basic Navigation

#### Navigate Forward

```swift
router?.navigate(to: .profile(user: user))
```

#### Navigate Back

```swift
// Go back one screen
router?.navigateBack()

// Go back to root (home)
router?.navigateToRoot()

// Go back to a specific screen
router?.navigateBack(to: .home)

// Go back N screens
router?.navigateBack(count: 2)
```

#### Replace Current Screen

```swift
// Replace current screen (useful for edit flows)
router?.replace(with: .profile(user: updatedUser))
```

### Advanced Navigation

#### Pop and Push

Navigate back to a screen and then push a new one:

```swift
router?.popAndPush(to: .home, then: .settings)
```

### Passing Data

Pass data through associated values:

```swift
enum AppDestination: Routable {
    case detail(id: String)
    case editProfile(user: User, mode: EditMode)
    case checkout(items: [CartItem], total: Double)
    
    @ViewBuilder
    func createDestinationView() -> some View {
        switch self {
        case .detail(let id):
            DetailView(id: id)
        case .editProfile(let user, let mode):
            EditProfileView(user: user, mode: mode)
        case .checkout(let items, let total):
            CheckoutView(items: items, total: total)
        }
    }
}

// Usage
router?.navigate(to: .editProfile(user: currentUser, mode: .create))
```

### Query Methods

Check navigation state:

```swift
// Check if on a specific screen
if router?.isOnScreen(.settings) == true {
    print("Currently on settings")
}

// Get current screen
if let current = router?.currentScreen {
    print("Current: \(current)")
}

// Get navigation depth
let depth = router?.depth ?? 0
print("Navigation depth: \(depth)")

// Check if can go back
if router?.canGoBack == true {
    // Show back button
}

// Get all screens in stack
let screens = router?.allScreens ?? []
```

## API Reference

### Router Class

#### Navigation Methods

| Method | Description |
|--------|-------------|
| `navigate(to:)` | Navigate forward to a destination |
| `navigateBack()` | Go back one screen |
| `navigateToRoot()` | Return to root screen |
| `navigateBack(to:)` | Go back to specific destination |
| `navigateBack(count:)` | Go back N screens |
| `replace(with:)` | Replace current screen |
| `popAndPush(to:then:)` | Pop to destination then push new one |

#### Query Properties

| Property | Type | Description |
|----------|------|-------------|
| `currentScreen` | `Destination?` | Current destination at top of stack |
| `allScreens` | `[Destination]` | All destinations in navigation stack |
| `depth` | `Int` | Number of screens in stack |
| `isEmpty` | `Bool` | Whether stack is empty (at root) |
| `canGoBack` | `Bool` | Whether backward navigation is possible |

#### Query Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `isOnScreen(_:)` | `Bool` | Check if destination is in stack |

### Routable Protocol

```swift
protocol Routable: Hashable {
    associatedtype ViewType: View
    
    @ViewBuilder
    func createDestinationView() -> ViewType
}
```

Conform your destination enum to this protocol to enable navigation.

### RouterContainerView

```swift
RouterContainerView<Destination, RootView>(router: router) {
    RootView()
}
```

Creates a navigation container with automatic router injection.

### @RouterEnvironment

```swift
@RouterEnvironment<YourDestination> var router
```

Property wrapper to access the router in any view.

## Examples

### Example 1: Authentication Flow

```swift
enum AuthDestination: Routable {
    case login
    case signup
    case forgotPassword
    case home(user: User)
    
    @ViewBuilder
    func createDestinationView() -> some View {
        switch self {
        case .login: LoginView()
        case .signup: SignupView()
        case .forgotPassword: ForgotPasswordView()
        case .home(let user): HomeView(user: user)
        }
    }
}

struct LoginView: View {
    @RouterEnvironment<AuthDestination> var router
    
    var body: some View {
        VStack {
            // Login form...
            
            Button("Login") {
                // After successful login
                router?.replace(with: .home(user: authenticatedUser))
            }
            
            Button("Forgot Password?") {
                router?.navigate(to: .forgotPassword)
            }
            
            Button("Sign Up") {
                router?.navigate(to: .signup)
            }
        }
    }
}
```

### Example 2: E-Commerce Flow

```swift
enum ShopDestination: Routable {
    case home
    case category(name: String)
    case product(id: String)
    case cart(items: [CartItem])
    case checkout
    case orderConfirmation(orderId: String)
    
    @ViewBuilder
    func createDestinationView() -> some View {
        switch self {
        case .home: ShopHomeView()
        case .category(let name): CategoryView(name: name)
        case .product(let id): ProductView(id: id)
        case .cart(let items): CartView(items: items)
        case .checkout: CheckoutView()
        case .orderConfirmation(let id): OrderConfirmationView(orderId: id)
        }
    }
}

struct ProductView: View {
    @RouterEnvironment<ShopDestination> var router
    let id: String
    
    var body: some View {
        VStack {
            // Product details...
            
            Button("Add to Cart") {
                router?.navigate(to: .cart(items: cartItems))
            }
        }
        .navigationTitle("Product")
    }
}

struct CheckoutView: View {
    @RouterEnvironment<ShopDestination> var router
    
    var body: some View {
        VStack {
            // Checkout form...
            
            Button("Place Order") {
                processOrder { orderId in
                    // Replace checkout with confirmation (can't go back)
                    router?.replace(with: .orderConfirmation(orderId: orderId))
                }
            }
        }
    }
}
```

### Example 3: Multiple Router Types

You can have multiple router types in the same app:

```swift
struct MainTabView: View {
    var body: some View {
        TabView {
            RouterContainerView<AuthDestination, AuthHomeView> {
                AuthHomeView()
            }
            .tabItem { Label("Auth", systemImage: "person") }
            
            RouterContainerView<ShopDestination, ShopHomeView> {
                ShopHomeView()
            }
            .tabItem { Label("Shop", systemImage: "cart") }
            
            RouterContainerView<ProfileDestination, ProfileHomeView> {
                ProfileHomeView()
            }
            .tabItem { Label("Profile", systemImage: "person.circle") }
        }
    }
}
```

### Example 4: Deep Linking

```swift
struct DeepLinkHandler: View {
    @RouterEnvironment<AppDestination> var router
    
    var body: some View {
        ContentView()
            .onOpenURL { url in
                handleDeepLink(url)
            }
    }
    
    func handleDeepLink(_ url: URL) {
        // Parse URL and navigate
        if url.path == "/profile" {
            router?.navigate(to: .profile(user: currentUser))
        } else if url.path.starts(with: "/product/") {
            let id = String(url.path.dropFirst(9))
            router?.navigate(to: .productDetail(id: id))
        }
    }
}
```

### Example 5: Navigation Guards

```swift
struct ProtectedView: View {
    @RouterEnvironment<AppDestination> var router
    @State private var isAuthenticated = false
    
    var body: some View {
        Group {
            if isAuthenticated {
                ProtectedContent()
            } else {
                Text("Not Authenticated")
            }
        }
        .onAppear {
            if !isAuthenticated {
                router?.replace(with: .login)
            }
        }
    }
}
```

## Architecture

### How It Works

SwiftUIRouter uses a combination of SwiftUI's `NavigationStack` and a custom environment system to provide type-safe navigation:

1. **NavigationPath**: Uses SwiftUI's type-erased `NavigationPath` for the actual navigation
2. **Type-Safe Stack**: Maintains a parallel typed stack for type-safe operations
3. **Environment Injection**: Stores router in SwiftUI's environment for easy access
4. **Generic Design**: Works with any `Routable` conforming type without code generation

### Type Safety

The router ensures compile-time safety through:

- Generic constraints on the `Router<Destination>` type
- Protocol-based design with `Routable`
- Strongly-typed destination enums
- No string-based routing or magic values

### Memory Management

- Router uses `ObservableObject` and `@Published` for reactive updates
- `RouterContainerView` manages the router lifecycle with `@StateObject`
- No retain cycles or memory leaks
- Automatic cleanup when navigation hierarchy is dismissed

## Best Practices

### 1. One Router Per Flow

Create separate router types for distinct flows:

```swift
// ✅ Good
enum AuthDestination: Routable { ... }
enum MainDestination: Routable { ... }

// ❌ Avoid
enum AppDestination: Routable {
    case login, signup, home, profile, settings, ...  // Too many
}
```

### 2. Use Associated Values for Data

Pass data through destination cases:

```swift
// ✅ Good
case profile(user: User)
case detail(id: String, context: Context)

// ❌ Avoid global state
var globalUser: User?  // Don't do this
case profile
```

### 3. Handle Optional Router

Always safely unwrap the router:

```swift
// ✅ Good
router?.navigate(to: .home)

// ❌ Avoid force unwrapping
router!.navigate(to: .home)
```

### 4. Use Replace for Auth Flows

Prevent going back to login after authentication:

```swift
// ✅ Good
router?.replace(with: .home(user: user))

// ❌ Avoid navigate (allows back to login)
router?.navigate(to: .home(user: user))
```

## Troubleshooting

### Router is nil

**Problem**: `@RouterEnvironment` returns `nil`

**Solution**: Ensure `RouterContainerView` is in the view hierarchy:

```swift
// Make sure RouterContainerView wraps your views
RouterContainerView<AppDestination, HomeView> {
    HomeView()  // Router available here
}
```

### Wrong Router Type

**Problem**: Router is nil even though RouterContainerView exists

**Solution**: Check that destination types match:

```swift
// Router type must match usage
RouterContainerView<AuthDestination, HomeView> { ... }

// In views
@RouterEnvironment<AuthDestination> var router  // ✅ Matches
@RouterEnvironment<ShopDestination> var router  // ❌ Wrong type
```

### Navigation Not Working

**Problem**: Navigation methods have no effect

**Solution**: 
1. Check that router is not nil
2. Verify NavigationStack is in the hierarchy
3. Ensure destination enum cases are correct

## Requirements

- iOS 16.0+
- macOS 13.0+
- Swift 5.9+
- Xcode 15.0+

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## Support

- 📧 Email: avirubhattacharjee2@gmail.com
- 💬 Issues: [GitHub Issues](https://github.com/yourusername/SwiftUIRouter/issues)

---

**Star ⭐️ this repo if you find it useful!**
