import io
import cv2
import numpy as np
from fastapi import FastAPI, UploadFile, File
from ultralytics import YOLO

app = FastAPI(title="EdgeGuard CV Microservice")

# Load model out of request scope so it stays in VRAM
# Replace 'yolov8n.pt' with your custom fabric defect detection weights
try:
    model = YOLO('yolov8n.pt') 
except Exception as e:
    model = None
    print(f"Warning: Could not load YOLO model. Run bare minimum. {e}")

@app.post("/api/detect")
async def detect_defects(file: UploadFile = File(...)):
    """
    Ingests raw image frames from Partner dashboard.
    Returns standard JSON array of bounding boxes for the main backend.
    """
    if not model:
        return {"error": "Model not loaded"}

    contents = await file.read()
    nparr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    # Perform inference
    results = model(img)
    
    defects = []
    
    for r in results:
        boxes = r.boxes
        for box in boxes:
            x1, y1, x2, y2 = box.xyxy[0].tolist()
            cls_id = int(box.cls[0].item())
            conf = float(box.conf[0].item())
            
            defects.append({
                "type": model.names[cls_id],
                "confidence": round(conf, 3),
                "bbox": [int(x1), int(y1), int(x2), int(y2)]
            })

    # You can also generate heavily compressed heatmaps here and stash them to S3/CDN.
    # heatmap_url = s3_upload(img_with_boxes)

    quality_score = 100.0 if not defects else max(0.0, 100.0 - (15.0 * len(defects)))

    return {
        "quality_score": round(quality_score, 1),
        "defects_found": len(defects),
        "defect_details": defects
    }
