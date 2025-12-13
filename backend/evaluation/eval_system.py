import time
import csv
import requests

BASE_URL = "http://127.0.0.1:8000"

MODES = ["textrank", "kobart", "hybrid"]  # 세 가지 요약 방식

def load_articles(csv_path="eval_articles.csv"):
    articles = []
    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            articles.append(row)
    return articles

def eval_system():
    articles = load_articles()
    results = []

    for art in articles:
        article_id = art["id"]
        url = art["url"]

        for mode in MODES:
            payload = {"url": url, "mode": mode}

            start = time.perf_counter()
            resp = requests.post(f"{BASE_URL}/news-summary", json=payload)
            elapsed = time.perf_counter() - start

            if resp.status_code != 200:
                print(f"[ERROR] id={article_id}, mode={mode}, status={resp.status_code}, detail={resp.text}")
                continue

            data = resp.json()
            original_len = data["original_length"]
            summary_len = data["summary_length"]
            compression = summary_len / original_len if original_len > 0 else 0.0

            results.append({
                "article_id": article_id,
                "mode": mode,
                "latency_sec": elapsed,
                "original_length": original_len,
                "summary_length": summary_len,
                "compression_ratio": compression,
            })

            print(f"[OK] id={article_id}, mode={mode}, time={elapsed:.3f}s, "
                  f"len={original_len}->{summary_len} (ratio={compression:.2f})")

    # CSV로 저장
    with open("eval_system_results.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=["article_id", "mode", "latency_sec",
                        "original_length", "summary_length", "compression_ratio"],
        )
        writer.writeheader()
        writer.writerows(results)

if __name__ == "__main__":
    eval_system()
