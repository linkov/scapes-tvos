//
//  ShaderService.swift
//  Fvnction TV
//
//  Created by Alex Linkov on 1/21/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import Foundation
import MetalKit
public class ShaderStore {
    
    public static let shared = ShaderStore()
    private init() {}
    private let apiKey = "21eae9e0795240bdaf52fbfa7db37732"
    private let baseAPIURL = "https://api.themoviedb.org/3"
    private let urlSession = URLSession.shared
    

    public func fetchShadersLocally() -> [Shader] {
    let shader1 = Shader(id: "january01", title: "01", month: "January", imageURL: "scene1.png", mainColor: simd_float3(1.0,1.0,1.0))
    let shader6 = Shader(id: "january06", title: "02", month: "January", imageURL: "scene2.png", mainColor: simd_float3(0.1,0.618,0.985))

    let shader7 = Shader(id: "january07", title: "03", month: "January", imageURL: "scene3.png", mainColor: simd_float3(0.0,0.0,0.0))
        
        
let shader8 = Shader(id: "january08", title: "04", month: "January", imageURL: "scene4.png", mainColor: simd_float3(0.0,0.0,0.0))
        
let shader9 = Shader(id: "january09", title: "05", month: "January", imageURL: "scene5.png", mainColor: simd_float3(0.0,0.0,0.0))
        
let shader10 = Shader(id: "january10", title: "06", month: "January", imageURL: "scene6.png", mainColor: simd_float3(0.0,0.0,0.0))
        
        return [shader1, shader6, shader7, shader8, shader9, shader10]
    
    }

    

    
}
