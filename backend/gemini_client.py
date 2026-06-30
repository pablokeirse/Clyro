import time
import logging

from google import genai
from google.genai import errors as genai_errors

from config import settings

logger = logging.getLogger("clyro.gemini")

_client: genai.Client | None = None


def get_client() -> genai.Client:
    global _client
    if _client is None:
        if not settings.GEMINI_API_KEY:
            raise RuntimeError("GEMINI_API_KEY is not configured. Add it to backend/.env")
        _client = genai.Client(api_key=settings.GEMINI_API_KEY)
    return _client


SYSTEM_PROMPT = (
    "You are CLYROAI, the assistant inside the CLYRO app. CLYRO connects people who "
    "need help around the house (plumbing, electrical, cleaning, and similar home "
    "services) with nearby service providers. Help the user describe their problem, "
    "ask clarifying questions when useful, and suggest what kind of provider/category "
    "they should search for in the app. Keep answers concise and practical."
)


def generate_reply(message: str, history: list[dict] | None = None, max_retries: int = 3) -> str:
    """
    Calls Gemini with the user's message plus optional prior turns.
    Retries with exponential backoff on transient 503 (model overloaded) errors,
    matching the retry pattern used elsewhere in GrappleAI's Gemini integration.
    """
    client = get_client()

    contents = []
    for turn in history or []:
        role = "model" if turn.get("role") == "assistant" else "user"
        contents.append({"role": role, "parts": [{"text": turn["content"]}]})
    contents.append({"role": "user", "parts": [{"text": message}]})

    delay = 1.0
    last_error: Exception | None = None

    for attempt in range(max_retries):
        try:
            response = client.models.generate_content(
                model=settings.GEMINI_MODEL,
                contents=contents,
                config={"system_instruction": SYSTEM_PROMPT},
            )
            text = (response.text or "").strip()
            if not text:
                raise ValueError("Empty response from Gemini")
            return text
        except genai_errors.ServerError as e:
            last_error = e
            logger.warning("Gemini server error (attempt %d/%d): %s", attempt + 1, max_retries, e)
            time.sleep(delay)
            delay *= 2
        except Exception as e:
            last_error = e
            logger.error("Gemini call failed: %s", e)
            break

    raise RuntimeError(f"CLYROAI is temporarily unavailable: {last_error}")