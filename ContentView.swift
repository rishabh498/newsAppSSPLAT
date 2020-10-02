//
//  ContentView.swift
//  newsApp
//
//  Created by Rishabh on 10/2/20.
//  Copyright © 2020 Rishabh. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var results = [Article]()
    
    var body: some View {
        VStack {
            List(results, id: \.id) { item in
                NavigationLink(destination: DetailedNewsView(article: item)) {
                    VStack(alignment: .leading) {
                        Text(item.title!)
                            .font(.headline)
                        Text(item.author ?? "Unknown")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }.onAppear(perform: loadData)
        .navigationBarTitle(Text("News"))
        }.embedNavigationView()
    }
    
    func loadData() {
        guard let url = URL(string: topHeadlineURL) else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedRes = try? JSONDecoder().decode(TopHeadline.self, from: data) {
                    
                    DispatchQueue.main.async {
                        self.results = decodedRes.articles!
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
