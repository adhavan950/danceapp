//
//  dance_appApp.swift
//  dance app
//
//  Created by Adhavan senthil kumar on 23/8/25.
//

import SwiftUI
import Vision
import AVFoundation
import UIKit
class PoseDetector {
    let request = VNDetectHumanBodyPoseRequest()

    func processVideo(url: URL) {
        let asset = AVURLAsset(url: url)
        guard let track = asset.tracks(withMediaType: .video).first else { return }

        let reader = try! AVAssetReader(asset: asset)
        let settings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
        reader.add(output)
        reader.startReading()

        while let buffer = output.copyNextSampleBuffer(),
              let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            analyze(pixelBuffer)
        }
    }

    private func analyze(_ pixelBuffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])

        if let results = request.results {
            for obs in results {
                if let points = try? obs.recognizedPoints(.all) {
                    for (joint, point) in points where point.confidence > 0.3 {
                        print("\(joint.rawValue): (\(point.x), \(point.y))")
                    }
                }
            }
        }
    }
}
@main
struct dance_appApp: App {
    var body: some Scene {
        WindowGroup {
            
            ContentView()
        }
    }
}
