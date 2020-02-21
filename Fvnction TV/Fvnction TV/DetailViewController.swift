//
//  DetailViewController.swift
//  Fvnction TV
//
//  Created by Alex Linkov on 1/21/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import UIKit
import MetalKit
import EasyPeasy



enum UIState {
    case colorPresets
    case mainMenu
    case allClosed
}

class DetailViewController: UIViewController {

    
    
    var focusedView: UIView?
    
    
    @IBOutlet var mainMenuView: UIVisualEffectView!
    var menuTableViewController: MenuTableViewController?
    var state: UIState = .allClosed
    var propertyAnimators: [UIViewPropertyAnimator] = []
    var hasPressedMenuButton = false
    var pressedMenuButtonRecognizer: UITapGestureRecognizer?
    
    
    @IBOutlet var mainMenuLeadingConstraint: NSLayoutConstraint!


    
    let shaderSettings = [
        ShaderSettingColor(title: "Main color", mainColor: .black),
        ShaderSettingVariable(title: "Scale", variableValue: 0.4),
        ShaderSettingVariable(title: "Intensity", variableValue: 0.7),
        ] as [ShaderSetting]
    
    
    
    var computeState: MTLComputePipelineState?
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var device: MTLDevice!
    var time:Float = 0
    var timespeed:Float = Float.pi / 680.00
    
    @IBOutlet weak var animationView: MTKView!
    var shaderID: String!
    var mainShaderColor: simd_float3!
    var shaderScale: Float = 1.0
    var shaderIntensity: Float = 1.0
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.isUserInteractionEnabled = true
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        
        return [mainMenuView]
    }
    


    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "menuEmbedSegue" {
            if let tableViewController = segue.destination as? MenuTableViewController {
                menuTableViewController = tableViewController
                menuTableViewController?.tableView.delegate = self
                menuTableViewController?.tableView.dataSource = self
                menuTableViewController?.tableView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 80)
                menuTableViewController?.tableView.separatorInset = UIEdgeInsets.zero
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

     
        setupView()
        setupGestureRecognizers()
        setupMetal(shader: shaderID)
    }
//    fileprivate func setupView() {
//        view.translatesAutoresizingMaskIntoConstraints = false
//    }
    fileprivate func setupView() {
//        menuHintToast.layer.cornerRadius = menuHintToast.frame.height / 2
//        menuHintToast.clipsToBounds = true
//        menuHintToast.alpha = 1
//
//        colorMenuCloseToast.layer.cornerRadius = colorMenuCloseToast.frame.height / 2
//        colorMenuCloseToast.clipsToBounds = true
//        colorMenuCloseToast.alpha = 0
//
//        mainMenuCloseToast.layer.cornerRadius = colorMenuCloseToast.frame.height / 2
//        mainMenuCloseToast.clipsToBounds = true
//        mainMenuCloseToast.alpha = 0
        mainMenuLeadingConstraint.constant = mainMenuView.frame.width

        updateViewConstraints()


    }

    fileprivate func setupMetal(shader: String) {
        //view
        
        animationView.delegate = self
        animationView.framebufferOnly = false
        device = MTLCreateSystemDefaultDevice()
        animationView.device = device
        let defaultLibrary = device.makeDefaultLibrary()
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineStateDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        
        let computeProgram = defaultLibrary!.makeFunction(name: shader)
        self.computeState = try! device.makeComputePipelineState(function: computeProgram!)
        commandQueue = device.makeCommandQueue()
    }
    
    
    func render(_ drawable: CAMetalDrawable?) {
        guard let drawable = drawable else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let computeEncoder = commandBuffer!.makeComputeCommandEncoder()
        
        computeEncoder?.setComputePipelineState(self.computeState!)
        
        
        if (shaderID == "january06") {
            let texture =  MetalTexture.imageToTexture(imageNamed: "texture1.png", device: self.device)
            computeEncoder?.setTexture(texture , index: 1)
            
        } else {
            
            let texture =  MetalTexture.imageToTexture(imageNamed: "marble3.png", device: self.device)
            computeEncoder?.setTexture(texture , index: 1)
        }
        
        
               computeEncoder?.setTexture(drawable.texture , index: 0)

        computeEncoder?.setBytes(&self.shaderScale, length: MemoryLayout<Float>.size, index: 0)
        computeEncoder?.setBytes(&self.time, length: MemoryLayout<Float>.size, index: 1)
        computeEncoder?.setBytes(&self.mainShaderColor, length: MemoryLayout<simd_float3>.size, index: 2)
        computeEncoder?.setBytes(&self.shaderIntensity, length: MemoryLayout<Float>.size, index: 3)
        
        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width, drawable.texture.height / threadGroupCount.height, 1)
        
        computeEncoder!.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        computeEncoder!.endEncoding()
        commandBuffer?.present(drawable)
        
        commandBuffer!.commit()
        self.time += self.timespeed;
    }
    
    
    
    
    
    
    // Menus

    
    func showMainMenu() {
        cancelRunningAnimators()
        if !hasPressedMenuButton {
            hasPressedMenuButton = true
        }
        DispatchQueue.main.async {
            self.mainMenuLeadingConstraint.constant = 0
            self.state = .mainMenu
            self.pressedMenuButtonRecognizer?.isEnabled = false

            let propertyAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
                self.view.layoutIfNeeded()

            })
            propertyAnimator.addCompletion { _ in
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
            self.propertyAnimators.append(propertyAnimator)
            propertyAnimator.startAnimation()
        }
    }
    
    func hideAllMenus() {
        cancelRunningAnimators()
        DispatchQueue.main.async {
            self.mainMenuLeadingConstraint.constant = self.mainMenuView.frame.width
            self.state = .allClosed
            self.pressedMenuButtonRecognizer?.isEnabled = true

            let propertyAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
                self.view.layoutIfNeeded()
            })
            propertyAnimator.addCompletion { _ in
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
            self.propertyAnimators.append(propertyAnimator)
            propertyAnimator.startAnimation()
        }
    }

    func cancelRunningAnimators() {
        propertyAnimators.forEach {
            $0.pauseAnimation()
            $0.stopAnimation(true)
        }
        propertyAnimators.removeAll()
    }
    
    
    fileprivate func setupGestureRecognizers() {
        let swipeFromRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        swipeFromRight.direction = .left
        swipeFromRight.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        view.addGestureRecognizer(swipeFromRight)

        let swipeFromLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeFromLeft.direction = .right
        swipeFromLeft.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        view.addGestureRecognizer(swipeFromLeft)


        pressedMenuButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressMenuButton))
        pressedMenuButtonRecognizer!.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        view.addGestureRecognizer(pressedMenuButtonRecognizer!)
    }
    
    @objc func didPressMenuButton(gesture _: UIGestureRecognizer) {
        showMainMenu()
    }
    @objc func didSwipeLeft(gesture _: UIGestureRecognizer) {
        if state == .mainMenu {
            hideAllMenus()
        }

    }

    @objc func didSwipeRight(gesture _: UIGestureRecognizer) {

        if state == .allClosed {
            showMainMenu()
        }
    }
    
    
//    @objc func changedScale(_ slider: TvOSSlider) {
//        let scale = slider
//        print(scale)
//        shaderScale = Float(scale)
//    }
//
    @objc func changedScale(slider: TvOSSlider) {
        print(slider.value)
        shaderScale = slider.value
    }
    
    @objc func changedIntensity(slider: TvOSSlider) {
        shaderIntensity = slider.value
    }
    
    
    @objc func changedColor(_ slider: ColorSlider) {
        let color = slider.color
        mainShaderColor = simd_float3(Float(color.redValue), Float(color.greenValue), Float(color.blueValue))
        print(color)
    }
    
    @objc func modalDidConfirm(gesture _: UIGestureRecognizer) {
        
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        
         hideAllMenus()

    }
    
    fileprivate func showColorPicker() {
        let alert = UIAlertController(
            title: "Change main color",
            message: nil,
            preferredStyle: .actionSheet
        )
    

        
        let colorSlider = ColorSlider(orientation: .horizontal, previewSide: .top)
        alert.view.addSubview(colorSlider)
        colorSlider.easy.layout(Edges(10))
        colorSlider.addTarget(self, action: #selector(changedColor), for: .valueChanged)
        colorSlider.color = UIColor(red: CGFloat(mainShaderColor![0]), green: CGFloat(mainShaderColor![1]), blue: CGFloat(mainShaderColor![2]), alpha: 1.0)
        
        
        let pressedSelectButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(modalDidConfirm))
        pressedSelectButtonRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
        colorSlider.addGestureRecognizer(pressedSelectButtonRecognizer)
        
        
        let modalpressedMenuButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(modalDidConfirm))
        modalpressedMenuButtonRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        colorSlider.addGestureRecognizer(modalpressedMenuButtonRecognizer)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    fileprivate func showScaleSlider() {
        let alert = UIAlertController(
            title: "",
            message: nil,
            preferredStyle: .actionSheet
        )
    

        
        let scaleSlider = TvOSSlider()
        alert.view.addSubview(scaleSlider)
        scaleSlider.easy.layout(Edges(10))
        print(shaderScale)
        scaleSlider.setValue(shaderScale, animated: true)
        scaleSlider.addTarget(self, action: #selector(changedScale), for: .valueChanged)
        scaleSlider.minimumValue = 0.0
        scaleSlider.maximumValue = 10.0
        scaleSlider.isContinuous = false
        scaleSlider.minimumTrackTintColor = .black


        
        let pressedSelectButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(modalDidConfirm))
        pressedSelectButtonRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
        scaleSlider.addGestureRecognizer(pressedSelectButtonRecognizer)
        
        
        let modalpressedMenuButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(modalDidConfirm))
        modalpressedMenuButtonRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        scaleSlider.addGestureRecognizer(modalpressedMenuButtonRecognizer)
        
        present(alert, animated: true, completion: nil)
    }

    fileprivate func showIntensitySlider() {
        let alert = UIAlertController(
            title: "",
            message: nil,
            preferredStyle: .actionSheet
        )
    
        
        
        let scaleSlider = TvOSSlider()
        alert.view.addSubview(scaleSlider)
        scaleSlider.easy.layout(Edges(10))
        scaleSlider.setValue(shaderIntensity, animated: true)
        scaleSlider.addTarget(self, action: #selector(changedIntensity), for: .valueChanged)
        scaleSlider.minimumValue = 0.0
        scaleSlider.maximumValue = 50.0
        scaleSlider.isContinuous = false
        scaleSlider.minimumTrackTintColor = .black
        



        
        
        let pressedSelectButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(modalDidConfirm))
        pressedSelectButtonRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
        scaleSlider.addGestureRecognizer(pressedSelectButtonRecognizer)
        
        
        let modalpressedMenuButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(modalDidConfirm))
        modalpressedMenuButtonRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        scaleSlider.addGestureRecognizer(modalpressedMenuButtonRecognizer)
        
        present(alert, animated: true, completion: nil)
    }
    
    

}

extension DetailViewController: RangeSeekSliderDelegate {
 
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        print(maxValue)
        print(minValue)
    }
}

extension DetailViewController: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        render(view.currentDrawable)
    }
}


// MARK: - Preset Table View

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
         if ((context.previouslyFocusedIndexPath) != nil) {
            let cell = tableView.cellForRow(at: context.previouslyFocusedIndexPath!)  as! SimpleTableViewCell
            cell.textLabel?.textColor = UIColor.white
         }
         if ((context.nextFocusedIndexPath) != nil) { // focused state
            let cell = tableView.cellForRow(at: context.nextFocusedIndexPath!) as! SimpleTableViewCell
//            let image = UIImage(named: "colorpickerIcon")!.withRenderingMode(.alwaysTemplate)
//            cell.iconImageView!.image = image
//            cell.iconImageView!.tintColor = UIColor.black
            cell.textLabel?.textColor = UIColor.black
            
         }
     }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableViewCell", for: indexPath) as? SimpleTableViewCell
            {
            
                
            let preset = shaderSettings[indexPath.row]
                cell.cellTitle = preset.title
                cell.layoutMargins = UIEdgeInsets.zero
                
                
                if (indexPath.row == 0) {
                    cell.imageView?.image = UIImage(named: "colorpickerIcon")
                    
                }
                
                if (indexPath.row == 1) {
                    cell.imageView?.image = UIImage(named: "scaleIcon")
                    
                }
                
                if (indexPath.row == 2) {
                    cell.imageView?.image = UIImage(named: "intensityIcon")
                    
                }
                
                
            return cell
        }

        return UITableViewCell()
        
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200.0
//    }
    
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

//    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
//         return "Presets"
//    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shaderSettings.count
    }



    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (indexPath.row == 0) {
            showColorPicker()
        }
        
        if (indexPath.row == 1) {
            showScaleSlider()
        }
        
        if (indexPath.row == 2) {
            showIntensitySlider()
        }
    }
}
