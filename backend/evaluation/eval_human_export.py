# backend/eval_human_export.py
import csv
import json
import random
import requests

BASE_URL = "http://127.0.0.1:8000"
MODES = ["textrank", "kobart", "hybrid"]

def load_articles(csv_path="eval_articles.csv"):
    articles = []
    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            articles.append(row)
    return articles

def export_for_human_eval():
    articles = load_articles()
    all_items = []
    mapping = []  # A/B/C -> mode 기록용

    for art in articles:
        article_id = art["id"]
        url = art["url"]

        candidates = []
        for mode in MODES:
            resp = requests.post(
                f"{BASE_URL}/news-summary",
                json={"url": url, "mode": mode},
            )
            data = resp.json()
            candidates.append((mode, data["summary"]))

        # A/B/C 라벨 섞기
        labels = ["A", "B", "C"]
        random.shuffle(labels)

        for label, (mode, summary) in zip(labels, candidates):
            all_items.append({
                "article_id": article_id,
                "label": label,         # A/B/C
                "summary": summary,
            })
            mapping.append({
                "article_id": article_id,
                "label": label,
                "mode": mode,
            })

    # 평가용 텍스트/마크다운 파일로 저장
    with open("human_eval_summaries.txt", "w", encoding="utf-8") as f:
        for item in all_items:
            f.write(f"=== Article {item['article_id']} - Summary {item['label']} ===\n")
            f.write(item["summary"] + "\n\n")

    # A/B/C -> 모드 매핑은 따로 JSON으로 저장 (후에 분석용)
    with open("human_eval_mapping.json", "w", encoding="utf-8") as f:
        json.dump(mapping, f, ensure_ascii=False, indent=2)

if __name__ == "__main__":
    export_for_human_eval()
