from typing import Optional, List, Dict
import httpx
import base64
import io
from PIL import Image
import google.generativeai as genai

from app.core.config import settings


class AIDesignService:
    """Service for AI-powered fabric design, risk analysis, and QC"""
    
    @staticmethod
    async def generate_design_gemini(prompt: str) -> str:
        """Generate fabric design using Google Gemini Pro Vision"""
        
        if not settings.GEMINI_API_KEY:
            raise ValueError("Gemini API key not configured")
        
        genai.configure(api_key=settings.GEMINI_API_KEY)
        model = genai.GenerativeModel('gemini-pro-vision')
        
        # Placeholder for actual image generation via Imagen
        return "https://placeholder-image-url.com/design.png"
    
    @staticmethod
    async def analyze_risk_nlp(news_snippet: str) -> Dict:
        """RiskRadar: Use Gemini to analyze supply chain risks from news"""
        if not settings.GEMINI_API_KEY:
            return {"risk_level": "Unknown", "impact_score": 0.0}
            
        genai.configure(api_key=settings.GEMINI_API_KEY)
        model = genai.GenerativeModel('gemini-pro')
        
        prompt = f"""
        Analyze the following supply chain news snippet and determine the risk level (Low, Medium, High) 
        and an impact score (0.0 to 1.0) for textile manufacturers in the region mentioned.
        News: {news_snippet}
        
        Format the output as JSON: {{"risk_level": "...", "impact_score": 0.0, "reason": "..."}}
        """
        
        response = model.generate_content(prompt)
        # In production, parse the JSON response. For now, simulate:
        return {
            "risk_level": "High",
            "impact_score": 0.8,
            "reason": "Port strike detected in sourcing region"
        }

    @staticmethod
    async def detect_defects_yolo(image_data: str) -> List[Dict]:
        """EdgeGuard: Detect defects using YOLO (Mocked for now)"""
        # This would normally load a .pt or .onnx model
        # For simulation, we return predefined defects
        return [
            {"type": "Hole", "confidence": 0.98, "location": {"x": 120, "y": 450}},
            {"type": "Stain", "confidence": 0.85, "location": {"x": 800, "y": 210}}
        ]

    @staticmethod
    async def generate_design_stable_diffusion(prompt: str) -> str:
        """Generate fabric design using Stable Diffusion API"""
        
        if not settings.STABLE_DIFFUSION_API_KEY:
            raise ValueError("Stable Diffusion API key not configured")
        
        # Enhance the prompt
        enhanced_prompt = f"""High-quality seamless textile pattern, {prompt}, 
        professional fabric design, tileable, 4K resolution, photorealistic texture, 
        suitable for textile manufacturing"""
        
        # Stable Diffusion API call
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image",
                headers={
                    "Authorization": f"Bearer {settings.STABLE_DIFFUSION_API_KEY}",
                    "Content-Type": "application/json",
                },
                json={
                    "text_prompts": [
                        {
                            "text": enhanced_prompt,
                            "weight": 1
                        },
                        {
                            "text": "blurry, low quality, distorted, non-seamless",
                            "weight": -1
                        }
                    ],
                    "cfg_scale": 7,
                    "height": 1024,
                    "width": 1024,
                    "samples": 1,
                    "steps": 30,
                }
            )
            
            if response.status_code == 200:
                data = response.json()
                image_data = data["artifacts"][0]["base64"]
                return f"data:image/png;base64,{image_data}"
            else:
                raise Exception(f"Stable Diffusion API error: {response.text}")
    
    @staticmethod
    async def calculate_bom(
        fabric_type: str,
        quantity_meters: int,
        thread_count: int,
        gsm: int
    ) -> list:
        """Calculate Bill of Materials for a fabric order"""
        bom_items = []
        
        # Calculate thread requirements based on fabric type and specs
        if fabric_type.lower() == "cotton":
            thread_weight_per_meter = (gsm / 1000) * 1.5  # kg per meter
            total_thread_kg = thread_weight_per_meter * quantity_meters
            
            bom_items.append({
                "material_name": f"Cotton Thread {thread_count}s",
                "material_type": "Thread",
                "quantity_required": round(total_thread_kg, 2),
                "unit": "kg",
                "estimated_cost": round(total_thread_kg * 15, 2)
            })
        
        elif fabric_type.lower() == "polyester":
            thread_weight_per_meter = (gsm / 1000) * 1.3
            total_thread_kg = thread_weight_per_meter * quantity_meters
            
            bom_items.append({
                "material_name": f"Polyester Thread {thread_count}s",
                "material_type": "Thread",
                "quantity_required": round(total_thread_kg, 2),
                "unit": "kg",
                "estimated_cost": round(total_thread_kg * 12, 2)
            })
        
        elif fabric_type.lower() == "silk":
            thread_weight_per_meter = (gsm / 1000) * 1.2
            total_thread_kg = thread_weight_per_meter * quantity_meters
            
            bom_items.append({
                "material_name": f"Silk Thread {thread_count}s",
                "material_type": "Thread",
                "quantity_required": round(total_thread_kg, 2),
                "unit": "kg",
                "estimated_cost": round(total_thread_kg * 50, 2)
            })
        
        # Add dye requirements (10% of thread weight)
        dye_kg = sum(item["quantity_required"] for item in bom_items) * 0.1
        bom_items.append({
            "material_name": "Textile Dye (Color as per design)",
            "material_type": "Dye",
            "quantity_required": round(dye_kg, 2),
            "unit": "kg",
            "estimated_cost": round(dye_kg * 25, 2)
        })
        
        # Add chemical requirements
        bom_items.append({
            "material_name": "Finishing Chemicals",
            "material_type": "Chemical",
            "quantity_required": round(quantity_meters * 0.05, 2),
            "unit": "liters",
            "estimated_cost": round(quantity_meters * 0.05 * 8, 2)
        })
        
        return bom_items
