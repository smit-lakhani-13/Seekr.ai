from . import VisionProvider

_RESPONSES: dict[str, str] = {
    "scene": "A well-lit room. A person is standing near a window on your left. Two chairs are visible ahead.",
    "ocr": "Sign reads: Exit. Arrow pointing right.",
    "vqa": "The object appears to be blue.",
    "product": "Product: whole milk, one litre. Best before: five days from today.",
}


class MockProvider(VisionProvider):
    name = "mock"

    async def describe(
        self,
        image_bytes: bytes,
        task: str,
        question: str | None = None,
    ) -> str:
        return _RESPONSES.get(task, "Unable to describe. Please try again.")
