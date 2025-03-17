from flask import Flask, request, jsonify
import torch
import cv2
import numpy as np
from ultralytics import YOLO
from PIL import Image
import io

app = Flask(__name__)

# Load YOLO model - using YOLOv11 for better performance
yolo_model = YOLO("yolov12x.pt")  # Updated to YOLOv12

# Custom class mapping for common objects
CUSTOM_CLASSES = {
    'pen': ['pen', 'pencil', 'writing implement'],
    'door': ['door', 'entrance', 'gate'],
    # Add more custom mappings as needed
}

def preprocess_image(img):
    """
    Preprocess image for better detection
    """
    # Convert to RGB (YOLO expects RGB)
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # Enhance contrast
    lab = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2LAB)
    l, a, b = cv2.split(lab)
    clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8,8))
    cl = clahe.apply(l)
    enhanced = cv2.merge((cl,a,b))
    
    # Convert back to RGB
    enhanced_rgb = cv2.cvtColor(enhanced, cv2.COLOR_LAB2RGB)
    
    return enhanced_rgb

def refine_bbox(img, bbox, padding_percent=0.02):
    """
    Refined bounding box detection with improved contour detection
    """
    x1, y1, x2, y2 = [int(coord) for coord in bbox]
    
    # Extract ROI
    roi = img[y1:y2, x1:x2]
    if roi.size == 0:
        return bbox
    
    # Convert to grayscale
    gray = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
    
    # Apply Gaussian blur to reduce noise
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    
    # Use adaptive thresholding for better segmentation
    thresh = cv2.adaptiveThreshold(
        blurred, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, 
        cv2.THRESH_BINARY, 11, 2
    )
    
    # Find contours with hierarchy
    contours, hierarchy = cv2.findContours(
        thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
    )
    
    if not contours:
        return bbox
    
    # Filter contours by area
    min_area = (x2-x1)*(y2-y1)*0.01  # 1% of bbox area
    valid_contours = [cnt for cnt in contours if cv2.contourArea(cnt) > min_area]
    
    if not valid_contours:
        return bbox
    
    # Combine all valid contours
    all_points = np.concatenate(valid_contours)
    x, y, w, h = cv2.boundingRect(all_points)
    
    # Adjust coordinates relative to original image
    refined_x1 = x1 + x
    refined_y1 = y1 + y
    refined_x2 = refined_x1 + w
    refined_y2 = refined_y1 + h
    
    # Add padding
    padding_x = int(w * padding_percent)
    padding_y = int(h * padding_percent)
    
    refined_x1 = max(0, refined_x1 - padding_x)
    refined_y1 = max(0, refined_y1 - padding_y)
    refined_x2 = min(img.shape[1], refined_x2 + padding_x)
    refined_y2 = min(img.shape[0], refined_y2 + padding_y)
    
    return [refined_x1, refined_y1, refined_x2, refined_y2]

def match_custom_class(label):
    """
    Match detected label with custom classes
    """
    for custom_class, aliases in CUSTOM_CLASSES.items():
        if any(alias in label.lower() for alias in aliases):
            return custom_class
    return label

def process_detections(img, results, conf_threshold=0.3):  # Lowered confidence threshold
    detections = []
    object_counts = {}
    
    for result in results:
        boxes = result.boxes.xyxy.cpu().numpy()
        scores = result.boxes.conf.cpu().numpy()
        class_ids = result.boxes.cls.cpu().numpy().astype(int)
        names = result.names
        
        for i in range(len(boxes)):
            if scores[i] >= conf_threshold:
                label = names[class_ids[i]]
                
                # Match with custom classes
                custom_label = match_custom_class(label)
                
                # Refine bounding box
                refined_bbox = refine_bbox(img, boxes[i])
                
                # Convert to integers
                bbox = [int(coord) for coord in refined_bbox]
                
                detections.append({
                    "label": custom_label,
                    "confidence": float(scores[i] * 100),
                    "bbox": bbox,
                    "original_label": label  # Keep original label for reference
                })
                object_counts[custom_label] = object_counts.get(custom_label, 0) + 1
    
    return detections, object_counts

@app.route("/detect", methods=["POST"])
def detect():
    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400
    
    try:
        # Read image file
        file = request.files["image"].read()
        npimg = np.frombuffer(file, np.uint8)
        img = cv2.imdecode(npimg, cv2.IMREAD_COLOR)
        
        if img is None:
            return jsonify({"error": "Invalid image format"}), 400
        
        # Preprocess image
        processed_img = preprocess_image(img)
        
        # Run detection with augmentation
        results = yolo_model(
            processed_img,
            conf=0.3,  # Lower confidence threshold
            iou=0.45,  # Adjusted IOU threshold
            augment=True,  # Enable test time augmentation
            device='cpu' if not torch.cuda.is_available() else 'cuda',
            verbose=False
        )
        
        detections, object_counts = process_detections(img, results)
        
        return jsonify({
            "detections": detections,
            "objectCounts": object_counts,
            "model_info": {
                "model": "YOLOv11",
                "confidence_threshold": 0.3,
                "iou_threshold": 0.45
            }
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)