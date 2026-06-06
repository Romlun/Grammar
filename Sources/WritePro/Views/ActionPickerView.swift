import SwiftUI

struct ActionPickerView: View {
    @Binding var selectedAction: Action

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Action.allCases) { action in
                    Button(action.label) {
                        selectedAction = action
                    }
                    .buttonStyle(.bordered)
                    .background(selectedAction == action ? Color.accentColor.opacity(0.2) : Color.clear)
                    .cornerRadius(6)
                }
            }
            .padding(.horizontal, 4)
        }
    }
}
