# protoColl
This is the source-code for the Playground app for my Colloqium Demo. 
This app is designed for testing layout and performance of my dissertation database. It requires exist-db >2.2, results are best viewed in Chrome. 
Texts are placeholders, the app focuses on layout and performance testing. 

## Data
The data folder contains dummy datasets modeling my sources. These are *NOT* real transcription, but heavily modified materials for testing. You can find out more about the test sets on the wiki here.

## Building
You can follow the link from moodle to see the app running on the cluster's test server. To install a local copy you need the following: 
* exist-db 2.2+
* ant 1.8+


### To install ... 
1. Download, fork or clone this GitHub repository
2. Open the the folder you just downloaded in CLI, type:  
``` cd protoColl ```
3. call ant by typing:
``` ant ```
you should see:
```BUILD SUCCESSFUL```

4. Go to your running exist-db and open package manager from the dashboard. 
  1. Click on the "add package" symbol in the upper left corner
  2. Click on the Upload button, and select the .xar file you just created which is inside the "build" folder.

## Caveat
This app is running on our test-server, in case you receive a 404, please try again after a few minutes. Chances are someone tested something while you were trying to access it.

## Issues
I'm very interessted to hear about bugs or display errors on different computers, if you notice something odd, please open a ticket here on github by clicking on issues. 

