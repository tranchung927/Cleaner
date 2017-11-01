//
//  GaugeView.swift
//  GaugeViewV2
//
//  Created by ChungTran on 10/13/17.
//  Copyright © 2017 ChungTran. All rights reserved.
//

import UIKit

@IBDesignable
public class GaugeView: UIView {
    
    ///
    // Class proprty
    ///
    override public func layoutSubviews() {
        super.layoutSubviews()
        if cornerRadius == -1 {
            self.layer.cornerRadius = self.bounds.width < self.bounds.height ? self.bounds.width * 0.5 : self.bounds.height * 0.5
        }
        setup()
        awakeFromNib()
        createGaugeView()
        createTitleLabel()
    }
    
    private var label: UILabel!
    
    private var gaugeLayer: GaugeLayer!
    
    //Gauge property
    @IBInspectable public var startAngle: Float = 0.0
    
    @IBInspectable public var radius: CGFloat {
        return min(self.bounds.width, self.bounds.height)/2
    }
    
    @IBInspectable public var thickness: CGFloat = 20 {
        didSet {
            if let gaugeLayer = gaugeLayer {
                self.setNeedsDisplay()
                gaugeLayer.setNeedsDisplay()
            }
        }
    }
    
    public var animationDuration: Float = 0.5
    
    @IBInspectable public var percentage: Float = 20 {
        didSet {
            if let gaugeLayer = gaugeLayer {
                gaugeLayer.stopAngle  = convertPercentageInRadius(percentage: percentage)
                self.accessibilityValue = "\(percentage)%"
            }
        }
    }
    
    @IBInspectable public var gaugeBackgroundColor: UIColor = UIColor.gray {
        didSet {
            if let gaugeLayer = gaugeLayer {
                self.setNeedsDisplay()
                gaugeLayer.setNeedsDisplay()
            }
        }
    }
    
    @IBInspectable public var gaugeColor: UIColor = UIColor.red {
        didSet {
            if let gaugeLayer = gaugeLayer {
                self.setNeedsDisplay()
                gaugeLayer.setNeedsDisplay()
            }
        }
    }
    
    //Label property
    @IBInspectable public var labelText: String = "" {
        didSet {
            label.text = labelText
            updateTextLabel()
        }
    }
    
    @IBInspectable public var labelFont: UIFont? {
        didSet {
            if let labelFont = labelFont {
                label.font = labelFont
                updateTextLabel()
            }
        }
    }
    
    @IBInspectable public var labelColor: UIColor? {
        didSet {
            if let labelColor = labelColor {
                label.textColor = labelColor
                updateTextLabel()
            }
        }
    }
    ///
    // Class methods
    ///
    
    //MARK: - Init methods
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    //MARK: - Draw method
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        gaugeLayer.radius = radius
        gaugeLayer.thickness = thickness
        gaugeLayer.frame = self.bounds
        gaugeLayer.gaugeBackgroundColor = gaugeBackgroundColor
        gaugeLayer.gaugeColor = gaugeColor
        gaugeLayer.animationDuration = animationDuration
        gaugeLayer.startAngle = convertDegreesToRadius(degrees: startAngle)
        gaugeLayer.stopAngle = convertPercentageInRadius(percentage: percentage)
        
        updateTextLabel()
    }
    
    //MARK: - Setup method
    private func setup() {
        createGaugeView()
        createTitleLabel()
        
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        self.isAccessibilityElement = true
    }
    
    private func createGaugeView() {
        gaugeLayer = GaugeLayer(layer: layer)
        
        gaugeLayer.radius = radius
        gaugeLayer.thickness = thickness
        gaugeLayer.frame = self.bounds
        gaugeLayer.gaugeBackgroundColor = gaugeBackgroundColor
        gaugeLayer.gaugeColor = gaugeColor
        gaugeLayer.animationDuration = animationDuration
        gaugeLayer.startAngle = convertDegreesToRadius(degrees: startAngle)
        gaugeLayer.stopAngle = convertPercentageInRadius(percentage: percentage)
        
        layer.addSublayer(gaugeLayer)
        
        self.backgroundColor = UIColor.clear
    }
    
    private func createTitleLabel() {
        label = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize.zero))
        
        updateTextLabel()
        
        self.addSubview(label)
    }
    
    private func updateTextLabel() {
        label.sizeToFit()
        label.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
    }
    
    //MARK: - Utility method
    private func convertPercentageInRadius(percentage: Float) -> Float {
        return convertDegreesToRadius(degrees: (360.0 / 100.0 * percentage) + startAngle)
    }
    
    private func convertDegreesToRadius(degrees: Float) -> Float {
        return ((Float(Double.pi) * degrees) / 180.0)
    }
    
}
