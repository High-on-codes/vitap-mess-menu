//
//  AdminLoginView.swift
//  VIT-AP Mess Menu
//
//  The account (super admin or block operator) must already exist in
//  Firebase (Console -> Authentication -> Add user, email/password) —
//  this screen only signs in, it doesn't create accounts. A block
//  operator additionally needs a doc at operators/{their uid} with their
//  assigned block, or sign-in succeeds but is immediately rejected for
//  having no role.
//

import SwiftUI

struct AdminLoginView: View {
    @EnvironmentObject var adminAuth: AdminAuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        Form {
            Section {
                TextField("Username", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Password", text: $password)
            }

            if let error = adminAuth.errorMessage {
                Section {
                    Text(error).foregroundColor(.red).font(.caption)
                }
            }

            Section {
                Button {
                    Task { await adminAuth.signIn(email: email, password: password) }
                } label: {
                    if adminAuth.isSigningIn {
                        ProgressView()
                    } else {
                        Text("Sign In")
                    }
                }
                .disabled(email.isEmpty || password.isEmpty || adminAuth.isSigningIn)
            }
        }
        .navigationTitle("Admin Sign In")
        .onChange(of: adminAuth.hasAccess) { _, hasAccess in
            if hasAccess { dismiss() }
        }
    }
}
