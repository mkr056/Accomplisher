//
//  GoalMotivationViewController.swift
//  Accomplisher
//
//  Created by Artem Mkr on 18.08.2022.
//

import AVKit
import UIKit
import MediaPlayer
import RealmSwift
import Photos


class GoalMotivationViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, AVPlayerViewControllerDelegate, UIViewControllerTransitioningDelegate {
    
    let realm = try! Realm()
    var mediaArray: Results<Media>?
    
    var selectedGoal: Goal? {
        didSet {
            loadMedia()
        }
    }
    
    
    
    var indexPathOfSelectedMedia: IndexPath?
    var selectedImage: UIImage? // to update the collection view
    
    var videoURL: URL?
    
    
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        loadMedia()
        setupCollectionView()
        self.navigationItem.title = "Motivation Corner"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewMedia))
    }
    
    func loadMedia() {
        mediaArray = selectedGoal?.files.sorted(byKeyPath: "date", ascending: false)
        collectionView.reloadData()
    }
    
    func setupCollectionView() {
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(MediaCell.self, forCellWithReuseIdentifier: "cellId")
    }
    
    @objc func addNewMedia() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.videoExportPreset = AVAssetExportPresetPassthrough
        //picker.videoQuality = .typeHigh
        picker.mediaTypes = ["public.image", "public.movie"]
        present(picker, animated: true)
        
    }
    
    func requestAuthorization(completion: @escaping ()->Void) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                    completion()
                
            }
        } else if PHPhotoLibrary.authorizationStatus() == .authorized{
            completion()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let newMedia = Media()
        
        guard let currentGoal = selectedGoal else { return }
        if let editedImage = info[.editedImage] as? UIImage {
            if let originalImage = info[.originalImage] as? UIImage {
                do {
                    try realm.write({
                        let editedImageData = editedImage.jpegData(compressionQuality: 1.0)!
                        newMedia.collectionViewImage = editedImageData
                        newMedia.originalImage = originalImage.jpegData(compressionQuality: 1.0)!
                        newMedia.isImage = true
                        currentGoal.files.append(newMedia)
                    })
                } catch {
                    print("Error saving new image, \(error)")
                }
            }
            selectedImage = editedImage
            
        } else if let videoURL = info[.mediaURL] as? URL {
            selectedImage = videoURL.makeThumbnail()
            do {
                try realm.write({
                    
                    let videoName = UUID().uuidString
                    let videoPath = getDocumentsDirectory().appendingPathComponent("\(videoName).MOV")
                    
                    print(videoPath.absoluteString)
                    
                    newMedia.videoURLString = videoPath.absoluteString // defining reference for the video in documents folder
                    newMedia.isImage = false
                    let videoData = try Data(contentsOf: videoURL)
                    try videoData.write(to: videoPath)
                    
                    newMedia.collectionViewImage = (selectedImage?.jpegData(compressionQuality: 0.0))!
                    currentGoal.files.append(newMedia)
    
                })
            } catch {
                print("Error saving new video, \(error)")
                
            }
            selectedGoal?.image.insert(selectedImage ?? UIImage(), at: 0)
   
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.reloadItems(at: [indexPath])
        dismiss(animated: true)
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
   
    func mediaTapped(_ sender: Any, mediaType: SelectedMediaType) {
        switch mediaType {
        case .image:
            if let sender = sender as? UIImage {
                
                let newImageView = UIImageView(image: sender)
                newImageView.frame = UIScreen.main.bounds
                newImageView.backgroundColor = .label
                newImageView.contentMode = .scaleAspectFit
                newImageView.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
                newImageView.addGestureRecognizer(tap)
                self.view.addSubview(newImageView)
                self.navigationController?.isNavigationBarHidden = true
                self.tabBarController?.tabBar.isHidden = true
            }
        case .video:
            playVideo(videoUrl: videoURL ?? URL(fileURLWithPath: ""))
        }
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    @objc func playVideo(videoUrl: URL) {
        
        let player = AVPlayer(url: videoURL!)
        let playerVc = AVPlayerViewController()
        playerVc.delegate = self
        playerVc.player = player
        playerVc.player?.actionAtItemEnd = .none
        self.present(playerVc, animated: true) {
            playerVc.player?.play()
        }
        
        
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false // this becomes nil when playing video, thats why does not work
        
        // you can fetch when video ended
        NotificationCenter.default.addObserver(self, selector: #selector(animationDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        
    }
    
    @objc func animationDidFinish(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: .zero, completionHandler: nil)
        }
    }
    
    
    @objc func longTap(sender: UIGestureRecognizer) {
        var timer = Timer()
        let selectedMedia = sender.view as? UIImageView
        let cell = selectedMedia?.superview as? MediaCell
        indexPathOfSelectedMedia = collectionView?.indexPath(for: cell ?? UICollectionViewCell())
        
        if sender.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(showAlert), userInfo: nil, repeats: false)
        }
        
        if sender.state == .ended {
            timer.invalidate()
        }
        
        
    }
    
    @objc func showAlert() {
        let ac = UIAlertController(title: "Choose action", message: "What do you want to do with this asset?", preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: saveToLibrary))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: deleteMedia))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func saveToLibrary(alert: UIAlertAction) {
        if mediaArray?[indexPathOfSelectedMedia!.item].videoURLString.isEmpty ?? true {
            if let image = UIImage(data: (mediaArray?[indexPathOfSelectedMedia!.item].originalImage)!) {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        } else {
            videoURL  = URL(string: (mediaArray?[indexPathOfSelectedMedia!.item].videoURLString)!)
            if let videoURL = videoURL {
                saveVideo(videoURL) { error in print(error?.localizedDescription as Any) }
                
            }
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func saveVideo(_ outputURL: URL, _ completion: ((Error?) -> Void)?) {
        requestAuthorization {
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .video, fileURL: outputURL, options: nil)
            }) { (result, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Saved successfully")
                    }
                    completion?(error)
                }
            }
        }
    }
    
    
    func deleteMedia(alert: UIAlertAction) {
           do {
               try realm.write {
                   if !(mediaArray?[indexPathOfSelectedMedia!.item].isImage)! {
                   let videoPath = (mediaArray?[indexPathOfSelectedMedia!.item].videoURLString)!
                   try? FileManager.default.removeItem(at: URL(string: videoPath)!)

                   }

                   realm.delete((mediaArray?[indexPathOfSelectedMedia!.item])!)
               }
           } catch {
               print("Error deleting media, \(error)")

       }
        collectionView.reloadData()

    }
    
   

}





extension URL {
    func makeThumbnail() -> UIImage? {
        do {
            let asset: AVURLAsset = AVURLAsset(url: self, options: nil)
            let imgGenerator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage: CGImage = try imgGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
        
            let uiImage: UIImage = UIImage(cgImage: cgImage)
            return uiImage
        } catch {
            print("Error generating thumbnail: \(error)")
        }
        return nil
    }
    
   
    
}


enum SelectedMediaType {
    case image, video
}









