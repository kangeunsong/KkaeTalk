# 💬 KkaeTalk: AI News Alarm System

An AI-powered smart alarm application that **wakes you up through natural conversation**

> Beyond simple sound notifications, an intelligent alarm system that induces cognitive awakening through news summarization and conversation

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![Python](https://img.shields.io/badge/Python-3.9+-3776AB?logo=python)](https://python.org)
<br><br><br>

## Project Overview

**KkaeTalk** is an AI alarm system inspired by the experience of naturally waking up through morning conversations with parents.

### Core Concept

- **Conversational Interface**: Complete awakening through news summaries + AI conversation, not just sound alerts
- **News Summarization**: Summarize Naver News using 3 methods (TextRank, KoBART, Hybrid)
- **Gemini-based Q&A**: Free conversation and questions about summarized content
- **Conversation Mode Control**: Control AI proactivity with Quiet/Standard/Deep conversation modes
  <br><br><br>

## Key Features

### News Summarization (3 Methods)

| Method       | Description                      | Latency  | Quality Score |
| ------------ | -------------------------------- | -------- | ------------- |
| **TextRank** | Extractive (sentence selection)  | 0.54s ⚡ | 3.08/5.0      |
| **KoBART**   | Abstractive (sentence rewriting) | 7.65s    | 4.39/5.0 🏆   |
| **Hybrid**   | 2-stage (TextRank + KoBART)      | 6.76s    | 3.92/5.0      |

<br>

### Conversation Modes

- Level 1 · Quiet Mode<br>
  → AI doesn't initiate questions
  → User-led conversation

- Level 2 · Standard Conversation Mode<br>
  → AI occasionally asks light questions
  → Natural conversation flow

- Level 3 · Deep Conversation Mode<br>
  → AI actively asks deep questions
  → Helps organize thoughts
  <br><br>

### Evaluation Results

**Human Evaluation (N=3, 12 articles):**

- Content Coverage: KoBART 4.22 > Hybrid 3.92 > TextRank 3.64
- Fluency: KoBART 4.53 > Hybrid 3.50 > TextRank 2.42
- Overall Quality: KoBART 4.39 > Hybrid 3.92 > TextRank 3.08

**Automatic Evaluation (ROUGE-1):**

- Hybrid 0.446 > KoBART 0.366 > TextRank 0.290

→ **Actual app uses KoBART, ranked #1 in human evaluation**
<br><br><br>

## System Architecture

```
┌─────────────────────────────────────────────────┐
│                Flutter App (Client)             │
│  ┌──────────────┐  ┌──────────────────────────┐ │
│  │ Alarm Setup  │  │  News Summary + AI Chat  │ │
│  └──────────────┘  └──────────────────────────┘ │
└─────────────────┬───────────────────────────────┘
                  │ HTTP/REST
                  ▼
┌─────────────────────────────────────────────────┐
│           FastAPI Backend (Server)              │
│  ┌──────────────┐  ┌──────────────────────────┐ │
│  │ News Crawler │  │  Summarization Engine    │ │
│  └──────┬───────┘  │  - TextRank              │ │
│         │          │  - KoBART                │ │
│         ▼          │  - Hybrid                │ │
│  ┌──────────────┐  └──────────────────────────┘ │
│  │ Naver News   │  ┌──────────────────────────┐ │
│  └──────────────┘  │  Gemini Chat Model       │ │
│                    │  - 3-level conversation  │ │
│                    └──────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### API Endpoints

```python
POST /news-summary
- Input URL → Generate news summary
- Params: url, mode (textrank/kobart/hybrid)

POST /chat
- Q&A based on summary
- Params: summary, question, level (1/2/3)
```

<br><br><br>

## Evaluation Methods

We evaluate the three summarization modes (**TextRank / KoBART / Hybrid**) using **three complementary evaluation approaches**:.

### 1) System Performance Evaluation (Efficiency)

**Goal:** Measure responsiveness and compactness for real-time alarm usage.

**Metrics:**

- **Processing time (latency)** per article
- **Compression ratio** (summary length / original length)

### 2) Automatic Quality Evaluation

**Goal:** Quantitatively compare summary quality against reference summaries.

**Metrics:**

- **ROUGE scores:** ROUGE-1, ROUGE-2, ROUGE-L
- **Keyword coverage:** overlap between extracted keywords and summary (or reference) keywords

### 3) Human Evaluation (User-Oriented Quality)

**Goal:** Assess perceived summary quality from an end-user perspective.

**Setup:**

- **3 evaluators**
- **5-point Likert scale**
- **Blind evaluation** (A/B/C labels)
- **Criteria:** Content coverage, Fluency, Overall quality

<br><br><br>

## Experimental Results

### Compression Ratio and Summary Length

| Method        | Compression Ratio | Avg Length (chars) |
| ------------- | ----------------- | ------------------ |
| TextRank      | 0.72              | 751                |
| KoBART        | 0.45              | 352                |
| **Hybrid** 🏆 | 0.43              | 331                |

### Processing Time by Category (seconds)

| Category       | **TextRank** 🏆 | BART | Hybrid |
| -------------- | --------------- | ---- | ------ |
| Politics       | 1.75            | 5.99 | 5.33   |
| Economy        | 0.27            | 9.44 | 6.30   |
| Society        | 0.38            | 6.90 | 6.47   |
| Life & Culture | 0.33            | 8.06 | 8.03   |
| IT & Science   | 0.27            | 7.82 | 7.17   |
| World          | 0.24            | 7.66 | 7.23   |

### Human Evaluation Results (N=3 evaluators, 12 articles)

| Method        | Content Coverage | Fluency     | Overall Quality |
| ------------- | ---------------- | ----------- | --------------- |
| TextRank      | 3.64 ± 0.59      | 2.42 ± 0.73 | 3.08 ± 0.60     |
| **KoBART** 🏆 | 4.22 ± 0.59      | 4.53 ± 0.51 | 4.39 ± 0.49     |
| Hybrid        | 3.92 ± 0.44      | 3.50 ± 0.61 | 3.92 ± 0.60     |

<br><br><br>

## Tech Stack

### Backend

- **FastAPI**: High-performance async API server
- **KoBART**: Korean BART-based abstractive summarization
- **TextRank**: Graph-based extractive summarization
- **Gemini API**: Conversational AI interface
- **BeautifulSoup**: Naver News crawling

### Frontend

- **Flutter**: Cross-platform UI framework
- **Provider**: State management
- **HTTP**: REST API communication
  <br><br><br>

## Future Roadmap

- [ ] Korean STT/TTS integration
- [ ] User feedback collection and implementation
- [ ] UI/UX improvements
      <br>
- [ ] Evaluation with larger dataset
- [ ] Introduction of additional metrics (BERTScore, factuality evaluation)
- [ ] Speed optimization through model quantization
      <br>
- [ ] Google Play Store / App Store release
- [ ] Multi-language support (English, Chinese, etc.)
- [ ] Personalized recommendation algorithm development
