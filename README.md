# 🎥 Video Capture iOS App

An iOS application built with UIKit using the **MVVM architecture**, which allows users to record short videos (up to 30 seconds), preview them, add metadata (title and description), and manage them through a searchable and editable list. Videos are stored locally and metadata is saved using Core Data. Smooth user experience with permission handling, search, AVPlayer video playback, and intuitive swipe-to-delete gesture.

---

## 📲 Features

* TableView displaying a list of user-recorded videos.
* `+` button on the Navigation Bar to open the camera view.
* Permission handling for **Camera** and **Microphone**:

  * If permissions are not granted, an alert is shown.
  * Users are redirected to app **Settings** to enable access.
* Record videos with a maximum duration of **30 seconds**.
* Save recorded videos in the app's **Documents Directory**.
* Preview screen after recording:

  * Watch the video.
  * Add a **Title** and **Description**.
  * Save video metadata to **Core Data**.
* Video listing:

  * Search by video title.
  * Swipe-to-delete gesture.
  * Tap to play using `AVPlayerViewController`.

---

## 📁 Setup Instructions

1. Clone the repository:

   ```bash
   https://github.com/tanmaydeo/Field-Reporter.git
   ```

2. Open the project in **Xcode** (version 15 or above recommended).

3. Run the project on a real device (Camera and Microphone access not supported in Simulator).

4. When prompted, **grant Camera and Microphone permissions**.

5. Record a video, preview, and save metadata to begin populating the list.

---

## 📄 Architecture Overview

This app follows **MVVM (Model-View-ViewModel)** architecture with a clear separation of concerns:

### Model:

* Represents video metadata: title, description, file path.
* Stored using **Core Data**.

### ViewModel:

* Contains business logic and state management.
* Binds data to views using **closures** for reactive UI updates.
* Handles:

  * Permission logic
  * Video recording flow
  * File management
  * Core Data interactions

### View:

* UIKit-based UI components (`UIViewController`, `UITableView`, etc.).
* Lightweight views observing data via ViewModel closures.
* Navigation between camera, preview, and player screens.

---

## 🚫 Assumptions & Known Issues

### Assumptions

* Videos are stored only locally; no cloud sync or sharing implemented.
* No third-party libraries used for camera or AV playback.

### Known Issues

* **Landscape mode is disabled**. Only portrait orientation is supported.
* **Dark Mode/Light Mode is not handled** explicitly.

  * UI defaults to system appearance.
  * Could be enhanced with proper theming support.

Given more time, both of these issues would be properly addressed.

---

## 🚀 Future Enhancements

* Add custom theming for Dark/Light mode.
* Support landscape orientation.
* Add video duration and thumbnail previews in list.
* Allow editing video metadata.
* Add export/share functionality.

---

## 📈 Tech Stack

* **Swift** & **UIKit**
* **AVFoundation** for recording and playback
* **Core Data** for persistent storage
* **MVVM** architecture with closure-based binding
* **FileManager** for saving videos in Document Directory
