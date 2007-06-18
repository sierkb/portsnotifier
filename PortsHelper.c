/*
 *  PortsHelper.c
 *  PortsNotifier
 *
 *  Created by eddyxu@gmail.com on 07-5-25.
 *  Copyright 2007 portsnotifier.sf.net All rights reserved.
 *
 *  PortsNotifier is released under BSD License
 */

#include <CoreFoundation/CoreFoundation.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <syslog.h>

#include "PNDefines.h"

/**
 * @brief store property list to file
 *
 * @param propertyList a reference to property list
 * @param fileURL url of file location
 *
 */
void WritePropertyListToFile( CFPropertyListRef propertyList,
            CFURLRef fileURL ) {
   CFDataRef xmlData;
   Boolean status;
   SInt32 errorCode;

   // Convert the property list into XML data.
   xmlData = CFPropertyListCreateXMLData( kCFAllocatorDefault, propertyList );

   // Write the XML data to the file.
   status = CFURLWriteDataAndPropertiesToResource (
               fileURL,                  // URL to use
               xmlData,                  // data to write
               NULL,
               &errorCode);

   CFRelease(xmlData);
}

/// load property list form file that named from fileURL
CFPropertyListRef CreatePropertyListFromFile( CFURLRef fileURL ) {

   CFPropertyListRef propertyList;
   CFStringRef       errorString;
   CFDataRef         resourceData;
   Boolean           status;
   SInt32            errorCode;

   // Read the XML file.
   status = CFURLCreateDataAndPropertiesFromResource(
               kCFAllocatorDefault,
               fileURL,
               &resourceData,            // place to put file data
               NULL,
               NULL,
               &errorCode);

   // Reconstitute the dictionary using the XML data.
   propertyList = CFPropertyListCreateFromXMLData( kCFAllocatorDefault,
               resourceData,
               kCFPropertyListImmutable,
               &errorString);

   CFRelease( resourceData );

   return propertyList;

}

/// check if the ports in installed
int pn_is_ports_installed(void)
{
	return access(PN_PORT_PATH, F_OK) < 0 ? 0 : 1;
}

/// sync the ports
int pn_sync_ports(void)
{
	if(!pn_is_ports_installed())
		return 1;
		
	syslog(LOG_INFO ,"Run port selfupdate");
	return system("/opt/local/bin/port selfupdate");
}


/// create the property list for launchd
CFDictionaryRef pn_create_launchd_plist(int interval){
	CFMutableDictionaryRef dict;
	CFNumberRef num;
	
	int seconds = interval * 60; // translate to seconds
	
	// Create a dictionary that will hold the data.
	
	dict = CFDictionaryCreateMutable( kCFAllocatorDefault,
									  0,
									  &kCFTypeDictionaryKeyCallBacks,
									  &kCFTypeDictionaryValueCallBacks );
									  
	CFDictionarySetValue(dict, CFSTR("Label"), CFSTR(PN_APP_ID));
	CFDictionarySetValue(dict, CFSTR("Program"), CFSTR(PN_HELPER_PATH));
	CFDictionarySetValue(dict, CFSTR("ServiceDescription"),
			CFSTR("Automatic update macports"));
	CFDictionarySetValue(dict, CFSTR("StandardErrorPath"), 
			CFSTR("/var/log/portsnotifier.log"));
			
	num = CFNumberCreate( kCFAllocatorDefault,
            kCFNumberIntType,
            &seconds );
	CFDictionarySetValue( dict, CFSTR("StartInterval"), num );
	CFRelease( num );
   
	int timeout = 125;
	num = CFNumberCreate( kCFAllocatorDefault,
            kCFNumberIntType,
            &timeout );
	CFDictionarySetValue( dict, CFSTR("TimeOut"), num );
	CFRelease( num );
   
	CFDictionarySetValue( dict, CFSTR("UserName"), CFSTR("root"));
	return dict;
}

/// write launchd plist with new startInterval	
int pn_write_plist(int interval)
{
	if(interval < 0) 
		return -1;
		
	syslog(LOG_INFO, "Modified interval to: %d", interval);
	
	CFPropertyListRef propertyList;
	CFURLRef fileURL;
 
	fileURL = CFURLCreateWithFileSystemPath( kCFAllocatorDefault,
               CFSTR(PN_LAUNCHD_PLIST),       // file path name
               kCFURLPOSIXPathStyle,    // interpret as POSIX path
               false ); 
	propertyList = pn_create_launchd_plist(interval);
	WritePropertyListToFile( propertyList, fileURL );
	CFRelease(propertyList);
	return 0;
}

void pn_usage(void)
{
	printf("PortsHelper -- Helper for PortsNotifier\n");
	printf("Usage: PortsHelper [OPTIONS]\n");
	printf("Options:\n");
	printf("-i <minutes>\t\tsetting the interval of calling helper by launchd\n");
	printf("-h\t\t\tdisplay this help\n");
	printf("\nIf no options be provided, PortsHelper will do \"port sync\"\n");
}

int main(int argc, char * const argv[])
{
	
	openlog("PortsHelper", (LOG_CONS|LOG_PERROR|LOG_PID), LOG_DAEMON);
	int ch, ret;
	
	while((ch = getopt(argc, argv, "hi:")) != -1){
		switch (ch) {
		case 'h':
			pn_usage();
			exit(0);
			break;
		case 'i':
			ret = pn_write_plist(atoi(optarg));
			return ret;	
			break;
		case '?':
		default:
			pn_usage();
			exit(0);
			break;
		}
	}
	
	argc -= optind;
	argv += optind;
	
	
	ret =  pn_sync_ports();
	closelog();
	return ret;
}

