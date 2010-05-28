//
//  AtomParser.h
//
//  Created by Mike Mayo on 1/28/10.
//  Copyright Mike Mayo 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FeedItem;

@interface AtomParser : NSObject {
	NSMutableString *currentElementValue;
	NSString *currentDataType;
	FeedItem *feedItem;
	NSMutableArray *feedItems;
	BOOL parsingItem;
    BOOL parsingContent;
}

@property (nonatomic, retain) FeedItem *feedItem;
@property (nonatomic, retain) NSString *currentDataType;
@property (nonatomic, retain) NSMutableArray *feedItems;

@end
