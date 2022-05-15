# Intercept for SwiftUI

Intercept is a collection of extensions for SwiftUI that enable features which are not yet natively supported.


## Installation

```swift
.package(url: "https://github.com/freyaariel/intercept.git", branch: "main"),
```

```swift
.product(name: "Intercept", package: "intercept"),
```


## Overview

### List Clip Inset for macOS

```swift
List(selection: $selection) {
  // …
  // …
  // …
}
.listClipInset(EdgeInsets(top: -5, leading: 0, bottom: 0, trailing: 0))
```


### List Double-Clicking for macOS

`.onListDoubleClick` intercepts `NSTableView`’s `doubleAction` target-action invocation for `List` on macOS. `NSProxy` is used for this.

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


### List Selection Emphasis for macOS

`.listSelectionEmphasized` sets `NSTableRowView`’s `isEmphasized` to true. `objc_allocateClassPair()` is used for this.

```swift
List(selection: $selection) {
  // …
  // …
  // …
}
.listSelectionEmphasized()
```


### Interception Proxy

`InterceptionProxy` is like a [meddler-in-the-middle attack](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) but for Swift and Objective-C.

It’s an `NSProxy` subclass which delegates calls between a `middleDelegate` and an `originalDelegate`.

`InterceptionProxy` is implemented in Objective-C due to `NSProxy` being unavailable in Swift. 

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

