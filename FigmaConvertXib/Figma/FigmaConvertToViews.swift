

import Foundation
import UIKit



class FigmaConvertToViews: NSObject {

    //MARK: - Separator Children
    
    var figmaImagesURLs: [String: String] = [:]
    
    
    func add(page: F_Page, imagesURLs: [String: String]) -> (UIView, F_View) {
        
        figmaImagesURLs = imagesURLs
        
        let view = pageConvert(page: page)
        
        return view
    }
    
    
    func pageConvert(page: F_Page) -> (UIView, F_View) {
        
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = page.backgroundColor
        
        var minX: CGFloat = 0
        var minY: CGFloat = 0
        
        var maxW: CGFloat = 0
        var maxH: CGFloat = 0
        
        /// поиск минальных X Y
        for subview: F_View in page.subviews {
            
            if minX == 0 {
                minX = subview.absoluteBoundingBox.origin.x
            } else if minX > subview.absoluteBoundingBox.origin.x {
                minX = subview.absoluteBoundingBox.origin.x
            }
            
            if minY == 0 {
                minY = subview.absoluteBoundingBox.origin.y
            } else if minY > subview.absoluteBoundingBox.origin.y {
                minY = subview.absoluteBoundingBox.origin.y
            }
        }
        
        /// поиск максимального размера Всей Страницы
        ///  исходя из его Subviews
        for subview: F_View in page.subviews {
            
            var x = subview.absoluteBoundingBox.origin.x
            var y = subview.absoluteBoundingBox.origin.y
            let width = subview.absoluteBoundingBox.size.width
            let height = subview.absoluteBoundingBox.size.height
            
            x = x - minX
            y = y - minY
            
            let cur_maxW = (x + width)
            if maxW == 0 {
                maxW = cur_maxW
            } else if maxW < cur_maxW {
                maxW = cur_maxW
            }
            
            let cur_maxH = (y + height)
            if maxH == 0 {
                maxH = cur_maxH
            } else if maxH < cur_maxH {
                maxH = cur_maxH
            }
        }
        
        let resultPageRealFrame = CGRect(x: 0, y: 0, width: maxW, height: maxH)
        
        view.frame = resultPageRealFrame
        page.realFrame = resultPageRealFrame
        
        
        
        
        for subview: F_View in page.subviews {
            
            
            /// добавление subviews
            if subview.visible, subview.type != .vector, subview.type != .booleanOperation {
                
                var image: Bool = false
                for fill in subview.fills { if fill.type == .image { image = true }}
                
                var resultView: UIView!
                if image {
                    resultView = pageConvertToImage(page: subview)
                } else if subview.type == .text {
                    resultView = pageConvertToLabel(page: subview)
                } else {
                    resultView = pageConvert(figma_view: subview)
                }
                
                /// проверка на cornerRadius - максимум
                subview.realRadius = radiusMax(radius: subview.cornerRadius, frame: resultView.bounds)
                resultView.layer.cornerRadius = subview.realRadius
                
                let x = subview.absoluteBoundingBox.origin.x - minX
                let y = subview.absoluteBoundingBox.origin.y - minY
                let width = subview.absoluteBoundingBox.size.width
                let height = subview.absoluteBoundingBox.size.height
                
                let frame = CGRect(x: x, y: y, width: width, height: height)
                resultView.frame = frame
                subview.realFrame = frame
                view.addSubview(resultView)
            }
            
            
//            print(" \(x) \(y) \(width) \(height) ")
            
        }
        
        return (view, F_View(page))
    }
    
    
    func add(figma_view: F_View, frame: CGRect) -> UIView {
        
        let view: UIView = pageConvert(figma_view: figma_view)
        view.frame = frame
        
        figma_view.realFrame = view.frame
        figma_view.realRadius = radiusMax(radius: figma_view.cornerRadius, frame: view.bounds)
        
        return view
    }
    
    func add(figma_view: F_View, imagesURLs: [String: String]) -> UIView {
        
        self.figmaImagesURLs = imagesURLs
//        self.mainView = mainView
//        self.figmaView?.removeFromSuperview()
        
        let view: UIView = pageConvert(figma_view: figma_view)
        view.frame.origin.x = 0
        view.frame.origin.y = 0
        
        figma_view.realFrame = view.frame
        figma_view.realRadius = radiusMax(radius: figma_view.cornerRadius, frame: view.bounds)
        
//        figmaView = view
        
        return view
    }
    
    func separatorChildrenViewsType(figma_view: F_View, mailView: UIView) {
        
        for cpage: F_View in figma_view.subviews {
            
            if cpage.visible,
                cpage.type != .vector,
                cpage.type != .booleanOperation {
            
                var image: Bool = false
                for fill in cpage.fills {
                    if fill.type == .image {
                        image = true
                    }
                }
                
                var resultView: UIView!
                
                if image {
                    resultView = pageConvertToImage(page: cpage)
                } else if cpage.type == .text {
                    resultView = pageConvertToLabel(page: cpage)
                } else {
                    resultView = pageConvert(figma_view: cpage)
                }
                
                /// проверка на cornerRadius - максимум
                cpage.realRadius = radiusMax(radius: cpage.cornerRadius, frame: resultView.bounds)
                resultView.layer.cornerRadius = cpage.realRadius
                
                
                /// проверка на группу - она не вычисляет  - x y    у своих subviews
                resultView.frame.origin.x =  (resultView.frame.origin.x - mailView.frame.origin.x)
                resultView.frame.origin.y = (resultView.frame.origin.y - mailView.frame.origin.y)

                
                cpage.realFrame = resultView.frame
                
                mailView.addSubview( resultView )
            }
        }
    }
    
    //MARK: - Radius
    
    func radiusMax(radius: CGFloat, frame: CGRect) -> CGFloat {
        
        /// проверка на cornerRadius - максимум
        let rmin = (min(frame.width, frame.height) / 2)
        if radius > rmin {
            return rmin
        } else {
            return radius
        }
    }
    
    //MARK: - View
    
    func pageConvert(figma_view: F_View) -> UIView {
        
        let view = UIView(frame: figma_view.absoluteBoundingBox)
        
        if figma_view.type == .ellipse {
            
            view.backgroundColor = .clear
            
            for fill: F_Fill in figma_view.fills {
                
                switch fill.type {
                case .solid:
                    
                    if fill.visible {
                        let ellipsePath = UIBezierPath(ovalIn: view.bounds)
                        
                        let shapeLayer = CAShapeLayer()
                        shapeLayer.frame = view.bounds
                        shapeLayer.path = ellipsePath.cgPath
                        shapeLayer.fillColor = fill.color.cgColor
                        shapeLayer.opacity = Float(fill.opacity)
                        shapeLayer.strokeColor = figma_view.strokeColor.cgColor
                        shapeLayer.lineWidth = figma_view.strokeWeight
                        view.layer.addSublayer(shapeLayer)
                    }
                
                case .gradientLinear:
                    
                    if fill.visible {
                        let ellipsePath = UIBezierPath(ovalIn: view.bounds)
                        
                        var gradietCGColors: [CGColor] = [ ]
                        
                        for color in fill.gradientStops {
                            gradietCGColors.append( color.cgColor )
                        }
                        
                        let pointFirst: CGPoint = fill.gradientHandlePositions[0]
                        let pointLast: CGPoint = fill.gradientHandlePositions[fill.gradientHandlePositions.count - 2]
                        
                        let layer = CAGradientLayer()
                        layer.frame = view.bounds
                        layer.colors = gradietCGColors
                        layer.startPoint = pointFirst //CGPoint(x: pointFirst.y, y: pointFirst.x)
                        layer.endPoint = pointLast //CGPoint(x: pointLast.y, y: pointLast.x)
                        layer.cornerRadius = radiusMax(radius: figma_view.cornerRadius, frame: view.bounds)
                        //  view.layer.insertSublayer(layer, at: 0)
                        
                        let shapeLayer = CAShapeLayer()
                        shapeLayer.frame = view.bounds
                        shapeLayer.path = ellipsePath.cgPath
                        shapeLayer.fillColor = UIColor.black.cgColor
                        shapeLayer.opacity = Float(fill.opacity)
                        
                        layer.mask = shapeLayer
                        
                        view.layer.addSublayer(layer)
                    }
                    
                default: break
                }
            }
            
        } else {
            
//            view.backgroundColor = page.backgroundColor
            view.clipsToBounds = figma_view.clipsContent
            view.layer.cornerRadius = radiusMax(radius: figma_view.cornerRadius, frame: view.bounds)
            
            for fill: F_Fill in figma_view.fills {
                
                switch fill.type {
                case .solid:
                    
                    if fill.visible {
                        let layer = CALayer()
                        layer.frame = view.bounds
                        layer.cornerRadius = radiusMax(radius: figma_view.cornerRadius, frame: view.bounds)
                        layer.backgroundColor = fill.color.cgColor
                        layer.opacity = Float(fill.opacity)
                        view.layer.addSublayer(layer)
                    }
                case .gradientLinear:
                    
                    if fill.visible {
                        
                        var gradietCGColors: [CGColor] = [ ]
                        
                        for color in fill.gradientStops {
                            gradietCGColors.append( color.cgColor )
                        }
                        
                        let pointFirst: CGPoint = fill.gradientHandlePositions[0]
                        let pointLast: CGPoint = fill.gradientHandlePositions[fill.gradientHandlePositions.count - 2]
                        
                        let layer = CAGradientLayer()
                        layer.frame = view.bounds
                        layer.colors = gradietCGColors
                        layer.startPoint = pointFirst
                        layer.endPoint = pointLast
                        layer.cornerRadius = radiusMax(radius: figma_view.cornerRadius, frame: view.bounds)
                        // view.layer.insertSublayer(layer, at: 0)
                        view.layer.addSublayer(layer)
                    }
                    
                default: break
                }
            }
            
            for stroke: F_Fill in figma_view.strokes {
                if stroke.type == .solid {
                    if stroke.visible {
                        view.layer.borderColor = stroke.color.withAlphaComponent(stroke.opacity).cgColor
                        view.layer.borderWidth = figma_view.strokeWeight
                    } else {
                        view.layer.borderColor = UIColor.clear.cgColor
                        view.layer.borderWidth = 0.0
                    }
                }
            }
            
        }
        
        separatorChildrenViewsType(figma_view: figma_view, mailView: view)
        
        return view
    }
    
    //MARK: - Image
    
    func pageConvertToImage(page: F_View) -> UIImageView {
        
        let imageView = UIImageView(frame: page.absoluteBoundingBox)
//        imageView.backgroundColor = page.backgroundColor
        imageView.clipsToBounds = page.clipsContent
        imageView.layer.cornerRadius = radiusMax(radius: page.cornerRadius, frame: imageView.bounds)
        
        var imageFill: F_Fill!
        
        for fill in page.fills {
            if fill.type == .image {
                imageFill = fill
            }
        }
        
        if !imageFill.visible {
            return imageView
        }
        
        for stroke: F_Fill in page.strokes {
            if stroke.type == .solid {
                if stroke.visible {
                    imageView.layer.borderColor = stroke.color.withAlphaComponent(stroke.opacity).cgColor
                    imageView.layer.borderWidth = page.strokeWeight
                } else {
                    imageView.layer.borderColor = UIColor.clear.cgColor
                    imageView.layer.borderWidth = 0.0
                }
            }
        }
        
        if let imageURL = self.figmaImagesURLs[imageFill.imageRef] {
            
            let url = URL(string: imageURL)!
            
            downloadImage(url: url, completion: { (image: UIImage) in
                // guard let _self = self else { return }
                
                imageView.image = image
            })
            
            switch imageFill.scaleMode {
            case .fill: imageView.contentMode = .scaleAspectFill
            case .fit: imageView.contentMode = .scaleAspectFit
            default: break
            }
            
            imageView.clipsToBounds = true
        }
        
        separatorChildrenViewsType(figma_view: page, mailView: imageView)
        
        return imageView
    }
    
    //MARK: - Label
    
    func pageConvertToLabel(page: F_View) -> UILabel {
        
        let label = UILabel(frame: page.absoluteBoundingBox)
        label.text = page.text
        
        label.numberOfLines = 100
        
        
        
        if let pageFont = page.fontStyle {
            
            var findFont: UIFont?
            
            if let fontName = pageFont.fontPostScriptName {
                
                if let font = UIFont(name: fontName, size: pageFont.fontSize) {
                    findFont = font
                } else {
                    if let font = UIFont(name: "\(fontName)-Regular", size: pageFont.fontSize) {
                        findFont = font
                    }
                }
            }
            
            if (findFont != nil) {
                label.font = findFont
            } else {
                
                if let fontPostScriptName = pageFont.fontPostScriptName {
                    
                    label.font = UIFont.systemFont(ofSize: pageFont.fontSize)
                    
                    if fontPostScriptName.contains("Bold") || fontPostScriptName.contains("bold") {
                        label.font = UIFont.boldSystemFont(ofSize: pageFont.fontSize)
                    } else if fontPostScriptName.contains("Semibold") || fontPostScriptName.contains("semibold") {
                        label.font = UIFont.systemFont(ofSize: pageFont.fontSize, weight: UIFont.Weight.semibold)
                    } else if fontPostScriptName.contains("Medium") || fontPostScriptName.contains("medium") {
                        label.font = UIFont.systemFont(ofSize: pageFont.fontSize, weight: UIFont.Weight.medium)
                    } else if fontPostScriptName.contains("Light") || fontPostScriptName.contains("light") {
                        label.font = UIFont.systemFont(ofSize: pageFont.fontSize, weight: UIFont.Weight.light)
                    }
                    
                } else {
                    label.font = UIFont.systemFont(ofSize: pageFont.fontSize)
                }
            }
            
            switch pageFont.textAlignHorizontal {
            case .left: label.textAlignment = .left
            case .center: label.textAlignment = .center
            case .right:  label.textAlignment = .right
            case .justified: label.textAlignment = .justified
            }
            
            // switch pageFont.textAlignVertical {
            // case .center: label.textAlignment = .center
            // case .bottom: label.textAlignment = .left
            // case .top:  label.textAlignment = .right
            // default: break
            
        }
        
        for fill: F_Fill in page.fills {
            
            switch fill.type {
            case .solid:
                
                label.textColor = fill.color
                
            default: break
            }
        }
        
        label.clipsToBounds = page.clipsContent
        label.layer.cornerRadius = radiusMax(radius: page.cornerRadius, frame: label.bounds)
        // label.layer.borderColor = page.strokeColor.cgColor
        // label.layer.borderWidth = page.strokeWeight
        
        for stroke: F_Fill in page.strokes {
            if stroke.type == .solid {
                if stroke.visible {
                    label.layer.borderColor = stroke.color.withAlphaComponent(stroke.opacity).cgColor
                    label.layer.borderWidth = page.strokeWeight
                } else {
                    label.layer.borderColor = UIColor.clear.cgColor
                    label.layer.borderWidth = 0.0
                }
            }
        }
        
        separatorChildrenViewsType(figma_view: page, mailView: label)
        
        return label
    }
}
