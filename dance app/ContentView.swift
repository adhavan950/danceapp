import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Dance Pose Detection")
                .font(.title)
                .padding()

            Button("Run Pose Detection") {
                if let url = Bundle.main.url(forResource: "gooddance4",withExtension: "mov") {
                    PoseDetector().processVideo(url: url)
                } else {
                    print("Video not found in bundle!")
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}


