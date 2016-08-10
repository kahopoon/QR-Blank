# QR Blank - QR Code URL scanner

No Ads, Clean, Simple open source QR Code URL scanner  
Check URL by Google Safe Browsing before open.  

![Alt text](readme-iamges/intro.gif?raw=true "intro gif")

### Google Safe Browsing: On, Open Automatically: On
URL open automatically if checking passed, prompt to ask if failed.

### Google Safe Browsing: On, Open Automatically: Off
All scanned URL will prompt to ask with checking result.

### Google Safe Browsing: Off, Open Automatically: On
All scanned URL will open automatically WITHOUT prompt.

### Google Safe Browsing: Off, Open Automatically: Off
All scanned URL will prompt to ask but without url status.

## App store available
If you don't want to make it complicated to clone this project, or you want to support this project / me,  
you may download this app simply at app store https://itunes.apple.com/us/app/qr-blank/id1137064763?mt=8 ,  
it will cost you less thank a buck. Thanks:)

## Edit to your Google API key
First, to get your Google API key, please refer to: https://developers.google.com/safe-browsing/v4/get-started  
After you got your api key, simply put it here at 'ViewController.swift' in the project.  
```swift
let googleAPIKey = "Your Google API key here"
```

## App Screen
![Alt text](readme-iamges/screenA.jpeg?raw=true "screen A")
![Alt text](readme-iamges/screenB.jpeg?raw=true "screen B")
