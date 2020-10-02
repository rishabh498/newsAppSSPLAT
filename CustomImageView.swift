//
//  CustomImageView.swift
//  newsApp
//
//  Created by Rishabh on 10/2/20.
//  Copyright © 2020 Rishabh. All rights reserved.
//

import Combine
import SwiftUI


struct CustomImageView: View {
    
    @ObservedObject var imageLoader: ImageLoader
    @State var image: UIImage = UIImage()
    
    init(withURL url: String) {
        imageLoader = ImageLoader(urlString: url)
    }
    
    var body: some View {
        VStack {
            Image(uiImage: image)
            .resizable()
                .aspectRatio(contentMode: .fill)
//            .frame(width: 55, height: 55)
        }.onReceive(imageLoader.dataPublisher) { data in
            self.image = UIImage(data: data) ?? UIImage()
        }
    }
}
