import SwiftUI

struct StatsView: View {
    @Bindable var model: StatsViewModel
    @State private var isConfirmingReset = false

    var body: some View {
        VStack(alignment: .leading, spacing: StatsLayout.sectionSpacing) {
            header
            if model.hasData {
                StatsContentView(model: model)
            } else {
                emptyState
            }
        }
        .padding(StatsLayout.windowPadding)
        .frame(minWidth: StatsLayout.minimumWidth, maxWidth: .infinity, minHeight: StatsLayout.minimumHeight, maxHeight: .infinity, alignment: .topLeading)
        .onChange(of: model.range) { model.load() }
        .confirmationDialog("Delete all posture history?", isPresented: $isConfirmingReset) {
            Button("Delete history", role: .destructive) { model.resetHistory() }
        } message: {
            Text("This removes every recorded minute and cannot be undone.")
        }
    }

    private var header: some View {
        HStack(spacing: StatsLayout.itemSpacing) {
            rangePicker
            Spacer()
            Button("Copy stats") { model.copyReport() }
                .disabled(!model.hasData)
                .help("Copies a Markdown report of this range to paste into an AI assistant")
            Button("Reset…") { isConfirmingReset = true }
                .disabled(!model.hasData)
        }
    }

    private var rangePicker: some View {
        Picker("Range", selection: $model.range) {
            ForEach(StatsRange.allCases) { range in
                Text(range.title).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No posture data yet",
            systemImage: "chart.bar",
            description: Text("Statistics appear here after a few minutes of monitoring.")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
