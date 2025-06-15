//
//  CurrencyCrafterViewController.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import UIKit
import Combine

final class CurrencyCrafterViewController: UIViewController {
  private let viewModel: CurrencyCrafterViewModel
  private let padding: CGFloat = 20.0
  // TODO - Add activity indicator to show loader on screen

  init(viewModel: CurrencyCrafterViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private let amountTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Enter amount"
    textField.borderStyle = .roundedRect
    textField.keyboardType = .decimalPad
    textField.translatesAutoresizingMaskIntoConstraints = false
    return textField
  }()

  private lazy var convertButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = .systemBlue
    button.setTitle("Convert Currency", for: .normal)
    button.addTarget(self, action: #selector(convertCurrencyButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private lazy var currencyPicker: UIPickerView = {
    let picker = UIPickerView()
    picker.dataSource = self
    picker.delegate = self
    picker.translatesAutoresizingMaskIntoConstraints = false
    picker.layer.borderWidth = 2
    picker.layer.borderColor = UIColor.black.cgColor
    return picker
  }()

  private let collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    return collectionView
  }()

  enum Section {
    case main
  }

  private lazy var dataSource: UICollectionViewDiffableDataSource<Section, CurrencyConversionResult> = UICollectionViewDiffableDataSource<Section, CurrencyConversionResult>(
    collectionView: self.collectionView,
    cellProvider: { (collectionView, indexPath, model) ->
      UICollectionViewCell? in
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: "cell",
        for: indexPath)

      // Remove any existing subviews to avoid duplication
      cell.contentView.subviews.forEach { $0.removeFromSuperview() }

      cell.contentView.backgroundColor = .gray

      // Create and configure the UILabel
      let label = UILabel(frame: cell.contentView.bounds)
      label.numberOfLines = 0
      label.textAlignment = .center
      label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
      label.textColor = .black
      label.text = "\(model.currency): \(String(format: "%.2f", model.amount))"

      // Add the label to the cell's content view
      cell.contentView.addSubview(label)
      return cell
    }
  )

  private func configureLayout() {
    collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
      let isPhone = layoutEnvironment.traitCollection.userInterfaceIdiom == .phone

      // Define item size with scaling
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(0.48),  // Adjust width for spacing
        heightDimension: .fractionalHeight(1.0)  // Full height within group
      )
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

      // Horizontal group with items (using custom layout approach)
      let itemCount = isPhone ? 3 : 5
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(120)
      )
      let group = NSCollectionLayoutGroup.custom(layoutSize: groupSize) { environment in
        var frames: [NSCollectionLayoutGroupCustomItem] = []
        let totalSpacing = CGFloat(itemCount - 1) * 10
        let itemWidth = (environment.container.contentSize.width - totalSpacing) / CGFloat(itemCount)

        for i in 0..<itemCount {
          let xOffset = CGFloat(i) * (itemWidth + 10)
          let frame = CGRect(x: xOffset, y: 0, width: itemWidth, height: environment.container.contentSize.height)
          frames.append(NSCollectionLayoutGroupCustomItem(frame: frame))
        }
        return frames
      }

      // Section configuration
      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
      section.interGroupSpacing = 10

      return section
    }
  }

  private func applySnapshot(_ rates: [CurrencyConversionResult]) {

    var newSnapshot = NSDiffableDataSourceSnapshot<Section, CurrencyConversionResult>()
    newSnapshot.appendSections([.main])
    newSnapshot.appendItems(rates)

    self.dataSource.apply(newSnapshot, animatingDifferences: true)
  }

  override func loadView() {
    view = UIView()
    view.backgroundColor = .white
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Currency Crafter"
    navigationController?.navigationBar.prefersLargeTitles = true
    setupUI()
    configureLayout()
    bindUI()
    viewModel.fetch()

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tapGesture)
  }

  private func bindUI() {
    viewModel.onLoadExchangeRate = { [weak self] in
      self?.currencyPicker.reloadAllComponents()
    }

    viewModel.onReceivedError = { error in
      // Handle error
      print("Error while fetching Exchange Rate \(error)")
    }
  }
let label = UILabel()
  var subscriptions  = Set<AnyCancellable>()
  func setupSubscription() {
    NotificationCenter.default
      .publisher(for: UITextField.textDidChangeNotification, object: amountTextField)
      .compactMap{($0.object as? UITextField )?.text }
      .assign(to: \.text, on: label)
      .store(in: &subscriptions)

  }
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }

  @objc private func convertCurrencyButtonTapped() {
    calculateAndApplySnapshot()
  }

  private func setupUI() {
    view.addSubview(amountTextField)
    view.addSubview(currencyPicker)
    view.addSubview(collectionView)
    view.addSubview(convertButton)

    NSLayoutConstraint.activate([
      amountTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
      amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),

      convertButton.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 10),
      convertButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      convertButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),

      currencyPicker.topAnchor.constraint(equalTo: convertButton.bottomAnchor, constant: padding),
      currencyPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      currencyPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      currencyPicker.heightAnchor.constraint(equalToConstant: 150),

      collectionView.topAnchor.constraint(equalTo: currencyPicker.bottomAnchor, constant: padding),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate
extension CurrencyCrafterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
  func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return viewModel.pickerData.count
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return viewModel.pickerData[row]
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    calculateAndApplySnapshot()
  }

  private func calculateAndApplySnapshot() {
    view.endEditing(true)

    guard let amountText = amountTextField.text,
      let amount = Double(amountText)
    else {
      return
    }

    let row = currencyPicker.selectedRow(inComponent: 0)
    let selectedCurrency = viewModel.pickerData[row]
    let rates = viewModel.convertRates(amount, selectedCurrency: selectedCurrency)
    applySnapshot(rates)
  }
}
