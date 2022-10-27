import UIKit

extension GoalMotivationViewController {
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaArray?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as? MediaCell {
            cell.backgroundColor = .gray
            cell.media = mediaArray
            
            if let flag = mediaArray?[indexPath.item].isImage {
            if !flag {
                cell.setupPlayImageView()
            } else {
                cell.removePlayImageView()
            }
            
            }
            cell.imageView.image = UIImage(data: mediaArray?[indexPath.item].collectionViewImage ?? Data())
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
            longGesture.minimumPressDuration = 0.2
            cell.imageView.addGestureRecognizer(longGesture)
            cell.imageView.isUserInteractionEnabled = true
            
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if mediaArray?[indexPath.item].videoURLString.isEmpty ?? true {
            mediaTapped(UIImage(data: mediaArray?[indexPath.item].originalImage ?? Data()) as Any, mediaType: .image)
        } else {
            
            let videoToShow = URL(string: (mediaArray?[indexPath.item].videoURLString)!)
            videoURL = videoToShow
            mediaTapped(videoURL!, mediaType: .video)
        }
        
        
        
    }
    
    
}
