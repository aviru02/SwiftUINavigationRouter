//
//  Router.swift
//  SwiftUINavigationRouter
//
//  Created by Aviru Bhattacharjee on 02/10/25.
//
import SwiftUI
import Combine

// MARK: - Generic Router Class

/// A generic, type-safe router for SwiftUI navigation
///
/// The Router class manages navigation state and provides methods for programmatic navigation.
/// It uses SwiftUI's NavigationPath under the hood and maintains a type-safe stack of destinations.
///
/// Key Features:
/// - Generic over any Routable destination type
/// - Maintains navigation history
/// - Provides forward and backward navigation
/// - Query methods for navigation state
/// 
/// Example:
/// ```swift
/// let router = Router<AppDestination>()
/// router.navigate(to: .detail(id: "123"))
/// router.navigateBack()
/// ```
@MainActor
public class Router<Destination: Routable>: ObservableObject {
    
    /// The navigation path used by SwiftUI's NavigationStack
    ///
    /// This is bound to the NavigationStack and automatically updates the UI when changed.
    @Published public var navPath = NavigationPath()
    
    /// Internal stack tracking all destinations for type-safe operations
    ///
    /// This parallel stack allows us to perform operations like navigating back to a specific
    /// destination without losing type information (NavigationPath is type-erased).
    @Published private var pathStack: [Destination] = []
    
    /// Creates a new router instance
    public init() {}
    
    // MARK: - Navigation Methods
    
    /// Navigate forward to a new destination
    ///
    /// Pushes a new destination onto the navigation stack, displaying its view.
    ///
    /// Example:
    /// ```swift
    /// router.navigate(to: .profile(user: currentUser))
    /// ```
    ///
    /// - Parameter destination: The destination to navigate to
    public func navigate(to destination: Destination) {
        navPath.append(destination)
        pathStack.append(destination)
    }
    
    /// Navigate back one screen
    ///
    /// Pops the top destination from the stack, returning to the previous screen.
    /// Does nothing if already at the root.
    ///
    /// Example:
    /// ```swift
    /// router.navigateBack()
    /// ```
    public func navigateBack() {
        guard !navPath.isEmpty else { return }
        navPath.removeLast()
        if !pathStack.isEmpty {
            pathStack.removeLast()
        }
    }
    
    /// Navigate back to the root screen (home)
    ///
    /// Removes all destinations from the stack, returning to the initial view.
    ///
    /// Example:
    /// ```swift
    /// router.navigateToRoot() // Go back to home
    /// ```
    public func navigateToRoot() {
        navPath.removeLast(navPath.count)
        pathStack.removeAll()
    }
    
    /// Navigate back to a specific destination
    ///
    /// Finds the destination in the stack and removes all destinations after it.
    /// Useful for "back to X" navigation patterns.
    ///
    /// Example:
    /// ```swift
    /// router.navigateBack(to: .login) // Return to login screen
    /// ```
    ///
    /// - Parameter destination: The destination to navigate back to
    /// - Note: Does nothing if the destination is not found in the stack
    public func navigateBack(to destination: Destination) {
        guard let index = pathStack.lastIndex(of: destination) else {
            return
        }
        
        let itemsToRemove = pathStack.count - index - 1
        if itemsToRemove > 0 {
            navPath.removeLast(itemsToRemove)
            pathStack.removeLast(itemsToRemove)
        }
    }
    
    /// Navigate back by a specific number of screens
    ///
    /// Removes the specified number of destinations from the top of the stack.
    ///
    /// Example:
    /// ```swift
    /// router.navigateBack(count: 2) // Go back 2 screens
    /// ```
    ///
    /// - Parameter count: The number of screens to go back
    /// - Note: If count exceeds stack depth, navigates to root
    public func navigateBack(count: Int) {
        let itemsToRemove = min(count, navPath.count)
        if itemsToRemove > 0 {
            navPath.removeLast(itemsToRemove)
            pathStack.removeLast(min(itemsToRemove, pathStack.count))
        }
    }
    
    /// Replace the current screen with a new destination
    ///
    /// Removes the current destination and pushes a new one, useful for
    /// scenarios like "edit → save → show updated" without navigation buildup.
    ///
    /// Example:
    /// ```swift
    /// router.replace(with: .profile(user: updatedUser))
    /// ```
    ///
    /// - Parameter destination: The destination to replace the current screen with
    public func replace(with destination: Destination) {
        if !navPath.isEmpty {
            navPath.removeLast()
            if !pathStack.isEmpty {
                pathStack.removeLast()
            }
        }
        navPath.append(destination)
        pathStack.append(destination)
    }
    
    /// Pop to a destination and then push a new one
    ///
    /// Combines navigateBack(to:) and navigate(to:) in one operation.
    /// Useful for complex navigation flows.
    ///
    /// Example:
    /// ```swift
    /// router.popAndPush(to: .home, then: .profile(user: user))
    /// ```
    ///
    /// - Parameters:
    ///   - targetDestination: The destination to navigate back to
    ///   - newDestination: The new destination to navigate to after popping
    public func popAndPush(to targetDestination: Destination, then newDestination: Destination) {
        navigateBack(to: targetDestination)
        navigate(to: newDestination)
    }
    
    // MARK: - Query Methods
    
    /// Check if a specific destination is currently in the navigation stack
    ///
    /// Useful for conditional UI logic based on navigation state.
    ///
    /// Example:
    /// ```swift
    /// if router.isOnScreen(.settings) {
    ///     // Show settings indicator
    /// }
    /// ```
    ///
    /// - Parameter destination: The destination to check for
    /// - Returns: `true` if the destination is in the stack, `false` otherwise
    public func isOnScreen(_ destination: Destination) -> Bool {
        return pathStack.contains(destination)
    }
    
    /// Get the current screen (top of the stack)
    ///
    /// Returns the most recently navigated destination.
    ///
    /// Example:
    /// ```swift
    /// if let current = router.currentScreen {
    ///     print("Currently on: \(current)")
    /// }
    /// ```
    ///
    /// - Returns: The current destination, or `nil` if at root
    public var currentScreen: Destination? {
        return pathStack.last
    }
    
    /// Get all screens in the navigation stack
    ///
    /// Returns the complete navigation history from root to current.
    ///
    /// Example:
    /// ```swift
    /// let breadcrumbs = router.allScreens
    /// ```
    ///
    /// - Returns: Array of all destinations in the stack
    public var allScreens: [Destination] {
        return pathStack
    }
    
    /// Get the navigation depth (number of screens in stack)
    ///
    /// Returns how many levels deep the user has navigated.
    ///
    /// Example:
    /// ```swift
    /// print("Navigation depth: \(router.depth)")
    /// ```
    ///
    /// - Returns: The number of destinations in the stack (0 = root only)
    public var depth: Int {
        return pathStack.count
    }
    
    /// Check if the navigation stack is empty (at root)
    ///
    /// Example:
    /// ```swift
    /// if router.isEmpty {
    ///     // Show root-only UI
    /// }
    /// ```
    ///
    /// - Returns: `true` if at root, `false` if there are destinations in the stack
    public var isEmpty: Bool {
        return pathStack.isEmpty
    }
    
    /// Check if backward navigation is possible
    ///
    /// Returns whether there are any destinations to navigate back to.
    ///
    /// Example:
    /// ```swift
    /// Button("Back") { ... }
    ///     .disabled(!router.canGoBack)
    /// ```
    ///
    /// - Returns: `true` if can go back, `false` if at root
    public var canGoBack: Bool {
        return !navPath.isEmpty
    }
}
