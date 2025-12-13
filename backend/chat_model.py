# backend/chat_model.py
import os
from pathlib import Path
import google.generativeai as genai

GEMINI_MODEL_NAME = "gemini-2.5-flash"  # 빠르고 싸고 한글도 잘함


key_path = Path(__file__).parent / "gemini_api_key.txt"
if key_path.exists():
    api_key = key_path.read_text(encoding="utf-8").strip()
if not api_key:
    raise RuntimeError("환경변수 GEMINI_API_KEY 또는 gemini_api_key.txt가 설정되어 있지 않습니다.")

# api_key = os.getenv("GEMINI_API_KEY")
# if not api_key:
#     raise RuntimeError("환경변수 GEMINI_API_KEY 가 설정되어 있지 않습니다.")

genai.configure(api_key=api_key)

model = genai.GenerativeModel(GEMINI_MODEL_NAME)


def build_prompt(summary: str, history, question_level: int) -> str:
    """
    summary: 뉴스 요약 텍스트
    history: [{"role": "user"|"assistant", "content": "..."}] 리스트
    question_level: 1~3
    """

    level_desc = {
        1: "사용자가 먼저 질문하지 않는 이상, 질문을 거의 하지 말고 주로 설명 위주로 말해라.",
        2: "가볍게 대화를 이어가기 위해 가끔(3~4턴에 한 번 정도) 질문을 섞어라.",
        3: "거의 매 턴마다 사용자의 생각을 물어보거나, 이유를 물어보는 질문을 해서 대화를 깊게 이어가라.",
    }.get(question_level, "기본적으로 자연스럽게 대화하되, 너무 질문이 많지는 않게 해라.")

    history_text_lines = []
    for turn in history[-10:]:  # 최근 10턴만
        prefix = "사용자" if turn["role"] == "user" else "AI"
        history_text_lines.append(f"{prefix}: {turn['content']}")
    history_text = "\n".join(history_text_lines) if history_text_lines else "아직 대화 기록 없음."

    prompt = f"""
너는 '깨톡'이라는 아침 알람 앱 안에서 동작하는 한국어 대화형 AI야.
사용자는 막 알람을 끄고 이제 막 잠에서 깬 상태다. 말투는 친근하지만 너무 반말은 아니고,
한국인 20대에게 말하듯 자연스럽게 반말/존댓말 섞인 편한 말투를 사용해.

[오늘의 뉴스 요약]
{summary}

이 뉴스가 오늘 대화의 기본 주제이지만,
사용자가 다른 질문을 해도 자연스럽게 대답해 주고,
가능하면 다시 이 뉴스/주제와 연결해서 대화를 이어가려고 노력해라.

[질문 스타일 지시]
질문 레벨: {question_level}
{level_desc}

[지금까지의 대화 기록]
{history_text}

위 정보를 모두 고려해서 '다음 한 턴의 AI 응답'만 한국어로 생성해라.
- 응답은 2~4문장 정도로 너무 길지 않게.
- 마크다운, 리스트, 이모지 남발은 하지 말고 일반 채팅처럼 자연스럽게.
- "요약에 따르면" 같은 말은 너무 자주 쓰지 말고 자연스럽게 이야기하듯 말해라.
"""
    return prompt.strip()


def generate_reply(summary: str, history, question_level: int) -> str:
    prompt = build_prompt(summary, history, question_level)
    response = model.generate_content(prompt)
    text = response.text or ""
    return text.strip()
