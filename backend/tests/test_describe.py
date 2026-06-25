"""
Keyless round-trip tests for POST /describe using the mock provider.
No cloud credentials required — VISION_PROVIDER defaults to "mock".
"""

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app

_FAKE_JPEG = b"\xff\xd8\xff\xe0" + b"\x00" * 16  # minimal fake JPEG header


@pytest.mark.asyncio
async def test_health():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        r = await client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


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
