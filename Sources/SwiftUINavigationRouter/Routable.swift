//
//  Routable.swift
//  SwiftUIRouter
//
//  Created by Aviru Bhattacharjee on 05/10/25.
//
import SwiftUI

// MARK: - Router Protocol

/// Protocol that defines the contract for a navigation destination
///
/// Conform your destination enum to this protocol to enable type-safe navigation.
///
/// Example:
/// ```swift
/// enum AppDestination: Routable {
///     case home
///     case detail(id: String)
///
///     func createView() -> some View {
///         switch self {
///         case .home: HomeView()
///         case .detail(let id): DetailView(id: id)
///         }
///     }
/// }
/// ```
public protocol Routable: Hashable, Sendable {
    associatedtype ViewType: View
    
    /// Creates the view for this destination
    ///
    /// Implement this method to return the appropriate view for each destination case.
    /// This is called automatically by the RouterView when navigating. 
    @ViewBuilder
    @MainActor
    func createDestinationView() -> ViewType
}
