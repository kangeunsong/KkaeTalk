import re
import numpy as np
import networkx as nx
from sklearn.feature_extraction.text import TfidfVectorizer


def split_sentences(text: str):
    """아주 단순 문장 분리 (필요하면 나중에 개선)"""
    candidates = re.split(r'(?<=[.?!])\s+', text)
    sentences = [s.strip() for s in candidates if len(s.strip()) > 5]
    return sentences


def tokenize(sentence: str):
    """
    간단 토큰화:
    - 특수문자 제거
    - 공백 기준으로 쪼개기
    - 한 글자 토큰은 버림 (너무 많아서 노이즈)
    """
    # 한글/영어/숫자/공백만 남기기
    cleaned = re.sub(r'[^0-9A-Za-z가-힣\s]', ' ', sentence)
    tokens = cleaned.split()
    return [t for t in tokens if len(t) > 1]


def textrank_summarize(text: str, top_k: int = 3) -> str:
    sentences = split_sentences(text)
    if len(sentences) <= top_k:
        return text  # 문장이 너무 적으면 원문 반환

    # 문장별 토큰 리스트를 문자열로 결합
    tokenized_sentences = [" ".join(tokenize(s)) for s in sentences]

    # 혹시 전처리 후 다 비어버리면 그냥 원문 리턴
    if all(len(t.strip()) == 0 for t in tokenized_sentences):
        return text

    # TF-IDF 기반 문장 벡터화
    vectorizer = TfidfVectorizer()
    tfidf = vectorizer.fit_transform(tokenized_sentences)

    # 코사인 유사도 행렬
    sim_matrix = (tfidf * tfidf.T).toarray()

    # 자기 자신 유사도는 0으로
    np.fill_diagonal(sim_matrix, 0)

    # 그래프 만들고 TextRank (PageRank) 점수 계산
    graph = nx.from_numpy_array(sim_matrix)
    scores = nx.pagerank(graph)

    # 점수 높은 상위 문장 선택
    ranked_sentences = sorted(
        ((score, idx) for idx, score in scores.items()),
        reverse=True,
    )
    selected_idx = sorted([idx for _, idx in ranked_sentences[:top_k]])

    # 원래 순서대로 이어 붙이기
    summary = " ".join(sentences[i] for i in selected_idx)
    return summary
