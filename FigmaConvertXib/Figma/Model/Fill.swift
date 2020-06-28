//
//  Fill.swift
//  FigmaConvertXib
//
//  Created by Рустам Мотыгуллин on 26.06.2020.
//  Copyright © 2020 mrusta. All rights reserved.
//

import UIKit

class F_Fill {
    
    var blendMode: F_View.BlendMode = .modeDefault
    var type: F_Fill.Type_ = .solid
    
    var visible: Bool = true /// gradint
    var gradientHandlePositions: [CGPoint] = [] /// gradint
    var gradientStops: [UIColor] = [] /// gradint
    var gradientPosition: [CGFloat] = [] /// gradint
        
    var scaleMode: F_Fill.ScaleMode = .fill /// image
    var imageRef: String = "" /// image
        
    var opacity: CGFloat = 1.0 /// color
    var color: UIColor = .clear /// color
    
    init(_ dict: [String:Any]) {
        
        let type = dict["type"] as! String
        self.type = F_Fill.Type_.type(type)
        
        
        if let blendMode = dict["blendMode"] as? String {
            self.blendMode = F_View.BlendMode.blendMode(blendMode)
        }
        
        if let visible = dict["visible"] as? Bool {
            self.visible = visible
        }
        
        if let scaleMode = dict["scaleMode"] as? String {
            self.scaleMode = F_Fill.ScaleMode.type(scaleMode)
        }
        if let imageRef = dict["imageRef"] as? String {
            self.imageRef = imageRef
        }
        
        
        if let opacity = dict["opacity"] as? CGFloat {
            self.opacity = opacity
        }
        if let color = dict["color"] as? [String: Any] {
            self.color = F_Color.color(color)
        }
        
        if let gradientHandlePositions = dict["gradientHandlePositions"] as? [ [String:CGFloat] ] {
            self.gradientHandlePositions = []
            for pos in gradientHandlePositions {
                if let x: CGFloat = pos["x"], let y: CGFloat = pos["y"] {
                    let point = CGPoint(x: x, y: y)
                    self.gradientHandlePositions.append(point)
                }
            }
        }
        
        if let gradientStops = dict["gradientStops"] as? [ [String:Any] ] {
            self.gradientStops = []
            for gradient in gradientStops {
                if let color = gradient["color"] as? [String: Any] {
                    let color = F_Color.color(color)
                    self.gradientStops.append(color)
                }
            }
        }
        
        if let gradientStops = dict["gradientStops"] as? [ [String:Any] ] {
            self.gradientPosition = []
            for gradient in gradientStops {
                if let position = gradient["position"] as? CGFloat {
                    self.gradientPosition.append(position)
                }
            }
        }
        
    }
    
     
}

extension F_Fill {
    
    enum Type_: String {
        
        case emoji = "EMOJI"
        case gradientAngular = "GRADIENT_ANGULAR"
        case gradientDiamond = "GRADIENT_DIAMOND"
        case gradientLinear = "GRADIENT_LINEAR"
        case gradientRadial = "GRADIENT_RADIAL"
        case image = "IMAGE"
        case solid = "SOLID"
        
        static func type(_ str: String) -> Type_ {
            var type: Type_ = .solid
            
            switch str {
            case "EMOJI": type = .emoji
            case "GRADIENT_ANGULAR": type = .gradientAngular
            case "GRADIENT_DIAMOND": type = .gradientDiamond
            case "GRADIENT_LINEAR": type = .gradientLinear
            case "GRADIENT_RADIAL": type = .gradientRadial
            case "IMAGE": type = .image
            case "SOLID": type = .solid
            default: break
            }
            return type
        }
    }
}

extension F_Fill {
    
    enum ScaleMode: String {

        case fill = "FILL"
        case fit = "FIT"
        case crop = "STRETCH"
        case tile = "TILE"
        
        static func type(_ str: String) -> ScaleMode {
            var type: ScaleMode = .fill
            
            switch str {
            case "FILL": type = .fill
            case "FIT": type = .fit
            case "STRETCH": type = .crop
            case "TILE": type = .tile
            default: break
            }
            return type
        }
    }
}
