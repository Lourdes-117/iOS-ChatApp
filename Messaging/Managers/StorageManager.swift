//
//  StorageManager.swift
//  Messaging
//
//  Created by Lourdes on 4/27/21.
//

import Foundation
import FirebaseStorage

class StorageManager {
    static let shared = StorageManager()
    
    let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Uploads Picture to firebase storage and returns Url of Image
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        let filePath = "\(StringConstants.shared.storage.profilePicturesPath)\(fileName)"
        uploadImageAtPath(filePath: filePath, imageData: data, completion: completion)
    }
    
    /// Uploads Photo In A Conversation
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        let filePath = "\(StringConstants.shared.storage.messageImagesPath)\(fileName)"
        uploadImageAtPath(filePath: filePath, imageData: data, completion: completion)
    }
    
    /// Upload Video Or File With URL
    public func uploadMessageVideo(with url: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        let filePath = "\(StringConstants.shared.storage.messageVideosPath)\(fileName)"
        uploadVideoWithURL(filePath: filePath, fileURL: url, completion: completion)
    }
    
    /// Get Download URL for a file
    public func downloadUrl(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToDownload))
                return
            }
            completion(.success(url))
        }
    }
    
    /// Upload Image At Given Location
    fileprivate func uploadImageAtPath(filePath: String, imageData: Data, completion: @escaping UploadPictureCompletion) {
        storage.child(filePath).putData(imageData, metadata: nil) { [weak self] (metaData, error) in
            guard error == nil else {
                //failed
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child(filePath).downloadURL { (url, error) in
                guard let url = url else {
                    debugPrint("Failed To Download Image")
                    completion(.failure(StorageErrors.failedToDownload))
                    return
                }
                let urlString = url.absoluteString
                debugPrint("download Url returned \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    fileprivate func uploadVideoWithURL(filePath: String, fileURL: URL, completion: @escaping UploadPictureCompletion) {
        
        storage.child(filePath).putFile(from: fileURL, metadata: nil) { [weak self] _, error in
            guard error == nil else {
                //failed
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child(filePath).downloadURL(completion: { url, error in
                guard let url = url else {
                    debugPrint("Failed To Download Image")
                    completion(.failure(StorageErrors.failedToDownload))
                    return
                }
                let urlString = url.absoluteString
                debugPrint("download Url returned \(urlString)")
                completion(.success(urlString))
            })
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToDownload
    }
}
