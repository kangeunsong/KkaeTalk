# backend/eval_auto_improved.py
import csv
import json
import requests
import re
from rouge_score import rouge_scorer

BASE_URL = "http://127.0.0.1:8000"
MODES = ["textrank", "kobart", "hybrid"]

ARTICLE_KEYWORDS = {
    "1": ["새만금 개발", "사업 재검토", "민간투자 유치", "개인정보 유출", "경제 제재"],
    "2": ["조현", "핵추진잠수함", "북한 핵 고도화", "전력 균형", "비확산 규범"],
    "3": ["코스피", "브로드컴 호실적", "기관 순매수", "삼성전자", "원달러 환율"],
    "4": ["신혼부부 통계", "혼인 5년 이내", "맞벌이 비중", "평균소득", "대출 잔액"],
    "5": ["용인 아파트", "40대 투신", "9살 아들 사망", "살해 후 자살 추정", "주식 손실"],
    "6": ["광주대표도서관", "공사장 붕괴", "장스팬 구조물", "용접 접합부", "콘크리트 타설 하중"],
    "7": ["주말 눈", "중부·수도권", "강원 내륙 대설", "시간당 강한 눈", "추위 지속"],
    "8": ["종묘", "세계유산지구", "세운4구역 재개발", "세계유산영향평가", "국가유산청"],
    "9": ["크래프톤", "네온 자이언트", "NO LAW", "오픈월드 슈터 RPG", "언리얼 엔진5"],
    "10": ["넥슨", "아크 레이더스", "TGA 2025", "최고의 멀티플레이어", "엠바크 스튜디오"],
    "11": ["노벨평화상", "마리아 코리나 마차도", "베네수엘라 야권", "그레이 불", "극비 탈출 작전"],
    "12": ["불가리아", "Z세대 시위", "사회보장 분담금 인상", "총리 사임", "부패 반발"],
}

REFERENCE_SUMMARIES = {
    "1": "이재명 대통령은 새만금 개발이 30년 넘게 지지부진하고(매립 40% 수준) 민자 유치도 비현실적이라며 사업 계획을 현실화·정리해야 한다고 지적했다.\n"
         "전북도민에게 ‘희망고문’이 될 수 있다며 필요하면 규모 축소 등 전면 재검토를 시사했다.\n"
         "또 개인정보 유출을 낸 기업에는 ‘회사가 망한다’는 생각이 들 정도의 강력한 경제 제재가 필요하다고 강조했다.",

    "2": "조현 외교부 장관은 북한의 핵 능력 고도화에 대응해 남북 간 ‘핵-재래식 전력’ 균형을 맞출 필요가 있다고 말했다.\n"
         "이를 위한 방안으로 핵추진잠수함 도입 필요성을 언급했다.\n"
         "아울러 국제 비확산 규범을 준수하겠다는 취지를 함께 강조했다.",

    "3": "코스피는 미국발 훈풍 속에 1%대 상승하며 4160선을 회복했고, 종가는 4167.16을 기록했다.\n"
         "기관·외국인이 순매수하며 지수를 끌어올렸고 개인은 순매도했다.\n"
         "브로드컴 호실적 영향으로 반도체 업종이 강세를 보이며 삼성전자와 SK하이닉스도 상승했고 원달러 환율은 1473.7원으로 마감했다.",

    "4": "2024년 신혼부부 통계에서 혼인 5년 이내 신혼부부는 95만2천쌍으로 전년 대비 2.3% 감소했지만, 감소폭은 역대 최소였다.\n"
         "혼인 1~2년 차 신혼부부는 늘었고, 자녀가 없는 부부 비중이 높아지며 평균 자녀 수도 0.61명으로 최저치를 기록했다.\n"
         "맞벌이 비중은 59.7%로 증가했고, 초혼 신혼부부의 평균소득 및 대출 보유·잔액도 함께 늘어난 것으로 나타났다.",

    "5": "경기 용인의 한 아파트에서 40대 남성이 투신해 숨졌고, 그의 차량에서는 9살 아들이 숨진 채 발견됐다.\n"
         "검안 소견과 CCTV 동선 등을 토대로 경찰은 아들을 살해한 뒤 투신한 것으로 보고 있다.\n"
         "집에서는 신변을 비관하는 메모가 나왔고, 최근 주식 투자로 큰 손실을 봤다는 정황도 수사 내용에 포함됐다.",

    "6": "광주대표도서관 공사 현장에서 콘크리트 타설 중 구조물이 붕괴하는 사고가 발생해 매몰자 구조와 원인 조사가 진행 중이다.\n"
         "전문가들은 장스팬(긴 경간) 철제 구조물을 볼트 체결 대신 용접으로 이어 붙인 접합부 결함이 하중을 버티지 못했을 가능성을 제기했다.\n"
         "구조검토·조립도 작성 여부, 접합부 품질, 타설 과정의 하중·시공 상태 등 다각도로 사고 원인이 규명될 전망이다.",

    "7": "주말인 13일 대부분 지역에 눈이 내리고, 중부(수도권 포함)는 오전부터 시작해 오후엔 더 넓은 지역으로 확대될 전망이다.\n"
         "중부·경북 북부 내륙에는 시간당 1~3cm의 강한 눈이 쏟아질 수 있고, 경기 내륙 3~10cm·강원 내륙은 최대 15cm까지 예보됐다.\n"
         "서울은 아침 2도·낮 3도 수준으로 추위가 이어져 빙판길 등 안전에 유의가 필요하다는 내용이다.",

    "8": "국가유산청이 유네스코 세계유산 ‘종묘’ 일대를 세계유산지구로 지정하고 관보 고시를 완료했다.\n"
         "이는 종묘 인근 세운4구역 재개발(고층빌딩 계획) 등에 대해 세계유산영향평가를 요구할 근거를 강화하려는 조치로 해석된다.\n"
         "서울시의 ‘강북죽이기 법’ 주장에 대해 국가유산청은 법 취지와 다르다며 반박했고, 시행령 개정 등을 통해 평가 절차를 구체화하겠다고 밝혔다.",

    "9": "크래프톤은 스웨덴 개발사 네온 자이언트의 신작 ‘NO LAW’를 더 게임 어워드 2025에서 처음 공개했다.\n"
         "산업 항구 도시 ‘포트 디자이어’를 배경으로 전직 군인 ‘그레이 하커’의 서사와 1인칭 전투가 결합된 오픈월드 슈터 RPG로 소개됐다.\n"
         "플레이어 선택에 따라 루트·전개·엔딩이 달라지며, 언리얼 엔진5 기반으로 PC·콘솔 플랫폼 출시를 준비 중이라는 내용이다.",

    "10": "넥슨의 ‘아크 레이더스’가 2025 더 게임 어워드(TGA)에서 ‘최고의 멀티플레이어’ 부문 상을 수상했다.\n"
         "넥슨의 스웨덴 자회사 엠바크 스튜디오가 개발했으며, 출시 이후 스팀 기준 최고 동시접속자 약 48만2천명을 기록하는 등 흥행 성과도 언급됐다.\n"
         "한국 기업이 관여한 게임의 TGA 수상은 2017년 PUBG 이후 8년 만이라는 점이 강조됐다.",

    "11": "노벨평화상을 받은 베네수엘라 야권 지도자 마리아 코리나 마차도의 오슬로 이동 과정에 미국 민간 구조대가 극비리에 개입한 정황이 전해졌다.\n"
         "전직 특수부대 출신 브라이언 스턴이 이끄는 ‘그레이 불’이 육상·해상 탈출을 주도했고, 마차도는 해상 접선 뒤 13~14시간 항해해 비공개 장소를 거쳐 오슬로행 비행기에 올랐다.\n"
         "작전 과정에서 다양한 시나리오와 ‘가짜 소문’까지 활용했으며, 미국 정부의 공식 개입은 없었지만 충돌 방지를 위한 비공식 협력 정황도 언급됐다.",

    "12": "불가리아에서 사회보장 분담금 인상안에 반대하는 Z세대 주도 시위가 확산되며 총리가 사임하겠다고 밝혔다.\n"
         "불신임안 표결 직전 사임 선언이 나왔고, 유럽에서 Z세대 시위로 지도자가 물러난 첫 사례라는 점이 강조됐다.\n"
         "시위는 부패와 불평등에 대한 반발, 유로화 도입 이후 물가 불안 우려 등이 결합됐으며 밈·SNS를 활용한 조직화가 특징으로 소개됐다.",
}


def split_sentences(text: str):
    """문장 분리"""
    sents = re.split(r'(?<=[.!?])\s+', text)
    sents = [s.strip() for s in sents if len(s.strip()) > 0]
    return sents

def redundancy_score(summary: str) -> float:
    """중복도 계산: 중복된 문장 비율"""
    sents = split_sentences(summary)
    if len(sents) <= 1:
        return 0.0
    unique = set(sents)
    dup_count = len(sents) - len(unique)
    return dup_count / len(sents)

def keyword_coverage(summary: str, keywords: list) -> float:
    """키워드 커버리지: 키워드 중 요약문에 포함된 비율"""
    if not keywords:
        return 0.0
    hit = sum(1 for kw in keywords if kw in summary)
    return hit / len(keywords)

def calculate_rouge(reference: str, hypothesis: str) -> dict:
    """ROUGE 점수 계산"""
    scorer = rouge_scorer.RougeScorer(['rouge1', 'rouge2', 'rougeL'], use_stemmer=False)
    scores = scorer.score(reference, hypothesis)
    return {
        'rouge1_f': scores['rouge1'].fmeasure,
        'rouge2_f': scores['rouge2'].fmeasure,
        'rougeL_f': scores['rougeL'].fmeasure,
    }

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
        reference = REFERENCE_SUMMARIES.get(article_id, "")

        for mode in MODES:
            resp = requests.post(
                f"{BASE_URL}/news-summary",
                json={"url": url, "mode": mode},
            )
            if resp.status_code != 200:
                print(f"[ERROR] id={article_id}, mode={mode}, status={resp.status_code}")
                continue

            data = resp.json()
            summary = data["summary"]

            # 메트릭 계산
            red = redundancy_score(summary)
            cov = keyword_coverage(summary, keywords)
            
            rouge_scores = {}
            if reference:
                rouge_scores = calculate_rouge(reference, summary)

            row = {
                "article_id": article_id,
                "mode": mode,
                "redundancy": red,
                "keyword_coverage": cov,
            }
            row.update(rouge_scores)
            rows.append(row)

            print(f"[OK] id={article_id}, mode={mode}, red={red:.2f}, cov={cov:.2f}, "
                  f"R1={rouge_scores.get('rouge1_f', 0):.2f}")

    # CSV 저장
    with open("eval_auto_results_improved.csv", "w", newline="", encoding="utf-8") as f:
        fieldnames = ["article_id", "mode", "redundancy", "keyword_coverage", 
                     "rouge1_f", "rouge2_f", "rougeL_f"]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    
    print("\n결과 저장: eval_auto_results_improved.csv")

if __name__ == "__main__":
    eval_auto_metrics()