"""
Business logic services for the Health Education module.

Services:
  - SeedService          – idempotent DB seeding (categories + articles)
  - CategoryService      – CRUD for HealthCategory
  - ArticleService       – list, detail, search, featured, recommendations
  - BookmarkService      – add / remove / list user bookmarks
  - ReadingHistoryService – track reading progress
  - DashboardService     – compose the education dashboard payload
"""

from __future__ import annotations

import re
from typing import List, Optional

from sqlalchemy import func, or_, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.health_education.models import (
    HealthArticle,
    HealthCategory,
    ReadingHistory,
    UserBookmark,
)
from app.health_education.schemas import (
    ArticleListResponse,
    BookmarkResponse,
    EducationDashboard,
    HealthArticleDetail,
    HealthArticleSummary,
    HealthCategoryResponse,
    ReadingHistoryResponse,
    SearchResponse,
)


# ─── helpers ─────────────────────────────────────────────────────────────────

def _slugify(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r"[^\w\s-]", "", text)
    text = re.sub(r"[\s_]+", "-", text)
    return re.sub(r"-+", "-", text)


def _article_to_summary(
    article: HealthArticle,
    category: Optional[HealthCategory],
    bookmarked: bool = False,
) -> HealthArticleSummary:
    return HealthArticleSummary(
        id=article.id,
        category_id=article.category_id,
        category_name=category.name if category else None,
        category_slug=category.slug if category else None,
        category_color=category.color_hex if category else None,
        title=article.title,
        slug=article.slug,
        summary=article.summary,
        language=article.language,
        author=article.author,
        read_time_min=article.read_time_min,
        cover_image=article.cover_image,
        emoji=article.emoji,
        tags=article.tags or [],
        is_featured=article.is_featured,
        view_count=article.view_count,
        bookmark_count=article.bookmark_count,
        published_at=article.published_at,
        is_bookmarked=bookmarked,
    )


async def _get_category(db: AsyncSession, category_id: Optional[str]) -> Optional[HealthCategory]:
    if not category_id:
        return None
    result = await db.execute(select(HealthCategory).where(HealthCategory.id == category_id))
    return result.scalar_one_or_none()


async def _user_bookmark_ids(db: AsyncSession, user_id: str) -> set[str]:
    result = await db.execute(
        select(UserBookmark.article_id).where(UserBookmark.user_id == user_id)
    )
    return {row[0] for row in result.fetchall()}


# ─── SeedService ─────────────────────────────────────────────────────────────

_CATEGORIES = [
    ("Diseases",          "diseases",          "🩺", "#F97316", 1),
    ("Nutrition",         "nutrition",          "🥗", "#2ECC8B", 2),
    ("Vaccination",       "vaccination",        "💉", "#4F94FF", 3),
    ("Maternal Health",   "maternal-health",    "🤰", "#E879A0", 4),
    ("Child Health",      "child-health",       "👶", "#FFB829", 5),
    ("Hygiene",           "hygiene",            "🧼", "#18C8C8", 6),
    ("Healthy Lifestyle", "healthy-lifestyle",  "🏃", "#926EFF", 7),
    ("Mental Health",     "mental-health",      "🧠", "#7C3AED", 8),
    ("Heart Health",      "heart-health",       "❤️", "#EF4444", 9),
    ("First Aid",         "first-aid",          "🩹", "#F43F5E", 10),
    ("Women's Health",    "womens-health",      "♀️", "#EC4899", 11),
    ("Eye & Ear Care",    "eye-ear-care",       "👁️", "#0EA5E9", 12),
]

_SEED_ARTICLES = [
    # ── 1. Diabetes ──────────────────────────────────────────────────────────
    (
        "Understanding Diabetes: Causes, Symptoms & Prevention",
        "diseases", "Learn how diabetes develops, early warning signs, and proven prevention strategies.",
        """## What is Diabetes?
Diabetes is a chronic condition where the body cannot properly regulate blood sugar (glucose) levels.

## Types
- **Type 1** – Autoimmune; insulin-producing cells are destroyed.
- **Type 2** – Most common; body becomes resistant to insulin.
- **Gestational** – Occurs during pregnancy.

## Causes
- Genetics and family history
- Obesity and physical inactivity
- Poor diet high in refined carbohydrates
- Hormonal imbalances

## Symptoms
- Frequent urination and excessive thirst
- Unexplained weight loss
- Blurry vision and fatigue
- Slow-healing wounds

## Prevention
1. Maintain a healthy weight (BMI 18.5–24.9)
2. Exercise at least 30 minutes daily
3. Eat whole grains, vegetables, and lean proteins
4. Avoid sugary drinks and processed foods
5. Get regular blood sugar checkups

## Emergency Signs 🚨
Seek immediate care for: extreme confusion, difficulty breathing, or loss of consciousness.""",
        "🩸", "en", 5, ["diabetes", "sugar", "chronic disease", "prevention"], True,
    ),
    (
        "Malaria Prevention and Treatment Guide",
        "diseases", "Essential guide on malaria causes, prevention with mosquito nets, and treatment.",
        """## What is Malaria?
Malaria is a life-threatening disease caused by *Plasmodium* parasites, transmitted through infected Anopheles mosquito bites.

## Causes
- Plasmodium falciparum (most dangerous)
- Transmitted by female Anopheles mosquitoes

## Symptoms
- High fever (39–41°C) with chills and sweating
- Headache, muscle pain, nausea
- Symptoms appear 10–15 days after mosquito bite

## Prevention
1. Sleep under insecticide-treated bed nets (ITN)
2. Use mosquito repellent (DEET-based)
3. Wear long-sleeved clothes at dusk/dawn
4. Eliminate standing water near homes
5. Indoor Residual Spraying (IRS) programs

## Treatment
- Artemisinin-based Combination Therapy (ACT) is first-line
- Seek medical care within 24 hours of symptom onset

## Emergency Signs 🚨
Convulsions, difficulty breathing, or dark urine — go to hospital immediately.""",
        "🦟", "en", 4, ["malaria", "mosquito", "fever", "prevention", "rural health"], True,
    ),
    (
        "Nutrition During Pregnancy: What to Eat for a Healthy Baby",
        "nutrition", "A complete pregnancy nutrition guide covering essential nutrients, meal plans, and foods to avoid.",
        """## Why Nutrition Matters in Pregnancy
Proper nutrition ensures healthy fetal growth, prevents birth defects, and keeps the mother strong.

## Key Nutrients
| Nutrient | Why It Matters | Sources |
|---|---|---|
| Folic Acid | Prevents neural tube defects | Leafy greens, lentils |
| Iron | Prevents anemia | Red meat, spinach, beans |
| Calcium | Bone development | Milk, yogurt, tofu |
| Iodine | Brain development | Iodized salt, dairy |
| Protein | Tissue growth | Eggs, fish, chicken |

## Recommended Foods
- Dark leafy vegetables (spinach, fenugreek)
- Whole grains (brown rice, oats)
- Legumes (lentils, chickpeas, kidney beans)
- Fresh fruits (banana, papaya, guava)
- Dairy (milk, curd, paneer)

## Foods to Avoid
- Raw/undercooked meat and fish
- Unpasteurized dairy
- Excess caffeine (>200 mg/day)
- Alcohol completely
- Processed and junk foods

## Meal Plan (Daily)
- **Breakfast:** Oats with banana + 1 glass milk
- **Mid-morning:** Handful of nuts + fruits
- **Lunch:** Dal + rice + vegetables + curd
- **Snack:** Boiled egg + fruits
- **Dinner:** Roti + sabzi + dal soup""",
        "🤰", "en", 6, ["pregnancy", "nutrition", "maternal health", "diet"], True,
    ),
    (
        "BCG, Polio & Childhood Vaccination Schedule",
        "vaccination", "Complete childhood vaccination schedule from birth to 5 years with dose timing.",
        """## Why Vaccinate Children?
Vaccines protect children from life-threatening diseases before they are exposed. Every rupee spent on vaccination saves many more in treatment costs.

## Vaccination Schedule (0–5 Years)

| Vaccine | Disease | When |
|---|---|---|
| BCG | Tuberculosis | At birth |
| OPV-0 | Polio | At birth |
| Hepatitis B (1st) | Hepatitis B | At birth |
| DPT + Hib + Hep B | Diphtheria, Pertussis, Tetanus | 6, 10, 14 weeks |
| OPV | Polio | 6, 10, 14 weeks |
| PCV | Pneumococcal | 6, 10, 14 weeks |
| Rotavirus | Diarrhea | 6, 10 weeks |
| MR | Measles, Rubella | 9–12 months |
| JE | Japanese Encephalitis | 9–12 months |
| DPT Booster | Booster | 16–24 months |
| OPV Booster | Polio Booster | 16–24 months |

## Side Effects (Normal)
- Mild fever for 1–2 days
- Redness or soreness at injection site
- Slight swelling — goes away on its own

## When to See a Doctor
High fever (>39°C), seizures, or breathing difficulty after vaccination.""",
        "💉", "en", 5, ["vaccination", "children", "BCG", "polio", "immunization"], True,
    ),
    (
        "Hand Washing: The Most Powerful Disease Prevention Tool",
        "hygiene", "Learn the correct 7-step hand washing technique that prevents diarrhea, cholera, and flu.",
        """## Why Hand Washing Saves Lives
Proper hand washing can reduce diarrheal disease by 40% and respiratory infections by 20%.

## The 7-Step WHO Hand Washing Technique
1. **Wet** hands with clean running water
2. **Apply** soap and lather both palms
3. **Rub** back of hands and between fingers
4. **Interlock** fingers and scrub
5. **Clean** thumbs by rotating
6. **Scrub** fingertips and nails on palms
7. **Rinse** thoroughly and dry with clean cloth

**Duration:** At least 20 seconds

## When to Wash Hands
- Before eating or preparing food
- After using toilet
- After touching animals
- After coughing, sneezing, or blowing nose
- Before feeding a baby
- After touching garbage

## Alternatives When Water is Unavailable
- Use alcohol-based hand sanitizer (60%+ alcohol)
- Apply thoroughly and rub until dry

## Making Handwashing a Habit for Children
- Make it fun with songs (sing "Happy Birthday" twice = 20 sec)
- Use colorful soap and reward charts""",
        "🧼", "en", 3, ["hygiene", "hand washing", "disease prevention", "sanitation"], False,
    ),
    (
        "Managing High Blood Pressure (Hypertension) Naturally",
        "diseases", "Understand what raises your blood pressure and how diet, exercise, and stress management can help.",
        """## What is Hypertension?
Blood pressure above 130/80 mmHg consistently is considered hypertension. It is called the "silent killer" because it often has no symptoms.

## Risk Factors
- High salt diet
- Obesity and physical inactivity
- Smoking and alcohol
- Chronic stress
- Family history
- Age (risk increases after 40)

## Symptoms (When Present)
- Severe headache (especially in the morning)
- Nosebleeds
- Shortness of breath
- Blurred vision

## Lifestyle Changes That Work
1. **DASH Diet** – Fruits, vegetables, whole grains, low-fat dairy
2. **Reduce salt** – Less than 5g (1 teaspoon) per day
3. **Exercise** – 30 minutes brisk walking, 5 days a week
4. **Stop smoking** – Immediate benefit to blood vessels
5. **Limit alcohol** – Max 1 drink/day for women, 2 for men
6. **Manage stress** – Yoga, meditation, deep breathing

## Monitoring
Measure BP regularly. Home BP monitors are affordable and accurate.

## Emergency Signs 🚨
BP > 180/120 with chest pain, severe headache, or vision loss — call emergency immediately.""",
        "❤️", "en", 5, ["hypertension", "blood pressure", "heart health", "lifestyle"], True,
    ),
    (
        "Child Fever: When to Worry and Home Care Guide",
        "child-health", "Practical guide for parents to manage child fever safely at home and know when to rush to hospital.",
        """## What is Fever in Children?
A temperature above 38°C (100.4°F) is a fever. It is the body's natural response to infection.

## Taking Temperature
- Rectal (most accurate for infants): 38°C+ = fever
- Armpit: 37.5°C+ = fever
- Forehead thermometer: useful but less accurate

## Home Care for Mild Fever (38–38.9°C)
- Keep child well-hydrated (water, ORS, breast milk)
- Dress lightly — do not wrap in blankets
- Lukewarm sponge bath (not cold water)
- Paracetamol: 10–15 mg/kg every 4–6 hours (pediatric dose)
- Rest in a cool, ventilated room

## Foods During Fever
- ORS (Oral Rehydration Solution) for dehydration
- Soft foods: rice porridge, banana, boiled potato
- Avoid forcing food if child refuses

## When to See a Doctor 🏥
- Fever above 39°C that does not reduce with paracetamol
- Child is under 3 months old
- Fever lasting more than 3 days
- Child has rash, stiff neck, or difficulty breathing

## Emergency Signs 🚨
Febrile seizures, extreme difficulty breathing, blue lips — call emergency immediately.""",
        "👶", "en", 4, ["child fever", "pediatric", "children health", "home care"], False,
    ),
    (
        "Mental Wellness for Rural Communities",
        "mental-health", "Practical mental health strategies designed for rural communities facing stigma, stress, and limited access.",
        """## Mental Health in Rural Areas
Rural communities face unique mental health challenges: isolation, agricultural stress, limited access to specialists, and social stigma.

## Common Mental Health Issues
- **Depression** – Persistent sadness, loss of interest, fatigue
- **Anxiety** – Excessive worry, restlessness, physical symptoms
- **Substance Use** – Alcohol, tobacco as coping mechanisms
- **Farmer Stress** – Crop failure, debt, and climate uncertainty

## Signs You Need Help
- Feeling sad or hopeless for more than 2 weeks
- Unable to perform daily activities
- Thinking about harming yourself
- Withdrawing from family and friends

## Self-Care Strategies
1. **Talk to someone trusted** – friend, family member, or community leader
2. **Physical activity** – Even farming work counts as exercise
3. **Sleep hygiene** – Regular sleep and wake times
4. **Spiritual practice** – Prayer, meditation, community rituals
5. **Limit alcohol** – A major risk factor for depression
6. **Social connection** – Attend community events and festivals

## Breaking the Stigma
Mental illness is a medical condition, not a character weakness. Seeking help is a sign of strength.

## Free Help Available
- National Mental Health Helpline: 1800-599-0019 (India)
- NIMHANS Helpline: 080-46110007""",
        "🧠", "en", 5, ["mental health", "depression", "anxiety", "rural", "wellness"], False,
    ),
    (
        "Breastfeeding: Benefits and Best Practices for New Mothers",
        "maternal-health", "Everything a new mother needs to know about breastfeeding, positions, and overcoming challenges.",
        """## Why Breastfeed?
Breast milk is the perfect food for infants. It provides complete nutrition and immunity for the first 6 months of life.

## Benefits for Baby
- Protection against infections (diarrhea, pneumonia, ear infections)
- Optimal brain development (DHA in breast milk)
- Lower risk of allergies, obesity, and diabetes
- Comfort and emotional bonding

## Benefits for Mother
- Helps uterus return to normal size faster
- Reduces risk of breast and ovarian cancer
- Natural contraceptive (lactational amenorrhea)
- Saves money on formula

## How to Breastfeed (Latch Technique)
1. Position baby with tummy facing your tummy
2. Support baby's head and neck
3. Tickle baby's lip with nipple to open mouth wide
4. Bring baby to breast (not breast to baby)
5. A good latch: no pain, baby's chin touches breast

## Breastfeeding Positions
- **Cradle hold** – Most common, baby across your front
- **Football hold** – Baby under arm, good after C-section
- **Side-lying** – Rest while feeding, good for night feeds

## Common Challenges & Solutions
- **Sore nipples** – Check latch; apply expressed milk to soothe
- **Low supply** – Feed more frequently; stay hydrated
- **Engorgement** – Feed often; warm compress before feeding

## WHO Recommendation
Exclusive breastfeeding for 6 months, then continued with complementary foods up to 2 years.""",
        "🤱", "en", 6, ["breastfeeding", "maternal health", "newborn", "infant nutrition"], False,
    ),
    (
        "Tuberculosis (TB): Facts, Prevention, and Treatment",
        "diseases", "Complete guide on TB spread, DOTS treatment, and prevention for households and communities.",
        """## What is Tuberculosis?
TB is a bacterial infection caused by *Mycobacterium tuberculosis*, mainly affecting the lungs.

## How TB Spreads
TB spreads through the air when an infected person coughs, sneezes, or speaks. You CANNOT get TB from:
- Shaking hands
- Sharing food or drink
- Touching surfaces

## Symptoms
- Persistent cough for 2+ weeks
- Coughing up blood or mucus
- Night sweats and fever
- Unexplained weight loss and fatigue
- Chest pain

## Risk Factors
- HIV infection (30x higher risk)
- Malnutrition and poverty
- Overcrowded living conditions
- Smoking and alcohol use
- Diabetes

## Treatment (DOTS — Directly Observed Treatment)
TB is curable with a 6-month course of antibiotics:
- **Phase 1 (2 months):** 4 drugs: Rifampicin + Isoniazid + Pyrazinamide + Ethambutol
- **Phase 2 (4 months):** 2 drugs: Rifampicin + Isoniazid

**Critical:** Complete the full course even if feeling better. Stopping early creates drug-resistant TB.

## Prevention
- BCG vaccination at birth (protects children)
- Good ventilation in homes and workplaces
- Cough etiquette (cover mouth when coughing)
- Early diagnosis and treatment

## Free Treatment
TB treatment is **free** at all government health centers under the National TB Elimination Programme (NTEP).""",
        "🫁", "en", 5, ["tuberculosis", "TB", "respiratory", "DOTS", "treatment"], False,
    ),
    # ── 11. Diarrhoea & ORS ──────────────────────────────────────────────────
    (
        "Diarrhoea in Children: ORS, Zinc & Prevention",
        "child-health",
        "How to prepare ORS at home, use zinc supplements, and prevent deadly dehydration in children.",
        """## Diarrhoea: A Leading Child Killer

Diarrhoea kills **500,000 children under 5** every year worldwide — almost all deaths are due to **dehydration**, not the infection itself. Simple ORS saves lives.

## Signs of Diarrhoea
- 3 or more loose/watery stools in 24 hours
- May be accompanied by vomiting, fever, and stomach cramps

## Levels of Dehydration

| Level | Signs | Action |
|---|---|---|
| **None** | Normal, playful | Continue ORS at home |
| **Mild** | Slightly less active, mildly dry mouth | ORS 50–100 mL/kg over 3–4 hours |
| **Severe** | Sunken eyes, no tears, very lethargic | Hospital immediately |

## How to Make ORS at Home
**Recipe:** 1 litre of clean water + 6 level teaspoons of sugar + half a teaspoon of salt

1. Boil and cool 1 litre of water
2. Add 6 level teaspoons (not heaped) of sugar
3. Add half a teaspoon of salt
4. Mix well until fully dissolved
5. Give small frequent sips — do not force large amounts

## Zinc Supplementation
- WHO recommends **zinc tablets** for 10–14 days during diarrhoea
- Under 6 months: 10 mg/day; Over 6 months: 20 mg/day

## Continue Feeding During Diarrhoea
- **Do NOT stop breast milk** — continue breastfeeding
- Offer soft foods: khichdi, banana, rice water

## Prevention
1. Exclusive breastfeeding for 6 months
2. Proper hand washing before feeding and after toilet
3. Safe drinking water (boil if unsure)
4. Rotavirus vaccine at 6 and 10 weeks""",
        "🥛", "en", 4, ["diarrhoea", "ORS", "zinc", "child health", "dehydration"], False,
    ),
    # ── 12. Anaemia ──────────────────────────────────────────────────────────
    (
        "Anaemia in Women: Iron Deficiency, Symptoms & Iron-Rich Diet",
        "womens-health",
        "Why anaemia is so common in women, how to recognize it, and the best dietary and supplementation strategies.",
        """## Anaemia: India's Biggest Nutritional Crisis

**Over 50% of women** in India have anaemia — a condition where blood lacks enough healthy red blood cells to carry oxygen throughout the body.

## Causes
- **Iron deficiency** (most common) — insufficient iron intake or absorption
- Vitamin B12 deficiency
- Blood loss (heavy periods, childbirth)
- Malaria and other infections

## Symptoms
- Persistent fatigue and weakness
- Pale or yellowish skin, gums, and nails
- Shortness of breath on mild exertion
- Rapid heartbeat and dizziness
- Brittle nails and hair loss

## Diagnosis
A simple blood test (CBC) measuring **haemoglobin level**:
- Normal women: Hb ≥ 12 g/dL
- Pregnant women: Hb ≥ 11 g/dL
- Anaemia: Hb < 11 g/dL

## Best Iron-Rich Foods

| Food | Iron Content |
|---|---|
| Chicken liver | 12 mg per 100g |
| Spinach (cooked) | 3.6 mg per 100g |
| Lentils (masoor dal) | 3.3 mg per 100g |
| Ragi (finger millet) | 3.9 mg per 100g |

## Enhance Iron Absorption
- Eat iron-rich foods WITH Vitamin C (lemon, orange, guava, amla)
- **Avoid** tea/coffee for 1 hour before and after iron-rich meals
- Cook in iron cookware — adds iron to food naturally

## Iron Supplements
- IFA (Iron & Folic Acid) tablets are FREE at government health centers
- Normal to have dark/black stools — harmless side effect""",
        "🩷", "en", 5, ["anaemia", "iron deficiency", "womens health", "diet", "pregnancy"], True,
    ),
    # ── 13. Snake Bite First Aid ─────────────────────────────────────────────
    (
        "Snake Bite First Aid: Do's, Don'ts & Emergency Response",
        "first-aid",
        "Critical first aid steps for snake bites, dangerous myths to avoid, and when to reach hospital fast.",
        """## Snake Bite Emergency Response

In India, **58,000+ people die** from snake bites annually — most deaths are preventable with the right first aid and timely anti-venom at hospital.

## IMMEDIATE Steps — The Do's
1. **Stay calm** — panic increases heart rate and speeds venom spread
2. **Immobilize the bitten limb** — keep it below heart level
3. **Remove jewellery and tight clothing** near the bite (for swelling)
4. **Mark the edge of swelling** with a pen and note the time
5. **Get to hospital FAST** — anti-venom is the ONLY cure
6. **If possible, photograph or describe the snake**

## Critical DON'Ts
- Do NOT cut the wound and suck out venom (causes infection)
- Do NOT apply a tourniquet (cuts off blood, causes gangrene)
- Do NOT apply ice (causes tissue damage)
- Do NOT give alcohol or traditional remedies
- Do NOT waste time with traditional healers — go to hospital

## Signs of Envenomation
- Severe local pain, swelling, and bruising
- Drooping eyelids and blurred vision (neurotoxic snake)
- Difficulty swallowing or breathing

## At Hospital
Anti-snake venom (ASV) is available **FREE** at all government hospitals.

## Prevention in Rural Areas
- Wear thick footwear when walking in fields at night
- Use a torch after dark
- Snakes are most active during monsoon season""",
        "🐍", "en", 4, ["snake bite", "first aid", "emergency", "rural health", "poison"], True,
    ),
    # ── 14. Eye Care ─────────────────────────────────────────────────────────
    (
        "Protecting Your Eyesight: Common Eye Problems & Prevention",
        "eye-ear-care",
        "Guide to common eye conditions including cataracts, glaucoma, and digital eye strain, with prevention tips.",
        """## Protecting Your Precious Eyesight

**2.2 billion people** globally have vision impairment — half of these cases are preventable. Regular eye care is as important as dental care.

## Common Eye Conditions in India

**Cataracts**
- Leading cause of blindness in India (80% of cases)
- Lens becomes cloudy — blurry, foggy vision
- **Treatment:** Simple 15-minute surgery completely cures it — FREE at government hospitals

**Glaucoma**
- "Silent thief of sight" — no symptoms until significant damage
- Annual eye check after age 40 is essential

**Refractive Errors**
- Most common vision problem — corrected with glasses or contact lenses
- Children: Untreated short-sightedness affects learning in school

**Diabetic Retinopathy**
- Affects 1 in 3 diabetics — annual dilated eye exam is mandatory

## Digital Eye Strain — The 20-20-20 Rule
Every **20 minutes**, look at something **20 feet away** for **20 seconds**

## Eye-Protective Nutrition
- **Vitamin A:** Carrots, sweet potato, papaya (prevents night blindness)
- **Lutein & Zeaxanthin:** Spinach, kale
- **Omega-3:** Fish (reduces dry eye risk)

## Emergency Signs
- Sudden vision loss or blurring in one eye
- Sudden onset of multiple floaters or flashes of light
- Eye injury — rinse immediately with clean water for 15 mins""",
        "👁️", "en", 5, ["eye care", "cataract", "glaucoma", "vision", "eye health"], False,
    ),
    # ── 15. Safe Drinking Water ──────────────────────────────────────────────
    (
        "Safe Drinking Water: Purification Methods for Rural Homes",
        "hygiene",
        "Practical guide to making water safe at home using boiling, chlorination, and solar disinfection.",
        """## Safe Water Saves Lives

Contaminated water causes **cholera, typhoid, dysentery, and diarrhoea** — together responsible for 2 million deaths annually, mostly children.

## Method 1: Boiling (Most Effective)
1. Fill a clean pot with water
2. Bring to a **rolling boil for 1 full minute**
3. Cover and let cool naturally — do NOT add ice
4. Store in a covered clean container
- **Cost:** Free (fuel only). Kills ALL pathogens.

## Method 2: Chlorination
- Add **2 drops** of sodium hypochlorite solution (bleach, 5%) per litre
- Stir and wait **30 minutes** before drinking

## Method 3: Solar Disinfection (SODIS)
- Fill **clear PET plastic bottles** with water
- Place in direct sunlight for **6 hours** (or 2 days if cloudy)
- **Cost:** Completely free

## Water Storage Rules
- Store in narrow-neck containers
- Keep covered at all times
- Clean storage containers weekly with dilute bleach

## Signs Your Water May Be Contaminated
- Unusual colour, smell, or taste
- Diarrhoea/illness in multiple family members
- Flooding (contaminates wells and borewells)""",
        "💧", "en", 4, ["water safety", "WASH", "sanitation", "cholera", "typhoid", "rural"], False,
    ),
    # ── 16. Heart Attack ─────────────────────────────────────────────────────
    (
        "Heart Attack Warning Signs & Immediate Action Steps",
        "heart-health",
        "Learn to recognize heart attack symptoms before they become fatal and what to do in the critical first minutes.",
        """## Recognise a Heart Attack — Every Minute Counts

A heart attack (myocardial infarction) occurs when blood supply to part of the heart muscle is blocked. **Brain damage begins within 4 minutes** of cardiac arrest.

## Classic Heart Attack Symptoms
- **Chest pain or pressure** — feels like squeezing, heaviness, or tightness
- Pain radiating to **left arm, jaw, neck, or back**
- **Sweating** (cold, clammy sweat without exertion)
- **Shortness of breath** even at rest
- Nausea, vomiting, or indigestion-like discomfort

## Warning: Women's Symptoms Are Often Different
- Unusual fatigue for days before
- Shortness of breath WITHOUT chest pain
- Jaw pain, neckache, or upper back pain

## IMMEDIATE Action — Call for Help NOW
1. **Call 112 (India emergency)** or 108 immediately
2. Have the person sit or lie comfortably
3. Loosen tight clothing around neck and chest
4. If unconscious and not breathing, start CPR

## Basic CPR (Hands-Only)
1. Place heel of hand on center of chest
2. Press down **hard and fast** — 5–6 cm deep, 100–120 times per minute
3. Continue until ambulance arrives

## Risk Factors You Can Control
- Stop smoking (risk halves within 1 year of quitting)
- Control blood pressure, cholesterol, and diabetes
- Exercise regularly and maintain healthy weight""",
        "🫀", "en", 4, ["heart attack", "cardiac emergency", "heart health", "CPR", "first aid"], True,
    ),
    # ── 17. Sleep Health ─────────────────────────────────────────────────────
    (
        "Sleep Your Way to Better Health: Sleep Hygiene Guide",
        "healthy-lifestyle",
        "Why quality sleep is as important as diet and exercise, and practical habits for better rest.",
        """## Sleep: The Foundation of All Health

During sleep, your body **repairs muscles, consolidates memory, balances hormones, and resets the immune system**. Chronic sleep deprivation is linked to obesity, diabetes, heart disease, and depression.

## How Much Sleep Do You Need?

| Age Group | Recommended Sleep |
|---|---|
| School children (6–12) | 9–12 hours |
| **Adults (18–64)** | **7–9 hours** |
| Older adults (65+) | 7–8 hours |

## Signs of Poor Sleep Quality
- Difficulty falling asleep (> 30 minutes)
- Waking up multiple times per night
- Feeling tired even after 8 hours
- Needing caffeine to function

## Sleep Hygiene: 10 Science-Backed Tips
1. **Fixed schedule** — Same wake time every day (even weekends)
2. **Dark, cool, quiet room** — 18–22°C is ideal
3. **No screens 1 hour before bed** — Blue light suppresses melatonin
4. **No caffeine after 2 PM** — Caffeine has 5–6 hour half-life
5. **Exercise daily** — But not within 2 hours of bedtime
6. **Wind-down routine** — Reading, light stretching, warm bath
7. **No large meals within 2–3 hours** of sleep
8. **Reserve bed for sleep only**
9. **Get morning sunlight** — Sets your circadian clock
10. **Limit alcohol** — Disrupts REM sleep

## Natural Sleep Aids
- **Chamomile tea** — Mild sedative effect
- **Ashwagandha** — Reduces cortisol, improves sleep quality
- **Breathing technique:** 4-7-8 (inhale 4s, hold 7s, exhale 8s)""",
        "😴", "en", 5, ["sleep", "insomnia", "lifestyle", "mental health", "wellness"], False,
    ),
    # ── 18. Dengue ───────────────────────────────────────────────────────────
    (
        "Dengue Fever: Symptoms, Warning Signs & Home Management",
        "diseases",
        "How to recognize dengue fever early, manage it safely at home, and spot the dangerous warning signs.",
        """## What is Dengue Fever?

Dengue is caused by **4 dengue virus serotypes** spread by the *Aedes aegypti* mosquito — a **day-biting mosquito** that breeds in clean stagnant water.

## Symptoms — The Dengue Triad
**Days 1–3 (Febrile Phase):**
- Sudden high fever (39–40°C)
- Severe headache behind the eyes
- Intense joint and muscle pain ("breakbone fever")
- Skin rash

## Warning Signs Requiring IMMEDIATE Hospital Admission
- Abdominal pain or tenderness
- Persistent vomiting (3+ times in 24 hours)
- Bleeding from gums, nose, or under skin
- Blood in urine, stool, or vomit
- Extreme fatigue or restlessness

## Home Management for Uncomplicated Dengue
- **Rest completely**
- **Hydration is critical** — minimum 8–10 glasses water/day
- **Paracetamol** for fever — NEVER aspirin or ibuprofen (increase bleeding risk)
- Monitor platelet count daily if prescribed

## Prevention
- Aedes mosquitoes breed in **clean, stagnant water** — check and empty flower pots, coolers, tyres
- Use mosquito repellent, long sleeves during daytime
- Window and door screens""",
        "🦠", "en", 5, ["dengue", "fever", "mosquito", "platelet", "tropical disease"], True,
    ),
    # ── 19. Exercise ─────────────────────────────────────────────────────────
    (
        "Physical Activity for Health: A Beginner's Exercise Guide",
        "healthy-lifestyle",
        "How much exercise you actually need, the best types for different health goals, and how to start safely.",
        """## Why Physical Activity is Medicine

Regular physical activity prevents and manages **heart disease, diabetes, hypertension, depression, and 13 types of cancer**.

## WHO Weekly Recommendations

| Age Group | Weekly Target |
|---|---|
| Adults (18–64) | **150–300 min moderate** or 75–150 min vigorous |
| Children (5–17) | 60 min/day moderate-to-vigorous |
| Older adults (65+) | Same + balance exercises |

## Types of Exercise & Benefits

**Aerobic/Cardio** — Walking, jogging, cycling, swimming
- Target: At least 150 min/week

**Strength Training** — Bodyweight squats, push-ups
- Target: 2 sessions/week

**Flexibility** — Yoga, stretching
- Reduces injury risk, improves posture

## The FITT Principle for Beginners
- **Frequency** — Start 3 days/week, build to 5
- **Intensity** — Start easy (can hold conversation while exercising)
- **Time** — Start 15 min, increase by 5 min each week
- **Type** — Choose something you enjoy

## No Gym Needed!
- Brisk walking (30 min = 200 calories burned)
- Sun Salutations (Surya Namaskar) — full body workout
- Bodyweight squats, lunges, push-ups, plank

## When to Avoid Exercise
- Fever or active infection — rest completely
- Chest pain or dizziness during exercise — stop and see doctor""",
        "🏃", "en", 5, ["exercise", "fitness", "lifestyle", "weight loss", "heart health"], False,
    ),
    # ── 20. Antenatal Care ───────────────────────────────────────────────────
    (
        "Antenatal Care: Essential Pregnancy Check-ups & Tests",
        "maternal-health",
        "The minimum ANC visits every pregnant woman needs, what tests to expect, and danger signs to know.",
        """## Why Antenatal Care Saves Lives

Antenatal Care (ANC) visits allow healthcare workers to monitor mother and baby, prevent complications, and prepare for safe delivery. WHO recommends minimum 8 ANC visits.

## Recommended ANC Schedule

| Visit | When | Purpose |
|---|---|---|
| **1st** | < 12 weeks | Confirm pregnancy, baseline tests, folate/iron start |
| **2nd** | 14–26 weeks | Anomaly scan, blood sugar screening |
| **3rd** | 28–32 weeks | Check fetal growth, Hb test |
| **4th** | 36–40 weeks | Birth planning, check presentation |

## Tests You Should Expect
- Blood tests: Haemoglobin, blood group, HIV, VDRL, blood sugar
- Urine test: Protein and sugar
- Blood pressure at every visit
- Ultrasound scans: dating scan, anomaly scan, growth scan
- Tetanus Toxoid (TT): 2 doses in first pregnancy

## Mandatory Supplements (FREE at government centers)
- **IFA tablets** — take daily from first trimester
- **Calcium tablets** — 1g/day from 2nd trimester

## Danger Signs During Pregnancy
- Heavy vaginal bleeding at any stage
- Severe headache with blurred vision (pre-eclampsia)
- Sudden swelling of face, hands, or legs
- Reduced or absent fetal movement after 28 weeks""",
        "🏥", "en", 6, ["antenatal", "ANC", "pregnancy", "maternal health", "prenatal care"], False,
    ),
    # ── 21. Cholesterol ──────────────────────────────────────────────────────
    (
        "Understanding Cholesterol: Good vs Bad & Diet Changes",
        "heart-health",
        "What cholesterol numbers mean, which foods raise bad cholesterol, and what to eat to protect your heart.",
        """## Cholesterol: Not All Bad

Cholesterol is a fatty substance in the blood — the body needs it for cell membranes and hormones. But too much of the **wrong type** clogs arteries and causes heart attacks and strokes.

## Understanding Your Lipid Profile

| Type | Target | Role |
|---|---|---|
| **Total Cholesterol** | < 200 mg/dL | Overall indicator |
| **LDL ("Bad")** | < 100 mg/dL | Deposits in artery walls |
| **HDL ("Good")** | > 60 mg/dL | Removes cholesterol from arteries |
| **Triglycerides** | < 150 mg/dL | Raised by sugar & alcohol |

## Foods That Raise Bad Cholesterol (Limit These)
- **Trans fats** — vanaspati, commercial fried snacks, bakery items
- **Saturated fats** — excess ghee, butter, red meat
- **Refined carbohydrates** — white bread, sugary foods

## Foods That Lower Bad Cholesterol
- **Oats and barley** — beta-glucan fibre actively lowers LDL
- **Beans and lentils** — soluble fibre traps cholesterol
- **Nuts** — walnuts, almonds lower LDL by 5–10%
- **Fatty fish** — salmon, mackerel (omega-3 lowers triglycerides)

## Lifestyle Changes
- **Exercise** raises HDL ("good") cholesterol
- **Lose weight** — 5–10 kg weight loss significantly improves all lipid values
- **Stop smoking** — damages HDL""",
        "🫀", "en", 5, ["cholesterol", "heart health", "LDL", "HDL", "diet", "atherosclerosis"], False,
    ),
    # ── 22. Oral Health ──────────────────────────────────────────────────────
    (
        "Oral Health: Brushing, Flossing & Preventing Gum Disease",
        "hygiene",
        "Simple daily habits to prevent tooth decay, gum disease, and how oral health connects to heart and diabetes risk.",
        """## Oral Health = Overall Health

Poor oral health is **not just a cosmetic issue** — gum disease bacteria can enter the bloodstream and increase risk of heart disease, diabetes complications, and preterm birth.

## Correct Brushing Technique
1. Use a **soft-bristled toothbrush**
2. Apply pea-sized amount of fluoride toothpaste
3. Hold brush at **45-degree angle** to gum line
4. Gentle circular or short back-and-forth strokes
5. Brush all surfaces: outer, inner, and chewing surfaces
6. Gently brush the tongue (removes bacteria causing bad breath)
7. **Duration: 2 minutes, twice daily**
8. Replace toothbrush every 3 months

## Diet for Healthy Teeth
**Good for teeth:**
- Crunchy vegetables (carrots, cucumber) — natural cleaners
- Dairy (cheese, paneer) — calcium and phosphorus

**Harmful for teeth:**
- Sugary foods and drinks
- Carbonated/soft drinks — erode enamel

## Warning Signs — See a Dentist
- Toothache or sensitivity to hot/cold
- Gums that bleed when brushing (early gum disease)
- Ulcers that do not heal in 2 weeks (oral cancer screening)

## For Rural Communities
- **Neem twig (datun)** — traditional toothbrush; anti-bacterial; effective when used correctly
- **Salt water rinse** — helps with minor gum inflammation""",
        "🦷", "en", 4, ["oral health", "teeth", "brushing", "gum disease", "dental hygiene"], False,
    ),
    # ── 23. Pneumonia ────────────────────────────────────────────────────────
    (
        "Pneumonia in Children: Recognition, Treatment & Prevention",
        "diseases",
        "Pneumonia kills more children than any other disease. Learn to recognize it early and seek treatment fast.",
        """## Pneumonia: The No.1 Child Killer

Pneumonia kills **over 700,000 children under 5** every year — more than AIDS, malaria, and tuberculosis combined. Yet it is **preventable and treatable**.

## How to Recognise Pneumonia in Children

**Key Sign: Fast Breathing**
- Under 2 months: 60+ breaths/minute
- 2–12 months: 50+ breaths/minute
- 1–5 years: 40+ breaths/minute

**Other Signs:**
- Fever (may be high or lower than normal in infants)
- Chest in-drawing (skin pulling in below ribs with each breath)
- Blue lips or fingernails (cyanosis) — severe sign

## Go to Hospital Immediately If:
- Child has fast breathing AND chest in-drawing
- Blue lips or extreme lethargy
- Cannot drink or is vomiting everything
- Child is under 2 months with any fever

## Treatment
- **Bacterial pneumonia:** Antibiotics (amoxicillin) cure most cases in 5–7 days
- Antibiotics are FREE at government health centers
- Continue full antibiotic course even if child improves

## Prevention
1. **Vaccines** — PCV (pneumococcal), Hib, influenza vaccines
2. **Exclusive breastfeeding** for 6 months
3. **Reduce indoor air pollution** — improve ventilation
4. **Good nutrition** — prevent malnutrition which increases risk 4x""",
        "🌬️", "en", 4, ["pneumonia", "child health", "respiratory", "breathing", "infection"], False,
    ),
    # ── 24. Cancer Warning Signs ─────────────────────────────────────────────
    (
        "7 Cancer Warning Signs You Should Never Ignore",
        "healthy-lifestyle",
        "The universal early warning signs of cancer and which risk factors you can actually control to prevent it.",
        """## Cancer: Early Detection Saves Lives

When detected early, many cancers are **curable**. Knowing the warning signs and acting quickly is the difference between cure and terminal illness.

## The 7 Warning Signs of Cancer (CAUTION)

**C** — Change in bowel or bladder habits
**A** — A sore that does not heal (especially in mouth)
**U** — Unusual bleeding or discharge
**T** — Thickening or lump in breast or anywhere
**I** — Indigestion or difficulty swallowing that persists
**O** — Obvious change in wart or mole
**N** — Nagging cough or hoarseness lasting > 3 weeks

## Most Common Cancers in India

| Cancer | Main Risk Factors |
|---|---|
| **Oral/Mouth** | Tobacco (chewing/smoking), betel nut, alcohol |
| **Cervical** | HPV infection, multiple partners, poor hygiene |
| **Breast** | Age, family history, obesity, alcohol |
| **Lung** | Smoking (90% of cases), indoor air pollution |

## Lifestyle Changes for Cancer Prevention
1. **Stop all tobacco use** — causes 22% of all cancer deaths
2. **Limit alcohol** — linked to 7 cancer types
3. **Maintain healthy weight** — obesity linked to 13 cancers
4. **Physical activity** — reduces risk of colon, breast, uterine cancers

## Screening Saves Lives
- **Cervical cancer:** PAP smear every 3 years for women 25–65 (free at government hospitals)
- **Breast cancer:** Monthly self-examination; mammogram every 2 years after 40
- **Oral cancer:** Inspect mouth monthly (high tobacco users)""",
        "🔬", "en", 5, ["cancer", "prevention", "early detection", "screening", "lifestyle"], False,
    ),
    # ── 25. Newborn Care ─────────────────────────────────────────────────────
    (
        "Essential Newborn Care: First 28 Days Guide for Parents",
        "child-health",
        "Everything parents need for the critical first 28 days of a newborn's life — warmth, feeding, cord care, and danger signs.",
        """## The Critical First 28 Days

The neonatal period (first 28 days) is the **most vulnerable time in a child's life** — 75% of under-5 deaths occur in this period.

## Warmth: Preventing Hypothermia
Newborns lose heat rapidly — **hypothermia is a silent killer**.

- Dry baby immediately after birth and wrap in warm cloth
- **Kangaroo Mother Care (KMC):** Skin-to-skin contact between mother and baby for at least 2 hours/day
- Room temperature should be 25–28°C
- Delay first bath for at least **24 hours**

## Feeding: Breast Milk Only
- Initiate breastfeeding **within 1 hour of birth**
- Give colostrum (first yellowish milk) — extremely rich in antibodies
- **NO water, sugar water, or formula** unless medically indicated
- Feed on demand — approximately 8–12 times in 24 hours

## Cord Care
- Keep cord stump **dry and clean**
- Do NOT apply anything (ash, oil, mud, turmeric) — causes infection
- Cord falls off naturally in 7–14 days
- **Danger sign:** Redness around cord base, pus, or foul smell

## Routine Newborn Care
- **Vitamin K injection** at birth (prevents bleeding)
- **BCG and OPV-0** vaccines at birth

## Danger Signs in Newborns — Hospital Immediately
- Not breastfeeding or drinking for 6+ hours
- Convulsions/shaking
- Fast breathing (> 60/min) or severe chest in-drawing
- Temperature < 35.5°C or > 38°C
- Yellow colour on palms and soles (severe jaundice)""",
        "🍼", "en", 6, ["newborn", "infant care", "child health", "cord care", "baby"], True,
    ),
]


class SeedService:
    """Idempotent seed — safe to call on every startup."""

    @staticmethod
    async def seed(db: AsyncSession) -> None:
        # 1. Seed categories — upsert so colour changes take effect immediately
        for name, slug, icon, color, order in _CATEGORIES:
            result = await db.execute(
                select(HealthCategory).where(HealthCategory.slug == slug)
            )
            existing = result.scalar_one_or_none()
            if existing:
                # Always update icon and colour so changes are applied live
                existing.icon      = icon
                existing.color_hex = color
                existing.sort_order = order
            else:
                db.add(HealthCategory(
                    name=name, slug=slug, icon=icon,
                    color_hex=color, sort_order=order,
                    description=f"Educational content about {name.lower()}.",
                ))
        await db.flush()

        # 2. Seed articles
        for (title, cat_slug, summary, content, emoji, lang, read_time, tags, featured) in _SEED_ARTICLES:
            slug = _slugify(title)
            exists = await db.execute(select(HealthArticle).where(HealthArticle.slug == slug))
            if exists.scalar_one_or_none():
                continue
            cat_row = await db.execute(select(HealthCategory).where(HealthCategory.slug == cat_slug))
            category = cat_row.scalar_one_or_none()
            db.add(HealthArticle(
                category_id=category.id if category else None,
                title=title, slug=slug, summary=summary, content=content,
                emoji=emoji, language=lang, read_time_min=read_time,
                tags=tags, is_featured=featured, is_published=True,
                author="AI Healthcare Team",
            ))
        await db.commit()


# ─── CategoryService ─────────────────────────────────────────────────────────

class CategoryService:
    @staticmethod
    async def list_categories(db: AsyncSession) -> list[HealthCategoryResponse]:
        result = await db.execute(
            select(HealthCategory)
            .where(HealthCategory.is_active == True)
            .order_by(HealthCategory.sort_order)
        )
        cats = result.scalars().all()
        return [HealthCategoryResponse.model_validate(c) for c in cats]


# ─── ArticleService ───────────────────────────────────────────────────────────

class ArticleService:

    @staticmethod
    async def list_articles(
        db: AsyncSession,
        user_id: Optional[str],
        category_slug: Optional[str] = None,
        language: str = "en",
        page: int = 1,
        per_page: int = 20,
    ) -> ArticleListResponse:
        stmt = (
            select(HealthArticle)
            .where(HealthArticle.is_published == True)
            .where(HealthArticle.language == language)
        )
        if category_slug:
            cat = await db.execute(select(HealthCategory).where(HealthCategory.slug == category_slug))
            cat_obj = cat.scalar_one_or_none()
            if cat_obj:
                stmt = stmt.where(HealthArticle.category_id == cat_obj.id)

        total_result = await db.execute(select(func.count()).select_from(stmt.subquery()))
        total = total_result.scalar_one()

        stmt = stmt.order_by(HealthArticle.published_at.desc()).offset((page - 1) * per_page).limit(per_page)
        rows = await db.execute(stmt)
        articles = rows.scalars().all()

        bookmarked_ids = await _user_bookmark_ids(db, user_id) if user_id else set()
        summaries = []
        for a in articles:
            cat = await _get_category(db, a.category_id)
            summaries.append(_article_to_summary(a, cat, a.id in bookmarked_ids))

        return ArticleListResponse(total=total, page=page, per_page=per_page, articles=summaries)

    @staticmethod
    async def get_article_detail(
        db: AsyncSession,
        article_id: str,
        user_id: Optional[str],
    ) -> Optional[HealthArticleDetail]:
        result = await db.execute(select(HealthArticle).where(HealthArticle.id == article_id))
        article = result.scalar_one_or_none()
        if not article:
            return None

        # bump view count
        await db.execute(
            update(HealthArticle)
            .where(HealthArticle.id == article_id)
            .values(view_count=HealthArticle.view_count + 1)
        )
        await db.commit()

        cat = await _get_category(db, article.category_id)
        bookmarked_ids = await _user_bookmark_ids(db, user_id) if user_id else set()

        return HealthArticleDetail(
            id=article.id,
            category_id=article.category_id,
            category_name=cat.name if cat else None,
            category_slug=cat.slug if cat else None,
            category_color=cat.color_hex if cat else None,
            title=article.title,
            slug=article.slug,
            summary=article.summary,
            content=article.content,
            language=article.language,
            author=article.author,
            source=article.source,
            read_time_min=article.read_time_min,
            cover_image=article.cover_image,
            emoji=article.emoji,
            tags=article.tags or [],
            is_featured=article.is_featured,
            view_count=article.view_count,
            bookmark_count=article.bookmark_count,
            published_at=article.published_at,
            created_at=article.created_at,
            updated_at=article.updated_at,
            is_bookmarked=article.id in bookmarked_ids,
        )

    @staticmethod
    async def get_featured(
        db: AsyncSession, user_id: Optional[str], language: str = "en", limit: int = 5,
    ) -> list[HealthArticleSummary]:
        result = await db.execute(
            select(HealthArticle)
            .where(HealthArticle.is_featured == True)
            .where(HealthArticle.is_published == True)
            .where(HealthArticle.language == language)
            .order_by(HealthArticle.published_at.desc())
            .limit(limit)
        )
        articles = result.scalars().all()
        bookmarked_ids = await _user_bookmark_ids(db, user_id) if user_id else set()
        summaries = []
        for a in articles:
            cat = await _get_category(db, a.category_id)
            summaries.append(_article_to_summary(a, cat, a.id in bookmarked_ids))
        return summaries

    @staticmethod
    async def search(
        db: AsyncSession, query: str, user_id: Optional[str], language: str = "en", limit: int = 20,
    ) -> SearchResponse:
        like = f"%{query}%"
        result = await db.execute(
            select(HealthArticle)
            .where(HealthArticle.is_published == True)
            .where(HealthArticle.language == language)
            .where(
                or_(
                    HealthArticle.title.ilike(like),
                    HealthArticle.summary.ilike(like),
                    HealthArticle.content.ilike(like),
                )
            )
            .order_by(HealthArticle.view_count.desc())
            .limit(limit)
        )
        articles = result.scalars().all()
        bookmarked_ids = await _user_bookmark_ids(db, user_id) if user_id else set()
        summaries = []
        for a in articles:
            cat = await _get_category(db, a.category_id)
            summaries.append(_article_to_summary(a, cat, a.id in bookmarked_ids))
        return SearchResponse(query=query, total=len(summaries), articles=summaries)

    @staticmethod
    async def get_recommendations(
        db: AsyncSession,
        user_id: Optional[str],
        language: str = "en",
        limit: int = 8,
    ) -> list[HealthArticleSummary]:
        """Simple content-based recommendation: most viewed + bookmarked articles."""
        result = await db.execute(
            select(HealthArticle)
            .where(HealthArticle.is_published == True)
            .where(HealthArticle.language == language)
            .order_by(
                (HealthArticle.view_count + HealthArticle.bookmark_count * 3).desc()
            )
            .limit(limit)
        )
        articles = result.scalars().all()
        bookmarked_ids = await _user_bookmark_ids(db, user_id) if user_id else set()
        summaries = []
        for a in articles:
            cat = await _get_category(db, a.category_id)
            summaries.append(_article_to_summary(a, cat, a.id in bookmarked_ids))
        return summaries


# ─── BookmarkService ──────────────────────────────────────────────────────────

class BookmarkService:
    @staticmethod
    async def list_bookmarks(
        db: AsyncSession, user_id: str, language: str = "en",
    ) -> list[HealthArticleSummary]:
        result = await db.execute(
            select(UserBookmark).where(UserBookmark.user_id == user_id)
            .order_by(UserBookmark.created_at.desc())
        )
        bookmarks = result.scalars().all()
        summaries = []
        for bm in bookmarks:
            a_result = await db.execute(
                select(HealthArticle).where(HealthArticle.id == bm.article_id)
            )
            article = a_result.scalar_one_or_none()
            if article and article.is_published:
                cat = await _get_category(db, article.category_id)
                summaries.append(_article_to_summary(article, cat, True))
        return summaries

    @staticmethod
    async def add_bookmark(
        db: AsyncSession, user_id: str, article_id: str,
    ) -> BookmarkResponse:
        exists = await db.execute(
            select(UserBookmark)
            .where(UserBookmark.user_id == user_id)
            .where(UserBookmark.article_id == article_id)
        )
        bm = exists.scalar_one_or_none()
        if not bm:
            bm = UserBookmark(user_id=user_id, article_id=article_id)
            db.add(bm)
            await db.execute(
                update(HealthArticle)
                .where(HealthArticle.id == article_id)
                .values(bookmark_count=HealthArticle.bookmark_count + 1)
            )
            await db.commit()
            await db.refresh(bm)
        return BookmarkResponse.model_validate(bm)

    @staticmethod
    async def remove_bookmark(db: AsyncSession, user_id: str, bookmark_id: str) -> bool:
        result = await db.execute(
            select(UserBookmark)
            .where(UserBookmark.id == bookmark_id)
            .where(UserBookmark.user_id == user_id)
        )
        bm = result.scalar_one_or_none()
        if not bm:
            return False
        await db.execute(
            update(HealthArticle)
            .where(HealthArticle.id == bm.article_id)
            .values(bookmark_count=func.greatest(HealthArticle.bookmark_count - 1, 0))
        )
        await db.delete(bm)
        await db.commit()
        return True


# ─── ReadingHistoryService ────────────────────────────────────────────────────

class ReadingHistoryService:
    @staticmethod
    async def update_progress(
        db: AsyncSession,
        user_id: str,
        article_id: str,
        position: int,
        is_completed: bool,
    ) -> ReadingHistoryResponse:
        result = await db.execute(
            select(ReadingHistory)
            .where(ReadingHistory.user_id == user_id)
            .where(ReadingHistory.article_id == article_id)
        )
        rh = result.scalar_one_or_none()
        if rh:
            rh.last_read_position = position
            rh.is_completed = is_completed
            rh.read_count = rh.read_count + 1
        else:
            rh = ReadingHistory(
                user_id=user_id, article_id=article_id,
                last_read_position=position, is_completed=is_completed,
            )
            db.add(rh)
        await db.commit()
        await db.refresh(rh)
        return ReadingHistoryResponse.model_validate(rh)

    @staticmethod
    async def get_recent(
        db: AsyncSession, user_id: str, limit: int = 10,
    ) -> list[HealthArticleSummary]:
        result = await db.execute(
            select(ReadingHistory)
            .where(ReadingHistory.user_id == user_id)
            .order_by(ReadingHistory.updated_at.desc())
            .limit(limit)
        )
        history = result.scalars().all()
        bookmarked_ids = await _user_bookmark_ids(db, user_id)
        summaries = []
        for rh in history:
            a_result = await db.execute(select(HealthArticle).where(HealthArticle.id == rh.article_id))
            article = a_result.scalar_one_or_none()
            if article and article.is_published:
                cat = await _get_category(db, article.category_id)
                summaries.append(_article_to_summary(article, cat, rh.article_id in bookmarked_ids))
        return summaries


# ─── DashboardService ─────────────────────────────────────────────────────────

class DashboardService:
    @staticmethod
    async def get_dashboard(
        db: AsyncSession,
        user_id: Optional[str],
        language: str = "en",
    ) -> EducationDashboard:
        featured    = await ArticleService.get_featured(db, user_id, language, limit=5)
        categories  = await CategoryService.list_categories(db)
        recommended = await ArticleService.get_recommendations(db, user_id, language, limit=8)
        recent      = await ReadingHistoryService.get_recent(db, user_id) if user_id else []
        bookmarks   = await BookmarkService.list_bookmarks(db, user_id, language) if user_id else []

        return EducationDashboard(
            featured_articles=featured,
            categories=categories,
            recommended_articles=recommended,
            recent_articles=recent,
            bookmarks=bookmarks[:5],
        )
