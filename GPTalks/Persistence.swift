//
//  Persistence.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/22.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer
    
    func save() throws {
        try container.viewContext.save()
        print("[CoreData] Save succeed.")
    }

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "GPTalks")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("[CoreData] \(storeDescription.description)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
