//
//  RouterEnvironment.swift
//  SwiftUIRouter
//
//  Created by Aviru Bhattacharjee on 05/10/25.
//

import SwiftUI

// MARK: - Convenience Property Wrapper for Router Access

/// Property wrapper for accessing a typed router from the environment
///
/// This property wrapper simplifies router access in views by handling
/// the type casting from the type-erased environment value.
///
/// Example:
/// ```swift
/// struct MyView: View {
///     @RouterEnvironment<AppDestination> var router
///
///     var body: some View {
///         Button("Navigate") {
///             router?.navigate(to: .detail(id: "123"))
///         }
///     }
/// }
/// ```
///
/// The router is optional because:
/// - It might not be injected into the environment
/// - The wrong router type might be in the environment
@propertyWrapper
@MainActor
public struct RouterEnvironment<Destination: Routable>: DynamicProperty {
    
    /// The type-erased router from the environment
    @Environment(\.router) private var routerObject
    
    /// The typed router instance
    ///
    /// Returns the router cast to the correct type, or nil if:
    /// - No router is in the environment
    /// - The router in the environment is of a different destination type
    public var wrappedValue: Router<Destination>? {
        routerObject as? Router<Destination>
    }
    
    /// Creates a new RouterEnvironment property wrapper
    public init() {}
}
