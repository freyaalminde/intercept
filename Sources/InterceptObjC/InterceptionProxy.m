#import "InterceptionProxy.h"

@implementation InterceptionProxy

- (instancetype)init {
  return self;
}

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

@end
