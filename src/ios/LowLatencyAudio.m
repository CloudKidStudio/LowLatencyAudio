//
//  PGAudio.m
//  PGAudio
//
//  Created by Andrew Trice on 1/19/12.
//
// THIS SOFTWARE IS PROVIDED BY ANDREW TRICE "AS IS" AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
// EVENT SHALL ANDREW TRICE OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "LowLatencyAudio.h"
#import <AVFoundation/AVAudioSession.h>

@implementation LowLatencyAudio

NSString* ERROR_NOT_FOUND = @"file not found";
NSString* WARN_EXISTING_REFERENCE = @"a reference to the audio ID already exists";
NSString* ERROR_MISSING_REFERENCE = @"a reference to the audio ID does not exist";
NSString* CONTENT_LOAD_REQUESTED = @"content has been requested";
NSString* PLAY_REQUESTED = @"PLAY REQUESTED";
NSString* PAUSE_REQUESTED = @"PAUSE REQUESTED";
NSString* LOOP_REQUESTED = @"LOOP REQUESTED";
NSString* STOP_REQUESTED = @"STOP REQUESTED";
NSString* SET_VOLUME_REQUESTED = @"SET VOLUME REQUESTED";
NSString* UNLOAD_REQUESTED = @"UNLOAD REQUESTED";
NSString* RESTRICTED = @"ACTION RESTRICTED FOR FX AUDIO";

- (void)pluginInitialize
{

    AudioSessionInitialize(NULL, NULL, nil , nil);
    AVAudioSession *session = [AVAudioSession sharedInstance];

    NSError *setCategoryError = nil;

    // Allows the application to mix its audio with audio from other apps.
    if (![session setCategory:AVAudioSessionCategoryAmbient
                  withOptions:AVAudioSessionCategoryOptionMixWithOthers
                        error:&setCategoryError]) {

        NSLog (@"Error setting audio session category.");
        return;
    }

    [session setActive: YES error: nil];
}

- (void) preloadFX:(CDVInvokedUrlCommand*)command;
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult;
        NSString* callbackID = command.callbackId;
        NSString *audioID =  [command.arguments objectAtIndex:0];
        NSString *assetPath =  [command.arguments objectAtIndex:1];
        if(audioMapping == nil)
        {
            audioMapping = [NSMutableDictionary dictionary];
        }
        
        NSNumber* existingReference = [audioMapping objectForKey: audioID];
        if (existingReference == nil)
        {
            NSString* basePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"];
            NSString* path = [NSString stringWithFormat:@"%@/%@", basePath, assetPath];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath : path])
            {
                NSURL *pathURL = [NSURL fileURLWithPath : path];
                SystemSoundID soundID;
                AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain(pathURL), & soundID);
                [audioMapping setObject:[NSNumber numberWithInt:soundID]  forKey: audioID];
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: CONTENT_LOAD_REQUESTED];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
            }
            else
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: ERROR_NOT_FOUND];        
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
            }
        }
        else 
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: WARN_EXISTING_REFERENCE];        
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
    }];
}

- (void) preloadAudio:(CDVInvokedUrlCommand*)command;
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult;
        NSString* callbackID =  command.callbackId;
        
        NSString *audioID = [command.arguments objectAtIndex:0];
        NSString *assetPath = [command.arguments objectAtIndex:1];
        
        NSNumber *voices;
        if ( [command.arguments count] > 2 )
        {
            voices = [command.arguments objectAtIndex:2];
        }
        else
        {
            voices = [NSNumber numberWithInt:1];
        }
        
        if(audioMapping == nil)
        {
            audioMapping = [NSMutableDictionary dictionary];    }
        
        NSNumber* existingReference = [audioMapping objectForKey: audioID];
        if (existingReference == nil)
        {
            NSString* basePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"];
            NSString* path = [NSString stringWithFormat:@"%@/%@", basePath, assetPath];
            if ([[NSFileManager defaultManager] fileExistsAtPath : path])
            {
                LowLatencyAudioAsset* asset = [[LowLatencyAudioAsset alloc] initWithPath:path withVoices:voices];
                [audioMapping setObject:asset  forKey: audioID];
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: CONTENT_LOAD_REQUESTED];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
            }
            else
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: ERROR_NOT_FOUND];        
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
            }
        }
        else 
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: WARN_EXISTING_REFERENCE];        
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
    }];
}

- (void) play:(CDVInvokedUrlCommand*)command;
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult;
        NSString* callbackID = command.callbackId;
        NSString *audioID = [command.arguments objectAtIndex:0];
        
        if ( audioMapping )
        {
            NSObject* asset = [audioMapping objectForKey: audioID];
            if ([asset isKindOfClass:[LowLatencyAudioAsset class]])
            { 
                LowLatencyAudioAsset *_asset = (LowLatencyAudioAsset*) asset;
                [_asset play];
            }
            else if ( [asset isKindOfClass:[NSNumber class]] )
            {
                NSNumber *_asset = (NSNumber*) asset;
                AudioServicesPlaySystemSound([_asset intValue]);
            }
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: PLAY_REQUESTED];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
        else 
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: ERROR_MISSING_REFERENCE];        
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
    }];
}

- (void) unpause:(CDVInvokedUrlCommand*)command;
{
        [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult;
        NSString* callbackID = command.callbackId;
        NSString *audioID = [command.arguments objectAtIndex:0];

        if ( audioMapping )
        {
            NSObject* asset = [audioMapping objectForKey: audioID];
            if ([asset isKindOfClass:[LowLatencyAudioAsset class]])
            {
                LowLatencyAudioAsset *_asset = (LowLatencyAudioAsset*) asset;
                [_asset unpause];

                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: PAUSE_REQUESTED];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
            }
            else if ( [asset isKindOfClass:[NSNumber class]] )
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: RESTRICTED];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
            }

        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: ERROR_MISSING_REFERENCE];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
    }];
}

- (void) pause:(CDVInvokedUrlCommand*)command;
{
        [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult;
        NSString* callbackID = command.callbackId;
        NSString *audioID = [command.arguments objectAtIndex:0];

        if ( audioMapping )
        {
            NSObject* asset = [audioMapping objectForKey: audioID];
            if ([asset isKindOfClass:[LowLatencyAudioAsset class]])
            {
                LowLatencyAudioAsset *_asset = (LowLatencyAudioAsset*) asset;
                [_asset pause];

                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: PAUSE_REQUESTED];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
            }
            else if ( [asset isKindOfClass:[NSNumber class]] )
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: RESTRICTED];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
            }

        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: ERROR_MISSING_REFERENCE];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
    }];
}

- (void) stop:(CDVInvokedUrlCommand*)command;
{
        [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult;
        NSString* callbackID = command.callbackId;
        NSString *audioID = [command.arguments objectAtIndex:0];
        
        if ( audioMapping )
        {
            NSObject* asset = [audioMapping objectForKey: audioID];
            if ([asset isKindOfClass:[LowLatencyAudioAsset class]])
            { 
                LowLatencyAudioAsset *_asset = (LowLatencyAudioAsset*) asset;
                [_asset stop];
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: STOP_REQUESTED];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
            }
            else if ( [asset isKindOfClass:[NSNumber class]] )
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: RESTRICTED];        
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
            }
            
        }
        else 
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: ERROR_MISSING_REFERENCE];        
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
    }];
}

- (void) loop:(CDVInvokedUrlCommand*)command;
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult;
        NSString* callbackID = command.callbackId;
        NSString *audioID = [command.arguments objectAtIndex:0];
        
        if ( audioMapping )
        {
            NSObject* asset = [audioMapping objectForKey: audioID];
            if ([asset isKindOfClass:[LowLatencyAudioAsset class]])
            { 
                LowLatencyAudioAsset *_asset = (LowLatencyAudioAsset*) asset;
                [_asset loop];
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: LOOP_REQUESTED];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
            }
            else if ( [asset isKindOfClass:[NSNumber class]] )
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: RESTRICTED];        
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
            }
        }
        else 
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: ERROR_MISSING_REFERENCE];        
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
    }];
}

- (void) unload:(CDVInvokedUrlCommand*)command;
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult;
        NSString* callbackID = command.callbackId;
        NSString *audioID = [command.arguments objectAtIndex:0];
        
        if ( audioMapping )
        {
            NSObject* asset = [audioMapping objectForKey: audioID];
            if ([asset isKindOfClass:[LowLatencyAudioAsset class]])
            { 
                LowLatencyAudioAsset *_asset = (LowLatencyAudioAsset*) asset;
                [_asset unload];
            }
            else if ( [asset isKindOfClass:[NSNumber class]] )
            {
                NSNumber *_asset = (NSNumber*) asset;
                AudioServicesDisposeSystemSoundID([_asset intValue]);
            }
            
            [audioMapping removeObjectForKey: audioID];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: UNLOAD_REQUESTED];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
        else 
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: ERROR_MISSING_REFERENCE];        
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
    }];
}

- (void) getPosition:(CDVInvokedUrlCommand*)command;
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult;
        NSString* callbackID = command.callbackId;
        NSString *audioID = [command.arguments objectAtIndex:0];

        if ( audioMapping )
        {
            float seconds = -1;
            NSObject* asset = [audioMapping objectForKey: audioID];
            if ([asset isKindOfClass:[LowLatencyAudioAsset class]])
            {
                LowLatencyAudioAsset *_asset = (LowLatencyAudioAsset*) asset;
                // Send back as miliseconds to be consistent.
                // TODO cast to double ?
                seconds = [_asset getPosition] * 1000;
            }
            else if ( [asset isKindOfClass:[NSNumber class]] )
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: RESTRICTED];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
            }

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt: seconds];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: ERROR_MISSING_REFERENCE];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
    }];
}

- (void) setVolume:(CDVInvokedUrlCommand*)command;
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult;
        NSString* callbackID = command.callbackId;
        NSString *audioID = [command.arguments objectAtIndex:0];
        // TODO allow setting volume per voice which sits in 1 in the index.
        NSNumber *volume = [command.arguments objectAtIndex:2];
        Float32 volumeFloat;

        if ( audioMapping )
        {
            NSObject* asset = [audioMapping objectForKey: audioID];
            if ([asset isKindOfClass:[LowLatencyAudioAsset class]])
            {
                volumeFloat = [volume floatValue];
                LowLatencyAudioAsset *_asset = (LowLatencyAudioAsset*) asset;
                [_asset setVolume:&volumeFloat];
            }
            else if ( [asset isKindOfClass:[NSNumber class]] )
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: RESTRICTED];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
            }

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:SET_VOLUME_REQUESTED];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: ERROR_MISSING_REFERENCE];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
    }];
}

@end
