//
//  MessMenuXLSXParser.swift
//  VIT-AP Mess Menu
//
//  Reads an .xlsx mess-menu sheet straight off disk with no third-party
//  dependency: a minimal ZIP reader (Apple's Compression framework already
//  implements raw DEFLATE, which is exactly what ZIP entries use) plus
//  Foundation's XMLParser for the worksheet/sharedStrings XML.
//
//  Mirrors the structure of VIT-AP's published mess-menu workbook: a title
//  row naming the plan ("...SPECIAL MESS MENU..." vs the regular one), a
//  header row naming each column ("Day, Breakfast, Lunch, Snacks, Dinner"),
//  then one row-block per weekday whose first cell holds the weekday and
//  the calendar dates it covers (e.g. "Tue\n1, 15, 29").
//
//  Deliberately tolerant of small format drift from month to month: the
//  breakfast/lunch/snacks/dinner column order is read from the header row
//  rather than hardcoded, and the weekday can be a full name or an
//  abbreviation in any case. A block that still can't be understood isn't
//  silently dropped — it's returned as `unresolved` so the caller can hand
//  it to AIMenuExtractor (Apple Intelligence) or show it to the admin.
//

import Foundation
import Compression

enum MessMenuParseError: LocalizedError {
    case accessDenied
    case corruptArchive
    case missingSheet
    case noEntriesFound

    var errorDescription: String? {
        switch self {
        case .accessDenied: return "Couldn't access that file."
        case .corruptArchive: return "That doesn't look like a valid .xlsx file."
        case .missingSheet: return "No worksheet found inside the file."
        case .noEntriesFound: return "Couldn't find any recognizable day rows (Mon/Tue/.../Sun) in the sheet."
        }
    }
}

/// A row-block the deterministic parser found (something starts a new
/// section) but couldn't confidently turn into a weekday + meal items —
/// e.g. a date format or weekday spelling it doesn't recognize. Carried
/// forward so it can be shown to the admin or handed to Apple Intelligence
/// instead of silently vanishing.
struct UnresolvedMenuBlock: Identifiable {
    let id = UUID()
    let block: HostelBlock
    let plan: MessPlan
    let headerText: String
    let rawText: String
}

// MARK: - Minimal ZIP reader

private struct ZipEntry {
    let compressionMethod: UInt16
    let compressedSize: Int
    let uncompressedSize: Int
    let localHeaderOffset: Int
}

private final class ZipArchiveReader {
    private let bytes: [UInt8]
    private var entries: [String: ZipEntry] = [:]

    init(data: Data) throws {
        bytes = [UInt8](data)
        try parseCentralDirectory()
    }

    private func u16(_ offset: Int) -> Int {
        Int(bytes[offset]) | (Int(bytes[offset + 1]) << 8)
    }

    private func u32(_ offset: Int) -> Int {
        Int(bytes[offset]) | (Int(bytes[offset + 1]) << 8) | (Int(bytes[offset + 2]) << 16) | (Int(bytes[offset + 3]) << 24)
    }

    private func parseCentralDirectory() throws {
        guard let eocd = findEOCD() else { throw MessMenuParseError.corruptArchive }
        let entryCount = u16(eocd + 10)
        var offset = u32(eocd + 16)

        for _ in 0..<entryCount {
            guard offset + 46 <= bytes.count, u32(offset) == 0x02014b50 else { throw MessMenuParseError.corruptArchive }
            let method = UInt16(u16(offset + 10))
            let compSize = u32(offset + 20)
            let uncompSize = u32(offset + 24)
            let nameLen = u16(offset + 28)
            let extraLen = u16(offset + 30)
            let commentLen = u16(offset + 32)
            let localOffset = u32(offset + 42)
            let nameStart = offset + 46
            guard nameStart + nameLen <= bytes.count else { throw MessMenuParseError.corruptArchive }
            let name = String(decoding: bytes[nameStart..<(nameStart + nameLen)], as: UTF8.self)
            entries[name] = ZipEntry(compressionMethod: method, compressedSize: compSize, uncompressedSize: uncompSize, localHeaderOffset: localOffset)
            offset = nameStart + nameLen + extraLen + commentLen
        }
    }

    private func findEOCD() -> Int? {
        let searchWindow = min(bytes.count, 66_000)
        var i = bytes.count - 22
        let stop = bytes.count - searchWindow
        while i >= stop && i >= 0 {
            if bytes[i] == 0x50, bytes[i + 1] == 0x4b, bytes[i + 2] == 0x05, bytes[i + 3] == 0x06 {
                return i
            }
            i -= 1
        }
        return nil
    }

    func hasEntry(_ name: String) -> Bool { entries[name] != nil }
    func entryNames() -> [String] { Array(entries.keys) }

    func extract(_ name: String) throws -> Data {
        guard let entry = entries[name] else { throw MessMenuParseError.missingSheet }
        let lh = entry.localHeaderOffset
        guard lh + 30 <= bytes.count, u32(lh) == 0x04034b50 else { throw MessMenuParseError.corruptArchive }
        let nameLen = u16(lh + 26)
        let extraLen = u16(lh + 28)
        let dataStart = lh + 30 + nameLen + extraLen
        guard dataStart + entry.compressedSize <= bytes.count else { throw MessMenuParseError.corruptArchive }
        let compData = Data(bytes[dataStart..<(dataStart + entry.compressedSize)])

        switch entry.compressionMethod {
        case 0:
            return compData
        case 8:
            return try Self.inflate(compData, uncompressedSize: entry.uncompressedSize)
        default:
            throw MessMenuParseError.corruptArchive
        }
    }

    private static func inflate(_ input: Data, uncompressedSize: Int) throws -> Data {
        guard uncompressedSize > 0 else { return Data() }
        var output = [UInt8](repeating: 0, count: uncompressedSize)
        let decodedCount = output.withUnsafeMutableBytes { dst -> Int in
            input.withUnsafeBytes { src -> Int in
                compression_decode_buffer(
                    dst.bindMemory(to: UInt8.self).baseAddress!, uncompressedSize,
                    src.bindMemory(to: UInt8.self).baseAddress!, input.count,
                    nil, COMPRESSION_ZLIB
                )
            }
        }
        guard decodedCount == uncompressedSize else { throw MessMenuParseError.corruptArchive }
        return Data(output)
    }
}

// MARK: - sharedStrings.xml

private final class SharedStringsParser: NSObject, XMLParserDelegate {
    private(set) var strings: [String] = []
    private var current = ""
    private var inSI = false
    private var inT = false

    func parse(_ data: Data) -> [String] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return strings
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes attributeDict: [String: String] = [:]) {
        switch elementName {
        case "si": inSI = true; current = ""
        case "t": inT = true
        default: break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if inT { current += string }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
        switch elementName {
        case "t": inT = false
        case "si": strings.append(current); inSI = false
        default: break
        }
    }
}

// MARK: - workbook.xml / _rels -> sheetN.xml -> display name

/// Reads the human-visible tab names ("Spl Mess", "Veg & Non Veg") out of
/// xl/workbook.xml, keyed by relationship id — some workbooks reuse the
/// exact same title text inside every sheet, so the tab name is the only
/// reliable signal for which sheet is actually the special-mess one.
private final class WorkbookSheetsParser: NSObject, XMLParserDelegate {
    private(set) var sheets: [(name: String, rId: String)] = []

    func parse(_ data: Data) -> [(name: String, rId: String)] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return sheets
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes attributeDict: [String: String] = [:]) {
        guard elementName == "sheet" else { return }
        let name = attributeDict["name"] ?? ""
        let rId = attributeDict["r:id"] ?? attributeDict["id"] ?? ""
        guard !rId.isEmpty else { return }
        sheets.append((name: name, rId: rId))
    }
}

/// Reads xl/_rels/workbook.xml.rels, which maps each relationship id above
/// to the actual "worksheets/sheetN.xml" file it points at.
private final class RelationshipsParser: NSObject, XMLParserDelegate {
    private(set) var targets: [String: String] = [:]

    func parse(_ data: Data) -> [String: String] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return targets
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes attributeDict: [String: String] = [:]) {
        guard elementName == "Relationship", let id = attributeDict["Id"], let target = attributeDict["Target"] else { return }
        targets[id] = target
    }
}

// MARK: - sheetN.xml -> row/col grid

private final class SheetGridParser: NSObject, XMLParserDelegate {
    private let sharedStrings: [String]
    private(set) var rows: [Int: [Int: String]] = [:]

    private var currentRow = 0
    private var currentCol = 0
    private var currentType = ""
    private var currentValue = ""
    private var currentInline = ""
    private var inV = false
    private var inInlineT = false

    init(sharedStrings: [String]) { self.sharedStrings = sharedStrings }

    func parse(_ data: Data) {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes attributeDict: [String: String] = [:]) {
        switch elementName {
        case "row":
            currentRow = Int(attributeDict["r"] ?? "") ?? currentRow
        case "c":
            currentCol = Self.columnNumber(from: attributeDict["r"] ?? "")
            currentType = attributeDict["t"] ?? ""
            currentValue = ""
            currentInline = ""
        case "v":
            inV = true
        case "t":
            inInlineT = true
        default: break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if inV { currentValue += string }
        if inInlineT { currentInline += string }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
        switch elementName {
        case "v": inV = false
        case "t": inInlineT = false
        case "c":
            guard currentCol > 0 else { return }
            var resolved: String
            if currentType == "inlineStr" {
                resolved = currentInline
            } else if currentType == "s" {
                if let idx = Int(currentValue), idx >= 0, idx < sharedStrings.count {
                    resolved = sharedStrings[idx]
                } else {
                    resolved = ""
                }
            } else {
                resolved = currentValue
            }
            resolved = resolved.trimmingCharacters(in: .whitespaces)
            if !resolved.isEmpty {
                rows[currentRow, default: [:]][currentCol] = resolved
            }
        default: break
        }
    }

    static func columnNumber(from cellRef: String) -> Int {
        var num = 0
        for ch in cellRef {
            guard let ascii = ch.asciiValue, ch.isLetter else { break }
            num = num * 26 + Int(ascii - Character("A").asciiValue! + 1)
        }
        return num
    }
}

// MARK: - Public parser

/// Result of parsing one workbook: everything the deterministic parser
/// could confidently turn into a day menu, plus anything it found but
/// couldn't interpret.
struct ParsedWorkbook {
    var menus: [DayMenu]
    var unresolved: [UnresolvedMenuBlock]
}

enum MessMenuXLSXParser {
    /// Recognized either as a full name ("tuesday") or a >=3-letter
    /// prefix ("tue", "tues") — tolerant of whichever spelling a given
    /// month's sheet happens to use.
    private static func matchWeekday(_ text: String) -> Weekday? {
        let lower = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard lower.count >= 3 else { return nil }
        return Weekday.allCases.first { day in
            lower == day.rawValue || day.rawValue.hasPrefix(lower) || lower.hasPrefix(String(day.rawValue.prefix(3)))
        }
    }

    /// Scans free-form text for the first plausible day-of-month (1-31),
    /// so "1, 15, 29", "1st/15th/29th", or "Dates: 1 15 29" all work.
    private static func firstDateNumber(in text: String) -> Int? {
        var digits = ""
        var numbers: [Int] = []
        for ch in text {
            if ch.isNumber {
                digits.append(ch)
            } else if !digits.isEmpty {
                if let n = Int(digits), (1...31).contains(n) { numbers.append(n) }
                digits = ""
            }
        }
        if !digits.isEmpty, let n = Int(digits), (1...31).contains(n) { numbers.append(n) }
        return numbers.first
    }

    /// Reads the "Day / Breakfast / Lunch / Snacks / Dinner" header row to
    /// map column index -> meal, instead of assuming a fixed column order.
    /// Falls back to the known default layout if no header row is found.
    private static func detectColumnMealMap(rows: [Int: [Int: String]]) -> [Int: MealType] {
        for rowNumber in rows.keys.sorted() {
            guard let row = rows[rowNumber] else { continue }
            let col1 = (row[1] ?? "").lowercased()
            guard col1 == "day" || col1.hasPrefix("date") else { continue }
            var map: [Int: MealType] = [:]
            for (col, text) in row where col != 1 {
                let lower = text.lowercased()
                if lower.contains("breakfast") { map[col] = .breakfast }
                else if lower.contains("lunch") { map[col] = .lunch }
                else if lower.contains("snack") { map[col] = .snacks }
                else if lower.contains("dinner") { map[col] = .dinner }
            }
            if map.count == 4 { return map }
        }
        return [2: .breakfast, 3: .lunch, 4: .snacks, 5: .dinner]
    }

    /// Parses every worksheet in the workbook. Throws only if the file
    /// itself can't be read as a zip/xlsx, or truly nothing resembling a
    /// day block was found anywhere.
    static func parse(fileURL: URL, block: HostelBlock) throws -> ParsedWorkbook {
        let accessing = fileURL.startAccessingSecurityScopedResource()
        defer { if accessing { fileURL.stopAccessingSecurityScopedResource() } }

        let data = try Data(contentsOf: fileURL)
        let zip = try ZipArchiveReader(data: data)

        let sharedStrings: [String]
        if zip.hasEntry("xl/sharedStrings.xml") {
            sharedStrings = SharedStringsParser().parse(try zip.extract("xl/sharedStrings.xml"))
        } else {
            sharedStrings = []
        }

        let sheetPaths = zip.entryNames()
            .filter { $0.hasPrefix("xl/worksheets/sheet") && $0.hasSuffix(".xml") }
            .sorted { sheetIndex($0) < sheetIndex($1) }
        guard !sheetPaths.isEmpty else { throw MessMenuParseError.missingSheet }

        // Best-effort: map each "xl/worksheets/sheetN.xml" path to its
        // human-visible tab name, e.g. "Spl Mess". Some workbooks' title
        // cells don't actually say "SPECIAL" even on the special-mess
        // sheet, so the tab name is a second, more reliable signal.
        var sheetDisplayNames: [String: String] = [:]
        if zip.hasEntry("xl/workbook.xml"), zip.hasEntry("xl/_rels/workbook.xml.rels") {
            let sheetsList = WorkbookSheetsParser().parse(try zip.extract("xl/workbook.xml"))
            let targets = RelationshipsParser().parse(try zip.extract("xl/_rels/workbook.xml.rels"))
            for entry in sheetsList {
                guard let target = targets[entry.rId] else { continue }
                let fullPath = target.hasPrefix("/") ? String(target.dropFirst()) : "xl/\(target)"
                sheetDisplayNames[fullPath] = entry.name
            }
        }

        var result = ParsedWorkbook(menus: [], unresolved: [])
        for path in sheetPaths {
            let xml = try zip.extract(path)
            let gridParser = SheetGridParser(sharedStrings: sharedStrings)
            gridParser.parse(xml)
            let titleText = (gridParser.rows[2]?[1] ?? "").uppercased()
            let tabName = (sheetDisplayNames[path] ?? "").uppercased()
            let isSpecial = titleText.contains("SPECIAL") || tabName.contains("SPECIAL") || tabName.contains("SPL")
            let plan: MessPlan = isSpecial ? .special : .regular
            let sheetResult = dayMenus(from: gridParser.rows, block: block, plan: plan)
            result.menus.append(contentsOf: sheetResult.menus)
            result.unresolved.append(contentsOf: sheetResult.unresolved)
        }

        guard !result.menus.isEmpty || !result.unresolved.isEmpty else { throw MessMenuParseError.noEntriesFound }
        return result
    }

    private static func sheetIndex(_ path: String) -> Int {
        let digits = path.filter(\.isNumber)
        return Int(digits) ?? 0
    }

    private static func dayMenus(from rows: [Int: [Int: String]], block: HostelBlock, plan: MessPlan) -> ParsedWorkbook {
        struct Block { var header: String; var rows: [[Int: String]] }
        var blocks: [Block] = []
        var current: Block?

        for rowNumber in rows.keys.sorted() {
            let row = rows[rowNumber] ?? [:]
            let col1 = row[1] ?? ""
            let col2 = row[2] ?? ""
            if col2 == "MESS SERVICE INSTRUCTIONS" { break }
            if !col1.isEmpty {
                if let current { blocks.append(current) }
                current = Block(header: col1, rows: [row])
            } else if current != nil {
                current?.rows.append(row)
            }
        }
        if let current { blocks.append(current) }

        let columnMap = detectColumnMealMap(rows: rows)
        var menus: [DayMenu] = []
        var unresolved: [UnresolvedMenuBlock] = []

        for rowBlock in blocks {
            let firstLine = rowBlock.header.components(separatedBy: "\n").first ?? rowBlock.header
            let firstLineLower = firstLine.lowercased()
            guard firstLineLower != "day", !firstLineLower.hasPrefix("date") else { continue } // the header row itself

            guard let weekday = matchWeekday(firstLine), let firstDate = firstDateNumber(in: rowBlock.header) else {
                // Only worth surfacing if the block actually carries meal
                // content in one of the detected meal columns — otherwise
                // it's decorative (a title row, a blank spacer) rather than
                // a real day block we failed to read. Column 1 itself (the
                // header/label) doesn't count as meal content.
                let hasMealContent = rowBlock.rows.contains { row in
                    columnMap.keys.contains { col in !(row[col] ?? "").isEmpty }
                }
                if hasMealContent {
                    let raw = renderRawText(rowBlock.rows, columnMap: columnMap)
                    unresolved.append(UnresolvedMenuBlock(block: block, plan: plan, headerText: rowBlock.header, rawText: raw))
                }
                continue
            }

            let occurrence = (firstDate - 1) / 7 + 1
            let cycleWeek: CycleWeek = occurrence % 2 == 1 ? .a : .b

            var menu = DayMenu.empty(block: block, plan: plan, weekday: weekday, cycleWeek: cycleWeek)
            for row in rowBlock.rows {
                for (col, meal) in columnMap {
                    guard let value = row[col], !value.isEmpty else { continue }
                    menu.setItems(menu.items(for: meal) + [value], for: meal)
                }
            }
            menus.append(menu)
        }
        return ParsedWorkbook(menus: menus, unresolved: unresolved)
    }

    /// Flattens one block's rows into plain text, labeling each column by
    /// its detected meal — this is what gets shown to the admin, and what
    /// Apple Intelligence reads if asked to take a shot at the block.
    private static func renderRawText(_ blockRows: [[Int: String]], columnMap: [Int: MealType]) -> String {
        var lines: [String] = []
        for row in blockRows {
            for col in row.keys.sorted() {
                guard let value = row[col] else { continue }
                let label = columnMap[col]?.displayName ?? "Column \(col)"
                lines.append("\(label): \(value)")
            }
        }
        return lines.joined(separator: "\n")
    }
}
