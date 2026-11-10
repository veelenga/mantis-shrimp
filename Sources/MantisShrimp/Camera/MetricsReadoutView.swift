import AppKit

final class MetricsReadoutView: NSView {
    private static let rowsPerColumn = 3
    private static let columnSpacing: CGFloat = 32
    private static let rowSpacing: CGFloat = 4
    private static let cellSpacing: CGFloat = 12

    private struct RowCells {
        let name: NSTextField
        let value: NSTextField
        let limit: NSTextField
    }

    private let gridsRow = NSStackView()
    private let issuesLabel = NSTextField(labelWithString: "")
    private var cells: [RowCells] = []
    private let valueFont = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .medium)
    private let labelFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)

    override init(frame: NSRect) {
        super.init(frame: frame)
        buildLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    func render(rows: [MetricRow], issuesLine: String) {
        issuesLabel.stringValue = issuesLine
        if cells.count != rows.count {
            rebuildGrids(rowCount: rows.count)
        }
        for (row, cell) in zip(rows, cells) {
            cell.name.stringValue = row.name
            cell.value.stringValue = row.value
            cell.value.textColor = row.isOverLimit ? PostureTint.issue.color : .labelColor
            cell.limit.stringValue = "limit \(row.limit)"
        }
    }

    private func buildLayout() {
        gridsRow.orientation = .horizontal
        gridsRow.alignment = .top
        gridsRow.spacing = Self.columnSpacing
        issuesLabel.font = .systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)

        let column = NSStackView(views: [gridsRow, issuesLabel])
        column.orientation = .vertical
        column.alignment = .leading
        column.spacing = Self.cellSpacing
        column.translatesAutoresizingMaskIntoConstraints = false
        addSubview(column)
        NSLayoutConstraint.activate([
            column.leadingAnchor.constraint(equalTo: leadingAnchor),
            column.topAnchor.constraint(equalTo: topAnchor),
            column.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
        ])
    }

    private func rebuildGrids(rowCount: Int) {
        gridsRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cells = (0..<rowCount).map { _ in makeCells() }
        for chunkStart in stride(from: 0, to: rowCount, by: Self.rowsPerColumn) {
            let chunk = cells[chunkStart..<min(chunkStart + Self.rowsPerColumn, rowCount)]
            gridsRow.addArrangedSubview(makeGrid(Array(chunk)))
        }
    }

    private func makeGrid(_ rows: [RowCells]) -> NSGridView {
        let grid = NSGridView(views: rows.map { [$0.name, $0.value, $0.limit] })
        grid.rowSpacing = Self.rowSpacing
        grid.columnSpacing = Self.cellSpacing
        grid.column(at: 1).xPlacement = .trailing
        grid.setContentHuggingPriority(.required, for: .horizontal)
        return grid
    }

    private func makeCells() -> RowCells {
        let name = NSTextField(labelWithString: "")
        name.font = labelFont
        name.textColor = .secondaryLabelColor
        let value = NSTextField(labelWithString: "")
        value.font = valueFont
        value.alignment = .right
        let limit = NSTextField(labelWithString: "")
        limit.font = labelFont
        limit.textColor = .tertiaryLabelColor
        return RowCells(name: name, value: value, limit: limit)
    }
}
