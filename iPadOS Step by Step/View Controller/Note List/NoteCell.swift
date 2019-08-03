//
//  NoteCell.swift
//  iPadOS Step by Step
//
//  Created by BumMo Koo on 03/08/2019.
//  Copyright © 2019 BumMo Koo. All rights reserved.
//

import UIKit

class NoteCell: UICollectionViewCell {
    static let reuseIdentifier = "NoteCell"
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    
    // MARK: - Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        
    }
    
    // MARK: - Populate
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func populate(with note: Note) {
        imageView.image = note.thumbnailImage
    }
}
