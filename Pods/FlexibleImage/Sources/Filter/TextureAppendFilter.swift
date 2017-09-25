//
//  TextureAppendFilter.swift
//  Test Project
//
//  Created by Kawoou on 2017. 5. 13..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(OSX)
    import UIKit
#else
    import AppKit
#endif

#if !os(watchOS)
    import Metal
#endif

internal class TextureAppendFilter: ImageFilter {
    
    // MARK: - Property
    
    internal override var metalName: String {
        get {
            return "TextureAppendFilter"
        }
    }
    
    internal var offsetX: Float = 0
    internal var offsetY: Float = 0
    internal var scaleX: Float = 1.0
    internal var scaleY: Float = 1.0
    internal var threshold: Float = 1.0
    internal var image: FIImage?
    
    // MARK: - Private
    
    private var texture: AnyObject? // MTLTexture?
    
    #if !os(watchOS)
        @available(OSX 10.11, iOS 8, tvOS 9, *)
        private func makeTexture(_ device: MTLDevice) {
            guard self.texture == nil else { return }
            
            self.texture = nil
            
            guard let image = self.image else { return }
            guard let imageRef = image.cgImage else { return }
            
            let drawWidth = Int(Float(imageRef.width) * self.scaleX)
            let drawHeight = Int(Float(imageRef.height) * self.scaleY)
            
            let width = Int(Float(drawWidth) + self.offsetX)
            let height = Int(Float(drawHeight) + self.offsetY)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            let bytesPerRow = width * 4
            let bitsPerComponent = 8
            let memorySize = bytesPerRow * height
            
            let memoryPool = UnsafeMutablePointer<UInt8>.allocate(capacity: memorySize)
            defer { memoryPool.deallocate(capacity: memorySize) }
            memset(memoryPool, 0, memorySize)
            
            /// Create Context
            let bitmapContext = CGContext(
                data: memoryPool,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: (CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
            )
            guard let context = bitmapContext else { return }
            
            context.draw(imageRef, in: CGRect(x: Int(self.offsetX), y: Int(self.offsetY), width: drawWidth, height: drawHeight))
            
            let descriptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: .rgba8Unorm,
                width: width,
                height: height,
                mipmapped: false
            )
            let texture = device.makeTexture(descriptor: descriptor)
            texture.replace(
                region: MTLRegionMake2D(0, 0, width, height),
                mipmapLevel: 0,
                withBytes: memoryPool,
                bytesPerRow: bytesPerRow
            )
            
            self.texture = texture
            self.image = nil
        }
    #endif
    
    
    // MARK: - Internal
    
    #if !os(watchOS)
        @available(OSX 10.11, iOS 8, tvOS 9, *)
        internal override func processMetal(_ device: ImageMetalDevice, _ commandBuffer: MTLCommandBuffer, _ commandEncoder: MTLComputeCommandEncoder) -> Bool {
            self.makeTexture(device.device)
            
            let texture = self.texture as! MTLTexture
            commandEncoder.setTexture(texture, at: 2)
            
            let factors: [Float] = [
                Float(texture.width),
                Float(texture.height),
                self.threshold
            ]
            
            for i in 0..<factors.count {
                var factor = factors[i]
                let size = max(MemoryLayout<Float>.size, 16)
                
                let options: MTLResourceOptions
                if #available(iOS 9.0, *) {
                    options = [.storageModeShared]
                } else {
                    options = [.cpuCacheModeWriteCombined]
                }

                let buffer = device.device.makeBuffer(
                    bytes: &factor,
                    length: size,
                    options: options
                )
                commandEncoder.setBuffer(buffer, offset: 0, at: i)
            }
            
            return super.processMetal(device, commandBuffer, commandEncoder)
        }
    #endif
    
    override func processNone(_ device: ImageNoneDevice) -> Bool {
        guard let imageRef = self.image?.cgImage else { return false }
        
        let appendWidth = CGFloat(imageRef.width) * CGFloat(self.scaleX)
        let appendHeight = CGFloat(imageRef.height) * CGFloat(self.scaleY)
        
        device.context?.saveGState()
        
        device.context?.setBlendMode(.normal)
        device.context?.setAlpha(1.0)
        device.context?.draw(
            imageRef,
            in: CGRect(
                x: CGFloat(self.offsetX),
                y: CGFloat(device.context!.height) - CGFloat(self.offsetY) - appendHeight,
                width: appendWidth,
                height: appendHeight
            )
        )
        
        device.context?.restoreGState()
        
        return super.processNone(device)
    }
    
}
