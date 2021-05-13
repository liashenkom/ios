

#import "LBReplayViewer.h"

@implementation LBReplayViewer

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _stopButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [_stopButton setTitle:@"Stop" forState:UIControlStateNormal];
        [_stopButton addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
        _stopButton.frame = CGRectMake(320.0 - 60.0, 480.0 - 60.0, 44.0, 44.0);
    }
    return self;
}

- (void)dealloc
{
    [_movieURL release];
    [_player release];
    [_playerLayer release];
    
    [_stopButton release];
    
    [super dealloc];
}

- (NSURL*)movieURL
{
    return _movieURL;
}

- (void)setMovieURL:(NSURL *)movieURL
{
    if (movieURL == nil)
    {
        NSLog(@"ERROR: nil movieURL parameter");
        
        return;
    }
    
    [_movieURL release];
    _movieURL = [movieURL retain];
    
    if (_player != nil)
    {
        [_player release];
        [_playerLayer release];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    
    _player = [[AVPlayer playerWithURL:movieURL] retain];
    _playerLayer = [[AVPlayerLayer playerLayerWithPlayer:_player] retain];
    _playerLayer.frame = self.frame;
    [self.layer addSublayer:_playerLayer];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      [self performSelectorOnMainThread:@selector(_playerDidPlayToEndTime) withObject:nil waitUntilDone:YES];
                                                  }
     ];
    
    [self addSubview:_stopButton];
}

- (void)play
{
    [_player play];
}

- (void)stop
{
    [_player pause];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(replayViewer:didFinishPlaying:)])
    {
        [self.delegate replayViewer:self didFinishPlaying:NO];
    }
}

- (void)_playerDidPlayToEndTime
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(replayViewer:didFinishPlaying:)])
    {
        [self.delegate replayViewer:self didFinishPlaying:YES];
    }
}

@end
