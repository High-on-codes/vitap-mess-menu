//
//  MessMenuApp.swift
//  VIT-AP Mess Menu
//
//  iOS 17+ SwiftUI. Shows the mess's weekly breakfast/lunch/snacks/dinner
//  menu, backed by Firestore so it can be updated without shipping a new
//  build; falls back to a placeholder week if nothing's been entered yet.
//

import SwiftUI

@main
struct MessMenuApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var menuStore = MenuStore()
    @StateObject private var adminAuth = AdminAuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(menuStore)
                .environmentObject(adminAuth)
                .accentColor(Color("TerracottaAccent"))
                .onAppear {
                    menuStore.startListening()
                }
        }
    }
}
