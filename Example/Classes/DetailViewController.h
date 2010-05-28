//
//  DetailViewController.h
//  Example
//
//  Created by Michael Mayo on 5/28/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    
    id detailItem;
    UILabel *detailDescriptionLabel;
    
    NSMutableArray *feedItems;
	IBOutlet UITableViewCell *nibLoadedFeedItemCell;
    IBOutlet UITableViewCell *nibLoadedRSSEmptyCell;	
	IBOutlet UITableView *tableView;
    BOOL rssRequestFailed;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UILabel *detailDescriptionLabel;

@property (nonatomic, retain) NSMutableArray *feedItems;
@property (nonatomic, retain) IBOutlet UITableViewCell *nibLoadedFeedItemCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *nibLoadedRSSEmptyCell;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
