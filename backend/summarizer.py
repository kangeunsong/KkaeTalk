import torch
from transformers import PreTrainedTokenizerFast, BartForConditionalGeneration


def _load_model_and_tokenizer():
    """
    한국어 뉴스 요약용 KoBART 모델 로드 (gogamza/kobart-summarization)
    """
    tokenizer = PreTrainedTokenizerFast.from_pretrained(
        "gogamza/kobart-summarization"
    )
    model = BartForConditionalGeneration.from_pretrained(
        "gogamza/kobart-summarization"
    )
    model.eval()
    return model, tokenizer


# 서버 시작 시 한 번만 로드
model, tokenizer = _load_model_and_tokenizer()


def summarize_korean_text(text: str) -> str:
    """
    기사 본문 텍스트를 KoBART로 추상 요약
    """
    if not text:
        return ""

    # 줄바꿈 제거 및 간단 전처리
    text = text.replace("\n", " ")

    # 입력 최대 길이 제한 (KoBART 토큰 한도 보호)
    input_ids = tokenizer.encode(
        text,
        max_length=512,
        truncation=True,
    )
    input_ids = torch.tensor([input_ids])  # shape: (1, seq_len)

    with torch.no_grad():
        summary_ids = model.generate(
            input_ids,
            bos_token_id=model.config.bos_token_id,
            eos_token_id=model.config.eos_token_id,
            max_length=256,   # 요약 최대 길이
            min_length=128,    # 너무 짧게 안 나오도록
            num_beams=4,      # 빔 서치
            length_penalty=1.0,
            no_repeat_ngram_size=3,
        )

    summary = tokenizer.decode(summary_ids[0], skip_special_tokens=True)
    return summary.strip()
