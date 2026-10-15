//
//  ViewController.swift
//  FavoritesRoulette
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var spinButton: UIButton!

    private let favorites = Favorite.all
    private var currentIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        styleViews()
        showInitialState()
    }

    @IBAction private func spinTapped(_ sender: UIButton) {
        let index = nextRandomIndex()
        currentIndex = index
        show(favorites[index])
    }

    // MARK: - Private

    private func styleViews() {
        cardView.layer.cornerRadius = 28
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowRadius = 16
        cardView.layer.shadowOffset = CGSize(width: 0, height: 8)

        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true

        spinButton.layer.cornerRadius = 18
        spinButton.clipsToBounds = true
    }

    private func showInitialState() {
        imageView.image = UIImage(named: "Intro")
        titleLabel.text = "What's for dinner?"
        descriptionLabel.text = "Tap Spin to get a random dish from my top 10 favorite foods."
    }

    /// A random index that is never the same as the one shown right now.
    private func nextRandomIndex() -> Int {
        var candidates = Array(favorites.indices)
        if let currentIndex {
            candidates.removeAll { $0 == currentIndex }
        }
        return candidates.randomElement() ?? 0
    }

    private func show(_ favorite: Favorite) {
        UIView.transition(with: cardView, duration: 0.35, options: .transitionFlipFromLeft) {
            self.imageView.image = UIImage(named: favorite.imageName)
            self.titleLabel.text = favorite.title
            self.descriptionLabel.text = favorite.description
        }
    }
}
