import Foundation
import UIKit

class GameListApiModel: ObservableObject {
    @Published var imageUrl: String = ""
    @Published var imageText: String = "Placeholder"
    @Published private(set) var currentIndex: Int?
    @Published var currentImage: UIImage = UIImage()
    @Published var currentText: String = ""
    
    private var imageItems: [ImageItem] = []
    
    init() {
        fetchImageItems()
    }
    
    func fetchImageItems() {
        let apiUrl = "https://www.danielnavarroymas.com/wp-content/gameapp/test.json?test=5" // Replace with your REST API endpoint

        guard let url = URL(string: apiUrl) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let data = data {
                let decoder = JSONDecoder()
                do {
                    let fetchedImageItems = try decoder.decode([ImageItem].self, from: data)
                    DispatchQueue.main.async {
                        self.imageItems = fetchedImageItems
                        self.downloadAndStoreImages()
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func getRandomImageAndText() {
        if imageItems.isEmpty {
            currentImage = UIImage()
            currentText = "No images available"
        } else {
            
            var randomIndex: Int
            if imageItems.count > 1 {
                repeat {
                    randomIndex = Int.random(in: 0..<imageItems.count)
                } while randomIndex == currentIndex
            } else {
                randomIndex = 0
            }
            currentIndex = randomIndex
            
            let imageInfo = imageItems[randomIndex]

            if let imageUrl = URL(string: imageInfo.imageUrl),
               let documentsDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
               let uiImage = UIImage(contentsOfFile: documentsDirectory.appendingPathComponent(imageUrl.lastPathComponent).path) {
                currentImage = uiImage
                currentText = imageInfo.imageText
            } else {
                currentImage = UIImage()
                currentText = "Image not found"
            }
        }
    }

    func downloadAndStoreImages() {
        for imageInfo in imageItems {
            if let imageUrl = URL(string: imageInfo.imageUrl),
               let documentsDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                let localImagePath = documentsDirectory.appendingPathComponent(imageUrl.lastPathComponent)
                
                // Check if the image file already exists
                if !FileManager.default.fileExists(atPath: localImagePath.path) {
                    // If not, download and save it
                    URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                        if let data = data {
                            try? data.write(to: localImagePath)
                        }
                    }.resume()
                }
            }
        }
    }
    
    func downloadAndStoreImage(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])))
                return
            }
            
            do {
                let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileName = url.lastPathComponent
                let localURL = documentsDirectory.appendingPathComponent(fileName)
                try data.write(to: localURL)
                completion(.success(localURL))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
