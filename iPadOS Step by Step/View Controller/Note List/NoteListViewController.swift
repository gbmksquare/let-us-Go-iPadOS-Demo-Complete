//
//  NoteListViewController.swift
//  iPadOS Step by Step
//
//  Created by BumMo Koo on 03/08/2019.
//  Copyright © 2019 BumMo Koo. All rights reserved.
//

import UIKit

class NoteListViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let store = NoteStore.shared
    
    // MARK: - Key commands
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "n", modifierFlags: .command, action: #selector(addNewNote), discoverabilityTitle: "New Note")
        ]
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    private func setup() {
        collectionView.register(UINib(nibName: "NoteCell", bundle: nil), forCellWithReuseIdentifier: NoteCell.reuseIdentifier)
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        listenForNoteUpdate()
    }
    
    private func listenForNoteUpdate() {
        NotificationCenter.default.addObserver(self, selector: #selector(handle(notesUpdated:)), name: NoteStore.didUpdate, object: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == "detailSegue" {
            guard let destination = segue.destination as? NoteDetailViewController else { return }
            guard let indexPath = sender as? IndexPath else { return }
            destination.note = store.notes[indexPath.row]
        }
    }
    
    // MARK: - Action
    @IBAction
    private func tapped(add button: UIBarButtonItem) {
        addNewNote()
    }
    
    @IBAction
    private func tapped(deleteAll button: UIBarButtonItem) {
        deleteAll()
    }
    
    @objc
    private func handle(notesUpdated notification: Notification) {
        collectionView.reloadData()
    }
    
    // MARK: -
    @objc
    private func addNewNote() {
        store.addNewNote()
    }
    
    private func deleteAll() {
        store.deleteAll()
    }
    
    private func presentSharesheet(item: Any?, from indexPath: IndexPath) {
        guard let image = item as? UIImage else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) else  { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        share.popoverPresentationController?.sourceView = collectionView
        share.popoverPresentationController?.sourceRect = cell.convert(cell.frame, to: collectionView)
        present(share, animated: true)
    }
}

// MARK: - Contextual menu
extension NoteListViewController {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (element) -> UIMenu? in
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, attributes: .destructive) { (_) in
                self.store.delete(at: indexPath.row)
            }
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), identifier: nil) { (_) in
                let image = self.store.notes[indexPath.row].thumbnailImage
                self.presentSharesheet(item: image, from: indexPath)
            }
            let menu = UIMenu(title: "Menu", image: nil, identifier: nil, options: .displayInline, children: [share, delete])
            return menu
        }
    }
}

// MARK: - Collection view
extension NoteListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    // Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSegue", sender: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        typealias p = Preference
        let width = (collectionView.bounds.width - (p.columnCount - 1) * p.minimumInterSpacing - p.edgeInsets.left - p.edgeInsets.right) / p.columnCount
        let height = width * p.previewAspectRatio
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Preference.edgeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Preference.minimumInterSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Preference.minimumLineSpacing
    }
    
    // Data source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return store.notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCell.reuseIdentifier, for: indexPath) as! NoteCell
        let note = store.notes[indexPath.row]
        cell.populate(with: note)
        return cell
    }
}
