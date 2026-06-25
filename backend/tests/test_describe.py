"""
Keyless round-trip tests for POST /describe using the mock provider.
No cloud credentials required — VISION_PROVIDER defaults to "mock".
"""

import pytest
from httpx import ASGITransport, AsyncClient

from app import main as main_module
from app.main import app
from app.providers import VisionProvider, VisionProviderError
from app.providers.azure_openai_provider import AzureOpenAIProvider

_FAKE_JPEG = b"\xff\xd8\xff\xe0" + b"\x00" * 16  # minimal fake JPEG header


@pytest.mark.asyncio
async def test_health():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        r = await client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok", "provider": "mock"}


@pytest.mark.asyncio
async def test_describe_scene_default():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        r = await client.post(
            "/describe",
            files={"image": ("frame.jpg", _FAKE_JPEG, "image/jpeg")},
        )
    assert r.status_code == 200
    body = r.json()
    assert "text" in body and body["text"]
    assert body["provider"] == "mock"


@pytest.mark.asyncio
async def test_describe_ocr():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        r = await client.post(
            "/describe",
            files={"image": ("frame.jpg", _FAKE_JPEG, "image/jpeg")},
            data={"task": "ocr"},
        )
    assert r.status_code == 200
    assert r.json()["provider"] == "mock"


@pytest.mark.asyncio
async def test_describe_vqa_with_question():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        r = await client.post(
            "/describe",
            files={"image": ("frame.jpg", _FAKE_JPEG, "image/jpeg")},
            data={"task": "vqa", "question": "What colour is this?"},
        )
    assert r.status_code == 200
    assert r.json()["provider"] == "mock"


@pytest.mark.asyncio
async def test_invalid_task_returns_422():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        r = await client.post(
            "/describe",
            files={"image": ("frame.jpg", _FAKE_JPEG, "image/jpeg")},
            data={"task": "invalid_task"},
        )
    assert r.status_code == 422


@pytest.mark.asyncio
async def test_oversized_image_returns_413():
    big_image = b"\xff\xd8\xff" + b"\x00" * (5 * 1024 * 1024 + 1)
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        r = await client.post(
            "/describe",
            files={"image": ("big.jpg", big_image, "image/jpeg")},
        )
    assert r.status_code == 413


@pytest.mark.asyncio
async def test_empty_image_returns_422():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        r = await client.post(
            "/describe",
            files={"image": ("empty.jpg", b"", "image/jpeg")},
        )
    assert r.status_code == 422


def test_azure_provider_trims_secret_env_values(monkeypatch: pytest.MonkeyPatch):
    monkeypatch.setenv("AZURE_OPENAI_ENDPOINT", "https://example.openai.azure.com/\n")
    monkeypatch.setenv("AZURE_OPENAI_API_KEY", "test-key\n")
    monkeypatch.setenv("AZURE_OPENAI_DEPLOYMENT", "gpt-5.4-mini\n")
    monkeypatch.setenv("AZURE_OPENAI_API_VERSION", "2024-05-01-preview\n")

    provider = AzureOpenAIProvider()

    assert provider._endpoint == "https://example.openai.azure.com"
    assert provider._key == "test-key"
    assert provider._deployment == "gpt-5.4-mini"
    assert provider._api_version == "2024-05-01-preview"


@pytest.mark.asyncio
async def test_provider_error_returns_502(monkeypatch: pytest.MonkeyPatch):
    class FailingProvider(VisionProvider):
        name = "failing"

        async def describe(
            self,
            image_bytes: bytes,
            task: str,
            question: str | None = None,
        ) -> str:
            raise VisionProviderError("upstream unavailable")

    monkeypatch.setattr(main_module, "get_provider", lambda: FailingProvider())
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        r = await client.post(
            "/describe",
            files={"image": ("frame.jpg", _FAKE_JPEG, "image/jpeg")},
        )

    assert r.status_code == 502
    assert r.json() == {"detail": "upstream unavailable"}
