//
//  RouterEnvironmentConfig.swift
//  SwiftUINavigationRouter
//
//  Created by Aviru Bhattacharjee on 05/10/25.
//
import SwiftUI

// MARK: - Router Environment Key (iOS 16+ Compatible)

/// Private environment key for storing the router in SwiftUI's environment
///
/// This key stores a type-erased ObservableObject which allows us to store
/// any Router<Destination> type in a single environment slot.
/// MainActor-isolated for thread safety.
private struct RouterEnvironmentKey: @MainActor EnvironmentKey {
    @MainActor
    static let defaultValue: (any ObservableObject)? = nil
}

extension EnvironmentValues {
    /// The router stored in the environment
    ///
    /// This computed property provides access to the router through SwiftUI's environment system.
    /// The router is type-erased as (any ObservableObject) to allow generic storage.
    /// All access is MainActor-isolated for thread safety.
    @MainActor
    public var router: (any ObservableObject)? {
        get { self[RouterEnvironmentKey.self] }
        set { self[RouterEnvironmentKey.self] = newValue }
    }
}

// MARK: - Router Access Helpers

extension EnvironmentValues {
    /// Get a typed router from the environment
    ///
    /// This helper method casts the type-erased router back to the specific Router<Destination> type.
    ///
    /// - Parameter type: The destination type to retrieve the router for
    /// - Returns: The typed router, or `nil` if not found or wrong type
    @MainActor
    public func getRouter<Destination: Routable>(for type: Destination.Type) -> Router<Destination>? {
        return router as? Router<Destination>
    }
    
    /// Set a router in the environment
    ///
    /// This helper method stores a typed router as a type-erased ObservableObject.
    ///
    /// - Parameter newRouter: The router to store in the environment
    @MainActor
    public mutating func setRouter<Destination: Routable>(_ newRouter: Router<Destination>) {
        router = newRouter
    }
}

// MARK: - View Extensions

extension View {
    /// Inject a router into the environment
    ///
    /// This modifier makes the router available to all child views through the environment.
    /// Use this when you need fine-grained control over where the router is injected.
    ///
    /// Example:
    /// ```swift
    /// ContentView()
    ///     .withRouter(myRouter)
    /// ```
    ///
    /// - Parameter router: The router instance to inject
    /// - Returns: A view with the router injected into its environment
    @MainActor
    public func withRouter<Destination: Routable>(_ router: Router<Destination>) -> some View {
        self.environment(\.router, router)
    }
}

