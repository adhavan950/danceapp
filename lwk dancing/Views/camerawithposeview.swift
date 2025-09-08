//
//  camerawithposeview.swift
//  lwk dancing
//
//  Created by Adhavan senthil kumar on 7/9/25.
import SwiftUI
import AVFoundation
import Vision

struct CameraWithPoseView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var overlay: PoseOverlayView
        let request = VNDetectHumanBodyPoseRequest()
        
        init(overlay: PoseOverlayView) {
            self.overlay = overlay
        }
        
        func captureOutput(_ output: AVCaptureOutput,
                           didOutput sampleBuffer: CMSampleBuffer,
                           from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try? handler.perform([request])
            
            if let obs = request.results?.first,
               let pts = try? obs.recognizedPoints(.all) {
                DispatchQueue.main.async {
                    self.overlay.points = pts
                }
            }
        }
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        
        let session = AVCaptureSession()
        session.sessionPreset = .medium
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return vc
        }
        session.addInput(input)
        
       
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = UIScreen.main.bounds
        
        
        if let connection = preview.connection, connection.isVideoOrientationSupported {
            switch UIDevice.current.orientation {
            case .landscapeLeft:
                connection.videoOrientation = .landscapeRight
            case .landscapeRight:
                connection.videoOrientation = .landscapeLeft
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
            default:
                connection.videoOrientation = .portrait
            }
        }
        
        let previewView = UIView(frame: UIScreen.main.bounds)
        previewView.layer.addSublayer(preview)
        
        // Overlay skeleton
        let overlay = PoseOverlayView(frame: UIScreen.main.bounds)
        overlay.backgroundColor = .clear
        previewView.addSubview(overlay)
        
        vc.view = previewView
        
        
        let output = AVCaptureVideoDataOutput()
        let queue = DispatchQueue(label: "videoQueue")
        let coordinator = context.coordinator
        output.setSampleBufferDelegate(coordinator, queue: queue)
        session.addOutput(output)
        
        session.startRunning()
        
        coordinator.overlay = overlay
        
       
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            if let connection = preview.connection, connection.isVideoOrientationSupported {
                switch UIDevice.current.orientation {
                case .landscapeLeft:
                    connection.videoOrientation = .landscapeRight
                case .landscapeRight:
                    connection.videoOrientation = .landscapeLeft
                case .portraitUpsideDown:
                    connection.videoOrientation = .portraitUpsideDown
                default:
                    connection.videoOrientation = .portrait
                }
            }
        }
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(overlay: PoseOverlayView())
    }
}

#Preview {
    CameraWithPoseView()
}
