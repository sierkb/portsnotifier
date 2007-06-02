/**
 * @file PNPortInfo.h 
 * 
 * @brief interface for port information
 *
 * @id $Id
 *
 * @author: eddyxu@gmail.com
 * */

#import <Cocoa/Cocoa.h>

@interface PNPortInfo : NSObject
{
	NSString* title;
	NSString* oldVersion;
	NSString* newVersion;
}

-(id) initWithTitle:(NSString*) aTitle 
	oldVersion:(NSString*) aOldVersion 
	newVersion:(NSString*) aNewVersion;
	
-(id) initWithString:(NSString*) aLine;

-(NSString*) title;
-(void) setTitle:(NSString*)aTitle;
-(NSString*) oldVersion;
-(void) setOldVersion:(NSString*)aOldVersion;
-(NSString*) newVersion;
-(void) setNewVersion:(NSString*)aNewVersion;
//-(NSData*) description;
-(BOOL)isAvailable;

@end
