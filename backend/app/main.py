from fastapi import FastAPI, File, Form, HTTPException, UploadFile

from .models import DescribeResponse
from .providers import get_provider

app = FastAPI(title="Seekr Vision API", version="0.1.0")

_VALID_TASKS = {"scene", "ocr", "vqa", "product"}
_MAX_IMAGE_BYTES = 5 * 1024 * 1024  # 5 MB hard cap; phone camera source targets <150 KB


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/describe", response_model=DescribeResponse)
async def describe(
    image: UploadFile = File(..., description="JPEG image from the wearable camera"),
    task: str = Form("scene", description="scene | ocr | vqa | product"),
    question: str | None = Form(None, description="Question for vqa task"),
) -> DescribeResponse:
    if task not in _VALID_TASKS:
        raise HTTPException(status_code=422, detail=f"task must be one of {sorted(_VALID_TASKS)}")

    image_bytes = await image.read()
    if len(image_bytes) > _MAX_IMAGE_BYTES:
        raise HTTPException(status_code=413, detail="Image exceeds 5 MB limit")
    if not image_bytes:
        raise HTTPException(status_code=422, detail="Empty image")

    # ponytail: provider instantiated per-request; fine for mock, acceptable for azure (stateless HTTP).
    provider = get_provider()
    text = await provider.describe(image_bytes=image_bytes, task=task, question=question)
    return DescribeResponse(text=text, provider=provider.name)
