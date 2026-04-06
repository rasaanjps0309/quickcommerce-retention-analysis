# QuickCommerce Retention Analysis  
### Why Users Place One Order — and Never Come Back

---

## Overview

This project analyzes user retention for a quick-commerce grocery delivery platform to understand why users fail to return after their first order.

The analysis focuses on identifying **where users drop off, why it happens, and how it impacts business growth**.

---

## Business Context

QuickBasket is a quick-commerce platform operating across major Indian metros.

- ~52,000 users acquired in a quarter  
- ~63% activation rate  
- Severe drop in repeat purchases  

Despite strong acquisition, the business struggles to convert users into repeat buyers.

---

## Problem Statement

> A majority of users place their first order but do not return, leading to poor retention and weak unit economics.

- 60–75% users drop after Week 1 :contentReference[oaicite:0]{index=0}  
- Median user lifetime ~26 days :contentReference[oaicite:1]{index=1}  

This indicates a failure in **early habit formation**.

---

## Key Insight (TL;DR)

> Retention drops sharply after Week 1, indicating that users fail to build a repeat habit — not that the product lacks value.

Users who survive 4 weeks retain at **85–91%**, proving that once habits form, retention stabilizes. :contentReference[oaicite:2]{index=2}  

---

## Analytical Approach

The analysis was structured in layers:

1. **Cohort Retention Analysis**
   - Weekly cohort tracking (W0 → W6)

2. **Activation Funnel Analysis**
   - Signup → First Order → Second Order

3. **Survival Analysis**
   - Time-to-churn and hazard rate identification

4. **Behavioral Segmentation**
   - Returners vs non-returners

5. **Channel & City Analysis**
   - Retention comparison across acquisition channels and cities

---

## Key Findings

### 1. Severe Week-1 Drop (Habit Failure)

**Observation:** 60–75% users drop after Week 1  
**Interpretation:** Users do not integrate product into routine  
**Business Meaning:** Majority of CAC is lost early  

---

### 2. Discount Dependency Drives Churn

**Observation:** Non-returners received higher first-order discounts (~24% vs 18.5%) :contentReference[oaicite:3]{index=3}  
**Interpretation:** Discounts distort perceived value  
**Business Meaning:** Low-quality, price-sensitive users are acquired  

---

### 3. Strong Retention After Habit Formation

**Observation:** Users active for 4+ weeks retain at 85–91% :contentReference[oaicite:4]{index=4}  
**Interpretation:** Product works once habit forms  
**Business Meaning:** Problem is early-stage retention, not product-market fit  

---

### 4. Critical Churn Window: Day 0–14

**Observation:** Hazard rate peaks around Day 14–18 :contentReference[oaicite:5]{index=5}  
**Interpretation:** Users decide early whether to continue  
**Business Meaning:** Interventions must happen early  

---

### 5. Engagement Depth Predicts Retention

**Observation:** Habit users have higher order frequency, AOV, and lower discount usage :contentReference[oaicite:6]{index=6}  
**Interpretation:** Deeper interaction builds stickiness  
**Business Meaning:** Quality of engagement matters more than acquisition volume  

---

## Root Cause

Retention failure is driven by:

- Discount-led acquisition (low intent users)
- Value perception drop after first order
- Lack of structured engagement in Day 0–14 window

> The problem is not that users don’t like the product —  
> it’s that they never stay long enough to form a habit.

---

## Recommendation

### Progressive Milestone Incentive (PMI)

- Reduce friction for second order (free delivery)
- Incentivize repeat behavior in Week 1–4
- Avoid heavy discounts to prevent dependency  

---

## Impact Potential

- +5pp improvement in Week-1 retention  
- ~500 additional retained users/month  
- ~₹8L revenue uplift  

---

## Related Project

This analysis led to an A/B experiment:

### QuickCommerce Retention A/B Test(https://github.com/rasaanjps0309/quickcommerce-retention-ab-test)

---

## Tech Stack

- SQL (PostgreSQL)  
- Python (pandas, lifelines)  
- Jupyter Notebook  
- Claude AI
- NotebookLM   

---

