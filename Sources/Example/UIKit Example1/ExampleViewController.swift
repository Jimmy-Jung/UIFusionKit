//
//  ExampleViewController.swift
//
//
//  Created by 정준영 on 2024/6/21.
//

import UIKit
import Combine
import CombineCocoa

final class ExampleViewController: UIViewController {
    
    private var viewModel: ExampleViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(_ viewModel: ExampleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private let textLabel = UILabel()
    private let textButton = UIButton(configuration: .filled())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.send(.viewDidLoad)
        
        setupUI()
        bindInput()
        bindState()
    }
    
    private func setupUI() {
        view.body {
            VStackView(alignment: .center, distribution: .fill) {
                textLabel
                    .font(.systemFont(ofSize: 20, weight: .semibold))
                SpaceView(vertical: 20)
                textButton
            }
        }
        .backgroundColor(.white)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func bindInput() {
        textButton
            .tapPublisher
            .sink(with: self) { owner, output in
                owner.viewModel.send(.buttonTap)
            }
            .store(in: &cancellables)
    }
    
    private func bindState() {
        viewModel
            .$buttonText
            .bind(on: textButton, to: \.title)
            .store(in: &cancellables)
        
        viewModel
            .$buttonColor
            .sink(with: self) { owner, backgroundColor in
                owner.textButton.baseBackgroundColor(backgroundColor)
            }
            .store(in: &cancellables)
        
        viewModel
            .$buttonFrame
            .sink(with: self) { owner, frame in
                owner.textButton.snp.remakeConstraints { make in
                    make.height.equalTo(frame.height ?? 0)
                    make.width.equalTo(frame.width ?? 0)
                }
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    self.view.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)
        
        viewModel
            .$labelText
            .assign(to: \.text, on: textLabel)
            .store(in: &cancellables)
            
        // 오류 처리를 위한 바인딩
        viewModel
            .$activeAlert
            .sink(with: self) { owner, alertType in
                guard let alertType = alertType, case .error(let error) = alertType else { return }
                owner.showErrorAlert(error)
            }
            .store(in: &cancellables)
    }
    
    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "오류",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(iOS 17.0, *)
#Preview {
    ExampleViewController(ExampleViewModel())
}
