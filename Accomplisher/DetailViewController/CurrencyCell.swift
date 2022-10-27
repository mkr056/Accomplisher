
import UIKit

class CurrencyCell: UICollectionViewCell {
    
    
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 100, height: 400)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    

    
    func setupLabel() {
        addSubview(label)
        addConstraintsWithFormat(format: "H:|[v0]|", views: label)
        addConstraintsWithFormat(format: "V:|[v0]|", views: label)
    }

    

}







