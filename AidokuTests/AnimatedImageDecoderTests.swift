//
//  AnimatedImageDecoderTests.swift
//  Aidoku
//

import Foundation
import ImageIO
import Nuke
import Testing
import UIKit
import UniformTypeIdentifiers
@testable import Aidoku

@Suite struct AnimatedImageDecoderTests {
    /// Encodes solid color frames into image data of the given type using ImageIO.
    private func makeImageData(type: UTType, frameCount: Int) throws -> Data {
        let data = NSMutableData()
        let destination = try #require(
            CGImageDestinationCreateWithData(data, type.identifier as CFString, frameCount, nil)
        )
        let colors: [UIColor] = [.red, .green, .blue]
        for index in 0..<frameCount {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
            let image = renderer.image { context in
                colors[index % colors.count].setFill()
                context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
            }
            let cgImage = try #require(image.cgImage)
            CGImageDestinationAddImage(destination, cgImage, nil)
        }
        #expect(CGImageDestinationFinalize(destination))
        return data as Data
    }

    private func decode(_ data: Data) throws -> ImageContainer {
        try AnimatedImageDecoder(decoder: ImageDecoders.Default()).decode(data)
    }

    @Test func animatedPNGKeepsData() throws {
        let data = try makeImageData(type: .png, frameCount: 3)
        #expect(AnimatedImageView.isAnimated(data: data))

        let container = try decode(data)
        #expect(container.type == .png)
        #expect(container.animatedImageData == data)
    }

    @Test func staticPNGDropsData() throws {
        let data = try makeImageData(type: .png, frameCount: 1)
        #expect(!AnimatedImageView.isAnimated(data: data))

        let container = try decode(data)
        #expect(container.animatedImageData == nil)
    }

    @Test func gifKeepsData() throws {
        let data = try makeImageData(type: .gif, frameCount: 3)

        let container = try decode(data)
        #expect(container.type == .gif)
        #expect(container.animatedImageData == data)
    }

    @Test func staticJPEGDropsData() throws {
        let data = try makeImageData(type: .jpeg, frameCount: 1)

        let container = try decode(data)
        #expect(container.animatedImageData == nil)
    }
}
