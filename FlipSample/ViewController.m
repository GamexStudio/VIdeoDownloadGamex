//
//  ViewController.m
//  FlipSample
//
//  Created by TheTiger on 05/05/16.
//  Copyright © 2016 TheTiger. All rights reserved.
//

#import "ViewController.h"
#import "CustomCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController () <NSURLSessionDownloadDelegate, UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tblView;
    NSMutableArray *files;
    NSMutableDictionary *downloaded;
    NSMutableArray *progressValue;
   // int *selectedRow;
}

@property (strong, nonatomic) NSURLSession *globalSession;
@property (nonatomic, assign) int selectedRow;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.globalSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
   
    files = [[NSMutableArray alloc] initWithArray:@[@"http://techslides.com/demos/sample-videos/small.mp4",
                                                   @"http://techslides.com/demos/sample-videos/small.mp4",
                                                   @"http://0.s3.envato.com/h264-video-previews/80fad324-9db4-11e3-bf3d-0050569255a8/490527.mp4",
                                                   @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"]];
    downloaded = [NSMutableDictionary new];
    progressValue = [NSMutableArray new];
    
    for (int i=0; i<[files count]; i++) {
        [progressValue addObject:@0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSURLSessionDownloadTask *)taskForIndex:(NSInteger)index {
    return [downloaded objectForKey:[NSString stringWithFormat:@"%ld", index]];
}

- (void)addTask:(NSURLSessionDownloadTask *)task forIndex:(NSInteger)index {
    [downloaded setObject:task forKey:[NSString stringWithFormat:@"%ld", index]];
}

- (NSInteger)indexForTask:(NSURLSessionDownloadTask *)task {
    NSInteger index = 0;
    NSArray *keys = [downloaded allKeys];
    for (NSString *key in keys) {
        if ([[downloaded objectForKey:key] isEqual:task]) {
            index = [key integerValue];
            break;
        }
    }
    return index;
}

- (void)setProgress:(NSNumber *)progress toCell:(CustomCell *)cell {
    cell.lblProgress.text = [NSString stringWithFormat:@"%@%%", [progress stringValue]];
    
    [cell.progressView setProgress:[progress floatValue] animated:YES];
}

#pragma mark - TableView Delegates & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [files count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.button.tag = indexPath.row;
    
    NSURLSessionDownloadTask *task = [self taskForIndex:indexPath.row];
    if (task) {
        
        if ([task state] == NSURLSessionTaskStateCompleted) {
            // File is downloaded
            [cell.button setTitle:@"Play" forState:UIControlStateNormal];
            [cell.button addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.button.tag = indexPath.row;
            _selectedRow = (int)indexPath.row;
        }
        else if ([task state] ==  NSURLSessionTaskStateRunning){
            
            [cell.button setTitle:@"Pause" forState:UIControlStateNormal];
            [cell.button addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [cell.button setTitle:@"Resume" forState:UIControlStateNormal];
            [cell.button addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    else {
        [cell.button setTitle:@"Download" forState:UIControlStateNormal];
        [cell.button addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self setProgress:progressValue[indexPath.row] toCell:cell];
    
    
    return cell;
}

- (void)playAction:(id)sender {
    
    NSURLSessionDownloadTask *task = [self taskForIndex:[sender tag]];
    if (!task) {
        // No file
        return;
    }

    if ([task state] == NSURLSessionTaskStateCompleted) {
        // Play file here
        
        UIButton *button = (UIButton *)sender;
        
        NSLog(@"Tag Value = %ld",(long)button.tag);
        
        
        NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *videoName = [NSString stringWithFormat:@"video%d.mp4",(int)button.tag];
        NSURL *docsDirURL = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:videoName]];
        NSLog(@"File is saved to =%@",docsDirURL);
        
        [self playVideo:[docsDirURL path]];

        
        
        
    }
    
    [tblView reloadData];
}

- (void)downloadAction:(id)sender {
    
    NSURLSessionDownloadTask *task = [self taskForIndex:[sender tag]];
    if (!task) {
        NSURL *URL = [NSURL URLWithString:files[[sender tag]]];
        task = [self.globalSession downloadTaskWithURL:URL];
        [self addTask:task forIndex:[sender tag]];
    }
    
    if ([task state] == NSURLSessionTaskStateRunning) {
        // Pause
        [task suspend];
    }
    else  {
        // Resume
        
        [task resume];
    }
    
    [tblView reloadData];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      //  NSInteger percentage = (totalBytesWritten * 100)/(totalBytesExpectedToWrite)/100;
        
        CGFloat percentage = (CGFloat)(totalBytesWritten)/(CGFloat)(totalBytesExpectedToWrite);

        NSInteger index = [self indexForTask:downloadTask];
        progressValue[index] = @(percentage);
        // CustomCell *cell = [tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [tblView reloadData];
    }];
}





- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSError *err = nil;
   
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *videoName = [NSString stringWithFormat:@"video%d.mp4",_selectedRow];
    NSURL *docsDirURL = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:videoName]];
    NSLog(@"File is saved to =%@",docsDir);
    if ([fileManager moveItemAtURL:location toURL:docsDirURL error: &err])
    {
        
        NSLog(@"File path is   ----> %@",[docsDirURL path]);
        //[self playVideo:[docsDirURL path]];
        
        
       
    }
    else
    {
        NSLog(@"failed to move: %@",[err userInfo]);
    }
    
    
    
}

-(void)btnopen:(id)sender
{
    
    
    
    
}



- (void) playVideo:(NSString *)fileName
{
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileName];
    
    if (fileExists) {
        
        MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:fileName]];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(movieFinishedCallback:)
         name:MPMoviePlayerPlaybackDidFinishNotification
         object:[playerViewController moviePlayer]];
        
        [self.view addSubview:playerViewController.view];
        
        //play movie
        
        MPMoviePlayerController *player = [playerViewController moviePlayer];
        player.shouldAutoplay = YES;
        player.movieSourceType = MPMovieSourceTypeFile;
        [player play];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Please download the video first" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
}

- (void) movieFinishedCallback:(NSNotification*) aNotification
{
    MPMoviePlayerController *player = [aNotification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    [player stop];
    
    [player.view removeFromSuperview];
}


@end
