//
//  ReactorViewController.swift
//
//
//  Created by 정준영 on 2024/6/21.
//

import UIKit
import Combine

public final class ReactorViewController: UIViewController {
    
    typealias ViewModel = ReactorViewModel
    private var viewModel: any ViewModel
    private var cancellables = Set<AnyCancellable>()
    public init(_ viewModel: any ReactorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.input.send(.viewDidLoad)
        view.body {
            VStackView(alignment: .center, distribution: .fill) {
                UILabel()
                    .tag(1)
                    .text(viewModel.output.$labelText)
                SpaceView(vertical: 20)
                UIButton(configuration: .filled())
                    .tag(2)
                    .title(viewModel.output.$buttonText)
                    .baseBackgroundColor(viewModel.output.$buttonColor)
                    .frame(height: viewModel.output.buttonFrame.height)
                    .addAction { [weak self] button in
                        self?.viewModel.input.send(.buttonTap)
                    }
            }
        }
        .backgroundColor(.white)
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bind()
    }
    
    private func bind() {
        viewModel
            .output
            .$buttonFrame
            .sink { [weak self] frame in
                guard let self else { return }
                view.viewWithTag(2)?.snp.remakeConstraints { make in
                    make.height.equalTo(frame.height ?? 0)
                }
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        setupBackground()
    }
    
    private func setupBackground() {
        
    }
    
    private func setupLayout() {
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(iOS 17.0, *)
#Preview {
    ReactorViewController(DefaultReactorViewModel())
}
