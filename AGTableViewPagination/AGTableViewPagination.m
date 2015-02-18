//
//    The MIT License (MIT)
//
//    Copyright (c) 2015 Allgoritm LLC
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//

#import "AGTableViewPagination.h"

#import "WZProtocolInterceptor.h"

@interface AGTableViewPagination () <UITableViewDelegate>

@property (nonatomic, strong) WZProtocolInterceptor* msgRouter;

@end

@implementation AGTableViewPagination

#pragma mark - activity props
- (UIView *) loadingActivityView {
    if (_loadingActivityView == nil) {
        _loadingActivityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        
        UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_loadingActivityView addSubview:aiv];
        
        aiv.translatesAutoresizingMaskIntoConstraints = NO;
        [_loadingActivityView addConstraint:[NSLayoutConstraint constraintWithItem:_loadingActivityView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:0
                                                                            toItem:aiv
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1
                                                                          constant:0]];
        [_loadingActivityView addConstraint:[NSLayoutConstraint constraintWithItem:_loadingActivityView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:0
                                                                            toItem:aiv
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1
                                                                          constant:0]];
        [aiv startAnimating];
    }
    return _loadingActivityView;
}

- (void) setHasMoreToLoad:(BOOL)hasMoreToLoad {
    _hasMoreToLoad = hasMoreToLoad;
    if (self.hasMoreToLoad) {
        self.tableFooterView = self.loadingActivityView;
    }else{
        self.tableFooterView = nil;
    }
}

#pragma mark -
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.msgRouter.receiver respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.msgRouter.receiver scrollViewDidEndDecelerating:scrollView];
    }
    
    if (self.hasMoreToLoad && [self isContentScrolledToBottom]) {
        [self.msgRouter.receiver tableViewDidScrollToNextPage:self];
    }
}

- (BOOL) isContentScrolledToBottom {
    return (self.contentSize.height - self.contentOffset.y - self.bounds.size.height) <= 100;
}

#pragma mark - msg routing
- (WZProtocolInterceptor *) msgRouter {
    if (_msgRouter == nil) {
        self.msgRouter = [[WZProtocolInterceptor alloc] initWithInterceptedProtocol:@protocol(UITableViewDelegate)];
        self.msgRouter.middleMan = self;
    }
    return _msgRouter;
}

- (void) setDelegate:(id<AGTableViewPaginationDelegate>)delegate {
    [super setDelegate:nil];
    self.msgRouter.receiver = delegate;
    [super setDelegate:(id<AGTableViewPaginationDelegate>)self.msgRouter];
}

@end
