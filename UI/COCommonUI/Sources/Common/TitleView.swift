//
//  TitleView.swift
//  COCommonUI
//
//  Created by Taeyoung Son on 2022/11/05.
//

import UIKit

import FlexLayout

public final class TitleView: FlexLayoutView {
    private let leftBtn = UIButton()
    private let titleLabel = UILabel()
    private let rightInnerBtn = UIButton()
    private let rightOuterBtn = UIButton()
    private var rightBtns: [UIButton] {
        [self.rightInnerBtn, self.rightOuterBtn]
    }
    
    private var leftBtnAction: ButtonAction?
    private var rightInnerBtnAction: ButtonAction?
    private var rightOuterBtnAction: ButtonAction?
    
    public override func setupContainer() {
        super.setupContainer()
        
        self.rootContainer.flex
            .direction(.row)
            .alignItems(.center)
            .define { [weak self] flex in
                guard let self = self else { return }
                
                flex.addItem(self.leftBtn)
                    .marginLeft(28)
                    .width(17).height(20)
                
                flex.addItem(self.titleLabel)
                    .marginLeft(12)
                    .maxWidth(60%)
                
                flex.addItem()
                    .grow(1)
                
                self.rightBtns.enumerated().forEach { offset, btn in
                    flex.addItem(btn)
                        .width(24).height(24)
                        .marginEnd(20)
                }
            }
    }
}

public extension TitleView {
    typealias ButtonAction = (() -> Void)
    
    enum BtnType {
        case back, pin, star, alert, search, menu
        
        var image: UIImage? {
            var img: UIImage?
            switch self {
            case .back: img = COCommonUIAsset.icTitleBack.image
            case .pin: img = COCommonUIAsset.icTitlePin.image
            case .star: img = COCommonUIAsset.icTitleStar.image
            case .alert: img = COCommonUIAsset.icTitleAlert.image
            case .search: img = COCommonUIAsset.icTitleSearch.image
            case .menu: img = COCommonUIAsset.icTitleKebabMenu.image
            }
            return img
        }
    }
}

public extension TitleView {
    @discardableResult func setLeftBtn(type: BtnType, action: ButtonAction? = nil) -> Self {
        self.leftBtn.isHidden = false
        self.leftBtn.setImage(type.image, for: .normal)
        self.leftBtnAction = action
        return self
    }
    
    @discardableResult func setRightInnerBtn(type: BtnType, action: ButtonAction? = nil) -> Self {
        self.rightInnerBtn.isHidden = false
        self.rightInnerBtn.setImage(type.image, for: .normal)
        self.rightInnerBtnAction = action
        return self
    }
    
    @discardableResult func setRightOuterBtn(type: BtnType, action: ButtonAction? = nil) -> Self {
        self.rightOuterBtn.isHidden = false
        self.rightOuterBtn.setImage(type.image, for: .normal)
        self.rightOuterBtnAction = action
        return self
    }
}