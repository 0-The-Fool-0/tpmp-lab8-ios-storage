import CoreData

enum Persistence {
    static let shared = Persistence()
    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }

    private init() {
        container = NSPersistentContainer(name: "Students")
        container.loadPersistentStores { _, error in
            if let error { fatalError("\(error)") }
        }
    }

    func save() {
        guard context.hasChanges else { return }
        try? context.save()
    }
}
