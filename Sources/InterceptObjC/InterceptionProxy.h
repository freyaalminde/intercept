@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface InterceptionProxy : NSProxy

- (instancetype)init;

@property (weak) id middleDelegate;
@property (weak) id originalDelegate;

@end

NS_ASSUME_NONNULL_END
