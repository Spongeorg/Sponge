//
//  BottomSheet.swift
//  connect
//
//  Created by Kim dohyun on 2022/08/30.
//

import UIKit

import Then
import SnapKit
import CODomain
import COExtensions
import COManager
import JTAppleCalendar

public enum BottomSheetType: CustomStringConvertible, Equatable {
    public static func == (lhs: BottomSheetType, rhs: BottomSheetType) -> Bool {
        return lhs.description == rhs.description
    }
    
  public var description: String {
    switch self {
    case .onOffLine:
      return "온/오프라인"
    case .aligment:
      return "정렬"
    case .studyType:
      return "종류"
    case .date:
      return "진행기간"
    case .address:
      return "활동지역"
    case .interest:
      return "관심분야"
    }
  }
  
  case onOffLine
  case aligment
  case studyType
  case date
  case address([BottomSheetItem])
  case interest([BottomSheetItem])
}

public enum BottomSheetHandlerState {
  case confirm(Int, String), date(DateRange), cancel
}

public final class BottomSheet: UIViewController {
  
  private enum Height {
    static let containerView: CGFloat = 490
    static let defaultItem: CGFloat = 38
    static let collectionItem: CGFloat = 42
    static let calendarHeader: CGFloat = 50
  }
  
  private let dimView: UIView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let containerView: UIView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 20
    $0.layer.maskedCorners = CACornerMask(
      arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner
    )
  }
  
  private let titleLabel: UILabel = UILabel().then {
    $0.font = .regular(size: 16)
    $0.textColor = .hex3A3A3A
    $0.textAlignment = .center
    $0.numberOfLines = 1
  }
  
  private lazy var closeButton: UIButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_close"), for: .normal)
    $0.contentMode = .scaleToFill
    $0.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
  }
  
  private lazy var confirmButton: UIButton = UIButton().then {
    $0.setTitle("적용하기", for: .normal)
    $0.setTitleColor(UIColor.white, for: .normal)
    
    $0.backgroundColor = .hex028236
    $0.titleLabel?.font = .medium(size: 16)
    $0.layer.cornerRadius = 5
    $0.clipsToBounds = true
    
    $0.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
  }
  
  private lazy var calendar = JTACMonthView().then {
    $0.minimumLineSpacing = 0
    $0.minimumInteritemSpacing = 0
    $0.allowsRangedSelection = true
    $0.allowsMultipleSelection = true
    $0.scrollingMode = .stopAtEachCalendarFrame
    $0.scrollDirection = .horizontal
    $0.calendarDataSource = self
    $0.calendarDelegate = self
    $0.register(
      CalendarHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: CalendarHeaderView.reuseIdentifier
    )
    $0.register(CalendarDateCell.self, forCellWithReuseIdentifier: CalendarDateCell.reuseIdentifier)
  }
  
  private lazy var collectionViewLayout = UICollectionViewFlowLayout().then {
    
    switch type {
    case .address, .interest:
      $0.itemSize = .init(
        width: (view.bounds.width - 52) / 2,
        height: Height.collectionItem
      )
    default:
      $0.itemSize = .init(
        width: view.bounds.width,
        height: Height.defaultItem
      )
    }
  }
  
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: collectionViewLayout
  ).then {
    $0.register(BottomSheetItemCell.self, forCellWithReuseIdentifier: "BottomSheetItemCell")
    $0.register(BottomSheetListCell.self, forCellWithReuseIdentifier: "BottomSheetListCell")
    $0.delegate = self
    $0.dataSource = self
    $0.contentInset = .init(top: 0, left: 0, bottom: 13, right: 0)
  }
  
  private let type: BottomSheetType
  private var items: [BottomSheetItem] = []
  
  private var dateRange: DateRange = .init()
  
  public var handler: ((BottomSheetHandlerState) -> Void) = { _ in }
  
  public init(type: BottomSheetType) {
    self.type = type
    self.titleLabel.text = type.description
    
    switch type {
    case let .address(items), let .interest(items):
      self.items = items
    default:
      break
    }
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    bindEvent()
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    dimView.backgroundColor = .black.withAlphaComponent(0.5)
  }
  
  @discardableResult
  public func show() -> BottomSheet {
    if let controller = UIApplication.getTopViewController() {
      modalPresentationStyle = .overFullScreen
      controller.present(self, animated: true)
    }
    
    return self
  }
}

private extension BottomSheet {
  
  func configureUI() {
    
    self.view.backgroundColor = .clear
    self.view.addSubview(dimView)
    
    dimView.addSubview(containerView)
    
    let _ = [titleLabel, closeButton, confirmButton].map {
      containerView.addSubview($0)
    }
    
    dimView.snp.makeConstraints {
      $0.top.left.right.bottom.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(20)
      $0.height.equalTo(19)
      $0.centerX.equalToSuperview()
    }
    
    closeButton.snp.makeConstraints {
      $0.top.equalToSuperview().offset(21)
      $0.right.equalToSuperview().inset(20)
      $0.width.height.equalTo(18)
    }
    
    if case .date = type {
      containerView.addSubview(calendar)
      calendar.snp.makeConstraints {
        $0.top.equalTo(titleLabel.snp.bottom).offset(24)
        $0.leading.equalToSuperview().offset(20)
        $0.trailing.equalToSuperview().inset(20)
        $0.bottom.equalTo(confirmButton.snp.top).offset(-13)
      }
    } else {
      containerView.addSubview(collectionView)
      collectionView.snp.makeConstraints {
        $0.top.equalTo(titleLabel.snp.bottom).offset(24)
        $0.leading.equalToSuperview().offset(20)
        $0.trailing.equalToSuperview().inset(20)
        $0.bottom.equalTo(confirmButton.snp.top).offset(-13)
      }
    }
    
    confirmButton.snp.makeConstraints {
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
      $0.bottom.equalToSuperview().offset(-24)
      $0.height.equalTo(41)
    }
    
    containerView.snp.makeConstraints {
      $0.bottom.left.right.equalToSuperview()
      $0.height.equalTo(Height.containerView)
    }
  }
  
  func bindEvent() {
    let tapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(didTapDimView)
    )
    tapGesture.delegate = self
    dimView.addGestureRecognizer(tapGesture)
  }
  
  @objc func didTapDimView() {
    dimView.backgroundColor = .clear
    
    dismiss(animated: true)
  }
  
  @objc func didTapCloseButton() {
    dimView.backgroundColor = .clear
    
    dismiss(animated: true)
  }
  
  @objc func didTapConfirmButton() {
    
    switch type {
    case .date:
      if (dateRange.start == nil || dateRange.end == nil) || (dateRange.start == dateRange.end) {
        CommonAlert.shared
          .setMessage(.message("\(type.description)를(을) 선택해주세요."))
          .show()
        return
      }
      
      dimView.backgroundColor = .clear
      
      dismiss(animated: true) { [weak self] in
        guard let self = self else { return }
        self.handler(.date(self.dateRange))
      }
      
    default:
      let selectedIndex = self.items.enumerated()
        .map { offset, element in
          return element.isSelected ? offset : -1
        }
        .filter { $0 != -1 }
        .first
      
      guard let selectedIndex = selectedIndex else {
        CommonAlert.shared
          .setMessage(.message("\(type.description)를(을) 선택해주세요."))
          .show()
        return
      }
      
      dimView.backgroundColor = .clear
      
      dismiss(animated: true) { [weak self] in
        guard let self = self else { return }
        self.handler(
          .confirm(selectedIndex, self.items[safe: selectedIndex]?.value ?? "")
        )
      }
    }
  }
}

extension BottomSheet: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomSheetItemCell", for: indexPath) as? BottomSheetItemCell {
      let item = items[indexPath.item]
      
      cell.setup(title: item.value, isSelected: item.isSelected)
      return cell
    }
    
    return UICollectionViewCell()
  }
}

extension BottomSheet: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    if items[indexPath.item].isSelected == true {
      return
    }
    
    let _ = self.items.indices.map { offset in
      items[offset].update(isSelected: false)
    }
    
    items[indexPath.item].update(isSelected: true)
    
    collectionView.reloadData()
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 12
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 8
  }
}

extension BottomSheet: UIGestureRecognizerDelegate {
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return touch.view == dimView
  }
}

// MARK: JTAppleCalendar
private extension BottomSheet {
  func configureCell(view: JTACDayCell?, cellState: CellState) {
    guard let cell = view as? CalendarDateCell  else { return }
    cell.setup(title: cellState.text)
    handleCellTextColor(cell: cell, cellState: cellState)
    handleCellSelected(cell: cell, cellState: cellState)
  }
  
  func handleCellTextColor(cell: CalendarDateCell, cellState: CellState) {
    if cellState.dateBelongsTo == .thisMonth {
      cell.updateTextColor(state: .normal)
    } else {
      cell.updateTextColor(state: .notThisMonth)
    }
  }
  
  func handleCellSelected(cell: CalendarDateCell, cellState: CellState) {
    cell.updateSelectedView(cellState: cellState)
  }
}

extension BottomSheet: JTACMonthViewDataSource {
  public func configureCalendar(_ calendar: JTAppleCalendar.JTACMonthView) -> JTAppleCalendar.ConfigurationParameters {
    let today = Date().toDate()
    let endDate = today.afterDate(year: 2).toDate()
    return ConfigurationParameters(startDate: today, endDate: endDate)
  }
}

extension BottomSheet: JTACMonthViewDelegate {
  public func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
    
    if let startDate = dateRange.start, let endDate = dateRange.end {
      if startDate.compare(date) == .orderedDescending {
        dateRange.start = date
      } else if endDate.compare(date) == .orderedAscending {
        dateRange.end = date
      }
    } else {
      dateRange.start = date
      dateRange.end = date
    }
    
    if let startDate = dateRange.start, let endDate = dateRange.end {
      calendar.selectDates(
        from: startDate,
        to: endDate,
        triggerSelectionDelegate: false,
        keepSelectionIfMultiSelectionAllowed: true
      )
    }
    
    configureCell(view: cell, cellState: cellState)
  }
  
  public func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
    
    guard let startDate = dateRange.start,
          let endDate = dateRange.end else { return }
    
    if startDate == date && endDate == date {
      dateRange.start = nil
      dateRange.end = nil
    } else if dateRange.start == date {
      dateRange.start = endDate
    } else if dateRange.end == date {
      dateRange.end = startDate
    } else {
      guard let startDay = Calendar.current.dateComponents([.day], from: startDate, to: date).day,
            let endDay = Calendar.current.dateComponents([.day], from: date, to: endDate).day else { return }
      if startDay < endDay {
        dateRange.start = date
      } else {
        dateRange.end = date
      }
    }
    
    calendar.deselectAllDates(triggerSelectionDelegate: false)
    
    if let startDate = dateRange.start, let endDate = dateRange.end {
      calendar.selectDates(
        from: startDate,
        to: endDate,
        triggerSelectionDelegate: false,
        keepSelectionIfMultiSelectionAllowed: true
      )
    }
    
    configureCell(view: cell, cellState: cellState)
  }
  
  public func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
    if let header = calendar.dequeueReusableJTAppleSupplementaryView(
      withReuseIdentifier: CalendarHeaderView.reuseIdentifier,
      for: indexPath
    ) as? CalendarHeaderView {
      header.setup(title: range.start.toFormattedString(dateFormat: "yyyy년 MM월"))
      return header
    }
    
    return .init()
  }
  
  public func calendar(_ calendar: JTAppleCalendar.JTACMonthView, willDisplay cell: JTAppleCalendar.JTACDayCell, forItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) {
    configureCell(view: cell, cellState: cellState)
  }
  
  public func calendar(_ calendar: JTAppleCalendar.JTACMonthView, cellForItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) -> JTAppleCalendar.JTACDayCell {
    if let cell = calendar.dequeueReusableJTAppleCell(
      withReuseIdentifier: CalendarDateCell.reuseIdentifier,
      for: indexPath
    ) as? CalendarDateCell {
      self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
      return cell
    }
    
    return .init()
  }
  
  public func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
    return .init(defaultSize: Height.calendarHeader)
  }
}
