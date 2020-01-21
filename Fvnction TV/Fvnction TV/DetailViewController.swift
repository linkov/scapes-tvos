//
//  DetailViewController.swift
//  Fvnction TV
//
//  Created by Alex Linkov on 1/21/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import UIKit
import MetalKit


enum UIState {
    case colorPresets
    case mainMenu
    case allClosed
}

class DetailViewController: UIViewController {

    @IBOutlet var mainMenuView: UIVisualEffectView!
    var menuTableViewController: MenuTableViewController?
    var state: UIState = .allClosed
    var propertyAnimators: [UIViewPropertyAnimator] = []
    var hasPressedMenuButton = false
    var pressedMenuButtonRecognizer: UITapGestureRecognizer?
    
    
    @IBOutlet var mainMenuLeadingConstraint: NSLayoutConstraint!


    
    let shaderSettings = [
        ShaderSettingColor(title: "Main color", mainColor: .black),
        ShaderSettingVariable(title: "Main function", variableValue: 0.4),
        ShaderSettingVariable(title: "Second function", variableValue: 0.7),
        ] as [ShaderSetting]
    
    
    
    var computeState: MTLComputePipelineState?
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var device: MTLDevice!
    var time:Float = 0
    var timespeed:Float = Float.pi / 180.00
    
    @IBOutlet weak var animationView: MTKView!
    var shaderID: String!
    
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "presetCell", for: indexPath) as? ColorPresetTableViewCell
            {
            
                
            let preset = shaderSettings[indexPath.row]
            cell.titleLabel.text = preset.title
            return cell
        }

        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
         return "Presets"
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shaderSettings.count
    }



    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {

        
    }
}
