from typing import Literal
from pydantic import BaseModel

TaskType = Literal["scene", "ocr", "vqa", "product"]


class DescribeResponse(BaseModel):
    text: str
    provider: str  # "mock" or "azure_openai" — never log image data
