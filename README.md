# By Faith App

A cross platform application built with Flutter, designed to provide resources for reading, studying, praying, evangelism and missions.

## Features

- **Onboarding:** Non-Christian and Christian onboarding.
- **Home:** Features a dashboard.
- **Gospel:** Content related to the Gospel, and integration of osm map data, for         geographical context related to soul winning or missions. Also Offline support with Map Markers to Contact Management.
- **Pray:** Features to support a prayer life, create and share your prayers.
- **Read:** Read the KJV Bible, auto scrolling and save your bookmarks or favorite versus.
- **Study:** Tools and resources for in-depth study of the scriptures using Strong's Greek and Hebrew Numbers, KJV definitions, Websters 1828 dictionary. Every scripture verse can be notated with Notes Manager.

## Getting Started

This project is a Flutter application. To get started:

1. Ensure you have Flutter installed. Follow the official guide: [Install Flutter](https://docs.flutter.dev/get-started/install)
2. Clone the repository:
   ```bash
   git clone <repository_url>
   ```
3. Navigate to the project directory:
   ```bash
   cd by_faith_app
   ```
4. Get the project dependencies:
   ```bash
   flutter pub get
   ```
5. Run the app on a connected device or emulator:
   ```bash
   flutter run
   ```

## Instructions Use

1. Onboarding, every user has to onboard and create profile to use the app, once profile is created the onboarding will not appear again. Also no data is collected your data stays on your device. The onboard has a skip button during testing but will be disabled in production.
2. Navigation, there are two ways to navigate through the pages with tabs and links in dashboard by clicking the data cards. Also all pages have menu button on top right.
3. Maps & Markers, the world map is default online osm map. To use offline maps click menu and press "Select your own map" button and zoom out and move map around until the blue box is in the area you want to select then zoom down until you see street names, then click "Download Map" button. Be careful and look at the download size before clicking download, the further you zoom down the higher the download size. When you add marker it will auto create a new contact that you need to fill out and save before it appears on map. 
4. Prayers, after creating a new prayer swipe right to change status and swipe left to delete, and to share the prayer it has to be in Unanswered status. Only sharing through Social Media works but atm Offline Export does not.
5. Bible Reader, to add bookmarks or favorites click on the verse numbers and for auto scrolling to work turn on in settings first the go back and click full screen mode top left then it will start automatically.
6. Bible Study, to add bible notes click on the verse number and it will add the verse to Bible Notes category the click edit to add note, for Study and Peronal notes click the Add Note + top right in Notes. To access the 1828 Websters Dictionary you have to do a word Search that has search results for dictionary and bible.
7. Backup & Export, caution there is no data backup option yet during testing so be aware that you can lose your data and have to start over. 



## Screens

#Linux
![Linux Dashboard](lib/assets/screenshots/linux/linux_dashboard.png)
![Linux Gospel](lib/assets/screenshots/linux/linux_gospel.png)
![Linux Pray](lib/assets/screenshots/linux/linux_pray.png)
![Linux Read](lib/assets/screenshots/linux/linux_read.png)
![Linux Study](lib/assets/screenshots/linux/linux_study.png)

#Android
![Android Dashboard](lib/assets/screenshots/android/android_dashboard.png)
![Android Gospel](lib/assets/screenshots/android/android_gospel.png)
![Android Pray](lib/assets/screenshots/android/android_pray.png)
![Android Read](lib/assets/screenshots/android/android_read.png)
![Android Study](lib/assets/screenshots/android/android_study.png)

## Contributing

Contributions are welcome! Please see the CONTRIBUTING.md (if it exists) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
