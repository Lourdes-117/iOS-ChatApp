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
    
    ///Uploads Picture to firebase storage and returns Url of Image
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        let filePath = "images/\(fileName)"
        storage.child(filePath).putData(data, metadata: nil) { [weak self] (metaData, error) in
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
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToDownload
    }
}
