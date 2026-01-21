from typing import Optional
import httpx
import base64
import io
from PIL import Image

from app.core.config import settings


class AIDesignService:
    """Service for AI-powered fabric design generation"""
    
    @staticmethod
    async def generate_design_gemini(prompt: str) -> str:
        """Generate fabric design using Google Gemini Pro Vision"""
        
        if not settings.GEMINI_API_KEY:
            raise ValueError("Gemini API key not configured")
        
        # Enhance the prompt for better fabric design results
        enhanced_prompt = f"""Create a seamless, high-resolution textile pattern for fabric manufacturing.
        Design requirements: {prompt}
        Style: Professional textile design, seamless pattern, flat lay, high texture quality, 
        suitable for fabric printing. The pattern should be tileable and repeat seamlessly."""
        
        import google.generativeai as genai
        
        genai.configure(api_key=settings.GEMINI_API_KEY)
        
        # Use Gemini Pro Vision for image generation
        model = genai.GenerativeModel('gemini-pro-vision')
        
        # Note: As of now, Gemini doesn't directly generate images
        # You'd need to use Imagen or another image generation API
        # This is a placeholder for the logic
        
        # For now, return a placeholder
        return "https://placeholder-image-url.com/design.png"
    
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
                # Get the base64 image
                image_data = data["artifacts"][0]["base64"]
                
                # TODO: Upload to S3 or cloud storage and return URL
                # For now, return a placeholder
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
        
        # Simple BOM calculation logic
        # In production, this would be more sophisticated
        
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
                "estimated_cost": round(total_thread_kg * 15, 2)  # $15 per kg estimate
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
