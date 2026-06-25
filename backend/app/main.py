import base64
import binascii

from fastapi import FastAPI, File, Form, HTTPException, UploadFile

from .models import DescribeJsonRequest, DescribeResponse
from .providers import VisionProviderError, get_provider

app = FastAPI(title="Seekr Vision API", version="0.1.0")

_VALID_TASKS = {"scene", "ocr", "vqa", "product"}
_MAX_IMAGE_BYTES = 5 * 1024 * 1024  # 5 MB hard cap; phone camera source targets <150 KB


@app.get("/health")
async def health() -> dict[str, str]:
    provider = get_provider()
    return {"status": "ok", "provider": provider.name}


@app.post("/describe", response_model=DescribeResponse)
async def describe(
    image: UploadFile = File(..., description="JPEG image from the wearable camera"),
    task: str = Form("scene", description="scene | ocr | vqa | product"),
    question: str | None = Form(None, description="Question for vqa task"),
) -> DescribeResponse:
    image_bytes = await image.read()
    return await _describe_bytes(image_bytes=image_bytes, task=task, question=question)


@app.post("/describe_json", response_model=DescribeResponse)
async def describe_json(payload: DescribeJsonRequest) -> DescribeResponse:
    try:
        image_bytes = base64.b64decode(payload.image_base64, validate=True)
    except (binascii.Error, ValueError) as exc:
        raise HTTPException(status_code=422, detail="Invalid base64 image") from exc
    return await _describe_bytes(
        image_bytes=image_bytes,
        task=payload.task,
        question=payload.question,
    )


async def _describe_bytes(
    image_bytes: bytes,
    task: str,
    question: str | None = None,
) -> DescribeResponse:
    if task not in _VALID_TASKS:
        raise HTTPException(status_code=422, detail=f"task must be one of {sorted(_VALID_TASKS)}")

    if len(image_bytes) > _MAX_IMAGE_BYTES:
        raise HTTPException(status_code=413, detail="Image exceeds 5 MB limit")
    if not image_bytes:
        raise HTTPException(status_code=422, detail="Empty image")

    # Provider is stateless; per-request construction keeps mock/live selection simple.
    provider = get_provider()
    try:
        text = await provider.describe(image_bytes=image_bytes, task=task, question=question)
    except VisionProviderError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    return DescribeResponse(text=text, provider=provider.name)
