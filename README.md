
# Ramaz Student Life

This is an app to help Ramaz students navigate their student life.
It tells you what classes you have when, the latest sports news, lost and found information, and more.

## Complete list of features: 
- ### Ramaz login
	You can login with your Ramaz email to get your schedule sent directly to the app!
- ### Schedule explorer
	A complete schedule built-in to your phone. It can tell you what you have now, later, or you can specify a letter and schedule (eg, Rosh Chodesh) to explore your schedule. 
- ### Notes
	You can now schedule reminders for individual classes or periods, such as every B-4 or a reminder to bring your textbook to history class. 
<!-- - ### Lunch -->
<!-- A calendar with all the lunches of the year is right on your phone, so you always know what's for lunch -- and when to use your priveleges. -->
<!-- - ### Sports -->
<!-- See upcoming games across all of Ramaz's sports teams. After the games you can see the score and team's overal record. -->
<!-- - ### Newspapers -->
<!-- Have instant access to all of Ramaz's student publications, including RamPage, XeVeX, Breakthrough, and more. -->
<!-- - ### Lost & Found -->
<!-- Tired of getting notifications every second when something is lost, but still want everyone else to be notified when **you** lose something? The Lost & Found feature introduces a chat-based system that notifies only the people involved. An image-recognition based system is coming soon, so finding your lost objects will require less effort than ever. -->

## Your feedback is appreciated

We want to hear what you have to say, so please use the "Send Feedback" button in the app to tell us what you do -- or don't -- like, and we'll work on it.

# Contributing

This repo is to be modified *only* by the Ramaz Coding Club. It follows a simple yet sophisticated structure, in addition to the standard Flutter folders. Here is a rundown of everything you need to know: 

- ## The `android` folder: 

	This folder contains Android-specific implementation details. The only notable files in it are the gradle configurations: `gradle.properties`, `build.gradle`, and `app\build.gradle` (which have been changed to configured Firebase). An adjustment was made to `gradle\wrapper\gradle-wrapper.properties` to upgrade to the latest version of Gradle. Android-specific assets are stored under `app\src\main\res`, and modifications have been made to `AndroidManifest.xml` accordingly.

- ## The `data` folder: 

	This folder is not meant to be public. It is basically a collection of `.csv` versions of the Ramaz database. The naming convention here is simple: make everything lowercase, remove `RG_`, and make abbreviations into the full word. For example, `RG_SECT_SCHED` should be saved as `data\section_schedule.csv`. This is essential for the data processing (in the `firebase` folder) to work. Also included is the `calendar.csv` file needed for calendar parsing.

- ## The `doc` folder: 

	OK, so this folder is also absent from GitHub. But it's super simple to generate. Just run `dartdoc` in this repo and the full documentation will be saved here.

- ## The `firebase` folder: 

	This folder contains scripts whose sole purpose is to configure Google Firebase. This basically means configuring the database and authentication services based on data from the Ramaz database. It contains two more folders, `data` and `database` whose jobs are to handle data modeling and database configuration, respectively. Another notable file here is `auth.py`, which manages the FirebaseAuth API. 

- ## The `images` folder: 

	This folder contains image assets for the project. They are imported in the `pubspec.yaml` file. There are two child folders: 

	- ### The `icons` folder: 
		This folder contains basic icons used throughout the app

	- ### The `logos` folder: 
		This folder contains logos used for various services throughout the app. Note that despite the use of this iconography, excluding Ramaz, we do not claim any ownership whatsoever of these brands. The `ramaz` folder contains Ramaz-specific branding.

- ## The `ios` folder: 
	
	This folder contains iOS-specific modifications, including Firebase configuration and asset bundling. 

- ## The `lib` folder: 
	
	This is, where the main Dart code lies. This will be discussed in detail next section. 

## Code related folders:

  Inside `lib\`, there are five libraries, each of which define a different part of the structure of the app. Each library two sections -- a folder under `lib\src`, containing all the code, and a file under `lib\`, which declares the library (sort of like a header file).

  - ### The `data` library: 

  	This library contains data models for everything in the app, separated into files by topic. Here, all the business logic is implemented either as complex factories or methods. 

  - ### The `services` library: 

  	This library contains abstractions over many different APIs (data sources), separated into files by API.  

  - ### The `services_collection` library: 

	  This library contains logic for initializing the services. It can act as a wrapper around all the services, so function and constructor signatures can remain the same even after services are added or removed. 

- ### The `models` library: 
		
	This library contains two types of models: 
 	1. Data models. Data models control the state of the data across the lifespan of the app. The user profile is a good example of a data model, since it needs to be accessible to all code. 
 	2. View models. view models control the state of data in an element of UI, such as a page. View models can interact with data models to get their data, and should generally have a field for every label, and a method for every input action in the UI. 

 - ### The `widgets` library: 

  	This folder contains UI elements ("widgets") that are independent enough from the rest of the screen to be able to be imported and used reliably anywhere in the app (even if they in reality aren't). There are a few categories of widgets: 

  	1. Ambient widgets are widgets that are exposed to the whole app (usually via [`InheritedWidgets`](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)).
  	2. Atomic widgets are widgets that represent individual pieces of data. They should be used throughout the app exclusively to represent those data types. 
  	3. Generic widgets are miscellaneous widgets that help compose the UI.
  	4. Other helper widgets to display images and iconography throughout the UI. 

  - ### The `pages` library: 

  	This library contains all the screens of the app, separated into files. These files may import data templates (from `data`), APIs (from `services`), page states (from `models`), or other UI elements (from `widgets`). 

 ## Running the app: 

 To run the app, make sure you have [Flutter](https://flutter.dev) installed, and run these commands: 
	<pre>
		git clone https://github.com/Levi-Lesches/Ramaz-Student-Life.git
		cd ramaz
	</pre>

To be able to run and debug the app, run `flutter run`. To simply download it, run `flutter build apk` or `flutter build ios`, plug in your phone and run `flutter install`.
