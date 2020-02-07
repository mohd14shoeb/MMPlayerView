//
//  PlayerListView.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2019/12/24.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftUI
import MMPlayerView

extension PlayerListView {
    static let listEdge = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}
struct PlayerListView: View {
    let dismiss: (() -> Void)
    @ObservedObject var control: MMPlayerControl
    @ObservedObject var playListViewModel: PlayListViewModel
    @State var showDetailIdx: Int? = nil {
        didSet {
            if let s = self.showDetailIdx {
                if s != self.playListViewModel.currentViewIdx {
                    self.control.invalidate()
                }
                self.playListViewModel.updatePlayView(idx: s)
            }
        }
    }
    @State var topInfo = [CellPlayerFramePreference.Key.Info]() {
        didSet {
            if let new = topInfo.first(where: { $0.frame.origin.y > 0 }), new.idx != self.playListViewModel.currentViewIdx, showDetailIdx == nil {
                self.playListViewModel.updatePlayView(idx: new.idx)
            }
        }
    }

    init(dismiss: @escaping (()->Void)) {
        self.dismiss = dismiss
        let c = MMPlayerControl()
        self.control = c
        playListViewModel = PlayListViewModel(control: c)
    }
    @State var status: PlayerOrientation = .protrait
    @State var fromFrame = CGRect.zero
    var body: some View {
        let objs = playListViewModel.videoList.enumerated().map({ $0 })
        return ZStack {
            if showDetailIdx != nil {
                DetailView(obj: self.playListViewModel.videoList[showDetailIdx!], showDetailIdx: $showDetailIdx)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.playerTransition(view: MMPlayerViewUI(control: control) ,from: fromFrame))
                    .zIndex(1)
            }

            NavigationView {
                List {
                    ForEach(objs, id: \.element.title) { (offset, element) in
                        PlayCellView(player: self.cellPlayerOn(index: offset), obj: element, idx: offset) { rect in
                            withAnimation {
                                self.fromFrame = rect
                                self.showDetailIdx = offset
                            }
                        }
                    }
                    .listRowInsets(PlayerListView.listEdge)
                    }
                .modifier(CellPlayerVisiblePreference(list: Binding<[CellPlayerFramePreference.Key.Info]>(get: {
                    self.topInfo
                }) {
                    self.topInfo = $0
                }))
                .navigationBarConfig(config: { (nav) in
                        nav.navigationBar.barTintColor = UIColor(red: 0/255, green: 77/255, blue: 64/255, alpha: 1.0)
                })
                .navigationBarTitle("Swift UI Demo", displayMode: .inline)
                .alert(item: self.$control.error) { (err) -> Alert in
                        Alert(title: Text("Error"),
                              message: Text(err.localizedDescription),
                            dismissButton: .default(Text("OK"))
                    )
                }
                .navigationBarItems(leading:  Button.init("Dismiss", action: {
                    self.dismiss()
                }))
            }
        }
        .environmentObject(control)

    }
    
    func cellPlayerOn(index: Int) -> MMPlayerViewUI? {
        return index == self.playListViewModel.currentViewIdx && self.showDetailIdx == nil ? MMPlayerViewUI(control: self.control, cover: CoverAUI()) : nil
    }
}

struct PlayerListView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerListView.init {
            
        }
    }
}
