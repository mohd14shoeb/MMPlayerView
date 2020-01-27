//
//  MMPlayerView.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/24.
//

import SwiftUI
import AVFoundation
@available(iOS 13.0.0, *)
struct MMPlayerViewBridge: UIViewRepresentable {
    @EnvironmentObject var control: MMPlayerControl

    public func updateUIView(_ uiView: MMPlayerContainer, context: UIViewRepresentableContext<MMPlayerViewBridge>) {
    }
    static func dismantleUIView(_ uiView: MMPlayerContainer, coordinator: MMPlayerViewBridge.Coordinator) {
        uiView.playerLayer.player = nil
    }
    public func makeUIView(context: Context) -> MMPlayerContainer {
        return MMPlayerContainer(player: control.player)
    }
}

@available(iOS 13.0.0, *)
public struct MMPlayerViewUI: View {
    @ObservedObject private var control: MMPlayerControl
    let progress: AnyView?
    let cover: AnyView?
    @State var r: CGRect = .zero
    public var body: some View {
        return ZStack {
            MMPlayerViewBridge()
            self.cover?
                .opacity(self.control.isCoverShow ? 1.0 : 0.0)
                .animation(.easeOut(duration: control.coverAnimationInterval))
            self.progress
        }
            
        .gesture(self.coverTapGesture(), including: .all)
        .environmentObject(control)
        .modifier(GlobalFramePreference())
    }

    private func coverTapGesture() -> _EndedGesture<TapGesture> {
        return TapGesture().onEnded { (_) in
            self.control.coverViewGestureHandle()
        }
    }
}

extension MMPlayerViewUI {
    public init<P: View>(progress: P, control: MMPlayerControl) {
        self.init(pView: AnyView(progress), cView: nil, control: control)
    }

    public init<C: View>(cover: C, control: MMPlayerControl) {
        self.init(pView: AnyView(DefaultIndicator()), cView: AnyView(cover), control: control)
    }

    public init<P: View,C: View>(progress: P, cover: C, control: MMPlayerControl) {
        self.init(pView: AnyView(progress), cView: AnyView(cover), control: control)
    }
    
    public init(control: MMPlayerControl) {
        self.init(pView: AnyView(DefaultIndicator()), cView: nil, control: control)
    }

    init(pView: AnyView? = AnyView(DefaultIndicator()), cView: AnyView? = nil, control: MMPlayerControl) {
        self.progress = pView
        self.cover = cView
        self.control = control
    }
}
