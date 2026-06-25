from typing import Literal
from pydantic import BaseModel

TaskType = Literal["scene", "ocr", "vqa", "product"]


class DescribeResponse(BaseModel):
    text: str
    provider: str  # "mock" or "azure_openai" — never log image data


class DescribeJsonRequest(BaseModel):
    image_base64: str
    task: TaskType = "scene"
    question: str | None = None
