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
    var csvLines: [String] = ["frame,joint,x,y,confidence"]
    let request = VNDetectHumanBodyPoseRequest()
    var frameIndex = 0
    
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
        saveCSV()
    }
    
    private func analyze(_ pixelBuffer: CVPixelBuffer) {
        frameIndex += 1
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
        
        if let results = request.results {
            for obs in results {
                if let points = try? obs.recognizedPoints(.all) {
                    for (joint, point) in points where point.confidence > 0.3 {
                        let line = "\(frameIndex),\(joint.rawValue),\(point.x),\(point.y),\(point.confidence)"
                        csvLines.append(line)
                    }
                }
            }
        }
    }
    
    private func saveCSV() {
        let csvText = csvLines.joined(separator: "\n")
        let filename = "pose_data.csv"
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(filename)
            do {
                try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
                print("✅ CSV saved at: \(fileURL)")
            } catch {
                print("❌ Failed to save CSV: \(error)")
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
