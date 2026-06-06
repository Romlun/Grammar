import SwiftUI

struct StylePickerView: View {
    @Binding var selectedStyle: StyleContext

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Style:")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Style", selection: $selectedStyle) {
                ForEach(StyleContext.allCases) { style in
                    Text(style.label).tag(style)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
