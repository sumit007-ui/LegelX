from fastapi import FastAPI, UploadFile, File
from typing import List
import uvicorn
from services.ai_services import DocumentParser, ClauseSegmenter, RiskAnalyzer, Summarizer
from utils.encryption import encrypt_data


app = FastAPI(title="LegalX AI Backend")

parser = DocumentParser()
segmenter = ClauseSegmenter()
analyzer = RiskAnalyzer()
summarizer = Summarizer()

@app.get("/")
async def root():
    return {"message": "Welcome to LegalX AI API"}

@app.post("/analyze-document")
async def analyze_document(file: UploadFile = File(...)):
    # MODULE A: Client-Side / Entry-Point Encryption
    raw_bytes = await file.read()
    encrypted_payload = encrypt_data(raw_bytes)
    
    # 1. Parse (Receives ciphertext wrapper)
    content = parser.parse(encrypted_payload)
  
    # 2. Segment
    clauses = segmenter.segment(content)
    
    # 3. Analyze Risks (Precision)
    analyzed_clauses = [analyzer.analyze_clause(c) for c in clauses]
    
    # 4. Summarize
    summary_data = summarizer.summarize(content)
    
    return {
        "filename": file.filename,
        "summary": summary_data["summary"],
        "overall_score": summary_data["overall_score"],
        "fairness_metrics": summary_data["fairness_metrics"],
        "clauses": analyzed_clauses
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
