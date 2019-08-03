//
//  NoteStore.swift
//  iPadOS Step by Step
//
//  Created by BumMo Koo on 2019/08/03.
//  Copyright © 2019 BumMo Koo. All rights reserved.
//

import Foundation
import os.log

class NoteStore {
    static let shared = NoteStore()
    
    static let didUpdate = Notification.Name("NoteStore.didUpdate")
    
    private let finder = FileManager.default
    
    var notes = [Note]()
    
    // MARK: - Initialization
    private init() {
        let docDir = finder.urls(for: .documentDirectory, in: .userDomainMask).first!
        guard let urls = try? finder.contentsOfDirectory(at: docDir, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            notes = []
            return
        }
        let decoder = PropertyListDecoder()
        urls.forEach { url in
            guard let data = try? Data(contentsOf: url) else { return }
            guard let note = try? decoder.decode(Note.self, from: data) else { return }
            notes.append(note)
        }
        
        os_log(.info, log: .default, "NoteStore initialized with %{PUBLIC}@ notes", "\(notes.count)")
    }
    
    // MARK: - Action
    func addNewNote() {
        let note = Note()
        notes.append(note)
        
        postDidUpdateNotification()
        
        os_log(.info, log: .default, "NoteStore added a new note, now %{PUBLIC}@ notes", "\(notes.count)")
    }
    
    func delete(at index: Int) {
        notes.remove(at: index)
        postDidUpdateNotification()
        
        os_log(.info, log: .default, "NoteStore deleted a note, now %{PUBLIC}@ notes", "\(notes.count)")
    }
    
    func deleteAll() {
        let docDir = finder.urls(for: .documentDirectory, in: .userDomainMask).first!
        let urls = try? finder.contentsOfDirectory(at: docDir, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        urls?.forEach { url in
            try? finder.removeItem(at: url)
        }
        notes.removeAll()
        
        postDidUpdateNotification()
        
        os_log(.info, log: .default, "NoteStore deleted all notes")
    }
    
    func postDidUpdateNotification() {
        NotificationCenter.default.post(name: NoteStore.didUpdate, object: self)
    }
}
