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
    
//    private let jsonDecoder: JSONDecoder = {
//        let jsonDecoder = JSONDecoder()
//        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-mm-dd"
//        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
//        return jsonDecoder
//    }()
    
    
    public func fetchShadersLocally() -> [Shader] {
    
    let shader1 = Shader(id: "january01", title: "02", month: "January", imageURL: "https://sdwr-shader-scapesstorage-dev.s3.eu-central-1.amazonaws.com/public/caf8fc03-ae85-497f-ae31-49fd7db8da06shader.png", mainColor: simd_float3(1.0,1.0,1.0))
let shader2 = Shader(id: "january02", title: "01", month: "January", imageURL: "https://sdwr-shader-scapesstorage-dev.s3.eu-central-1.amazonaws.com/public/bfa62ac9-31dd-4b7d-9fe6-a6c6b5c12560shader.png", mainColor: simd_float3(0.010,0.103,0.185))


    let shader3 = Shader(id: "january03", title: "03", month: "January", imageURL: "https://sdwr-shader-scapesstorage-dev.s3.eu-central-1.amazonaws.com/public/70551e87-d453-4a35-a911-03611c194a37shader.png", mainColor: simd_float3(0.010,0.103,0.185))
    
        
  let shader4 = Shader(id: "january04", title: "04", month: "January", imageURL: "https://sdwr-shader-scapesstorage-dev.s3.eu-central-1.amazonaws.com/public/20ead228-6dc3-4cc8-9115-1273c16b6718shader.png", mainColor: simd_float3(0.975,0.010,0.980))
        
 let shader5 = Shader(id: "january05", title: "05", month: "January", imageURL: "https://sdwr-shader-scapesstorage-dev.s3.eu-central-1.amazonaws.com/public/3fc43bc1-c758-4e84-bb25-7c668efe3fc9shader.png", mainColor: simd_float3(0.1,0.118,0.985))
        
        return [shader2, shader1, shader3, shader4, shader5]
    
    }

    

    
}
