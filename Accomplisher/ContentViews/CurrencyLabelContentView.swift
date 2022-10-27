import UIKit
import RealmSwift


class CurrencyLabelContentView: UIView, UIContentView {
    struct Configuration: UIContentConfiguration {

        var text: String? = ""
        var onChange: (String)->Void = { _ in } // holds the behaviour that you'd like to perform when the user edits the text in the text field
        
        func makeContentView() -> UIView & UIContentView {
            return CurrencyLabelContentView(self)
        }
         static var action: () -> () = {
            
        }
    }
    
    let realm = try! Realm()

    let label = UILabel()
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        }
    }
    
    
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        addPinnedSubview(label, insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

 
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        label.text = configuration.text
    }
    
    @objc private func didChange(_ sender: UILabel) { // this method is triggered when the user changes the text in the field
        do {
            try realm.write {
                guard let configuration = configuration as? CurrencyLabelContentView.Configuration else { return }
                configuration.onChange(label.text ?? "")
                
            }
            
        } catch {
            print("Error updating title currency text \(error)")
        }
      
    }
}

extension UICollectionViewListCell {
    func labelConfiguration() -> CurrencyLabelContentView.Configuration {
        CurrencyLabelContentView.Configuration()
    }
}

