from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
from chat_model import generate_reply
from news_crawler import fetch_naver_news_text
from summarizer import summarize_korean_text

app = FastAPI(title="KkaeTalk Backend")


class NewsSummaryRequest(BaseModel):
    url: str


class NewsSummaryResponse(BaseModel):
    url: str
    original_length: int
    summary_length: int
    original_text: str
    summary: str


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.post("/news-summary", response_model=NewsSummaryResponse)
def news_summary(req: NewsSummaryRequest):
    # 1) 크롤링
    try:
        article_text = fetch_naver_news_text(req.url)
    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=f"뉴스를 가져오지 못했습니다 (url={req.url}, error={e})",
        )

    # 2) 본문 길이 체크
    if not article_text or len(article_text) < 50:
        raise HTTPException(
            status_code=400,
            detail="기사 본문이 너무 짧거나 비어 있습니다.",
        )

    # 3) 요약
    summary = summarize_korean_text(article_text)

    return NewsSummaryResponse(
        url=req.url,
        original_length=len(article_text),
        summary_length=len(summary),
        original_text=article_text,
        summary=summary,
    )

class ChatTurn(BaseModel):
    role: str  # "user" or "assistant"
    content: str


class ChatRequest(BaseModel):
    summary: str           # 뉴스 요약 텍스트
    question_level: int    # 1~3
    history: List[ChatTurn]


class ChatResponse(BaseModel):
    reply: str


@app.post("/chat", response_model=ChatResponse)
def chat(req: ChatRequest):
    try:
        reply = generate_reply(
            summary=req.summary,
            history=[t.model_dump() for t in req.history],
            question_level=req.question_level,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"LLM 호출 중 오류가 발생했습니다: {e}")

    return ChatResponse(reply=reply)