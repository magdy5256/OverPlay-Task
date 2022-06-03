# OverPlay-Task
over play task is about control video with gyroscope and location 


Features: 


1- Loads and plays a video file after launch. 

2- Using the user’s location, a change of 10 meters of the current and previous location
will reset the video and replay from the start.

3- A shake of the device should pause the video.

4- Using gyroscope events, rotation along the z-axis should be able to control the
current time where the video is playing. While rotation along the x-axis should control
the volume of the sound.
 
 
 
 
 
 
Technology Used:
- swift 
- MediaPlayer: for change volume
- CoreMotion: for gyroscope events
- CoreLocation: for user’s location and change location 
- AVFoundation: for playing video
 





For Testing:



if you want to test posation control  (z-axis), you can comment: 
  self.setVolume(newX: data.rotationRate.x) in line 95
  
if you want to test volume control  (x-axis), you can comment:
  self.setVideoPosition(newZ:data.rotationRate.z) in line 96

