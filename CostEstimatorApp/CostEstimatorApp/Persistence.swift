import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for previews
        let customer = Customer(context: viewContext)
        customer.id = UUID()
        customer.name = "Sample Customer"
        customer.email = "customer@example.com"
        customer.phone = "+971 50 123 4567"
        customer.address = "Dubai, UAE"
        customer.createdDate = Date()
        
        let project = Project(context: viewContext)
        project.id = UUID()
        project.name = "Sample Project"
        project.projectDescription = "A sample construction project"
        project.startDate = Date()
        project.endDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())
        project.status = "Active"
        project.customer = customer
        project.createdDate = Date()
        
        let material = Material(context: viewContext)
        material.id = UUID()
        material.itemCode = "MAT001"
        material.itemName = "Cement"
        material.storingUOM = "Bag"
        material.purchasingAmount = 25.0
        material.consumingUOM = "Kg"
        material.conversionUnit = 50.0
        material.createdDate = Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CostEstimatorApp")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController {
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}