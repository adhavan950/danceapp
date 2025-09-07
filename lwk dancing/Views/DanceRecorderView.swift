import SwiftUI
import AVFoundation
import AVKit
import Vision

struct DanceRecorderView: View {
    @State private var session = AVCaptureSession()
    @State private var output = AVCaptureMovieFileOutput()
    @State private var isRecording = false
    @State private var player: AVPlayer? = nil
    @State private var score: Double? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Reference video
                if let url = Bundle.main.url(forResource: "referenceDance", withExtension: "mov") {
                    VideoPlayer(player: player)
                        .onAppear {
                            player = AVPlayer(url: url)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("Reference video not found")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Camera + overlay
                CameraPreview(session: session)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Score display
            if let score = score {
                Text("Dance similarity score: \(String(format: "%.1f", score))")
                    .font(.title2)
                    .bold()
                    .padding(.top, 8)
            }
            
            // Record button
            Button(action: {
                toggleRecording()
            }) {
                Circle()
                    .fill(isRecording ? Color.gray : Color.red)
                    .frame(width: 70, height: 70)
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    .padding()
            }
        }
        .onAppear {
            setupCamera()
        }
    }
    
    // MARK: - Camera Setup
    private func setupCamera() {
        session.beginConfiguration()
        
        // Front camera input
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("❌ Camera unavailable")
            return
        }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        // Movie file output (for recording)
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        // Audio input (so your recording has sound!)
        if let mic = AVCaptureDevice.default(for: .audio),
           let micInput = try? AVCaptureDeviceInput(device: mic),
           session.canAddInput(micInput) {
            session.addInput(micInput)
        }
        
        session.commitConfiguration()
        session.startRunning()
    }
    
    // MARK: - Recording Control
    private func toggleRecording() {
        if isRecording {
            output.stopRecording()
            isRecording = false
        } else {
            guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                  let refURL = Bundle.main.url(forResource: "referenceDance", withExtension: "mov") else { return }
            
            let fileURL = documents.appendingPathComponent("userDance.mov")
            try? FileManager.default.removeItem(at: fileURL) // overwrite old recording
            
            output.startRecording(to: fileURL, recordingDelegate: CameraRecorderDelegate.shared)
            isRecording = true
            
            // Start reference video
            player?.seek(to: .zero)
            player?.play()
            
            // Stop both when video ends
            if let duration = player?.currentItem?.asset.duration {
                let seconds = CMTimeGetSeconds(duration)
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    if self.isRecording {
                        self.output.stopRecording()
                        self.isRecording = false
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let comparator = PoseComparator()
                            let result = comparator.compare(referenceURL: refURL, userURL: fileURL)
                            self.score = result
                            print("✅ Dance similarity score: \(result)")
                        }
                        
                    }
                }
            }
        }
    }
    
    // MARK: - Camera Preview (with orientation fix)
    struct CameraPreview: UIViewRepresentable {
        class VideoPreviewView: UIView {
            override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
            var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
        }
        
        let session: AVCaptureSession
        
        func makeUIView(context: Context) -> VideoPreviewView {
            let view = VideoPreviewView()
            view.videoPreviewLayer.session = session
            view.videoPreviewLayer.videoGravity = .resizeAspectFill
            return view
        }
        
        func updateUIView(_ uiView: VideoPreviewView, context: Context) {
            if let connection = uiView.videoPreviewLayer.connection, connection.isVideoOrientationSupported {
                let orientation = UIDevice.current.orientation
                switch orientation {
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
    }
    
    // MARK: - Recording Delegate
    class CameraRecorderDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {
        static let shared = CameraRecorderDelegate()
        
        func fileOutput(_ output: AVCaptureFileOutput,
                        didFinishRecordingTo outputFileURL: URL,
                        from connections: [AVCaptureConnection],
                        error: Error?) {
            if let error = error {
                print("❌ Recording failed: \(error)")
            } else {
                print("✅ Recording saved: \(outputFileURL.path)")
            }
        }
    }
    #Preview {
        DanceRecorderView()
    }
    
    
}
