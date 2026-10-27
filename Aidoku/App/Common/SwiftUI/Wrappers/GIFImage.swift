//
//  GIFImage.swift
//  Aidoku
//
//  Created by Skitty on 6/23/25.
//

import SwiftUI

struct GIFImage: UIViewRepresentable {
    var image: UIImage?
    var data: Data
    var contentMode: ContentMode = .fill

    func makeUIView(context: Context) -> AnimatedImageView {
        let imageView = AnimatedImageView(frame: .zero)
        imageView.isUserInteractionEnabled = true
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return imageView
    }

    func updateUIView(_ uiView: AnimatedImageView, context: Context) {
        if let image {
            uiView.image = image
        }
        uiView.animate(withData: data)
        uiView.contentMode = switch contentMode {
            case .fit: .scaleAspectFit
            case .fill: .scaleAspectFill
        }
    }
}
