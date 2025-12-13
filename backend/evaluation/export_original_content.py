import time
import pandas as pd
import requests
from bs4 import BeautifulSoup

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/98.0.4758.102"
}

def fetch_naver_news_text(url: str) -> str:
    resp = requests.get(url, headers=HEADERS, timeout=10)
    resp.raise_for_status()

    html = BeautifulSoup(resp.text, "html.parser")

    content_article = html.select(
        "div.newsct > div.newsct_body > "
        "div.newsct_article._article_body > article.go_trans._article_content"
    )

    if content_article:
        content_text = " ".join(
            [element.get_text(strip=True) for element in content_article]
        )
        return content_text

    candidates = [
        html.select_one("#dic_area"),
        html.select_one("#newsct_article"),
    ]
    for c in candidates:
        if c:
            return c.get_text(separator=" ", strip=True)

    body = html.find("body")
    if body:
        return body.get_text(separator=" ", strip=True)

    return ""


def main():
    # 1) eval_articles.csv 읽기 (id/category/url 있다고 가정)
    df = pd.read_csv("eval_articles.csv")

    texts = []
    errors = []

    # 2) URL별 크롤링
    for i, row in df.iterrows():
        url = row["url"]
        try:
            text = fetch_naver_news_text(url)
            texts.append(text)
            errors.append("")
        except Exception as e:
            texts.append("")
            errors.append(str(e))

        # 네이버 차단/부하 방지용: 너무 빠르게 치지 말기
        time.sleep(0.5)

    # 3) 결과 컬럼 추가
    df["article_text"] = texts
    df["error"] = errors

    # 4) CSV 저장 (엑셀 호환 좋게 utf-8-sig 추천)
    out_path = "eval_articles_crawled.csv"
    df.to_csv(out_path, index=False, encoding="utf-8-sig")
    print(f"Saved -> {out_path}")


if __name__ == "__main__":
    main()
