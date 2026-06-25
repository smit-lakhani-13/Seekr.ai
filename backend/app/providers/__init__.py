import os
from abc import ABC, abstractmethod


class VisionProvider(ABC):
    name: str

    @abstractmethod
    async def describe(
        self,
        image_bytes: bytes,
        task: str,
        question: str | None = None,
    ) -> str: ...


def get_provider() -> VisionProvider:
    """Select provider via VISION_PROVIDER env var (default: mock)."""
    provider = os.getenv("VISION_PROVIDER", "mock")
    if provider == "azure_openai":
        from .azure_openai_provider import AzureOpenAIProvider  # noqa: PLC0415
        return AzureOpenAIProvider()
    from .mock_provider import MockProvider  # noqa: PLC0415
    return MockProvider()
