//
//  PostStudyListCell.swift
//  App
//
//  Created by Kim dohyun on 2022/11/13.
//

import UIKit
import Then
import SnapKit



final class PostStduyListCell: UITableViewCell {
    
    
    //MARK: Property
    
    private let postContainerView: UIView = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 13
        $0.layer.borderColor = UIColor.hexEDEDED.cgColor
        $0.layer.borderWidth = 1
    }
    
    
    private let postStateView: UIView = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 2
    }
    
    private let postStateTitleLabel: UILabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 11, weight: .medium)
        $0.sizeToFit()
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    private let postTitleLabel: UILabel = UILabel().then {
        $0.textColor = .hex141616
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textAlignment = .left
        $0.sizeToFit()
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let postExplanationLabel: UILabel = UILabel().then {
        $0.textColor = .hex141616
        $0.font = .regular(size: 14)
        $0.textAlignment = .left
        $0.sizeToFit()
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let postBookMarkContainerView: UIView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let postBookMarkImageView: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "home_studylist_bookmark")
        $0.contentMode = .scaleToFill
    }
    
    private let postMemberImageView: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "home_studylist_member")
        $0.contentMode = .scaleToFill
    }
    
    private let postMemberLabel: UILabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textAlignment = .left
        $0.textColor = .hex8E8E8E
        $0.sizeToFit()
    }
    
    
    
    //MARK: initalization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Configure
    
    private func configure() {
        postStateView.addSubview(postStateTitleLabel)
        postBookMarkContainerView.addSubview(postBookMarkImageView)
        
        self.contentView.addSubview(postContainerView)
        
        
        _ = [postStateView, postTitleLabel, postExplanationLabel, postMemberImageView, postMemberLabel, postBookMarkContainerView].map {
            postContainerView.addSubview($0)
        }
        
        postContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        postStateView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.left.equalToSuperview().offset(20)
            $0.height.equalTo(18)
            $0.centerY.equalToSuperview()
        }
        
        postStateTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(3)
            $0.width.equalTo(30)
            $0.height.equalTo(12)
            $0.center.equalToSuperview()
        }
        
        postTitleLabel.snp.makeConstraints {
            $0.top.equalTo(postStateView)
            $0.left.equalTo(postStateView.snp.right).offset(10)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(19)
        }
        
        postBookMarkContainerView.snp.makeConstraints {
            $0.top.equalTo(postStateView)
            $0.right.equalToSuperview().offset(-20)
            $0.width.height.equalTo(20)
        }
        
        postBookMarkImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        postExplanationLabel.snp.makeConstraints {
            $0.top.equalTo(postStateView.snp.bottom).offset(8)
            $0.left.equalTo(postStateView)
            $0.height.equalTo(17)
            $0.centerY.equalToSuperview()
        }
        
        postMemberImageView.snp.makeConstraints {
            $0.left.equalTo(postStateView)
            $0.height.width.equalTo(16)
            $0.bottom.equalToSuperview().offset(-14)
        }
        
        postMemberLabel.snp.makeConstraints {
            $0.left.equalTo(postMemberLabel.snp.right).offset(5)
            $0.height.equalTo(14)
            $0.centerY.equalToSuperview()
        }
        
        
        
    }
    
    
}