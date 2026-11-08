//
//  AIMenuExtractor.swift
//  VIT-AP Mess Menu
//
//  Last-resort reading of a row-block the deterministic parser in
//  MessMenuXLSXParser couldn't confidently turn into a weekday + meal
//  items — e.g. next month's sheet spells the weekday differently, or
//  lists the dates in an unfamiliar way. Uses Apple Intelligence's
//  on-device model (FoundationModels), so the file's contents never leave
//  the phone and there's no server round trip.
//
//  Only available on iOS 26+ and only on Apple Intelligence-eligible
//  hardware with the feature turned on — every caller must check
//  `AIMenuExtractor.isAvailable` under `#available(iOS 26.0, *)` and fall
//  back gracefully (show the raw block for manual entry) when it's not.
//

import Foundation
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct AIExtractedDay {
    @Guide(description: "Which weekday this block of spreadsheet rows describes", .anyOf(["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]))
    var weekday: String

    @Guide(description: "The smallest calendar date number (1-31) mentioned in the block's header for this weekday")
    var firstDateOfMonth: Int

    @Guide(description: "Breakfast food items, one per entry, exactly as written in the rows")
    var breakfast: [String]

    @Guide(description: "Lunch food items, one per entry, exactly as written in the rows")
    var lunch: [String]

    @Guide(description: "Snacks / evening tea items, one per entry, exactly as written in the rows")
    var snacks: [String]

    @Guide(description: "Dinner food items, one per entry, exactly as written in the rows")
    var dinner: [String]
}

@available(iOS 26.0, *)
enum AIMenuExtractor {
    static var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    /// Why Apple Intelligence isn't usable right now, in plain language —
    /// nil when it's ready to go.
    static var unavailableReason: String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable(.deviceNotEligible):
            return "This device doesn't support Apple Intelligence."
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Turn on Apple Intelligence in Settings to use this."
        case .unavailable(.modelNotReady):
            return "Apple Intelligence is still downloading its model — try again shortly."
        case .unavailable:
            return "Apple Intelligence isn't available right now."
        }
    }

    /// Attempts to read one unresolved block on-device. Throws if the
    /// model can't produce a usable result — callers should treat that the
    /// same as "still unresolved" and let the admin enter it manually.
    static func resolve(_ block: UnresolvedMenuBlock) async throws -> DayMenu {
        let session = LanguageModelSession(instructions: """
        You are reading one block of rows from a hostel mess-menu spreadsheet. \
        The block covers a single weekday and lists food items under \
        breakfast, lunch, snacks and dinner. Its header names the weekday and \
        the calendar dates in the month this exact spread applies to (for \
        example a header of "Tue" with dates "1, 15, 29" means Tuesday, and \
        the smallest date is 1). Extract the food items exactly as written \
        and in the order given — never invent, correct spelling, merge, or \
        drop items.
        """)

        let prompt = """
        Header: \(block.headerText)

        Rows:
        \(block.rawText)
        """

        let response = try await session.respond(to: prompt, generating: AIExtractedDay.self)
        let extracted = response.content

        guard let weekday = Weekday(rawValue: extracted.weekday) else {
            throw MessMenuParseError.noEntriesFound
        }
        let occurrence = (extracted.firstDateOfMonth - 1) / 7 + 1
        let cycleWeek: CycleWeek = occurrence % 2 == 1 ? .a : .b

        var menu = DayMenu.empty(block: block.block, plan: block.plan, weekday: weekday, cycleWeek: cycleWeek)
        menu.breakfast = extracted.breakfast
        menu.lunch = extracted.lunch
        menu.snacks = extracted.snacks
        menu.dinner = extracted.dinner
        return menu
    }
}
