//
//  AnimatedImageView.swift
//  Aidoku
//
//  Created by Hankun Yu on 10/27/26.
//

import ImageIO
import UIKit

/// An image view that plays animated image data (GIF, APNG, animated WebP, HEICS) using ImageIO.
///
/// Playback pauses while the view is off-window and resumes when it's added back.
class AnimatedImageView: UIImageView {
    private var animatedData: Data?
    private var frameScale: CGFloat = 1
    private var isPlaying = false
    // incremented to invalidate any running ImageIO animation callback
    private var animationGeneration = 0

    /// Starts playing the given animated image data, replacing any current animation.
    func animate(withData data: Data) {
        // avoid restarting playback when the same data is set again (e.g. SwiftUI view updates)
        if data == animatedData { return }
        stopAnimatingImage()
        animatedData = data
        frameScale = image?.scale ?? 1
        if window != nil {
            startPlayback()
        }
    }

    /// Stops the current animation, leaving the last displayed frame in place.
    func stopAnimatingImage() {
        animatedData = nil
        pausePlayback()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            pausePlayback()
        } else {
            startPlayback()
        }
    }

    private func startPlayback() {
        guard let animatedData, !isPlaying else { return }

        animationGeneration += 1
        let generation = animationGeneration
        let scale = frameScale

        // the block is invoked on the main queue for each frame
        let status = CGAnimateImageDataWithBlock(animatedData as CFData, nil) { [weak self] _, cgImage, stop in
            let shouldStop = MainActor.assumeIsolated { () -> Bool in
                guard let self, self.animationGeneration == generation else { return true }
                self.image = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
                return false
            }
            if shouldStop {
                stop.pointee = true
            }
        }
        isPlaying = status == noErr
    }

    private func pausePlayback() {
        animationGeneration += 1
        isPlaying = false
    }
}

extension AnimatedImageView {
    /// Returns true if the image data contains more than one frame.
    nonisolated static func isAnimated(data: Data) -> Bool {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return false }
        return CGImageSourceGetCount(source) > 1
    }
}
