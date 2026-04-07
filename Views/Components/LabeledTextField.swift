import SwiftUI

/// A labelled, consistently-styled text field used throughout auth forms.
struct LabeledTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var submitLabel: SubmitLabel = .done
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .submitLabel(submitLabel)
                .onSubmit { onSubmit?() }
                .padding(14)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
