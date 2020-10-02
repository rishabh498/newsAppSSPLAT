//
//  DetailedNewsView.swift
//  newsApp
//
//  Created by Rishabh on 10/2/20.
//  Copyright © 2020 Rishabh. All rights reserved.
//

import SwiftUI


struct DetailedNewsView: View {
    private let imageHeight: CGFloat = 300
    private let collapsedImageHeight: CGFloat = 75
    
    @ObservedObject private var articleContent: ViewFrame = ViewFrame()
    @State private var titleRect: CGRect = .zero
    @State private var headerImageRect: CGRect = .zero
    @State private var imageName = "heart"
    @State private var imageState = false
    
    var article: Article
    
    func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let sizeOffScreen = imageHeight - collapsedImageHeight
        
        if offset < -sizeOffScreen {
            let imageOffset = abs(min(-sizeOffScreen, offset))
            return imageOffset - sizeOffScreen
        }
        
        if offset > 0 {
            return -offset
            
        }
        
        return 0
    }
    
    func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height
        
        if offset > 0 {
            return imageHeight + offset
        }
        
        return imageHeight
    }
    
    func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).maxY
        
        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height
        
        return blur * 6
    }
    
    private func getHeaderTitleOffset() -> CGFloat {
        let currentYPos = titleRect.midY
        
        
        if currentYPos < headerImageRect.maxY {
            let minYValue: CGFloat = 50.0
            let maxYValue: CGFloat = collapsedImageHeight
            let currentYValue = currentYPos

            let percentage = max(-1, (currentYValue - maxYValue) / (maxYValue - minYValue))
            let finalOffset: CGFloat = -30.0
            return 20 - (percentage * finalOffset)
        }
        
        return .infinity
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        
                        VStack(alignment: .leading) {
                            Text("Article Written By")
                                .foregroundColor(.gray)
                            Text(article.author!)
                                .font(.subheadline)
                        }
                    }
                    
                    Text(article.publishedAt!)
                        .foregroundColor(.gray)
                    
                    Text(article.title!)
                        .font(.headline)
                        .background(GeometryGetter(rect: self.$titleRect)) // 2
                    
                    Text(article.content!)
                        .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                .padding(.top, 16.0)
            }
            .offset(y: imageHeight + 16)
            .background(GeometryGetter(rect: $articleContent.frame))
            
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    CustomImageView(withURL: self.article.urlToImage!)
                        .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))
                        .blur(radius: self.getBlurRadiusForImage(geometry))
                        .clipped()
                        .background(GeometryGetter(rect: self.$headerImageRect))

                    Text(self.article.title!)
                        .offset(x: 0, y: self.getHeaderTitleOffset())
                        .navigationBarItems(trailing: HStack(spacing: 10) {
                            Button(action: {
                                
                                self.imageState.toggle()
                                
                            }) {
                                Image(systemName:self.imageState ? "heart.fill" : "heart")
                                    .resizable()
                                    .font(.body)
                                    .foregroundColor(.red)
                                
                                .frame(width: 20, height: 20)
                            }
                            Button(action: {
                                guard let data = URL(string: self.article.url!) else { return }
                                let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
                            }) {
                                Image(systemName:"square.and.arrow.up")
                                    .resizable()
                                .scaledToFill()
                                    .font(.body)
                                .frame(width: 20, height: 20)
                            }
                        })
                }
                .clipped()
                .offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
            }.frame(height: imageHeight)
            .offset(x: 0, y: -(articleContent.startingRect?.maxY ?? UIScreen.main.bounds.height))
            
            

            
        }
        .edgesIgnoringSafeArea(.all)
    }
}

class ViewFrame: ObservableObject {
    var startingRect: CGRect?
    
    @Published var frame: CGRect {
        willSet {
            if startingRect == nil {
                startingRect = newValue
            }
        }
    }
    
    init() {
        self.frame = .zero
    }
}

struct GeometryGetter: View {
    @Binding var rect: CGRect
    
    var body: some View {
        GeometryReader { geometry in
            AnyView(Color.clear)
                .preference(key: RectanglePreferenceKey.self, value: geometry.frame(in: .global))
        }.onPreferenceChange(RectanglePreferenceKey.self) { (value) in
            self.rect = value
        }
    }
}

struct RectanglePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
