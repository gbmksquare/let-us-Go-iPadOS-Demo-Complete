//
//  Note.swift
//  iPadOS Step by Step
//
//  Created by BumMo Koo on 03/08/2019.
//  Copyright © 2019 BumMo Koo. All rights reserved.
//

import Foundation
import PencilKit

class Note: Codable {
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case name
        case drawing
        case imageWrapper
    }
    
    // MARK: - Property
    let name = UUID().uuidString
    var drawing = PKDrawing()
    private var imageWrapper = ImageWrapper()
    
    var backgroundImage: UIImage? {
        get { imageWrapper.backgroundImage }
        set { imageWrapper.backgroundImage = newValue }
    }
    
    var thumbnailImage: UIImage? {
        get { imageWrapper.thumbnailImage }
        set { imageWrapper.thumbnailImage = newValue }
    }
}
