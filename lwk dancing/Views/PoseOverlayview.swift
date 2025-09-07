//
//  PoseOverlayview.swift
//  lwk dancing
//
//  Created by Adhavan senthil kumar on 7/9/25.
import UIKit
import Vision

class PoseOverlayView: UIView {
    var points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] = [:] {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        guard !points.isEmpty else { return }
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setStrokeColor(UIColor.red.cgColor)
        ctx?.setLineWidth(2.0)
        
        let connections: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
            (.leftShoulder, .rightShoulder),
            (.leftShoulder, .leftElbow), (.leftElbow, .leftWrist),
            (.rightShoulder, .rightElbow), (.rightElbow, .rightWrist),
            (.leftShoulder, .leftHip), (.rightShoulder, .rightHip),
            (.leftHip, .rightHip),
            (.leftHip, .leftKnee), (.leftKnee, .leftAnkle),
            (.rightHip, .rightKnee), (.rightKnee, .rightAnkle)
        ]
        
        func cgPoint(_ p: VNRecognizedPoint) -> CGPoint {
            CGPoint(x: CGFloat(p.x) * rect.width,
                    y: (1 - CGFloat(p.y)) * rect.height)
        }
        
       
        for (_, p) in points where p.confidence > 0.3 {
            let pt = cgPoint(p)
            ctx?.setFillColor(UIColor.red.cgColor)
            ctx?.fillEllipse(in: CGRect(x: pt.x - 3, y: pt.y - 3, width: 6, height: 6))
        }
        
       
        for (a, b) in connections {
            if let pa = points[a], let pb = points[b],
               pa.confidence > 0.3, pb.confidence > 0.3 {
                ctx?.move(to: cgPoint(pa))
                ctx?.addLine(to: cgPoint(pb))
            }
        }
        ctx?.strokePath()
    }
}

#Preview {
    PoseOverlayView()
}
