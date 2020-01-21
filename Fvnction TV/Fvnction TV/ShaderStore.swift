//
//  ShaderService.swift
//  Fvnction TV
//
//  Created by Alex Linkov on 1/21/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import Foundation
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
    
    let shader1 = Shader(id: "january01", title: "Mean flower", month: "January", imageURL: "https://sdwr-shader-scapesstorage-dev.s3.eu-central-1.amazonaws.com/public/caf8fc03-ae85-497f-ae31-49fd7db8da06shader.png")

    
    let shader2 = Shader(id: "january02", title: "Muted flames", month: "January", imageURL: "https://sdwr-shader-scapesstorage-dev.s3.eu-central-1.amazonaws.com/public/bfa62ac9-31dd-4b7d-9fe6-a6c6b5c12560shader.png")


    let shader3 = Shader(id: "january03", title: "Metal candy", month: "January", imageURL: "https://sdwr-shader-scapesstorage-dev.s3.eu-central-1.amazonaws.com/public/20ead228-6dc3-4cc8-9115-1273c16b6718shader.png")
    
    return [shader1,shader2, shader3]
    
    }

    

    
}
