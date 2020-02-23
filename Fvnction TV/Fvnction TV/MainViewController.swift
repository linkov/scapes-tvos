//
//  MainViewController.swift
//  Fvnction TV
//
//  Created by Alex Linkov on 1/21/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import UIKit
import MetalKit
import CenteredCollectionView
import EasyPeasy

class MainViewController: UIViewController {
    var gamepadPosition: simd_float4!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var animationView: MTKView!
    var shaderStore: ShaderStore = ShaderStore.shared
    var shaders = [Shader]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let cellPercentWidth: CGFloat = 0.5
    
    @IBOutlet weak var collectionView: UICollectionView!
    var device: MTLDevice!
    private var metalView : MTKView!
    var computeState: MTLComputePipelineState?
    
    var currentShaderName: String?
    var mainShaderColor: simd_float3!
    var time:Float = 0.0
    var timespeed:Float = Float.pi / 680.00
    var shaderScale: Float = 1.0
    var shaderIntensity: Float = 1.0
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    
    override func viewDidLoad() {
        super.viewDidLoad()

         setupView()
        
        
        
        collectionView.register(UINib(nibName: "ShaderCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        configureCenteredLayout()
//         setupMetal()
        fetchMovies()
    }
    
    private func fetchMovies() {
        
       shaders = ShaderStore.shared.fetchShadersLocally()
    }


    //MARK: SETUP
    fileprivate func setupView() {
//        view.translatesAutoresizingMaskIntoConstraints = false
        
        logoImageView.easy.layout(
            CenterX(0.0),
            Top(40.0),
            Width(700.0),
            Height(100.0)
        )
        
    }
    
    func configureCenteredLayout() {
        
        let centeredCollectionViewFlowLayout = CenteredCollectionViewFlowLayout()
        centeredCollectionViewFlowLayout.itemSize = CGSize(
            width: view.bounds.width * cellPercentWidth,
            height: view.bounds.height * cellPercentWidth
        )

        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        centeredCollectionViewFlowLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = centeredCollectionViewFlowLayout
    }
    
    func configureFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 80.0
        flowLayout.minimumLineSpacing = 80.0
        flowLayout.sectionInset = UIEdgeInsets(top: 80.0, left: 80.0, bottom: 80.0, right: 80.0)
        flowLayout.itemSize = CGSize(width: 550.0, height: 400.0)
        collectionView.collectionViewLayout = flowLayout
    }

    
    fileprivate func setupMetal(shader: String) {
        //view
        self.currentShaderName = shader;
        animationView.layer.opacity = 0.4
        
        if (animationView != nil && animationView.isKind(of: MTKView.self)) {
            animationView.delegate = self
        }
        
        animationView.framebufferOnly = false
        device = MTLCreateSystemDefaultDevice()
        animationView.device = device
        let defaultLibrary = device.makeDefaultLibrary()
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
//
//        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
//        pipelineStateDescriptor.colorAttachments[0].rgbBlendOperation = .add
//        pipelineStateDescriptor.colorAttachments[0].alphaBlendOperation = .add
//        pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
//        pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
//        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
//        pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        let computeProgram = defaultLibrary!.makeFunction(name: shader)
        self.computeState = try! device.makeComputePipelineState(function: computeProgram!)
        commandQueue = device.makeCommandQueue()
    }
    
    
    func render(_ drawable: CAMetalDrawable?) {
        guard let drawable = drawable else { return }
        
        if self.presentedViewController != nil {
            return
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let computeEncoder = commandBuffer!.makeComputeCommandEncoder()
        
        computeEncoder?.setComputePipelineState(self.computeState!)
        

        let texture =  MetalTexture.imageToTexture(imageNamed: "marble3.png", device: self.device)
        computeEncoder?.setTexture(texture , index: 1)

        
        computeEncoder?.setTexture(drawable.texture , index: 0)

        computeEncoder?.setBytes(&self.shaderScale, length: MemoryLayout<Float>.size, index: 0)
        computeEncoder?.setBytes(&self.time, length: MemoryLayout<Float>.size, index: 1)
        computeEncoder?.setBytes(&self.mainShaderColor, length: MemoryLayout<simd_float3>.size, index: 2)
        computeEncoder?.setBytes(&self.shaderIntensity, length: MemoryLayout<Float>.size, index: 3)
        computeEncoder?.setBytes(&self.gamepadPosition, length: MemoryLayout<simd_float4>.size, index: 4)
        
        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width, drawable.texture.height / threadGroupCount.height, 1)
        
        computeEncoder!.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        computeEncoder!.endEncoding()
        commandBuffer?.present(drawable)
        
        commandBuffer!.commit()
        self.time += self.timespeed;
    }
}

extension MainViewController: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        render(view.currentDrawable)
    }
}


extension UIView {
    public func addSubview(_ subview: UIView, stretchToFit: Bool = false) {
        addSubview(subview)
        if stretchToFit {
            subview.translatesAutoresizingMaskIntoConstraints = false
            leftAnchor.constraint(equalTo: subview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: subview.rightAnchor).isActive = true
            topAnchor.constraint(equalTo: subview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: subview.bottomAnchor).isActive = true
        }
    }
}


 //MARK: CollectionView Datasource, Delegate
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shaders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ShaderCell
        let shader = shaders[indexPath.item]
        cell.configure(shader)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
    didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
    with coordinator: UIFocusAnimationCoordinator) {

        if let indexPath = context.nextFocusedIndexPath {
            
            let shader = shaders[indexPath.item]
            mainShaderColor = shader.mainColor
            time = 0.0
            setupMetal(shader: shader.id)
            
         }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController

        detailVC.shaderID = shaders[indexPath.item].id
        detailVC.mainShaderColor = shaders[indexPath.item].mainColor
        
      
        
        present(detailVC, animated: true, completion: nil)
    }
}
