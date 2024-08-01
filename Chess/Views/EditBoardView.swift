import SwiftUI

struct EditBoardView: View {
    @Binding var lightSquareColor: Color
    @Binding var darkSquareColor: Color
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

            Spacer()

            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .padding()
    }
}
