//
//  ImageWrapper.swift
//  iPadOS Step by Step
//
//  Created by BumMo Koo on 2019/08/03.
//  Copyright © 2019 BumMo Koo. All rights reserved.
//

import UIKit

class ImageWrapper: Codable {
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case thumbnailImage
        case backgroundImage
    }
    
    // MARK: - Property
    var thumbnailImage: UIImage?
    var backgroundImage: UIImage?
    
    // MARK: - Initializer
    init() {
        
    }
    
    // MARK: - Codable
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let data = try? container.decode(Data.self, forKey: .thumbnailImage) {
            thumbnailImage = UIImage(data: data)
        }
        if let data = try? container.decode(Data.self, forKey: .backgroundImage) {
            backgroundImage = UIImage(data: data)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let data = thumbnailImage?.pngData() ?? thumbnailImage?.jpegData(compressionQuality: 1) {
            try container.encode(data, forKey: .thumbnailImage)
        }
        if let data = backgroundImage?.pngData() ?? backgroundImage?.jpegData(compressionQuality: 1) {
            try container.encode(data, forKey: .backgroundImage)
        }
    }
}
