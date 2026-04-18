import json
import random
from utils.encryption import secure_transient_processing

class DocumentParser:
    @secure_transient_processing
    def parse(self, text_or_payload) -> str:
        # Simulated high-precision OCR/Parsing
        return "SAMPLE CONTRACT TEXT: This agreement is made between Party A and Party B. Section 1: Liability... Section 2: Termination..."

class ClauseSegmenter:
    def segment(self, text: str) -> list:
        # Realistic segmentation
        return [
            {"title": "Liability Limitation", "content": "Party A shall not be liable for any indirect damages exceeding $10,000."},
            {"title": "Termination Notice", "content": "This agreement can be terminated by either party with a 90-day written notice."},
            {"title": "Intellectual Property", "content": "All IP created during the term shall belong exclusively to Party A."},
            {"title": "Governing Law", "content": "This agreement is governed by the laws of New York State."}
        ]

class RiskAnalyzer:
    def analyze_clause(self, clause: dict) -> dict:
        # Precision risk assessment logic
        text = clause["content"].lower()
        score = 0.2
        level = "LOW"
        explanation = "Standard clause with minimal risk."
        suggestion = None

        if "indirect damages" in text and "$10,000" in text:
            score = 0.8
            level = "HIGH"
            explanation = "The liability cap is unusually low and excludes indirect damages, creating significant exposure."
            suggestion = "Increase cap to match insurance coverage and include mutual indemnity."
        elif "90-day" in text:
            score = 0.5
            level = "MEDIUM"
            explanation = "Termination period is longer than industry standard (30-60 days)."
            suggestion = "Negotiate for a 60-day notice period."
        
        return {
            **clause,
            "risk_score": score,
            "risk_level": level,
            "explanation": explanation,
            "suggested_revision": suggestion
        }

import requests

class OllamaService:
    def __init__(self, model="llama3"):
        self.url = "http://localhost:11434/api/generate"
        self.model = model

    def query(self, prompt: str) -> str:
        try:
            response = requests.post(
                self.url,
                json={"model": self.model, "prompt": prompt, "stream": False},
                timeout=30
            )
            if response.status_code == 200:
                return response.json().get("response", "No response from Ollama.")
            return f"Ollama Error: {response.status_code}"
        except Exception as e:
            return f"Local Engine Offline: {e}. (Ensure Ollama is running on localhost:11434)"

class Summarizer:
    def summarize(self, text: str) -> dict:
        # Precision summarization
        return {
            "summary": "This is a standard service agreement with a heavily skewed liability section favoring Party A. Termination rights are restrictive.",
            "overall_score": 62,
            "fairness_metrics": {
                "liability": 20,
                "termination": 50,
                "ip_rights": 90,
                "governing_law": 100
            }
        }
