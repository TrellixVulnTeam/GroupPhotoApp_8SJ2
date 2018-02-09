//
//  ChooseGroupTVC.swift
//  GroupPhoto
//
//  Created by Andrew Burns on 11/27/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Photos
import Firebase
import AVKit
import Cloudinary
import NotificationBannerSwift

class ChooseGroupTVC: UITableViewController {
    
    var assets:[PHAsset]?
    var groups:[Group] = []
    var selectedGroups:[Group] = []
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        print("CURRENT USER", Auth.auth().currentUser?.uid)
        super.viewDidLoad()
        print("ASSETS", self.assets)
//        loadUserGroups()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
//    func loadUserGroups() {
//        if let current = Auth.auth().currentUser?.uid {
//            let ref = Database.database().reference().child("user-groups").child(current)
//            ref.observe(.childAdded, with: { (snapshot) in
//                if snapshot.exists() {
//                    self.getGroupFromKey(key: snapshot.key)
//                }
//            })
//            
//            
//        }
//    }
    
//    func getGroupFromKey(key: String) {
//        let newref = Database.database().reference().child("groups").child(key)
//        newref.observeSingleEvent(of: .value, with: {(snapshot) in
//            if snapshot.exists() {
//                if var data = snapshot.value as? [String:Any] {
//                    data["id"] = snapshot.key
//                    let memberRef = Database.database().reference().child("group-users").child(snapshot.key)
//                    memberRef.observeSingleEvent(of: .value, with: { (snapshot) in
//                        
//                    })
//                    let group = Group()
//                    group.setValuesForKeys(data)
//                    self.groups.append(group)
//                    DispatchQueue.main.async(execute: {
//                        self.tableView.reloadData()
//                    })
//
//                }
//            }
//        })
//        
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groups.count
    }
    
    
    @IBAction func finished(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        let the_groops1 = self.selectedGroups
        for asset in self.assets! {
            print("ASSET BELOW", "_____________________")
            print(asset)
            if (asset.mediaType == PHAssetMediaType.video) {
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                PHCachingImageManager().requestAVAsset(forVideo: asset, options: options) { (asset1, audioMix, args) in
                    let video = asset1
                    let urlThing = video as! AVURLAsset
                    let url = urlThing.url
//                     let storageRef = Storage.storage().reference().child("videos").child(UUID().uuidString+".mp4")

                    let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        
                    // Create a destination URL.
                    let string = randomString(30) + ".mp4"
                    let targetURL = tempDirectoryURL.appendingPathComponent(string)
                    
                    // Copy the file.
                    print(targetURL)
                    do {
                        try FileManager.default.copyItem(at: url, to: targetURL)
                        print(targetURL)
                        
                    } catch let error {
                        NSLog("Unable to copy file: \(error)")
                    }
                    let config = CLDConfiguration(cloudName: "groupphoto", apiKey: "529763434314274", apiSecret: "euZFOHie0ArsDODOl00IwZj9gmE")
                    let params = CLDUploadRequestParams()
                    params.setResourceType(.video)
                    let cloudinary = CLDCloudinary(configuration: config)
                    print(cloudinary)
                    cloudinary.createUploader().signedUpload(url: targetURL, params: params, progress: { (progress) in
                        // progress
                    }, completionHandler: { (result, error) in
//                        print(error)
                        if error == nil {
                        
                        let imageData = UIImagePNGRepresentation(self.thumbnailImageForFileUrl(targetURL)!)!
                        let config = CLDConfiguration(cloudName: "groupphoto", apiKey: "529763434314274", apiSecret: "euZFOHie0ArsDODOl00IwZj9gmE")
                        let cloudinary = CLDCloudinary(configuration: config)
                        print(cloudinary)
                        cloudinary.createUploader().signedUpload(data: imageData, params: nil, progress: { (progress) in
                            // progress
                        }, completionHandler: { (result2, error2) in
                            if error2 == nil {
                                let banner = NotificationBanner(title: "Success", subtitle: "Uploaded", style: .success)
                                banner.autoDismiss = true
                                banner.show(queuePosition: .front)
                                self.setUpVideoRecords(videoRef: (result?.secureUrl)! , thumbRef: (result2?.secureUrl)!, the_groups: self.selectedGroups)
                            } else {
                                let banner = NotificationBanner(title: "Error", subtitle: error.debugDescription, style: .danger)
                                banner.autoDismiss = true
                                banner.show(queuePosition: .front)
                            }
                            
                        })

                            
                            
                        }
                    })
                    
                    //

                    
                    
                    // need to create asset record
                }

            } else if (asset.mediaType == PHAssetMediaType.image) {
                let the_groops = self.selectedGroups
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var image = UIImage()
                option.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
                option.isSynchronous = true
                option.isNetworkAccessAllowed = true
                 let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                print("targetSize", targetSize)
                manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                    print("info", info)
                    
                    image = result!
                })
                print("IMAGE", image)
                print("ASSET", asset)
                let storageRef = Storage.storage().reference().child("images").child(UUID().uuidString+".png") // name this better probably in the group file
                
                if let uploadData = UIImagePNGRepresentation(image) {
                    let config = CLDConfiguration(cloudName: "groupphoto", apiKey: "529763434314274", apiSecret: "euZFOHie0ArsDODOl00IwZj9gmE")
                    let cloudinary = CLDCloudinary(configuration: config)
                    print(cloudinary)
                    let passed_groups = self.selectedGroups
                    let uploader = cloudinary.createUploader().signedUpload(data: uploadData, params: nil, progress: { (progress) in
                        // progress
                    }, completionHandler: { (result, error) in
                        if error == nil {
                            print("IMAGE UPLOADED LETS GO")
                            let banner = NotificationBanner(title: "Success", subtitle: "Uploaded", style: .success)
                            banner.autoDismiss = true
                            banner.show(queuePosition: .front)
                            self.setUpImageRecords(imageRef: (result?.secureUrl)!, the_groups: passed_groups)
                        } else {
                            let banner = NotificationBanner(title: "Error", subtitle: error.debugDescription, style: .danger)
                            banner.autoDismiss = true
                            banner.show(queuePosition: .front)
                        }
    
                    })
                    uploader.resume()
                    
                }
            
            } else {
                print("WTF IS HAPPENING")
                // wat did they upload???
            }
            
        }
        goBack()
        dismiss(animated: false, completion: nil)
    }
    
    func goBack() {
        self.dismiss(animated: true, completion: {
            //        let presenting = self.presentedViewController
            //        let nav = presenting?.navigationController
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func setUpVideoRecords(videoRef: String, thumbRef: String, the_groups: [Group]) {
        let baseRef = Database.database().reference()
        let timestamp:Int = Int(NSDate().timeIntervalSince1970)
//        print("TIMESTAMP FOR VIDEO",timestamp)
        baseRef.child("assets").childByAutoId().updateChildValues(["video_url" : videoRef, "thumbnail_url" : thumbRef, "timestamp" : timestamp], withCompletionBlock: {(err, ref) in
            for group in the_groups {
                
                baseRef.child("group-assets").child(group.id!).updateChildValues([ref.key : 0])
                print("CREATING GROUP ASSET FOR VIDEO")
                self.createUserAssetsForGroup(groupId: group.id!, assetRef: ref.key, groupName: group.name!)
                // now just need 'user-assets' to be able to track views
                

            }
            
        })

    }
    
    func setUpImageRecords(imageRef: String, the_groups: [Group]) {
        let baseRef = Database.database().reference()
        let timestamp:Int = Int(NSDate().timeIntervalSince1970)
//        print("TIMESTAMP FOR IMAGE",timestamp)
//        let saved_groups = the_groups
        print("CREATING ASSET FOR IMAGE!")
        baseRef.child("assets").childByAutoId().updateChildValues(["image_url" : imageRef, "timestamp": timestamp], withCompletionBlock: {(err, ref) in
            // might be error here
//            let num_groups  = "\(saved_groups.count)"
//            let banner = NotificationBanner(title: "Success", subtitle: num_groups , style: .success)
//            banner.autoDismiss = true
//            banner.show(queuePosition: .front)
            print("SELECTED GROUPS ARE",  the_groups)
            
            for group in the_groups {
                // are there even any groups?
                print("CREATING GROUP ASSET FOR IMAGE")
                baseRef.child("group-assets").child(group.id!).updateChildValues([ref.key : 0])
                self.createUserAssetsForGroup(groupId: group.id!, assetRef: ref.key, groupName: group.name!)
                // now just need 'user-assets' to be able to track views
            }
            
        })
    }
    
    func createUserAssetsForGroup(groupId: String, assetRef: String, groupName: String) {
        let ref = Database.database().reference().child("group-users").child(groupId)
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            if let users = snapshot.value as? [String:Any]{
                print("USERS IN GROUP", users)
                for user in users {
                    print("CREATING USER ASSET")
                    let finalRef = Database.database().reference().child("user-assets").child(user.key)
                    finalRef.updateChildValues([assetRef: 0])
                    let userRef = Database.database().reference().child("users").child(user.key)
                    userRef.observeSingleEvent(of: .value, with: { (snapshot4) in
                        if let user_values = snapshot4.value as? [String:Any] {
                            print("CREATED USER VALUES")
                            if let token = user_values["token"] as? String {
                                print("CREATED TOKEN")
                                if token != nil && token != "none"  {
                                    print("SENDING NOTIF")
                                    self.sendNotif(groupName: groupName, user_token: token )
                                    //                                self.dismiss(animated: false, completion: nil)
                                }
                            }
                        }
                    }, withCancel: nil)
                    self.dismiss(animated: false, completion: nil)
                    
                }
            }
            
        })
    }
    
    func sendNotif(groupName: String, user_token: String) {
        var alert = UserDefaults.standard.string(forKey: "username")! + " posted a new photo in " + groupName
        alert = alert.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let string = "https://wingman-notifs.herokuapp.com/send?token=" + user_token + "&alert=" + alert
        
        let url = URL(string: string)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    
                } catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
    }
    
    
    func getUIImage(asset: PHAsset) -> UIImage? {
        
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
    
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }

    fileprivate func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        
        return nil
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChooseGroupCell
        
        cell.group = groups[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // set checkbox to checked and highlight kind of
        print("TEST")
        if let list = tableView.indexPathsForSelectedRows {
            selectedGroups.removeAll()
            for item in list {
                self.selectedGroups.append(self.groups[item.row])
                
            }
            if self.selectedGroups.count > 0 {
                doneButton.isEnabled = true
            } else {
                doneButton.isEnabled = false
            }
        }
        //        print(indexPath)
        //        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let list = tableView.indexPathsForSelectedRows {
            selectedGroups.removeAll()
            for item in list {
                self.selectedGroups.append(self.groups[item.row])
            }
            
            if list.count > 0 {
                doneButton.isEnabled = true
            } else {
                doneButton.isEnabled = false
            }
            
        }
        //        print(indexPath)
        //        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

func randomString(_ length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}
