#if canImport(AppKit)

import SwiftUI
import Introspect
import InterceptObjC

@available(macOS 10.15.0, *)
public extension View {
  /// Emphasizes selection in a list.
  func listClipInset(_ insets: EdgeInsets) -> some View {
    deepIntrospectTableView {
      guard let clipView = $0.superview as? NSClipView else { return }
      clipView.automaticallyAdjustsContentInsets = false
      clipView.contentInsets = NSEdgeInsets(
        top: insets.top,
        left: insets.leading,
        bottom: insets.bottom,
        right: insets.trailing
      )

      print((#function, type(of: $0), listSubclass))
      if listSubclass == nil {
        let originalClass = type(of: $0)
        let newClassName = "\(originalClass)_Intercept_\(UUID())"
        
        guard let subclass: AnyClass = objc_allocateClassPair(originalClass, newClassName, 0) else {
          print("failed to call objc_allocateClassPair(\(originalClass), \(newClassName), 0)")
          return
        }
        
        objc_registerClassPair(subclass)
        
        print("objc_registerClassPair(): \(originalClass) → \(newClassName)")
        
        listSubclass = subclass
      }
      
      if type(of: $0) != listSubclass, let listSubclass = listSubclass {
        object_setClass($0, listSubclass)
      }
      
      guard let subclass = listSubclass else { fatalError() }
      print(subclass)
      do {
        let selector = #selector(Coordinator.scrollRowToVisible(_:))
        let method = class_getInstanceMethod(Coordinator.self, selector)!
        let implementation = method_getImplementation(method)
        let typeEncoding = method_getTypeEncoding(method)
        if class_getMethodImplementation(subclass, selector) != implementation {
          print("adding \(selector)")
          class_addMethod(subclass, selector, implementation, typeEncoding)
        }
      }
    }
  }
}

// https://github.com/gnustep/libs-gui/blob/98ebe51150ff15162b02eb0dff2b6301e24f8e60/Source/NSTableView.m#L5062-L5097
fileprivate class Coordinator: NSTableView {
  @objc override func scrollRowToVisible(_ row: Int) {
    guard let scrollView = enclosingScrollView else { return }
    guard let clipView = superview as? NSClipView else { return }
    
    // TODO: handle bottom also
    if row == 0 {
      clipView.scroll(to: NSMakePoint(0, clipView.contentInsets.top * -1))
      scrollView.reflectScrolledClipView(clipView)
      return
    }
    
    let rowRect = rect(ofRow: row)
    let visibleRect = self.visibleRect
        
    // If the row is over the top, or it is partially visible
    // on top,
    if rowRect.origin.y < visibleRect.origin.y {
      var newOrigin = NSPoint()
      // newOrigin.x = visibleRect.origin.x
      newOrigin.y = rowRect.origin.y
      newOrigin = convert(newOrigin, to: clipView)
      clipView.scroll(to: newOrigin)
      scrollView.reflectScrolledClipView(clipView)
      return
    }

    // If the row is under the bottom, or it is partially visible on
    // the bottom,
    if NSMaxY(rowRect) > NSMaxY(visibleRect) {
      var newOrigin = NSPoint()
      // newOrigin.x = visibleRect.origin.x
      newOrigin.y = visibleRect.origin.y
      newOrigin.y += NSMaxY(rowRect) - NSMaxY(visibleRect)
      newOrigin = convert(newOrigin, to: clipView)
      clipView.scroll(to: newOrigin)
      scrollView.reflectScrolledClipView(clipView)
      return
    }
  }
}

@available(macOS 10.15.0, *)
struct ListClipInsets_Previews: PreviewProvider {
  static var previews: some View { Preview() }
  
  struct Preview: View {
    @State var selection: Int?
    
    var body: some View {
      VStack {
        List(selection: $selection) {
          ForEach(0..<100) { i in
            Text("Hello, List!").tag(i)
          }
        }
        .border(.blue)
        
        List(selection: $selection) {
          ForEach(0..<100) { i in
            Text("Hello, List!").tag(i)
          }
        }
        .border(.red)
        // .list(emphasizeSelection: true, clipInsets: EdgeInsets(top: -5, leading: 0, bottom: 0, trailing: 0))
        .listClipInset(EdgeInsets(top: -5, leading: 0, bottom: 0, trailing: 0))
        .listSelectionEmphasized()
      }
    }
  }
}

#endif
