//
//  LocationAuthorizationState.swift
//  bumpd
//
//  Created by Alan Olvera on 27/09/23.
//

import Foundation

// Define un protocolo para el estado de autorización
protocol LocationAuthorizationState {
    func handleAuthorization()
}

// Implementaciones de diferentes estados
class RestrictedAuthorizationState: LocationAuthorizationState {
    func handleAuthorization() {
        print("Location access was restricted.")
    }
}

class DeniedAuthorizationState: LocationAuthorizationState {
    
    func handleAuthorization() {
        print("User denied access to location.")
    }
}

class NotDeterminedAuthorizationState: LocationAuthorizationState {
    func handleAuthorization() {
        print("Location status not determined.")
    }
}

class AuthorizedAuthorizationState: LocationAuthorizationState {
    func handleAuthorization() {
        print("Location status is OK.")
    }
}

class UnknownAuthorizationState: LocationAuthorizationState {
    func handleAuthorization() {
        print("Fatal error")
    }
}

// Utiliza el patrón State en el manejador de autorización de ubicación
class LocationAuthorizationHandler {
    private var state: LocationAuthorizationState
    
    init(state: LocationAuthorizationState) {
        self.state = state
    }
    
    func changeState(_ newState: LocationAuthorizationState) {
        state = newState
    }
    
    func handleAuthorization() {
        state.handleAuthorization()
    }
}
