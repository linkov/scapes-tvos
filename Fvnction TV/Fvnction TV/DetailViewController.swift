//
//  DetailViewController.swift
//  Fvnction TV
//
//  Created by Alex Linkov on 1/21/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import UIKit
import MetalKit

class DetailViewController: UIViewController {

    var computeState: MTLComputePipelineState?
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var device: MTLDevice!
    var time:Float = 0
    var timespeed:Float = Float.pi / 180.00
    
    @IBOutlet weak var animationView: MTKView!
    var shaderID: String!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupMetal(shader: shaderID)
    }
    fileprivate func setupView() {
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    

    fileprivate func setupMetal(shader: String) {
        //view
        
        animationView.layer.opacity = 0.4
        animationView.delegate = self
        animationView.framebufferOnly = false
        device = MTLCreateSystemDefaultDevice()
        animationView.device = device
        let defaultLibrary = device.makeDefaultLibrary()
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        let computeProgram = defaultLibrary!.makeFunction(name: shader)
        self.computeState = try! device.makeComputePipelineState(function: computeProgram!)
        commandQueue = device.makeCommandQueue()
    }
    
    
    func render(_ drawable: CAMetalDrawable?) {
        guard let drawable = drawable else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let computeEncoder = commandBuffer!.makeComputeCommandEncoder()
        
        computeEncoder?.setComputePipelineState(self.computeState!)
        
        computeEncoder?.setTexture(drawable.texture , index: 0)
        computeEncoder?.setBytes(&self.time, length: MemoryLayout<Float>.size, index: 0)
        
        
        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width, drawable.texture.height / threadGroupCount.height, 1)
        
        computeEncoder!.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        computeEncoder!.endEncoding()
        commandBuffer?.present(drawable)
        
        commandBuffer!.commit()
        self.time += self.timespeed;
    }

}

extension DetailViewController: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        render(view.currentDrawable)
    }
}
