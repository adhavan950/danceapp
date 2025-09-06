import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var recorder = DanceRecorder()
    
    var body: some View {
        VStack {
            HStack {
                // Left = Reference dance
                ReferenceVideoView(videoName: "dancevid")
                    .frame(width: 180, height: 320)
                
                // Right = User camera
                CameraPreviewView(session: recorder.captureSession)
                    .frame(width: 180, height: 320)
            }
            
            HStack {
                Button("Start Dance") {
                    recorder.startRecording()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Stop Dance") {
                    recorder.stopRecording()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
}
struct CameraPreviewView: UIViewRepresentable {
    var session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct ReferenceVideoView: UIViewRepresentable {
    var videoName: String
    var videoExtension: String = "mov" // default to .mov
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        // Load the video from the app bundle
        if let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) {
            let player = AVPlayer(url: url)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.frame = UIScreen.main.bounds
            view.layer.addSublayer(playerLayer)
            
            // Auto-play the video
            player.play()
        } else {
            print("Error: Could not find video \(videoName).\(videoExtension)")
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
