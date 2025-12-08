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
