//
//  Favorite.swift
//  FavoritesRoulette
//

import Foundation

struct Favorite {
    let title: String
    let description: String
    let imageName: String
}

extension Favorite {
    static let all: [Favorite] = [
        Favorite(
            title: "Beshbarmak",
            description: "Kazakhstan's national dish: tender boiled meat over flat noodles with onion broth. Eaten by hand.",
            imageName: "Beshbarmak"
        ),
        Favorite(
            title: "Plov",
            description: "Rice slow-cooked in a kazan with lamb, yellow carrots, garlic and cumin. Better the next day.",
            imageName: "Plov"
        ),
        Favorite(
            title: "Manti",
            description: "Big steamed dumplings with juicy minced meat and onion. Best with sour cream or chili sauce.",
            imageName: "Manti"
        ),
        Favorite(
            title: "Baursak",
            description: "Golden fried dough, crispy outside and fluffy inside. Always on the table with tea.",
            imageName: "Baursak"
        ),
        Favorite(
            title: "Lagman",
            description: "Hand-pulled noodles with beef, peppers and tomatoes in a rich, slightly spicy sauce.",
            imageName: "Lagman"
        ),
        Favorite(
            title: "Shashlik",
            description: "Marinated lamb skewers grilled over coals, served with raw onion and fresh bread.",
            imageName: "Shashlik"
        ),
        Favorite(
            title: "Pizza Margherita",
            description: "Thin crust, tomato sauce, mozzarella and basil. Simple, classic and impossible to stop eating.",
            imageName: "Pizza"
        ),
        Favorite(
            title: "Sushi",
            description: "Salmon and tuna nigiri with soy sauce and wasabi. Perfect for a light dinner.",
            imageName: "Sushi"
        ),
        Favorite(
            title: "Smash Burger",
            description: "Two crispy beef patties, melted cheddar, pickles and a soft brioche bun.",
            imageName: "Burger"
        ),
        Favorite(
            title: "Pancakes",
            description: "A fluffy stack with butter and maple syrup. The best way to start a weekend.",
            imageName: "Pancakes"
        )
    ]
}
