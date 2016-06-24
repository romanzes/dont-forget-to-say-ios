//
//  CouchbaseDataStore.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 6/20/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Async

var DatabaseName = "dont_forget"

class CouchbaseDataStore: DataStoreProtocol {
    // MARK: Protocol methods
    
    func fetchBuddies(completionHandler: (buddies: [Buddy]?, error: CrudStoreError?) -> Void) {
        CBLManager.sharedInstance().backgroundTellDatabaseNamed(DatabaseName) { database in
            self.fetchBuddiesImpl(database, completionHandler)
        }
    }
    
    func fetchBuddy(id: String, completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        CBLManager.sharedInstance().backgroundTellDatabaseNamed(DatabaseName) { database in
            self.fetchBuddyImpl(database, id, completionHandler)
        }
    }
    
    func addBuddy(name: String, contactId: String?, phones: [Phone], completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        CBLManager.sharedInstance().backgroundTellDatabaseNamed(DatabaseName) { database in
            self.addBuddyImpl(database, name, contactId, phones, completionHandler)
        }
    }
    
    func deleteBuddy(id: String, completionHandler: (error: CrudStoreError?) -> Void) {
        CBLManager.sharedInstance().backgroundTellDatabaseNamed(DatabaseName) { database in
            self.deleteBuddyImpl(database, id, completionHandler)
        }
    }
    
    func fetchTopicsForBuddy(buddyId: String, completionHandler: (topics: [Topic]?, error: CrudStoreError?) -> Void) {
        CBLManager.sharedInstance().backgroundTellDatabaseNamed(DatabaseName) { database in
            self.fetchTopicsForBuddyImpl(database, buddyId, completionHandler)
        }
    }
    
    func addTopic(text: String, buddyIds: [String], completionHandler: (topic: Topic?, error: CrudStoreError?) -> Void) {
        CBLManager.sharedInstance().backgroundTellDatabaseNamed(DatabaseName) { database in
            self.addTopicImpl(database, text, buddyIds, completionHandler)
        }
    }
    
    func deleteTopic(id: String, completionHandler: (error: CrudStoreError?) -> Void) {
        CBLManager.sharedInstance().backgroundTellDatabaseNamed(DatabaseName) { database in
            self.deleteTopicImpl(database, id, completionHandler)
        }
    }
    
    func deleteTopicFromBuddy(buddyId: String, topicId: String, completionHandler: (error: CrudStoreError?) -> Void) {
        CBLManager.sharedInstance().backgroundTellDatabaseNamed(DatabaseName) { database in
            self.deleteTopicFromBuddyImpl(database, buddyId, topicId, completionHandler)
        }
    }
    
    // MARK: implementation
    
    private func fetchBuddiesImpl(database: CBLDatabase, _ completionHandler: (buddies: [Buddy]?, error: CrudStoreError?) -> Void) {
        do {
            let view = database.viewNamed("buddies")
            if view.mapBlock == nil {
                view.setMapBlock({ (doc, emit) in
                    if (doc["type"] as? String == "buddy") {
                        emit(doc["name"] as! String, doc)
                    }
                }, version: "1")
            }
            let query = view.createQuery()
            let result: CBLQueryEnumerator = try query.run()
            let buddies = result.allObjects.map({ element -> Buddy in
                let row = element as! CBLQueryRow
                let couchbaseBuddy = CouchbaseBuddy(forDocument: row.document!)
                return convertBuddy(couchbaseBuddy)
            })
            completionHandler(buddies: buddies, error: nil)
        } catch {
            completionHandler(buddies: nil, error: CrudStoreError.CannotFetch("Cannot fetch buddies"))
        }
    }
    
    private func fetchBuddyImpl(database: CBLDatabase, _ id: String, _ completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        if let doc = database.existingDocumentWithID(id) {
            let buddy = CouchbaseBuddy(forDocument: doc)
            completionHandler(buddy: convertBuddy(buddy), error: nil)
        } else {
            completionHandler(buddy: nil, error: CrudStoreError.CannotFetch("Cannot fetch buddy with id \(id)"))
        }
    }
    
    private func addBuddyImpl(database: CBLDatabase, _ name: String, _ contactId: String?, _ phones: [Phone],
                              _ completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        let buddy = CouchbaseBuddy(forNewDocumentInDatabase: database)
        buddy.name = name
        buddy.contactId = contactId
        buddy.phones = phones.map({ phone -> CouchbasePhone in
            CouchbasePhone(title: phone.title, number: phone.number)
        })
        do {
            try buddy.save()
            let result = Buddy(id: buddy.document!.documentID, contactId: contactId, name: name, phones: phones)
            completionHandler(buddy: result, error: nil)
        } catch {
            completionHandler(buddy: nil, error: CrudStoreError.CannotCreate("Cannot add buddy"))
        }
    }
    
    private func deleteBuddyImpl(database: CBLDatabase, _ id: String, _ completionHandler: (error: CrudStoreError?) -> Void) {
        if let doc = database.existingDocumentWithID(id) {
            do {
                let buddy = CouchbaseBuddy(forDocument: doc)
                try buddy.topics.forEach({ topic in
                    if let index = topic.buddies.indexOf(buddy) {
                        topic.buddies.removeAtIndex(index)
                        if topic.buddies.count == 0 {
                            try topic.deleteDocument()
                        } else {
                            try topic.save()
                        }
                    }
                })
                try doc.deleteDocument()
                completionHandler(error: nil)
                return
            } catch {}
        }
        completionHandler(error: CrudStoreError.CannotFetch("Cannot delete buddy with id \(id)"))
    }
    
    private func fetchTopicsForBuddyImpl(database: CBLDatabase, _ buddyId: String, _ completionHandler: (topics: [Topic]?, error: CrudStoreError?) -> Void) {
        if let doc = database.existingDocumentWithID(buddyId) {
            let buddy = CouchbaseBuddy(forDocument: doc)
            let topics = buddy.topics.map({ topic -> Topic in
                convertTopic(topic)
            })
            completionHandler(topics: topics, error: nil)
        } else {
            completionHandler(topics: nil, error: CrudStoreError.CannotFetch("Cannot fetch topics for buddy id \(buddyId)"))
        }
    }
    
    private func addTopicImpl(database: CBLDatabase, _ text: String, _ buddyIds: [String], _ completionHandler: (topic: Topic?, error: CrudStoreError?) -> Void) {
        let topic = CouchbaseTopic(forNewDocumentInDatabase: database)
        topic.text = text
        topic.buddies = buddyIds.map { id -> CouchbaseBuddy in
            CouchbaseBuddy(forDocument: database.existingDocumentWithID(id)!)
        }
        do {
            try topic.save()
            try topic.buddies.forEach({ buddy in
                var topics: [CouchbaseTopic] = buddy.topics
                topics.append(topic)
                buddy.topics = topics
                try buddy.save()
            })
            let result = Topic(id: topic.document!.documentID, text: text, buddyCount: buddyIds.count)
            completionHandler(topic: result, error: nil)
        } catch {
            completionHandler(topic: nil, error: CrudStoreError.CannotCreate("Cannot add topic"))
        }
    }
    
    private func deleteTopicImpl(database: CBLDatabase, _ id: String, _ completionHandler: (error: CrudStoreError?) -> Void) {
        if let doc = database.existingDocumentWithID(id) {
            do {
                let topic = CouchbaseTopic(forDocument: doc)
                try topic.buddies.forEach({ buddy in
                    if let index = buddy.topics.indexOf(topic) {
                        buddy.topics.removeAtIndex(index)
                        try buddy.save()
                    }
                })
                try doc.deleteDocument()
                completionHandler(error: nil)
                return
            } catch {}
        }
        completionHandler(error: CrudStoreError.CannotFetch("Cannot delete topic with id \(id)"))
    }
    
    private func deleteTopicFromBuddyImpl(database: CBLDatabase, _ buddyId: String, _ topicId: String, _ completionHandler: (error: CrudStoreError?) -> Void) {
        if let doc = database.existingDocumentWithID(buddyId) {
            do {
                let buddy = CouchbaseBuddy(forDocument: doc)
                try buddy.topics.forEach({ topic in
                    if let topicIndex = buddy.topics.indexOf(topic) {
                        if let buddyIndex = topic.buddies.indexOf(buddy) {
                            topic.buddies.removeAtIndex(buddyIndex)
                            if topic.buddies.count == 0 {
                                try topic.deleteDocument()
                            } else {
                                try topic.save()
                            }
                        }
                        buddy.topics.removeAtIndex(topicIndex)
                        try buddy.save()
                    }
                })
                completionHandler(error: nil)
                return
            } catch {}
        }
        completionHandler(error: CrudStoreError.CannotFetch("Cannot delete topic with id \(topicId) from buddy with id \(buddyId)"))
    }
    
    // MARK: Helper functions
    
    private func convertBuddy(document: CouchbaseBuddy) -> Buddy {
        let phones = document.phones.map { phone -> Phone in
            convertPhone(phone)
        }
        return Buddy(id: document.document!.documentID, contactId: document.contactId, name: document.name, phones: phones)
    }
    
    private func convertTopic(document: CouchbaseTopic) -> Topic {
        return Topic(id: document.document!.documentID, text: document.text, buddyCount: document.buddies.count)
    }
    
    private func convertPhone(document: CouchbasePhone) -> Phone {
        return Phone(title: document.title, number: document.number)
    }
}