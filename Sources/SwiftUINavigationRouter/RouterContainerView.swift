//
//  RouterContainerView.swift
//  SwiftUIRouter
//
//  Created by Aviru Bhattacharjee on 05/10/25.
//
import SwiftUI

// MARK: - RouterContainerView

/// A reusable navigation container view
///
/// RouterContainerView sets up a NavigationStack with automatic router injection.
/// It creates the navigation container and ensures the router is available
/// to all views in the navigation hierarchy.
///
/// Example:
/// ```swift
/// RouterContainerView<AppDestination, HomeView> {
///     HomeView()
/// }
/// ```
/// Or
/// ```swift
/// RouterContainerView(router: router) {
/// AuthenticationHomeView()
/// }
/// ```
///
/// The RouterContainerView automatically:
/// - Creates a NavigationStack
/// - Injects the router into the environment
/// - Sets up navigationDestination for your destination type
/// - Handles view creation for each destination
@MainActor
public struct RouterContainerView<Destination: Routable, RootView: View>: View {
    
    /// The router instance managing navigation state
    @StateObject private var router: Router<Destination>
    
    /// The root view to display in the navigation stack
    private let rootView: RootView
    
    /// Creates a new RouterView
    ///
    /// - Parameters:
    ///   - router: The router instance to use (default: creates new Router)
    ///   - rootView: A closure that returns the root view to display
    public init(
        router: Router<Destination> = Router<Destination>(),
        @ViewBuilder rootView: () -> RootView
    ) {
        _router = StateObject(wrappedValue: router)
        self.rootView = rootView()
    }
    
    public var body: some View {
        NavigationStack(path: $router.navPath) {
            rootView
                .navigationDestination(for: Destination.self) { destination in
                    destination.createDestinationView()
                       // .withRouter(router)
                }
        }
        .withRouter(router)
    }
}
