//
//  AnimatedImageDecoder.swift
//  Aidoku
//
//  Created by Hankun Yu on 10/27/26.
//

import Foundation
import Nuke

/// Wraps Nuke's default decoder so animated non-GIF images (APNG, animated WebP, HEICS)
/// keep their original data in the image container, like Nuke already does for GIFs.
struct AnimatedImageDecoder: ImageDecoding {
    let decoder: ImageDecoders.Default

    // formats that may contain multiple frames, besides gif
    private static let animatableTypes: [AssetType] = [.png, .webp, .heic]

    var isAsynchronous: Bool { decoder.isAsynchronous }

    func decode(_ data: Data) throws -> ImageContainer {
        var container = try decoder.decode(data)
        if
            let type = container.type,
            Self.animatableTypes.contains(type),
            AnimatedImageView.isAnimated(data: data)
        {
            container.data = data
            container.userInfo[.isAnimatedKey] = true
        }
        return container
    }

    func decodePartiallyDownloadedData(_ data: Data) -> ImageContainer? {
        decoder.decodePartiallyDownloadedData(data)
    }
}

extension ImageContainer.UserInfoKey {
    static let isAnimatedKey: Self = "aidoku/isAnimated"
}

extension ImageContainer {
    /// The original data if the container holds an animated image, nil otherwise.
    var animatedImageData: Data? {
        guard type == .gif || userInfo[.isAnimatedKey] as? Bool == true else { return nil }
        return data
    }
}
