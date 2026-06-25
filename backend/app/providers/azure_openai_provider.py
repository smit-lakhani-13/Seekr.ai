"""
Azure OpenAI vision provider.

Required env vars (TODO(human): set before enabling):
  AZURE_OPENAI_ENDPOINT  — e.g. https://your-resource.openai.azure.com
  AZURE_OPENAI_KEY or AZURE_OPENAI_API_KEY — your Azure API key
  AZURE_OPENAI_DEPLOYMENT — deployment name (default: gpt-5.4-mini)
  AZURE_OPENAI_API_VERSION — API version (default: 2024-05-01-preview)

Enable: set VISION_PROVIDER=azure_openai
Security: image bytes are sent over TLS; never logged server-side.
"""

import base64
import os

import httpx

from . import VisionProvider

_TASK_PROMPTS: dict[str, str] = {
    "scene": (
        "Describe this scene briefly for a blind person. "
        "Mention objects, people, and layout. Two sentences max."
    ),
    "ocr": "Read all visible text in this image. Report it exactly as written.",
    "vqa": "Answer this question about the image: {question}. One sentence.",
    "product": (
        "Identify this product. State its name, size, and any expiry date visible. "
        "One sentence."
    ),
}


class AzureOpenAIProvider(VisionProvider):
    name = "azure_openai"

    def __init__(self) -> None:
        # Fail fast at construction time so misconfiguration surfaces immediately.
        self._endpoint = os.environ["AZURE_OPENAI_ENDPOINT"].rstrip("/")
        self._key = os.getenv("AZURE_OPENAI_KEY") or os.environ["AZURE_OPENAI_API_KEY"]
        self._deployment = os.getenv("AZURE_OPENAI_DEPLOYMENT", "gpt-5.4-mini")
        self._api_version = os.getenv("AZURE_OPENAI_API_VERSION", "2024-05-01-preview")

    async def describe(
        self,
        image_bytes: bytes,
        task: str,
        question: str | None = None,
    ) -> str:
        prompt = _TASK_PROMPTS.get(task, _TASK_PROMPTS["scene"])
        if task == "vqa":
            prompt = prompt.format(question=question or "What do you see?")

        b64 = base64.b64encode(image_bytes).decode()
        url = (
            f"{self._endpoint}/openai/deployments/{self._deployment}"
            f"/chat/completions?api-version={self._api_version}"
        )
        payload = {
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{b64}",
                                "detail": "low",  # low = faster + cheaper; sufficient for assistive use
                            },
                        },
                        {"type": "text", "text": prompt},
                    ],
                }
            ],
            "max_tokens": 150,
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            r = await client.post(
                url,
                json=payload,
                headers={"api-key": self._key, "Content-Type": "application/json"},
            )
            r.raise_for_status()
            data = r.json()
            return data["choices"][0]["message"]["content"].strip()
