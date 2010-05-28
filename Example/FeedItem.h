//
//  FeedItem.h
//
//  Created by Mike Mayo on 1/28/10.
//  Copyright Mike Mayo 2010. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FeedItem : NSObject {

	NSString *title;
	NSString *link;
	NSString *guid;
	NSString *description;
	NSString *content;
	NSString *creator;
	NSDate *pubDate;
		
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *guid;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *creator;
@property (nonatomic, retain) NSDate *pubDate;

- (NSComparisonResult)compare:(FeedItem *)anotherFeedItem;

@end
