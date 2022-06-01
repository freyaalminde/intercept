#if canImport(AppKit)

// TODO: Find out if the `intercept_` prefixes are really necessary since this isn’t @objc’d or anything.

import SwiftUI
import Introspect
import InterceptObjC

@available(macOS 10.15.0, *)
public extension View {
  /// Sets an action to perform when a list in this view receive a double-click.
  func onListDoubleClick(perform action: @escaping (NSTableView) -> Void) -> some View {
    deepIntrospectTableView {
      // print((#function, type(of: $0), listSubclass))
      $0.intercept_doubleAction = action
      if $0.intercept_coordinator == nil {
        $0.intercept_coordinator = Coordinator($0.target)
        $0.target = $0.intercept_coordinator!.proxy
      }
    }
  }
}

fileprivate class Coordinator: NSObject {
  private(set) var proxy: InterceptionProxy!
  
  init(_ target: AnyObject?) {
    super.init()
    proxy = InterceptionProxy()
    proxy.middleDelegate = self
    proxy.originalDelegate = target
  }
  
  @objc func onDoubleAction(_ sender: NSTableView?) {
    guard let sender = sender else { return }
    sender.intercept_doubleAction?(sender)
  }
}

fileprivate var DoubleActionKey: UInt8 = 0
fileprivate var CoordinatorKey: UInt8 = 0

fileprivate extension NSTableView {
  var intercept_doubleAction: ((NSTableView) -> Void)? {
    get { objc_getAssociatedObject(self, &DoubleActionKey) as! ((NSTableView) -> Void)? }
    set { objc_setAssociatedObject(self, &DoubleActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }
  
  var intercept_coordinator: Coordinator? {
    get { objc_getAssociatedObject(self, &CoordinatorKey) as! Coordinator? }
    set { objc_setAssociatedObject(self, &CoordinatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }
}

@available(macOS 10.15.0, *)
struct ListDoubleClick_Previews: PreviewProvider {
  static var previews: some View { Preview() }
  
  struct Preview: View {
    @State var selection: Int?
    
    var body: some View {
      VStack {
        List(selection: $selection) {
          Text("Hello, List!").tag(0)
          Text("Hello, List!").tag(1)
          Text("Hello, List!").tag(2)
        }
        
        List(selection: $selection) {
          Text("Hello, List!").tag(0)
          Text("Hello, List!").tag(1)
          Text("Hello, List!").tag(2)
        }
      }
      .onListDoubleClick { sender in
        let alert = NSAlert()
        alert.informativeText = "\(sender.selectedRow)"
        alert.runModal()
      }
    }
  }
}

#endif
