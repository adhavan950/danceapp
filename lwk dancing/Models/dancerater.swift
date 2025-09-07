//
//  dancerater.swift
//  lwk dancing
//
//  Created by Adhavan senthil kumar on 6/9/25.
//

import Foundation
import Vision
import AVFoundation
import CoreGraphics
extension CGPoint {
    func distance(to other: CGPoint) -> Double {
        let dx = Double(x - other.x)
        let dy = Double(y - other.y)
        return sqrt(dx*dx + dy*dy)
    }
}

func angle(between a: CGPoint, b: CGPoint, c: CGPoint) -> Double {
    let ab = CGVector(dx: a.x - b.x, dy: a.y - b.y)
    let cb = CGVector(dx: c.x - b.x, dy: c.y - b.y)
    
    let dot = ab.dx * cb.dx + ab.dy * cb.dy
    let magAB = sqrt(Double(ab.dx * ab.dx + ab.dy * ab.dy)) 
    let magCB = sqrt(Double(cb.dx * cb.dx + cb.dy * cb.dy))
    
    let cosTheta = Double(dot) / (magAB * magCB)
    return acos(cosTheta) * 180.0 / Double.pi
}


class PoseComparator {
    private let request = VNDetectHumanBodyPoseRequest()
    
    // Joints for angle calculations
    private let angleTriplets: [(VNHumanBodyPoseObservation.JointName,
                                VNHumanBodyPoseObservation.JointName,
                                VNHumanBodyPoseObservation.JointName)] = [
        (.leftShoulder, .leftElbow, .leftWrist),
        (.rightShoulder, .rightElbow, .rightWrist),
        (.leftHip, .leftKnee, .leftAnkle),
        (.rightHip, .rightKnee, .rightAnkle),
        (.neck, .leftShoulder, .leftElbow),
        (.neck, .rightShoulder, .rightElbow)           ]
    
   
    private let distancePairs: [(VNHumanBodyPoseObservation.JointName,
                                 VNHumanBodyPoseObservation.JointName)] = [
        (.leftWrist, .rightWrist),
        (.leftAnkle, .rightAnkle),
        (.leftShoulder, .rightShoulder),
        (.leftHip, .rightHip)
    ]
    

    func compare(referenceURL: URL, userURL: URL) -> Double {
        let refFrames = extractFrames(url: referenceURL)
        let userFrames = extractFrames(url: userURL)
        
        let minFrames = min(refFrames.count, userFrames.count)
        guard minFrames > 0 else { return 0 }
        
        var totalScore = 0.0
        
        for i in 0..<minFrames {
            let frameScore = compareFrame(refFrames[i], userFrames[i])
            totalScore += frameScore
        }
        
        return totalScore / Double(minFrames)
    }
    private func computeSimilarity(
        refPoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        userPoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> Double {
        var total: Double = 0
        var count = 0

        let importantJoints: [VNHumanBodyPoseObservation.JointName] = [
            .leftShoulder, .rightShoulder,
            .leftElbow, .rightElbow,
            .leftWrist, .rightWrist,
            .leftKnee, .rightKnee,
            .root, .neck
        ]

        for joint in importantJoints {
            if let ref = refPoints[joint], let usr = userPoints[joint],
               ref.confidence > 0.3, usr.confidence > 0.3 {

                let dx = Double(ref.x - usr.x)
                let dy = Double(ref.y - usr.y)
                let distance = sqrt(dx*dx + dy*dy)

                // Closer joints = higher similarity
                let similarity = max(0, 1 - distance * 2.5)
                total += similarity
                count += 1
            }
        }

        guard count > 0 else { return 0 }
        let avg = total / Double(count)

        
        let scaled = pow(avg, 2.0) * 100
        return min(100, max(0, scaled))
    }
    
    private func extractFrames(url: URL) -> [[String: Double]] {
        var results: [[String: Double]] = []
        
        let asset = AVAsset(url: url)
        guard let track = asset.tracks(withMediaType: .video).first else { return [] }
        
        do {
            let reader = try AVAssetReader(asset: asset)
            let settings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
            ]
            let output = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
            reader.add(output)
            reader.startReading()
            
            while let buffer = output.copyNextSampleBuffer(),
                  let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
                try? handler.perform([request])
                
                if let obs = request.results?.first {
                    if let points = try? obs.recognizedPoints(.all) {
                        var frameData: [String: Double] = [:]
                        
                        var torsoLength: Double = 1.0
                        if let neck = points[.neck], let root = points[.root],
                           neck.confidence > 0.3, root.confidence > 0.3 {
                            torsoLength = CGPoint(x: neck.x, y: neck.y)
                                .distance(to: CGPoint(x: root.x, y: root.y))
                        }
                        
                       
                        for (a, b, c) in angleTriplets {
                            if let pa = points[a], pa.confidence > 0.3,
                               let pb = points[b], pb.confidence > 0.3,
                               let pc = points[c], pc.confidence > 0.3 {
                                let ang = angle(between: CGPoint(x: pa.x, y: pa.y),
                                                b: CGPoint(x: pb.x, y: pb.y),
                                                c: CGPoint(x: pc.x, y: pc.y))
                                frameData["angle_\(b.rawValue)"] = ang
                            }
                        }
                        
                        
                        for (j1, j2) in distancePairs {
                            if let p1 = points[j1], p1.confidence > 0.3,
                               let p2 = points[j2], p2.confidence > 0.3 {
                                let d = CGPoint(x: p1.x, y: p1.y)
                                    .distance(to: CGPoint(x: p2.x, y: p2.y)) / torsoLength
                                frameData["dist_\(j1.rawValue)_\(j2.rawValue)"] = d
                            }
                        }
                        
                        results.append(frameData)
                    }
                }
            }
        } catch {
            print("Error reading video: \(error)")
        }
        return results
    }
    
    private func compareFrame(_ ref: [String: Double], _ user: [String: Double]) -> Double {
        var total = 0.0
        var count = 0
        
        for key in ref.keys {
            if let rv = ref[key], let uv = user[key] {
                if key.starts(with: "angle") {
                    let diff = abs(rv - uv)
                    total += max(0, 100 - diff)
                } else if key.starts(with: "dist") {
                    let diff = abs(rv - uv) * 100
                    total += max(0, 100 - diff)
                }
                count += 1
            }
        }
        
        return count > 0 ? total / Double(count) : 0
    }
}
