import Foundation
import FirebaseDatabase
import FirebaseStorage
import UIKit

class FirebaseDataAccessManager {
    
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference()

    func addNewUser(UserName: String, UserEmail: String, UserPhoneNum: Int, uid: String) -> Bool {
        
        var Success = true
        
        database.child("Increment").observeSingleEvent(of: .value, with: { snapshot in
            guard let Increment = snapshot.value as? Int else {
                print("Error in Receiving Incrementation number")
                Success = false
                return
            }
            let User: [String: String] = [
                "uid" : uid,
                "UserName" : UserName,
                "UserEmail" : UserEmail,
                "UserPhoneNumber" : String(UserPhoneNum),
                "UserType" : "NULL",
                "UserIconURL" : "NULL",
                "UserBannerURL" : "NULL",
                "UserPictureURL" : "NULL",
                "ProIndustry" : "NULL",
                "ProKeywords" : "NULL",
                "UserBio" : "NULL",
                "URL_ID" : String(Increment)
            ]
            self.database.child(uid).setValue(User)
            self.database.child("Increment").setValue(Increment + 1)
            Success = true
        })
        return Success
    }
    
    func getUserInfo(uid: String, completion: @escaping (_ UserInfo: [String: String]) -> Void) {
        
        print("UID: " + uid)
        database.child(uid).observeSingleEvent(of: .value, with:
            { snapshot in
                guard let UserInfo = snapshot.value as? [String: String] else {
                    print("Error in Receiving some Value")
                    return
            }
            completion(UserInfo)
        })
        print("Im Later!")
    }
    
    func updateUserIcon(URL_ID: String, image: UIImage, completion: @escaping (_ success: Bool, _ url: String) -> Void) {
        guard let imageData = image.pngData() else {
            return
        }
        
        let picRef = storage.child("UserIcon_" + URL_ID + ".png")
        
        picRef.putData(imageData, metadata: nil, completion: {_, UploadError in
                guard UploadError == nil else {
                    print ("Failed to Upload User Icon")
                    completion(false, "Nothing")
                    return
                }
                self.storage.child("UserIcon_" + URL_ID + ".png").downloadURL (completion: { (url, error) in
                    guard let url = url, error == nil else{
                        print("Failed to retrive user icon")
                        return
                }
                
                let urlString = url.absoluteString
                UserDefaults.standard.set(urlString, forKey: "ProfileURL")
                completion(true, urlString)
                })
        })
    }
    
    func updateUserBanner(URL_ID: String, image: UIImage, completion: @escaping (_ success: Bool, _ url: String) -> Void) {
        guard let imageData = image.pngData() else {
            return
        }
        
        let picRef = storage.child("UserBanner_" + URL_ID + ".png")
        
        picRef.putData(imageData, metadata: nil, completion: {_, error in
                guard error == nil else {
                    print ("Failed to Upload User Banner")
                    completion(false, "Nothing")
                    return
                }
            self.storage.child("UserBanner_" + URL_ID + ".png").downloadURL (completion: { (url, error) in
                guard let url = url, error == nil else{
                    print("Failed to retrive user Banner")
                    return
            }
            
            let urlString = url.absoluteString
            UserDefaults.standard.set(urlString, forKey: "BannerURL")
            completion(true, urlString)
            })
        })
    }
    
    func updateUserSetting(uid: String, UserName: String, UserBio: String, UserKeyword: String, completion: @escaping (_ success: Bool) -> Void) {
        
        let UpdateRef = database.child(uid)
        
        UpdateRef.updateChildValues([
            "UserName": UserName,
            "UserBio": UserBio,
            "UserKeywords": UserKeyword,
        ]) { (error, DatabaseRef) in
            if let error = error {
                print("Failed to update User's profile: \(error)")
                completion(false)
            }
            else {
                print("Update Successful")
                completion(true)
            }
        }
    }
    
    func updateUserIconURL(uid: String, url: String) {
        let UpdateRef = database.child(uid)
        
        UpdateRef.updateChildValues([
            "UserIconURL": url
        ]) { (error, DatabaseRef) in
            if let error = error {
                print("Failed to update User's profile: \(error)")
            }
            else {
                print("Update Successful")
            }
        }
    }
    
    func updateUserBannerURL(uid: String, url: String) {
        let UpdateRef = database.child(uid)
        
        UpdateRef.updateChildValues([
            "UserBannerURL": url
        ]) { (error, DatabaseRef) in
            if let error = error {
                print("Failed to update User's Banner: \(error)")
            }
            else {
                print("Update Successful")
            }
        }
    }
    
}


