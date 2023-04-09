import Foundation
import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showMainView = false
    
    var body: some View {
        Group {
            if showMainView {
                MainView()
            } else {
                PresentationView(showMainView: $showMainView)
            }
        }
    }
}

struct PresentationView: View {
    @Binding var showMainView: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Image("presentation_image")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showMainView = true
            }
        }
    }
}

struct ImageItem: Codable {
    let imageUrl: String
    let imageText: String
}

struct MainView: View {
    @StateObject var gameListApiModel = GameListApiModel()
    @State private var isAnimating: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: gameListApiModel.currentImage)
                    .resizable(resizingMode: .stretch)
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: geometry.size.width, height: geometry.size.height)
/*
                AsyncImage(url: URL(string: viewModel.imageUrl)) { image in
                    image
                        .resizable(resizingMode: .stretch)
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                        
                } placeholder: {
                    Color.clear
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
*/
                
                VStack {
                    Spacer()
                    
                    Text(gameListApiModel.currentText)
                        .font(.largeTitle)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .edgesIgnoringSafeArea(.all)
                        .gesture(
                            TapGesture()
                                .onEnded { _ in
                                    if !isAnimating {
                                            isAnimating = true
                                            startAnimationLoop()
                                        }
                                    //gameListApiModel.getRandomImageAndText()
                                }
                        )
                }
            }
        }
    }
    
    func startAnimationLoop() {
        let loopCount = 10 // Number of cycles
        var currentLoop = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            gameListApiModel.getRandomImageAndText()
            currentLoop += 1
            
            if currentLoop >= loopCount {
                timer.invalidate()
                isAnimating = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

