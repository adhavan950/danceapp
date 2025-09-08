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
    @State private var showResult = false
    @State private var isProcessing = false
    
    
    @State private var progress: Double = 0.0
    @State private var timer: Timer? = nil
    @State private var showDanceMessage: Bool = false
    @State private var countdown: Int = 0
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                if isProcessing {
                    ProgressView("Processing...")
                        .font(.title)
                        .padding()
                } else if showResult, let score = score {
                    Text("Dance similarity score: \(String(format: "%.1f", score))")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                } else {
                    HStack(spacing: 0) {
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
                        
                        CameraPreview(session: session)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .scaleEffect(x: 1, y: 4, anchor: .center)
                        .padding(.horizontal)
                    
                    Text("\(Int(progress * 100))% completed")
                        .font(.headline)
                        .padding(.top, 8)
                        
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
            }
         
            if countdown > 0 {
                Color.black.opacity(0.6).ignoresSafeArea()
                Text("\(countdown)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                    .transition(.scale)
            } else if showDanceMessage {
                Color.black.opacity(0.6).ignoresSafeArea()
                Text("DANCE!")
                    .font(.system(size: 60, weight: .heavy))
                    .foregroundColor(.white)
                    .transition(.opacity)
            }
        }
        .onAppear {
            setupCamera()
        }
    }
    

    private func setupCamera() {
        session.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Camera unavailable")
            return
        }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        if let mic = AVCaptureDevice.default(for: .audio),
           let micInput = try? AVCaptureDeviceInput(device: mic),
           session.canAddInput(micInput) {
            session.addInput(micInput)
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            output.stopRecording()
            isRecording = false
            stopProgressUpdates()
        } else {
            startCountdown()
        }
    }
 
    private func startCountdown() {
        countdown = 5
        showDanceMessage = false
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                countdown = 0
                showDanceMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showDanceMessage = false
                    startRecording()
                }
            }
        }
    }

    
   
    private func startRecording() {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let refURL = Bundle.main.url(forResource: "referenceDance", withExtension: "mov") else { return }
        
        let fileURL = documents.appendingPathComponent("userDance.mov")
        try? FileManager.default.removeItem(at: fileURL)
        
        output.startRecording(to: fileURL, recordingDelegate: CameraRecorderDelegate.shared)
        isRecording = true
        progress = 0.0
        
        player?.seek(to: .zero)
        player?.play()
        startProgressUpdates()
        
        if let duration = player?.currentItem?.asset.duration {
            let seconds = CMTimeGetSeconds(duration)
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                if self.isRecording {
                    self.output.stopRecording()
                    self.isRecording = false
                    self.stopProgressUpdates()
                    
                    self.isProcessing = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let comparator = PoseComparator()
                        let result = comparator.compare(referenceURL: refURL, userURL: fileURL)
                        
                        self.score = result
                        self.showResult = true
                        self.isProcessing = false
                    }
                }
            }
        }
    }
    
    private func startProgressUpdates() {
        stopProgressUpdates()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let current = player?.currentTime(), let duration = player?.currentItem?.duration {
                let currentSeconds = CMTimeGetSeconds(current)
                let totalSeconds = CMTimeGetSeconds(duration)
                if totalSeconds > 0 {
                    self.progress = min(currentSeconds / totalSeconds, 1.0)
                }
            }
        }
    }
    
    private func stopProgressUpdates() {
        timer?.invalidate()
        timer = nil
    }
}


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

class CameraRecorderDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {
    static let shared = CameraRecorderDelegate()
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        if let error = error {
            print("Recording failed: \(error)")
        } else {
            print("Recording saved: \(outputFileURL.path)")
        }
    }
}

#Preview {
    DanceRecorderView()
}

