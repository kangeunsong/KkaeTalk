# backend/eval_auto.py
import csv
import json
import requests
import re

from rouge_score import rouge_scorer

ref = "금융정보업체 에프앤가이드에 따르면 273개 기업 중 134개의 2분기 영업이익 추정치가 하향 조정되었다."
hyp = "에프앤가이드는 273개 기업 중 134개의 2분기 영업이익 전망이 낮아졌다고 밝혔다."


print("REF:", repr(ref))
print("HYP:", repr(hyp))
print("ref == hyp ?", ref == hyp)

scorer = rouge_scorer.RougeScorer(["rouge1", "rougeL"], use_stemmer=False)
scores = scorer.score(ref, hyp)
print(scores)


BASE_URL = "http://127.0.0.1:8000"
MODES = ["textrank", "kobart", "hybrid"]

def split_sentences(text: str):
    sents = re.split(r'(?<=[.!?])\s+', text)
    sents = [s.strip() for s in sents if len(s.strip()) > 0]
    return sents

def redundancy_score(summary: str) -> float:
    sents = split_sentences(summary)
    if len(sents) <= 1:
        return 0.0
    unique = set(sents)
    dup_count = len(sents) - len(unique)
    return dup_count / len(sents)

# 예시: 기사별 키워드(너가 직접 넣기)
ARTICLE_KEYWORDS = {
    "1": ["에쓰오일", "넷마블", "하향 조정", "상향 조정", "2분기 영업이익"],
    # "2": [...],
}

def keyword_coverage(summary: str, keywords: list[str]) -> float:
    if not keywords:
        return 0.0
    hit = sum(1 for kw in keywords if kw in summary)
    return hit / len(keywords)

def load_articles(csv_path="eval_articles.csv"):
    articles = []
    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            articles.append(row)
    return articles

def eval_auto_metrics():
    articles = load_articles()
    rows = []

    for art in articles:
        article_id = art["id"]
        url = art["url"]
        keywords = ARTICLE_KEYWORDS.get(article_id, [])

        for mode in MODES:
            resp = requests.post(
                f"{BASE_URL}/news-summary",
                json={"url": url, "mode": mode},
            )
            if resp.status_code != 200:
                print(f"[ERROR] auto-metric id={article_id}, mode={mode}, status={resp.status_code}")
                continue

            data = resp.json()
            summary = data["summary"]

            red = redundancy_score(summary)
            cov = keyword_coverage(summary, keywords)

            rows.append({
                "article_id": article_id,
                "mode": mode,
                "redundancy": red,
                "keyword_coverage": cov,
            })

            print(f"[OK] id={article_id}, mode={mode}, red={red:.2f}, cov={cov:.2f}")

    with open("eval_auto_results.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=["article_id", "mode", "redundancy", "keyword_coverage"],
        )
        writer.writeheader()
        writer.writerows(rows)

if __name__ == "__main__":
    eval_auto_metrics()
