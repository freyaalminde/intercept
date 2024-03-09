#if canImport(AppKit)

import SwiftUI
import Introspect
import InterceptObjC

@available(macOS 10.15.0, *)
public extension View {
  func deepIntrospectTableView(customize: @escaping (NSTableView) -> ()) -> some View {
    introspect(selector:  TargetViewSelector.siblingContainingOrAncestorOrAncestorChild, customize: customize)
  }
}

var listSubclass: AnyClass?

@available(macOS 10.15.0, *)
public extension View {
  /// Emphasizes selection in a list.
  func listSelectionEmphasized() -> some View {
    deepIntrospectTableView {
      if listSubclass == nil {
        let originalClass = type(of: $0)
        let newClassName = "\(originalClass)_Intercept_\(UUID())"
        
        guard let subclass: AnyClass = objc_allocateClassPair(originalClass, newClassName, 0) else {
          // print("failed to call objc_allocateClassPair(\(originalClass), \(newClassName), 0)")
          return
        }
        
        objc_registerClassPair(subclass)
        
        // print("objc_registerClassPair(): \(originalClass) → \(newClassName)")
        
        listSubclass = subclass
      }

      if type(of: $0) != listSubclass, let listSubclass = listSubclass {
        object_setClass($0, listSubclass)
      }

      guard let subclass = listSubclass else { fatalError() }
      // print(subclass)
      do {
        let selector = #selector(Coordinator.rowView(atRow:makeIfNecessary:))
        let method = class_getInstanceMethod(Coordinator.self, selector)!
        let implementation = method_getImplementation(method)
        let typeEncoding = method_getTypeEncoding(method)
        if class_getMethodImplementation(subclass, selector) != implementation {
          // print("adding \(selector)")
          class_addMethod(subclass, selector, implementation, typeEncoding)
        }
      }
      
//      do {
//        let selector = #selector(Coordinator.scrollRowToVisible(_:))
//        if class_getInstanceMethod(subclass, selector) == nil {
//          let method = class_getInstanceMethod(Coordinator.self, selector)!
//          let implementation = method_getImplementation(method)
//          let typeEncoding = method_getTypeEncoding(method)
//          class_addMethod(subclass, selector, implementation, typeEncoding)
//        }
//      }
    }
  }
}

fileprivate class Coordinator: NSTableView {
  @objc override func rowView(atRow row: Int, makeIfNecessary: Bool) -> NSTableRowView? {
    let rowView = super.rowView(atRow: row, makeIfNecessary: true)
    rowView?.isEmphasized = true
    DispatchQueue.main.async {
      rowView?.isEmphasized = true
    }
    if rowView == nil {
      // print("rowView is nil")
    }
    return rowView
  }
}

//fileprivate var SubclassKey: UInt8 = 0

//extension NSTableView {
//  var interceptSubclass: AnyClass {
//    get { objc_getAssociatedObject(self, &SubclassKey) as? AnyClass ?? NSObject.self }
//    set { objc_setAssociatedObject(self, &SubclassKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
//  }
//}

@available(macOS 10.15.0, *)
struct ListSelectionEmphasis_Previews: PreviewProvider {
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
        
        List(selection: $selection) {
          ForEach(0..<100) { i in
            Text("Hello, List!").tag(i)
          }
        }
        .listSelectionEmphasized()
        .listClipInset(EdgeInsets(top: -5, leading: 0, bottom: 0, trailing: 0))
      }
    }
  }
}

#endif
