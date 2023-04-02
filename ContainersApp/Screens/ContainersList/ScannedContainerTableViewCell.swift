//

import UIKit

class ScannedContainerTableViewCell: UITableViewCell {

    // MARK: - Properties
    lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    lazy var scanTimestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    lazy var identifiedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "isIdentified:"
        label.textColor = .darkGray
        return label
    }()
    
    lazy var identifiedTickImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var serialNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    lazy var latitudeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var longitudeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var sentToServerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "sent to server:"
        label.textColor = .darkGray
        return label
    }()
    
    lazy var sentToServerTickImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func setup(leftImage: UIImage?, scanTimestamp: String,
               isIdentified: Bool, serialNumber: String,
               latitude: String, longitude: String,
               sentToServer: Bool)
    {
        leftImageView.image = leftImage
        scanTimestampLabel.text = scanTimestamp
        serialNumberLabel.text = serialNumber
        latitudeLabel.text = "lat: " + latitude
        longitudeLabel.text = "long: " + longitude
        
        if isIdentified {
            identifiedTickImageView.image = UIImage.checkmark
            identifiedTickImageView.tintColor = .systemGreen
        } else {
            identifiedTickImageView.image = UIImage.xmark
            identifiedTickImageView.tintColor = .systemRed
        }
        
        if sentToServer {
            sentToServerTickImageView.image = UIImage.checkmark
            sentToServerTickImageView.tintColor = .systemGreen
        } else {
            sentToServerTickImageView.image = UIImage.xmark
            sentToServerTickImageView.tintColor = .systemRed
        }
    }
    
    // MARK: - Private methods
    private func setupUI() {
        contentView.addSubview(leftImageView)
        contentView.addSubview(scanTimestampLabel)
        contentView.addSubview(identifiedLabel)
        contentView.addSubview(identifiedTickImageView)
        contentView.addSubview(serialNumberLabel)
        contentView.addSubview(latitudeLabel)
        contentView.addSubview(longitudeLabel)
        contentView.addSubview(sentToServerLabel)
        contentView.addSubview(sentToServerTickImageView)
        
        leftImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(5)
            make.width.equalTo(120)
        }
        
        scanTimestampLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
            make.leading.equalTo(leftImageView.snp.trailing).offset(10)
        }
        
        identifiedLabel.snp.makeConstraints { make in
            make.leading.equalTo(scanTimestampLabel)
            make.top.equalTo(scanTimestampLabel.snp.bottom).offset(10)
        }
        
        identifiedTickImageView.snp.makeConstraints { make in
            make.centerY.equalTo(identifiedLabel)
            make.leading.equalTo(identifiedLabel.snp.trailing).offset(5)
            make.width.height.equalTo(20)
        }
        
        serialNumberLabel.snp.makeConstraints { make in
            make.leading.equalTo(scanTimestampLabel)
            make.top.equalTo(identifiedLabel.snp.bottom).offset(10)
        }
        
        latitudeLabel.snp.makeConstraints { make in
            make.leading.equalTo(scanTimestampLabel)
            make.top.equalTo(serialNumberLabel.snp.bottom).offset(10)
        }
        
        longitudeLabel.snp.makeConstraints { make in
            make.top.equalTo(latitudeLabel)
            make.leading.equalTo(latitudeLabel.snp.trailing).offset(15)
        }
        
        sentToServerLabel.snp.makeConstraints { make in
            make.leading.equalTo(scanTimestampLabel)
            make.top.equalTo(latitudeLabel.snp.bottom).offset(10)
        }
        
        sentToServerTickImageView.snp.makeConstraints { make in
            make.centerY.equalTo(sentToServerLabel)
            make.leading.equalTo(sentToServerLabel.snp.trailing).offset(5)
            make.width.height.equalTo(20)
        }
    }
}
