//
//  ImageLoader.swift
//  newsApp
//
//  Created by Rishabh on 10/2/20.
//  Copyright © 2020 Rishabh. All rights reserved.
//

import Foundation
import Combine


class ImageLoader: ObservableObject {
    
    // MARK: - Properties
    var dataPublisher = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            dataPublisher.send(data)
        }
    }
    
    // MARK: - Init
    init(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}
