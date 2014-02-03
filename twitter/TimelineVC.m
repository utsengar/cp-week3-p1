//
//  TimelineVC.m
//  twitter
//
//  Created by Timothy Lee on 8/4/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "TimelineVC.h"
#import "TweetCell.h"
#import "TweetVC.h"
#import "ComposeVC.h"
#import "UIImageView+AFNetworking.h"

@interface TimelineVC ()

@property (nonatomic, strong) NSMutableArray *tweets;

- (void)onSignOutButton;
- (void)reload;

@end

@implementation TimelineVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self reload];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
    
    self.navigationItem.title = @"Home";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onSignOutButton)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onNewTweetButton)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
    UINib *tweetNib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    [self.tableView registerNib:tweetNib forCellReuseIdentifier:@"TweetCell"];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(pullTweets) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)stopRefresh
{
    [self.refreshControl endRefreshing];
}

- (void)pullTweets
{
    [self reload];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TweetCell";
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Tweet *tweet = self.tweets[indexPath.row];
    cell.tweetText.text = tweet.text;
    [cell.tweetText sizeToFit];
    
    NSURL *url = [[NSURL alloc] initWithString:tweet.profile_image_url];
    [cell.displayImageUrl setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    cell.screenName.text = tweet.screen_name;
    cell.name.text = tweet.name;
    
    cell.replyButton.tag = indexPath.row;
    [cell.replyButton addTarget:self action:@selector(onReplyButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView_
//{
//    
//    CGFloat currentOffsetX = scrollView_.contentOffset.x;
//    CGFloat currentOffSetY = scrollView_.contentOffset.y;
//    CGFloat contentHeight = scrollView_.contentSize.height;
//    
//    if (currentOffSetY < (contentHeight / 8.0)) {
//        scrollView_.contentOffset = CGPointMake(currentOffsetX,(currentOffSetY + (contentHeight/2)));
//    }
//    if (currentOffSetY > ((contentHeight * 6)/ 8.0)) {
//        scrollView_.contentOffset = CGPointMake(currentOffsetX,(currentOffSetY - (contentHeight/2)));
//    } 
//}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TweetVC *tweetViewControler = [[TweetVC alloc] init];
    tweetViewControler.tweet = self.tweets[indexPath.row];
    [self.navigationController pushViewController:tweetViewControler animated:YES];
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */


-(void)sendDataToTimeline:(Tweet *)publishTweet
{
    [self.tweets insertObject:publishTweet atIndex:0];
    [self.tableView reloadData];
}


#pragma mark - Private methods

- (void)onNewTweetButton {
    ComposeVC *composeView = [[ComposeVC alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:composeView];
    composeView.delegate=self;
    composeView.user = [User currentUser];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)onReplyButton:(UIButton*)sender {
    ComposeVC *composeView = [[ComposeVC alloc] init];
    composeView.user = [User currentUser];
    composeView.tweet = [self.tweets objectAtIndex:sender.tag];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:composeView];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)onSignOutButton {
    [User setCurrentUser:nil];
}

- (void)reload {
    [[TwitterClient instance] homeTimelineWithCount:20 sinceId:0 maxId:0 success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"%@", response);
        self.tweets = [Tweet tweetsWithArray:response];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Do nothing
    }];
}

@end
