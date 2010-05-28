//
//  AtomParser.m
//
//  Created by Mike Mayo on 1/28/10.
//  Copyright Mike Mayo 2010. All rights reserved.
//

#import "AtomParser.h"
#import "FeedItem.h"


@implementation AtomParser

@synthesize feedItem, currentDataType, feedItems;

#pragma mark -
#pragma mark Date Parser

-(NSDate *)dateFromString:(NSString *)dateString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:sszzzz"];
	NSDate *date = [dateFormatter dateFromString:dateString];
	[dateFormatter release];	
	return date;
}

#pragma mark -
#pragma mark XML Parser Delegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	
	if ([elementName isEqualToString:@"feed"]) {
		// we're getting started, so go ahead and alloc the array
		self.feedItems = [[NSMutableArray alloc] initWithCapacity:1];
	} else if ([elementName isEqualToString:@"entry"]) {
		self.feedItem = [[FeedItem alloc] init];
		parsingItem = YES;
	} else if ([elementName isEqualToString:@"content"]) {
        self.feedItem.content = @"";
        parsingContent = YES;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
		
	if ([elementName isEqualToString:@"entry"]) {
		[self.feedItems addObject:self.feedItem];
		parsingItem = NO;
	} else if ([elementName isEqualToString:@"title"]) {
		feedItem.title = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//	} else if ([elementName isEqualToString:@"link"]) {
//		feedItem.link = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"id"]) {
		feedItem.guid = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"summary"]) {
		feedItem.description = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"content"]) {
		//feedItem.content = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        parsingContent = NO;        
	} else if ([elementName isEqualToString:@"name"]) {
		feedItem.creator = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"published"]) {
		feedItem.pubDate = [self dateFromString:[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}
	
	if (parsingContent) {
	    if ([elementName isEqualToString:@"div"]) {
	        // the div is just a wrapper for the rackcloud status item
	    } else if ([elementName isEqualToString:@"p"]) {
            NSString *newLine = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
			feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            feedItem.content = [feedItem.content stringByAppendingString:[NSString stringWithFormat:@"\n\n%@", newLine]];
	    }
	}
	
	if ([feedItem.content length] > 0 && [feedItem.content characterAtIndex:0] == ' ') {
		feedItem.content = [feedItem.content substringFromIndex:1];
	}
	
	
	[currentElementValue release];
	currentElementValue = nil;	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (!currentElementValue) {
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	} else {
		[currentElementValue appendString:string];
	}
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[feedItem release];
	[currentDataType release];
	[feedItems release];
	[super dealloc];
}

@end
