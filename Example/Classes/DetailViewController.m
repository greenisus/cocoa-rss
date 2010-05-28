//
//  DetailViewController.m
//  Example
//
//  Created by Michael Mayo on 5/28/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "ASIHTTPRequest.h"
#import "RSSParser.h"
#import "FeedItem.h"

// Feed Item Cell Tags
#define kDateTag 1
#define kTitleTag 2
#define kBodyTag 3
#define kAuthorTag 4



@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end



@implementation DetailViewController

@synthesize toolbar, popoverController, detailItem, detailDescriptionLabel;
@synthesize feedItems, tableView, nibLoadedFeedItemCell, nibLoadedRSSEmptyCell;

#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        [detailItem release];
        detailItem = [newDetailItem retain];
        
        // Update the view.
        [self configureView];
    }

    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
}


- (void)configureView {
    // Update the user interface for the detail item.
    detailDescriptionLabel.text = [detailItem description];   
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = @"Root List";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark HTTP Response Handlers

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[request responseData]];
	RSSParser *rssParser = [[RSSParser alloc] init];
	xmlParser.delegate = rssParser;
	if ([xmlParser parse]) {
        [self.feedItems release];
		self.feedItems = rssParser.feedItems;
	}	
	
	[rssParser release];
	[xmlParser release];
	[self.tableView reloadData];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: %@", [error description]);
    rssRequestFailed = YES;
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    rssRequestFailed = NO;
    self.feedItems = [[NSMutableArray alloc] init];
    
    // Load the Building43 RSS Feed
    NSURL *url = [NSURL URLWithString:@"http://building43.com/feed"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
}

#pragma mark -
#pragma mark Table View Methods

- (NSString *)dateToString:(NSDate *)date {
	NSString *result = @"";
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	[dateFormatter setTimeStyle:NSDateFormatterLongStyle];	
	result = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	return result;
}

+ (CGFloat) findLabelHeight:(NSString*) text font:(UIFont *)font label:(UILabel *)label {
    CGSize textLabelSize = CGSizeMake(label.frame.size.width, 9000.0f);
    CGSize stringSize = [text sizeWithFont:font constrainedToSize:textLabelSize lineBreakMode:UILineBreakModeWordWrap];
    return stringSize.height;
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if (rssRequestFailed) {
        return 1; // the empty RSS cell
    } else {
        return [self.feedItems count]; 
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	// adjust label widths for orientation
	NSArray *labels = [NSArray arrayWithObjects:[cell viewWithTag:kDateTag], 
					   [cell viewWithTag:kTitleTag], [cell viewWithTag:kBodyTag], [cell viewWithTag:kAuthorTag], nil];
	
	// label should be 40 pixels less than the cell width for both orientations
	for (int i = 0; i < [labels count]; i++) {
		UILabel *label = (UILabel *) [labels objectAtIndex:i];
		CGRect rect = label.frame;
		rect.size.width = cell.frame.size.width - 40 - 64;
		label.frame = rect;		
	}
	
}

- (UITableViewCell *)tableView:(UITableView *)aTableView emptyRSSCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyRSSCell"];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"RSSEmptyCell" owner:self options:NULL]; 
		cell = nibLoadedRSSEmptyCell;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView rssCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedItemCell"];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"FeedItemCell" owner:self options:NULL]; 
		cell = nibLoadedFeedItemCell;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	// show newest first
	FeedItem *item = [self.feedItems objectAtIndex:[self.feedItems count] - 1 - indexPath.row];
	
	UILabel *dateLabel = (UILabel *) [cell viewWithTag:kDateTag];
	dateLabel.text = [self dateToString:item.pubDate];
	
	UILabel *titleLabel = (UILabel *) [cell viewWithTag:kTitleTag];
	titleLabel.text = item.title;
	
	UILabel *bodyLabel = (UILabel *) [cell viewWithTag:kBodyTag];
	bodyLabel.text = item.content;
	
	UILabel *authorLabel = (UILabel *) [cell viewWithTag:kAuthorTag];
	authorLabel.text = [NSString stringWithFormat:@"Posted by %@", item.creator];
	
	// set the height of the title label to fit the size of the string
	CGFloat originalTitleHeight = titleLabel.frame.size.height;	
	CGFloat titleHeight = [[self class] findLabelHeight:item.title font:titleLabel.font label:titleLabel];
	
	CGRect titleRect = titleLabel.frame;
	titleRect.size.height = titleHeight;
	titleLabel.frame = titleRect;
	
	CGFloat originalBodyHeight = bodyLabel.frame.size.height;
	CGFloat bodyHeight = [[self class] findLabelHeight:item.content font:bodyLabel.font label:bodyLabel];
	
	CGRect subtitleRect = bodyLabel.frame;
	subtitleRect.origin.y += titleHeight - originalTitleHeight;
	subtitleRect.size.height = bodyHeight;
	bodyLabel.frame = subtitleRect;
	
	CGRect authorRect = authorLabel.frame;
	authorRect.origin.y += titleHeight - originalTitleHeight;
	authorRect.origin.y += bodyHeight - originalBodyHeight;
	authorLabel.frame = authorRect;
	
	CGRect cellRect = cell.frame;
	cellRect.size.height += titleHeight - originalTitleHeight;
	cellRect.size.height += bodyHeight - originalBodyHeight;
	cell.frame = cellRect;
	
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
    if (rssRequestFailed) {
        return [self tableView:aTableView emptyRSSCellForRowAtIndexPath:indexPath];
    } else {
        return [self tableView:aTableView rssCellForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// might be slower to make the extra cellForRowAtIndexPath call, but it's flexible and DRY
    return ((UITableViewCell *)[self tableView:aTableView cellForRowAtIndexPath:indexPath]).frame.size.height;
}

#pragma mark -
#pragma mark Memory management

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
*/

- (void)dealloc {
    [popoverController release];
    [toolbar release];
    
    [detailItem release];
    [detailDescriptionLabel release];
    
    [tableView release];
	[nibLoadedFeedItemCell release];
	[nibLoadedRSSEmptyCell release];
    [feedItems release];
    
    [super dealloc];
}

@end
