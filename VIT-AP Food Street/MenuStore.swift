//
//  MenuStore.swift
//  VIT-AP Mess Menu
//
//  Live view of the `messMenu` Firestore collection. Anyone can read it;
//  only the admin (see AppConfig.adminEmail / firestore.rules) can write.
//  Starts pre-loaded with RealMenuSeed so the app is correct even before
//  Firestore has anything in it.
//

import Foundation
import Combine
import FirebaseFirestore
import WidgetKit

@MainActor
final class MenuStore: ObservableObject {
    @Published private(set) var entries: [String: DayMenu] = RealMenuSeed.bundledEntries() {
        didSet {
            // Keep the widget's snapshot current — it can't reach Firestore
            // itself, so this is the only way it ever sees a menu update.
            WidgetSharedStore.saveEntries(entries)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    /// True once Firestore has actually returned data — as opposed to just
    /// showing the bundled seed.
    @Published private(set) var isLive = false
    /// Which hostel blocks have at least one document that actually came
    /// from Firestore, as opposed to only ever showing RealMenuSeed's
    /// placeholder — lets the UI tell students "this hostel's operator
    /// hasn't uploaded a menu yet" instead of quietly showing sample data
    /// as if it were real.
    @Published private(set) var liveBlocks: Set<HostelBlock> = []
    @Published var saveError: String?
    /// Firestore reports a rules rejection asynchronously, *after* a write
    /// already looked like it succeeded (it's applied to the local cache
    /// optimistically, then rolled back once the server rejects it) — so a
    /// failure here is what actually explains an edit that "reverts" a
    /// moment after Save, with no error from `save()` itself.
    @Published var listenerError: String?

    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()

    func startListening() {
        guard listener == nil else { return }
        listener = db.collection("messMenu").addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            if let error {
                self.listenerError = error.localizedDescription
                return
            }
            self.listenerError = nil
            guard let snapshot else { return }
            // Merge changed documents into `entries` rather than replacing
            // the whole dictionary — a wholesale replace meant that as soon
            // as Firestore held *any* documents, every plan/day/week combo
            // Firestore didn't have yet would drop back to empty instead of
            // keeping the bundled placeholder content.
            for change in snapshot.documentChanges {
                if let menu = try? change.document.data(as: DayMenu.self) {
                    self.entries[menu.id] = menu
                    self.liveBlocks.insert(menu.block)
                }
            }
            if !snapshot.documents.isEmpty {
                self.isLive = true
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func menu(block: HostelBlock, plan: MessPlan, weekday: Weekday, cycleWeek: CycleWeek) -> DayMenu {
        let id = DayMenu.docId(block: block, plan: plan, weekday: weekday, cycleWeek: cycleWeek)
        return entries[id] ?? DayMenu.empty(block: block, plan: plan, weekday: weekday, cycleWeek: cycleWeek)
    }

    func isBlockLive(_ block: HostelBlock) -> Bool {
        liveBlocks.contains(block)
    }

    func save(_ menu: DayMenu) async {
        saveError = nil
        do {
            try db.collection("messMenu").document(menu.id).setData(from: menu)
            // Update locally right away instead of waiting on the snapshot
            // listener's round trip — this is what makes an admin edit show
            // up on Today/Week the instant Save succeeds.
            entries[menu.id] = menu
            isLive = true
            liveBlocks.insert(menu.block)
        } catch {
            saveError = error.localizedDescription
        }
    }

    /// Writes a freshly parsed set of day menus (from an admin-picked .xlsx)
    /// to Firestore, overwriting whatever was there for those plan/day/week
    /// combinations.
    func importParsed(_ menus: [DayMenu]) async {
        for menu in menus {
            await save(menu)
            if saveError != nil { return }
        }
    }
}
