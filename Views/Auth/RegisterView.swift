import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name     = ""
    @State private var email    = ""
    @State private var phone    = ""
    @State private var password = ""

    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !phone.isEmpty && password.count >= 6
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerText
                    fieldsSection
                    signUpButton
                    signInLink
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
            .background(Color(.systemBackground))
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerText: some View {
        Text("Join the food-sharing community")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.top, 8)
    }

    private var fieldsSection: some View {
        VStack(spacing: 14) {
            LabeledTextField(label: "Full Name",
                             placeholder: "Md. Shifat Hasan",
                             text: $name,
                             submitLabel: .next,
                             onSubmit: { })

            LabeledTextField(label: "Email",
                             placeholder: "you@example.com",
                             text: $email,
                             keyboard: .emailAddress,
                             submitLabel: .next,
                             onSubmit: { })
                .autocapitalization(.none)

            LabeledTextField(label: "Phone",
                             placeholder: "+880 17XXXXXXXX",
                             text: $phone,
                             keyboard: .phonePad,
                             submitLabel: .next,
                             onSubmit: { })

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

    private var signUpButton: some View {
        Button {
            Task {
                await auth.register(name: name, email: email,
                                    password: password, phone: phone)
            }
        } label: {
            Text("Create Account")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(Color.appPrimary)
        .disabled(!isFormValid)
    }

    private var signInLink: some View {
        Button { dismiss() } label: {
            Text("Already have an account? **Sign In**")
                .font(.subheadline)
                .foregroundStyle(Color.appPrimary)
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
