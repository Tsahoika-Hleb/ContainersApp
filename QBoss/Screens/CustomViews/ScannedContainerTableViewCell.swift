import UIKit

private enum LayoutConstants {
    static let inset: CGFloat = 5
    static let labelOffset: CGFloat = 10
    static let imageViewSize: CGFloat = 20
    static let leftImageWidth: CGFloat = 120
}

final class ScannedContainerTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    private lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var scanTimestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont14
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var identifiedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont14
        label.text = S.Screens.Views.ScannedContainerCell.isIdentifiedLabel
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var identifiedTickImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var serialNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont20
        label.textColor = .black
        return label
    }()
    
    private lazy var latitudeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont14
        label.textColor = .black
        return label
    }()
    
    private lazy var longitudeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont14
        label.textColor = .black
        return label
    }()
    
    private lazy var sentToServerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont14
        label.text = S.Screens.Views.ScannedContainerCell.sentToServerLabel
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var sentToServerTickImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setSubviews()
        setConstraints()
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
        backgroundColor = .white
        
        leftImageView.image = leftImage
        scanTimestampLabel.text = scanTimestamp
        serialNumberLabel.text = serialNumber
        latitudeLabel.text = S.Screens.Views.ScannedContainerCell.latitudeLabel + latitude
        longitudeLabel.text = S.Screens.Views.ScannedContainerCell.longitudeLabel + longitude
        
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
    private func setSubviews() {
        contentView.addSubview(leftImageView)
        contentView.addSubview(scanTimestampLabel)
        contentView.addSubview(identifiedLabel)
        contentView.addSubview(identifiedTickImageView)
        contentView.addSubview(serialNumberLabel)
        contentView.addSubview(latitudeLabel)
        contentView.addSubview(longitudeLabel)
        contentView.addSubview(sentToServerLabel)
        contentView.addSubview(sentToServerTickImageView)
    }
    
    private func setConstraints() {
    
        leftImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(LayoutConstants.inset)
            make.width.equalTo(LayoutConstants.leftImageWidth)
        }
        
        scanTimestampLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(LayoutConstants.labelOffset)
            make.leading.equalTo(leftImageView.snp.trailing).offset(LayoutConstants.labelOffset)
        }
        
        identifiedLabel.snp.makeConstraints { make in
            make.leading.equalTo(scanTimestampLabel)
            make.top.equalTo(scanTimestampLabel.snp.bottom).offset(LayoutConstants.labelOffset)
        }
        
        identifiedTickImageView.snp.makeConstraints { make in
            make.centerY.equalTo(identifiedLabel)
            make.leading.equalTo(identifiedLabel.snp.trailing).offset(LayoutConstants.labelOffset / 2)
            make.width.height.equalTo(LayoutConstants.imageViewSize)
        }
        
        serialNumberLabel.snp.makeConstraints { make in
            make.leading.equalTo(scanTimestampLabel)
            make.top.equalTo(identifiedLabel.snp.bottom).offset(LayoutConstants.labelOffset)
        }
        
        latitudeLabel.snp.makeConstraints { make in
            make.leading.equalTo(scanTimestampLabel)
            make.top.equalTo(serialNumberLabel.snp.bottom).offset(LayoutConstants.labelOffset)
        }
        
        longitudeLabel.snp.makeConstraints { make in
            make.top.equalTo(latitudeLabel)
            make.leading.equalTo(latitudeLabel.snp.trailing).offset(LayoutConstants.labelOffset * 1.5)
        }
        
        sentToServerLabel.snp.makeConstraints { make in
            make.leading.equalTo(scanTimestampLabel)
            make.top.equalTo(latitudeLabel.snp.bottom).offset(LayoutConstants.labelOffset)
        }
        
        sentToServerTickImageView.snp.makeConstraints { make in
            make.centerY.equalTo(sentToServerLabel)
            make.leading.equalTo(sentToServerLabel.snp.trailing).offset(LayoutConstants.labelOffset / 2)
            make.width.height.equalTo(LayoutConstants.imageViewSize)
        }
    }
}
