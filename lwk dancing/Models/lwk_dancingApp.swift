//
//  lwk_dancingApp.swift
//  lwk dancing
//
//  Created by Adam Zafir on 8/28/25.
//

import SwiftUI
import AVFoundation
import Vision
import CoreMedia

@main
struct lwk_dancingApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    } 
}

class DanceRecorder: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let captureSession = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    private let poseRequest = VNDetectHumanBodyPoseRequest()
    
    var referencePlayer: AVPlayer!
    private var csvLines: [String] = ["frame,joint,x,y,confidence"]
    private var frameIndex = 0
    
    override init() {
        super.init()
        setupCamera()
        setupReferenceVideo()
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        captureSession.beginConfiguration()
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        }
        captureSession.commitConfiguration()
    }
    
    private func setupReferenceVideo() {
        if let url = Bundle.main.url(forResource: "dancevid", withExtension: "mov") {
            referencePlayer = AVPlayer(url: url)
        }
    }
    
    func startRecording() {
        frameIndex = 0
        csvLines = ["frame,joint,x,y,confidence"]
        captureSession.startRunning()
        referencePlayer?.seek(to: .zero)
        referencePlayer?.play()
    }
    
    func stopRecording() {
        captureSession.stopRunning()
        referencePlayer?.pause()
        saveCSV()
    }
    
    // MARK: Capture Frames + Pose Detection
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        analyzeFrame(pixelBuffer)
    }
    
    private func analyzeFrame(_ pixelBuffer: CVPixelBuffer) {
        frameIndex += 1
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([poseRequest])
        
        if let results = poseRequest.results as? [VNHumanBodyPoseObservation] {
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
        let filename = "dance_capture.csv"
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(filename)
            do {
                try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
                print("✅ CSV saved at: \(fileURL.path)")
            } catch {
                print("❌ Failed to save CSV: \(error)")
            }
        }
    }
}
