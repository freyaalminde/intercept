# Intercept for SwiftUI

Intercept is a collection of extensions for SwiftUI that enable subtle yet important features.

It’s meant to be used in conjuction with [Introspect for SwiftUI](https://github.com/siteline/SwiftUI-Introspect), hence the name.


## Installation

```swift
.package(url: "https://github.com/freyaariel/intercept.git", branch: "main"),
```

```swift
.product(name: "Intercept", package: "intercept"),
```


## Overview

### List Clip Inset for macOS

`.listClipInset` insets the list view’s clip view by the specified insets.

`objc_allocateClassPair()` is used for this.

```swift
List(selection: $selection) {
  // …
  // …
  // …
}
.listClipInset(EdgeInsets(top: -5, leading: 0, bottom: 0, trailing: 0))
```

Due to an unfortunate side effect which makes the inset jump when the list first appears, it’s recommended you hide your list, or the window containing it, for a single run loop iteration.  


#### Alternatives Considered

Why not use a negative padding, you might ask? Well, that could sort of work, but it messes up keyboard navigation.


### List Double-Clicking for macOS

`.onListDoubleClick` intercepts `NSTableView`’s `doubleAction` target-action invocation for `List` on macOS.

`InterceptionProxy` is used for this.

```swift
List(selection: $selection) {
  // …
  // …
  // …
}
.onListDoubleClick { sender in
  print(sender.selectedRow)
}
```


#### Alternatives Considered

Why not use `.onTapGesture(count: 2)`, you might ask? Well, it doesn’t reach all the way to the edge of the rows.


### List Selection Emphasis for macOS

`.listSelectionEmphasized` sets `NSTableRowView`’s `isEmphasized` to true.

`objc_allocateClassPair()` is used for this.

```swift
List(selection: $selection) {
  // …
  // …
  // …
}
.listSelectionEmphasized()
```


#### Alternatives Considered

Why not simply draw an emphasized selection yourself, you might ask? Well, that doesn’t work 100%, as there’s no `isSelected` environment value in SwiftUI, and the selection binding in lists are not updated while the mouse is down.  


### Interception Proxy

`InterceptionProxy` is like a [meddler-in-the-middle attack](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) for Swift and Objective-C.

It’s an `NSProxy` subclass which allows you to override the behavior of existing methods.

Since `NSInvocation` and its related APIs are unavailable in Swift, the proxy is implemented in Objective-C. 

```objc
- (void)forwardInvocation:(NSInvocation *)invocation {
  NSAssert(self.middleDelegate != self.originalDelegate, @"delegates should be unique");
  
  if ([self.middleDelegate respondsToSelector:invocation.selector]) {
    [invocation invokeWithTarget:self.middleDelegate];
  } else if ([self.originalDelegate respondsToSelector:invocation.selector]) {
    [invocation invokeWithTarget:self.originalDelegate];
  }
}

- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  id result = [self.middleDelegate methodSignatureForSelector:sel];

  if (!result) {
    result = [self.originalDelegate methodSignatureForSelector:sel];
  }

  return result;
}
```

