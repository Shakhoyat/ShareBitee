import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Binding var showRegister: Bool

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                heroSection
                fieldsSection
                signInButton
                signUpLink
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.appPrimary)
                .padding(.top, 56)

            Text("ShareBite BD")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Color(.label))

            Text("Share a plate. Save the world,\none bite at a time.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var fieldsSection: some View {
        VStack(spacing: 16) {
            LabeledTextField(label: "Email",
                             placeholder: "you@example.com",
                             text: $email,
                             keyboard: .emailAddress,
                             submitLabel: .next,
                             onSubmit: { })
                .autocapitalization(.none)

            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                SecureField("Min. 6 characters", text: $password)
                    .submitLabel(.done)
                    .onSubmit { }
                    .padding(14)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var signInButton: some View {
        Button {
            Task { await auth.login(email: email, password: password) }
        } label: {
            Text("Sign In")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(Color.appPrimary)
    }

    private var signUpLink: some View {
        Button { showRegister = true } label: {
            Text("Don't have an account? **Sign Up**")
                .font(.subheadline)
                .foregroundStyle(Color.appPrimary)
        }
    }
}
