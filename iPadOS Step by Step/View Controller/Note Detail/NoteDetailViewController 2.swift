//
//  NoteDetailViewController.swift
//  iPadOS Step by Step
//
//  Created by BumMo Koo on 03/08/2019.
//  Copyright © 2019 BumMo Koo. All rights reserved.
//

import UIKit
import PencilKit
import VisionKit
import MobileCoreServices
import SnapKit

class NoteDetailViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    private lazy var canvasView = PKCanvasView()
    
    var note: Note?
    
    private var image: UIImage? {
        didSet {
            imageView.image = image
            note?.backgroundImage = image
        }
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadCanvas()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        canvasView.becomeFirstResponder()
    }
    
    private func setup() {
        view.backgroundColor = .secondarySystemBackground
        containerView.backgroundColor = .systemBackground
        
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.delegate = self
        canvasView.isRulerActive = false
        canvasView.allowsFingerDrawing = true
        canvasView.tool = PKInkingTool(.pencil)
        
        containerView.addSubview(canvasView)
        canvasView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        if #available(macCatalyst 10.15, *) {
            let share = navigationItem.rightBarButtonItems?.first
            navigationItem.rightBarButtonItems = [share!]
        } else {
            let window = UIApplication.shared.windows.first!
            let picker = PKToolPicker.shared(for: window)
            picker?.addObserver(canvasView)
            picker?.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
        }
    }
    
    // MARK: - Action
    @IBAction
    private func tapped(clearCanvas button: UIBarButtonItem) {
        clearCanvas()
    }
    
    @IBAction
    private func tapped(document button: UIBarButtonItem) {
        presentDocumentPicker()
    }
    
    @IBAction
    private func tapped(scanner button: UIBarButtonItem) {
        presentDocumentScanner()
    }
    
    @IBAction
    private func tapped(photoLibrary button: UIBarButtonItem) {
        presentImagePicker()
    }
    
    @IBAction
    private func tapped(share button: UIBarButtonItem) {
        presentSharesheet(button)
    }
    
    // MARK: -
    private func presentDocumentPicker() {
        let picker = UIDocumentPickerViewController(documentTypes: [kUTTypeImage as String], in: .import)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func presentDocumentScanner() {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = self
        present(scanner, animated: true)
    }
    
    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.mediaTypes = [kUTTypeImage as String]
        present(picker, animated: true)
    }
    
    private func presentSharesheet(_ sourceView: UIBarButtonItem? = nil) {
        guard let outputImage = generateImage() else { return }
        let share = UIActivityViewController(activityItems: [outputImage], applicationActivities: nil)
        share.popoverPresentationController?.barButtonItem = sourceView
        present(share, animated: true)
    }
    
    // MARK: - Canvas
    private func loadCanvas() {
        guard let note = note else { return }
        canvasView.drawing = note.drawing
        imageView.image = note.backgroundImage
    }
    
    private func saveCanvas() {
        let thumbnail = generateImage(CGSize(width: 160, height: 120))
        note?.thumbnailImage = thumbnail
        
        let encoder = PropertyListEncoder()
        let data = try? encoder.encode(note)
        guard let note = note else { return }
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(note.name) else { return }
        try? data?.write(to: url)
    }
    
    private func generateImage(_ size: CGSize? = nil) -> UIImage? {
        let outputImage: UIImage?
        if image != nil {
            let size = size ?? canvasView.bounds.size
            UIGraphicsBeginImageContextWithOptions(size, true, 0)
            containerView.layer.render(in: UIGraphicsGetCurrentContext()!)
            outputImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        } else {
            outputImage = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.nativeScale)
        }
        return outputImage
    }
    
    private func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }
}

// MARK: - Canvas
extension NoteDetailViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        note?.drawing = canvasView.drawing
        saveCanvas()
    }
}

// MARK: - Drag & Drop
extension NoteDetailViewController: UIDropInteractionDelegate {
    
}

// MARK: - Documenet picker
extension NoteDetailViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        guard let image = UIImage(data: data) else { return }
        self.image = image
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
    }
}

// MARK: - Document scanner
extension NoteDetailViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        image = scan.imageOfPage(at: 0)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        dismiss(animated: true)
    }
}

// MARK: - Image picker
extension NoteDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            dismiss(animated: true)
        }
        
        if let image = info[.editedImage] as? UIImage {
            self.image = image
        } else if let image = info[.originalImage] as? UIImage {
            self.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
