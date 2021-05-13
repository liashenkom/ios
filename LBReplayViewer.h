

#import <UIKit/UIKit.h>

@class LBReplayViewer;

@protocol LBReplayViewerDelegate <NSObject>
@required
- (void)replayViewer:(LBReplayViewer*)replayViewer didFinishPlaying:(BOOL)succeeded;

@end

@interface LBReplayViewer : UIView
{
    AVPlayer*                               _player;
    AVPlayerLayer*                          _playerLayer;
    
    NSURL*                                  _movieURL;
    
    id<LBReplayViewerDelegate>              _delegate;
    
    UIButton*                               _stopButton;
}

@property(assign)   id<LBReplayViewerDelegate>  delegate;
@property(assign)   NSURL*                      movieURL;

- (void)play;
- (void)stop;

@end
