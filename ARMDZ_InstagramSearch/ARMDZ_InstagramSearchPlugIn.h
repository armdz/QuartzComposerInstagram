//
//  ARMDZ_InstagramSearchPlugIn.h
//  ARMDZ_InstagramSearch
//
//  Created by Lolo on 9/15/15.
//  Copyright (c) 2015 ARMDZ. All rights reserved.
//

#import <Quartz/Quartz.h>
#import <Foundation/Foundation.h>

@interface ARMDZ_InstagramSearchPlugIn : QCPlugIn<NSURLConnectionDataDelegate>
{
  BOOL  internal_do_request;
  NSMutableURLRequest *request;
  NSDictionary        *output_data;
}

// Declare here the properties to be used as input and output ports for the plug-in e.g.
//@property double inputFoo;
//@property (copy) NSString* outputBar;

@property (copy) NSString*  input_token;
@property (copy) NSString*  input_hash_tag;
@property BOOL       input_do_search;
@property (copy) NSDictionary*  output_results;

@end
