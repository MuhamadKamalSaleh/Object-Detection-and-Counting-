# Object Detection and Counting Using YOLO

## Introduction
This project focuses on real-time and image-based object detection and counting using the YOLO (You Only Look Once) deep learning model. The system processes images from both the camera and gallery, detects objects, identifies their types, and counts similar objects. The goal is to achieve high accuracy and speed in detection, with precise bounding box placement.

## Features
- Real-time object detection using a live camera feed
- Image-based object detection from the gallery
- Bounding box visualization around detected objects
- Object classification and counting
- Integration with a Flutter frontend for an interactive user interface
- Backend processing using Flask and Python
- Support for different YOLO models to enhance accuracy

## Technologies Used
- **Deep Learning Model:** YOLO (You Only Look Once)
- **Programming Languages:** Python, Dart (Flutter)
- **Frameworks and Libraries:**
  - OpenCV (Image Processing)
  - TensorFlow/PyTorch (YOLO Implementation)
  - Flask (Backend API)
  - Flutter (Mobile UI)

## Setup and Installation
### 1. Clone the Repository
```sh
git clone https://github.com/yourusername/object-detection-yolo.git
cd object-detection-yolo
```

### 2. Install Dependencies
#### Backend (Python + Flask)
```sh
pip install -r requirements.txt
```
#### Frontend (Flutter)
```sh
flutter pub get
```

### 3. Download YOLO Weights
Download the pre-trained YOLO weights (e.g., YOLOv5, YOLOv8) and place them in the `models/` directory.

### 4. Run the Backend Server
```sh
python app.py
```

### 5. Run the Flutter App
```sh
flutter run
```

## Usage
1. Open the mobile application.
2. Choose either **Real-time Detection** (Camera) or **Image Upload** (Gallery).
3. The system will process the input and detect objects.
4. The detected objects will be highlighted with bounding boxes and counted.
5. View the results on the UI with object labels and count.

## Future Enhancements
- Implementing model optimization for faster processing
- Adding support for custom-trained YOLO models
- Enhancing UI/UX with real-time analytics and visualizations

## Contributing
Contributions are welcome! Feel free to fork the repository and submit pull requests.

## License
This project is licensed under the MIT License.

## Contact
For inquiries or collaborations, please reach out at [muhamadkamal1298@gmail.com].

