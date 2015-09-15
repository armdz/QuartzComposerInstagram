//
//  ARMDZ_InstagramSearchPlugIn.m
//  ARMDZ_InstagramSearch
//
//  Created by Lolo on 9/15/15.
//  Copyright (c) 2015 ARMDZ. All rights reserved.
//

// It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering
#import <OpenGL/CGLMacro.h>

#import "ARMDZ_InstagramSearchPlugIn.h"

#define	kQCPlugIn_Name				@"ARMDZ_InstagramSearch"
#define	kQCPlugIn_Description		@"Little Instagram API Hashtag Search"


@implementation ARMDZ_InstagramSearchPlugIn

// Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
//@dynamic inputFoo, outputBar;

@dynamic input_hash_tag,input_do_search,output_results,input_token;

+ (NSDictionary *)attributes
{
	// Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
  
    return @{QCPlugInAttributeNameKey:kQCPlugIn_Name, QCPlugInAttributeDescriptionKey:kQCPlugIn_Description};
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
	// Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
  if ( [key isEqualToString:@"input_token"] ) {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Access Token", QCPortAttributeNameKey,nil];
  }else if ( [key isEqualToString:@"input_hash_tag"] ) {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Hash Tag", QCPortAttributeNameKey,nil];
  }else if ( [key isEqualToString:@"input_do_search"] ) {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Search", QCPortAttributeNameKey,nil];
  }else if( [key isEqualToString:@"output_results"]){
    return [NSDictionary dictionaryWithObjectsAndKeys:@"Result",QCPortAttributeNameKey,FALSE,QCPortAttributeDefaultValueKey, nil];
  }else{
    return nil;
  }
  
}

+ (QCPlugInExecutionMode)executionMode
{
	// Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
  
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode)timeMode
{
	// Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	return kQCPlugInTimeModeNone;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
    internal_do_request = false;
		// Allocate any permanent resource required by the plug-in.
	}
	
	return self;
}


@end

@implementation ARMDZ_InstagramSearchPlugIn (Execution)

- (BOOL)startExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	// Return NO in case of fatal failure (this will prevent rendering of the composition to start).
  output_data = NULL;
	return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
  
  if(self.input_do_search)
  {
    if(!internal_do_request)
    {
    
      /*Host:
       api.instagram.com
       X-Target-URI:
       https://api.instagram.com
       Connection:
       Keep-Alive*/
      
      NSString  *string_url = [NSString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?access_token=%@",self.input_hash_tag,self.input_token];
      request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:string_url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
      request.HTTPMethod = @"GET";
      
      [context logMessage:[NSString stringWithFormat:@"do req,%@",string_url]];
      
      [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError != NULL)
        {
          NSDictionary *output = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:connectionError.description,@"", nil] forKeys:[NSArray arrayWithObjects:@"error",@"data", nil]];
          output_data = output;
          [context logMessage:[NSString stringWithFormat:@"ERROR %@",connectionError.description]];
        }else{
          NSDictionary *output_dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
          output_data = output_dict;
        }
      }];
      
      self.output_results = output_data;

    }
    internal_do_request = true;
  }else{
    internal_do_request = false;
  }
  
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	
	The OpenGL context for rendering can be accessed and defined for CGL macros using:
	CGLContextObj cgl_ctx = [context CGLContextObj];
	*/
	
	return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
}

- (void)stopExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
}



@end
