//
//  AdminAuthManager.swift
//  VIT-AP Mess Menu
//
//  Thin wrapper around Firebase email/password auth, used to gate the
//  menu-editing screen and figure out which hostel block(s), if any, the
//  signed-in account may edit.
//
//  Two roles:
//  - Super admin: AppConfig.adminEmail, full access to every block.
//  - Block operator: any other Firebase account with a matching doc in the
//    `operators` collection (create the Firebase Auth user in the console,
//    then add a doc at operators/{their uid} with field block: "mh3" etc.)
//
//  This class only shapes the UI (which blocks show up as editable). The
//  real enforcement is server-side in firestore.rules, which checks the
//  exact same two conditions — a client can't write outside its assigned
//  block no matter what this class thinks.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AdminAuthManager: ObservableObject {
    @Published private(set) var isSignedIn = false
    @Published private(set) var isSuperAdmin = false
    @Published private(set) var allowedBlocks: [HostelBlock] = []
    @Published var errorMessage: String?
    @Published var isSigningIn = false

    /// True only once role resolution has confirmed this account can
    /// actually edit something — used to gate dismissing the sign-in
    /// screen, since `isSignedIn` alone can flip true then immediately
    /// false again for an account with no assigned role.
    var hasAccess: Bool { isSuperAdmin || !allowedBlocks.isEmpty }

    private var handle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            self.isSignedIn = user != nil
            if let user {
                Task { await self.resolveRole(uid: user.uid, email: user.email) }
            } else {
                self.isSuperAdmin = false
                self.allowedBlocks = []
            }
        }
    }

    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    /// Any registered Firebase account can attempt sign-in now that there
    /// isn't just one admin — the real gate is whether `resolveRole` finds
    /// them a role afterward, which firestore.rules checks again
    /// independently. A genuine sign-in failure shows Firebase's real
    /// error (useful for an operator debugging their own password); a
    /// successful sign-in with no assigned role signs them back out with a
    /// clear explanation instead of leaving them "in" but unable to do
    /// anything.
    func signIn(email: String, password: String) async {
        errorMessage = nil
        isSigningIn = true
        defer { isSigningIn = false }

        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        do {
            let result = try await Auth.auth().signIn(withEmail: normalized, password: password)
            await resolveRole(uid: result.user.uid, email: result.user.email)
            if !isSuperAdmin && allowedBlocks.isEmpty {
                try? Auth.auth().signOut()
                errorMessage = "This account isn't set up as an admin or block operator yet."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
    }

    /// Mirrors firestore.rules: super admin by email, otherwise looks up
    /// `operators/{uid}` for an assigned block.
    private func resolveRole(uid: String, email: String?) async {
        if let email, email.lowercased() == AppConfig.adminEmail.lowercased() {
            isSuperAdmin = true
            allowedBlocks = HostelBlock.all
            return
        }
        isSuperAdmin = false
        do {
            let doc = try await db.collection("operators").document(uid).getDocument()
            if let blockRaw = doc.data()?["block"] as? String, let block = HostelBlock(rawValue: blockRaw) {
                allowedBlocks = [block]
            } else {
                allowedBlocks = []
            }
        } catch {
            allowedBlocks = []
        }
    }
}
