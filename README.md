LowLatencyAudio
=================

LowLatencyAudio is a native plugin for PhoneGap.  This implementation is designed to be compatible with PhoneGap 3.0 CLI deployment, and supports both iOS and Android.

## Installation

The LowLatencyAudio plugin can be added to your project via the PhoneGap command line tools.  Simply use the following command to add this to your project:

`cordova plugin add https://github.com/JoliPixel/LowLatencyAudio`

You will also need to include the AudioToolbox library in your XCode project. Instructions for linking frameworks can be found [here](https://developer.apple.com/library/ios/recipes/xcode_help-project_editor/Articles/AddingaLibrarytoaTarget.html#//apple_ref/doc/uid/TP40010155-CH17-SW1).

## Usage

1. Preload the audio asset - Note: Make sure to wait for phonegap deviceready event before attempting to load assets
2. Play the audio asset
3. When done, unload the audio asset


## API methods
```javascript
preloadFX: function ( id, assetPath, success, 
```
* params : ID - string unique ID for the audio file
assetPath - the relative path to the audio asset within the www directory
success - success callback function
fail - error/fail callback function
* detail : The preloadFX function loads an audio file into memory.  Assets that are loaded using preloadFX are managed/played using AudioServices methods from the AudioToolbox framework. These are very low-level audio methods and have minimal overhead.  Audio loaded using this function is played using AudioServicesPlaySystemSound. These assets should be short, and are not intended to be looped or stopped. They are fully concurrent and polyphonic. Their volume can not be changed.
			
```javascript
preloadAudio: function ( id, assetPath, voices, success, fail) 
```
* params : ID - string unique ID for the audio file
assetPath - the relative path to the audio asset within the www directory
voices - the number of polyphonic voices available
success - success callback function
fail - error/fail callback function
* detail : The preloadAudio function loads an audio file into memory.  Assets that are loaded using preloadAudio are managed/played using AVAudioPlayer. These have more overhead than assets laoded via preloadFX, and can be looped/stopped.  By default, there is a single "voice" - only one instance that will be stopped & restarted when you hit play.  If there are multiple voices (number greater than 0), it will cycle through voices to play overlapping audio.
		
```javascript
play: function (id, success, fail) 	
```
* params : ID - string unique ID for the audio file
success - success callback function - takes an integer (index of audio that has been played)
fail - error/fail callback function
* detail : Plays an audio asset - the index is only passed to success with assets loaded via preloadAudio
		
```javascript
loop: function (id, success, fail) 	
```
* params : ID - string unique ID for the audio file
success - success callback function - takes an integer (index of audio that has been played)
fail - error/fail callback function
* detail : Loops an audio asset infinitely - this only works for assets loaded via preloadAudio
		
```javascript
stop: function (id, index, success, fail) 	
```
* params : ID - string unique ID for the audio file
index - index of a specific audio voice to stop - pass -1 or null to stop all voices for the audio file.
success - success callback function
fail - error/fail callback function
* detail : Stops an audio file - this only works for assets loaded via preloadAudio. It will set the audio position to the begining, at zero seconds.
		
```javascript
unload: function (id, success, fail) 	
```
* params : ID - string unique ID for the audio file
success - success callback function
fail - error/fail callback function
* detail : Unloads an audio file from memory

```javascript
pause: function (id, index, success, fail) 	
```
* params : ID - string unique ID for the audio file
index - index of a specific audio voice to pause - pass -1 or null to pause all voices for the audio file.
success - success callback function
fail - error/fail callback function
* detail : Pauses an audio file - this only works for assets loaded via preloadAudio


```javascript
pause: function (id, index, success, fail) 	
```
* params : ID - string unique ID for the audio file
index - index of a specific audio voice to unpause - pass -1 or null to unpause all voices for the audio file.
success - success callback function
fail - error/fail callback function
* detail : Unpauses an audio file. Recommanded instead of .stop() then .play().
* 
```javascript
setVolume: function (id, index, volume, success, fail) 	
```
* params : ID - string unique ID for the audio file
index - index of a specific audio voice to set the volume on - pass -1 or null to set all voices for the audio file.
volume - The volume between 0 and 1, inclusive, to set the volume to.
success - success callback function
fail - error/fail callback function
* detail : Sets the volume for an audio file - this only works for assets loaded via preloadAudio

```javascript
getDuration: function (id, success, fail) 	
```
* params : ID - string unique ID for the audio file
success - success callback function - takes an integer that is the duration in milliseconds
fail - error/fail callback function
* detail : Gets the duration of an audio file - this only works for assets loaded via preloadAudio

```javascript
getPosition: function (id, index, success, fail) 	
```
* params : ID - string unique ID for the audio file
index - index of a specific audio voice to check
success - success callback function - takes an integer that is the position in milliseconds. For audio that is not paused or playing, -1 is passed.
fail - error/fail callback function
* detail : Gets the position of an audio voice - this only works for assets loaded via preloadAudio

```javascript
getCapabilities: function (success, 
```
* params : success - success callback function
fail - error/fail callback function
* detail  Gets an object describing capabilities of the device as expected by SoundJS.
See http://www.createjs.com/Docs/SoundJS/classes/Sound.html#method_getCapabilities


