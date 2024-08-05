import SwiftUI

struct EditBoardView: View {
    @Binding var lightSquareColor: Color
    @Binding var darkSquareColor: Color
    @Binding var toggleSwitch: Bool
    @Binding var flipped: Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Edit Board Colors")
                .font(.headline)
                .padding()

            ColorPicker("Light Square Color", selection: $lightSquareColor)
                .padding()

            ColorPicker("Dark Square Color", selection: $darkSquareColor)
                .padding()

            if #available(iOS 17.0, *) {
                Toggle("Flip board", isOn: $toggleSwitch)
                    .onChange(of: toggleSwitch) { newValue, _ in
                        flipped.toggle()
                    }
                    .padding()
            } else {
                // Fallback on earlier versions
            }
            Spacer()

            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .padding()
    }
}
