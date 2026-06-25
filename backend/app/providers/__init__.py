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


class VisionProviderError(RuntimeError):
    """Sanitized provider failure safe to expose as an upstream error."""


def get_provider() -> VisionProvider:
    """Select provider via VISION_PROVIDER env var (default: mock)."""
    import warnings  # noqa: PLC0415

    provider = os.getenv("VISION_PROVIDER", "mock")
    if provider == "azure_openai":
        missing = []
        if not os.getenv("AZURE_OPENAI_ENDPOINT"):
            missing.append("AZURE_OPENAI_ENDPOINT")
        if not (os.getenv("AZURE_OPENAI_KEY") or os.getenv("AZURE_OPENAI_API_KEY")):
            missing.append("AZURE_OPENAI_KEY or AZURE_OPENAI_API_KEY")
        if missing:
            warnings.warn(
                f"VISION_PROVIDER=azure_openai but {missing} not set. "
                "Falling back to mock provider. "
                "Set the missing env vars to enable real vision calls.",
                RuntimeWarning,
                stacklevel=2,
            )
        else:
            from .azure_openai_provider import AzureOpenAIProvider  # noqa: PLC0415
            return AzureOpenAIProvider()
    from .mock_provider import MockProvider  # noqa: PLC0415
    return MockProvider()
