//
//  MetalTexture.swift
//  Fvnction TV
//
//  Created by Alex Linkov on 2/20/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import UIKit
import CoreGraphics

class MetalTexture {

    class func imageToTexture(imageNamed: String, device: MTLDevice) -> MTLTexture {
        let bytesPerPixel = 4
        let bitsPerComponent = 8

        let image = UIImage(named: imageNamed)!

        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let bounds = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))

        let rowBytes = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: rowBytes, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue)

        context!.clear(bounds)
        context!.translateBy(x: CGFloat(width), y: CGFloat(height))
        context!.scaleBy(x: -1.0, y: -1.0)
        context?.draw(image.cgImage!, in: bounds)

        let texDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
        texDescriptor.pixelFormat = .bgra8Unorm
        

        let texture = device.makeTexture(descriptor: texDescriptor)
        texture!.label = imageNamed

        let pixelsData = context!.data

        let region = MTLRegionMake2D(0, 0, width, height)
        texture!.replace(region: region, mipmapLevel: 0, withBytes: pixelsData!, bytesPerRow: rowBytes)

        return texture!
    }
}

//
//pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//
//pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
//pipelineStateDescriptor.colorAttachments[0].rgbBlendOperation = .add
//pipelineStateDescriptor.colorAttachments[0].alphaBlendOperation = .add
//pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
//pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
//pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
//pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
