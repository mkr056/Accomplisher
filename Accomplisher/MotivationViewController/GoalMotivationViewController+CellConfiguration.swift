import UIKit

import RealmSwift



class MediaCell: UICollectionViewCell {
    
    
    var media: Results<Media>?
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
       iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    lazy var playButtonImageView: UIImageView = {
        
        let iv = UIImageView()
        var config = UIImage.SymbolConfiguration(pointSize: imageView.frame.size.width / 1.5)
        let image = UIImage(systemName: "play.fill", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.lightGray.withAlphaComponent(0.7))
        iv.image = image
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    

    
    func setupImageView() {
        addSubview(imageView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
    }
    
    func setupPlayImageView() {
        imageView.addSubview(playButtonImageView)
        
        playButtonImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        playButtonImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

    }
    
    func removePlayImageView() {
        playButtonImageView.removeFromSuperview()
    }
    
    

}






