//
//  Models.swift
//  Fvnction TV
//
//  Created by Alex Linkov on 1/21/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import Foundation
import UIKit

public struct Shader {
    
    public let id: String
    public let title: String
    public let month: String
    public let imageURL: String
}


protocol ShaderSetting {
    
    var title: String { get set }
}



public struct ShaderSettingColor: ShaderSetting {

    public var title: String
    public let mainColor: UIColor
}

public struct ShaderSettingVariable: ShaderSetting  {
    public var title: String
    public let variableValue: Float
}
