import Foundation

struct MarkdownTable {
    struct Column {
        enum Alignment {
            case leading
            case trailing
        }

        let header: String
        let alignment: Alignment

        init(_ header: String, alignment: Alignment = .leading) {
            self.header = header
            self.alignment = alignment
        }
    }

    private static let leadingDivider = "---"
    private static let trailingDivider = "---:"

    let columns: [Column]
    let rows: [[String]]

    var text: String {
        ([line(columns.map(\.header)), dividerLine] + rows.map(line)).joined(separator: "\n")
    }

    private var dividerLine: String {
        "|" + columns.map(divider).joined(separator: "|") + "|"
    }

    private func divider(for column: Column) -> String {
        switch column.alignment {
        case .leading: Self.leadingDivider
        case .trailing: Self.trailingDivider
        }
    }

    private func line(_ cells: [String]) -> String {
        "|" + cells.map { " \($0) " }.joined(separator: "|") + "|"
    }
}
