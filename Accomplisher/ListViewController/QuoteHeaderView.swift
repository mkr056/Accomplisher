import UIKit

import RealmSwift
class QuoteHeaderView: UICollectionReusableView {
    static var elementKind: String { UICollectionView.elementKindSectionHeader }
    
    static var addQuoteButtonClicked: () -> () = {
        
    }
    
    
    static var goToEditQuote: () -> () = {
        
    }
    
    var quotes: Results<Quote>?
    
    var tap: UITapGestureRecognizer?
    
    var counter: Int = 0 {
        
        didSet {
            if !(quotes?.isEmpty ?? false) {
                quoteLabel.text = quotes?[counter].quoteText
                counterLabel.text = "\(counter + 1)/\(quotes!.count)"
                
            }
            if counter < 0 {
                counter = 0
            }
            
        }
    }
    
    
    private let containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .blue
        return container
    }()
    
    
    
    let quoteLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    
    
    let counterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Quote", for: .normal)
        button.tintColor = .red
        button.addTarget(nil, action: #selector(addQuoteClicked), for: .touchUpInside)
        return button
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareSubviews()
        addGesture()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
  
    
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        if quotes?.isEmpty ?? true {
            quoteLabel.text = "You haven't added any quotes yet\nUse the '+' button to do so!"
            counterLabel.isHidden = true
            addButton.isHidden = false
        } else {
            addButton.isHidden = true
            counterLabel.isHidden = false
            quoteLabel.text = quotes?[counter].quoteText
            counterLabel.text = "\(counter + 1)/\(quotes!.count)"
        }
        
        
        
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 0.1 * containerView.bounds.width
        
        
        quoteLabel.layer.masksToBounds = true
        quoteLabel.layer.cornerRadius = 0.1 * quoteLabel.bounds.width
        
    }
    
    
    private func prepareSubviews() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        containerView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95).isActive = true
        
        containerView.addSubview(quoteLabel)
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        quoteLabel.heightAnchor.constraint(equalTo: quoteLabel.widthAnchor, multiplier: 0.8).isActive = true
        quoteLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        quoteLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        quoteLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.9).isActive = true
        //quoteLabel.backgroundColor = .brown
        
        
        quoteLabel.addSubview(counterLabel)
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        counterLabel.bottomAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: -20).isActive = true
        counterLabel.centerXAnchor.constraint(equalTo: quoteLabel.centerXAnchor).isActive = true
        
        containerView.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.bottomAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: -20).isActive = true
        addButton.centerXAnchor.constraint(equalTo: quoteLabel.centerXAnchor).isActive = true
        
    }
    
    private func addGesture() {
        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerRight.direction = .right
        quoteLabel.addGestureRecognizer(swipeGestureRecognizerRight)
        
        
        let swipeGestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerRight.direction = .left
        quoteLabel.addGestureRecognizer(swipeGestureRecognizerLeft)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(editQuote))
        
        quoteLabel.addGestureRecognizer(tap ?? UITapGestureRecognizer())
        
        
        
        
        
        
        
        
    }
    
    
    
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            prevButtonAction()
        } else {
            nextButtonAction()
        }
        
    }
    
    @objc func prevButtonAction() {
        if quotes?.isEmpty ?? true {
            return
        } else if counter == 0 {
            counter = quotes!.count - 1
        } else {
            counter -= 1
        }
        
        
        
    }
    
    
    @objc func nextButtonAction() {
        if quotes?.isEmpty ?? true {
            return
        } else if counter == quotes!.count - 1 {
            counter = 0
        } else {
            counter += 1
        }
        
        
        
    }
    
    @objc func addQuoteClicked() {
        Self.addQuoteButtonClicked()
        
        
    }
    
    @objc func editQuote(_ sender: UITapGestureRecognizer) {
        Self.goToEditQuote()
    }
    
    
    
    
}




