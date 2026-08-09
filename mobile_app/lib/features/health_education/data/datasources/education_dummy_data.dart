import '../models/health_article_model.dart';
import '../models/health_category_model.dart';

/// Offline-first fallback data. 25 comprehensive health education articles.
/// Used when the API is unreachable (guest mode / no internet).
class EducationDummyData {
  EducationDummyData._();

  // ── Categories ─────────────────────────────────────────────────────────────

  static List<HealthCategoryModel> get categories => [
        const HealthCategoryModel(id: 'cat-1', name: 'Diseases',          slug: 'diseases',          icon: '🩺', colorHex: '#F97316', sortOrder: 1, isActive: true),
        const HealthCategoryModel(id: 'cat-2', name: 'Nutrition',         slug: 'nutrition',          icon: '🥗', colorHex: '#2ECC8B', sortOrder: 2, isActive: true),
        const HealthCategoryModel(id: 'cat-3', name: 'Vaccination',       slug: 'vaccination',        icon: '💉', colorHex: '#4F94FF', sortOrder: 3, isActive: true),
        const HealthCategoryModel(id: 'cat-4', name: 'Maternal Health',   slug: 'maternal-health',    icon: '🤰', colorHex: '#E879A0', sortOrder: 4, isActive: true),
        const HealthCategoryModel(id: 'cat-5', name: 'Child Health',      slug: 'child-health',       icon: '👶', colorHex: '#FFB829', sortOrder: 5, isActive: true),
        const HealthCategoryModel(id: 'cat-6', name: 'Hygiene',           slug: 'hygiene',            icon: '🧼', colorHex: '#18C8C8', sortOrder: 6, isActive: true),
        const HealthCategoryModel(id: 'cat-7', name: 'Lifestyle',         slug: 'healthy-lifestyle',  icon: '🏃', colorHex: '#926EFF', sortOrder: 7, isActive: true),
        const HealthCategoryModel(id: 'cat-8', name: 'Mental Health',     slug: 'mental-health',      icon: '🧠', colorHex: '#7C3AED', sortOrder: 8, isActive: true),
        const HealthCategoryModel(id: 'cat-9', name: 'Heart Health',      slug: 'heart-health',       icon: '❤️', colorHex: '#EF4444', sortOrder: 9, isActive: true),
        const HealthCategoryModel(id: 'cat-10', name: 'First Aid',        slug: 'first-aid',          icon: '🩹', colorHex: '#F43F5E', sortOrder: 10, isActive: true),
        const HealthCategoryModel(id: 'cat-11', name: 'Women\'s Health',  slug: 'womens-health',      icon: '♀️', colorHex: '#EC4899', sortOrder: 11, isActive: true),
        const HealthCategoryModel(id: 'cat-12', name: 'Eye & Ear Care',   slug: 'eye-ear-care',       icon: '👁️', colorHex: '#0EA5E9', sortOrder: 12, isActive: true),
      ];

  // ── Articles ───────────────────────────────────────────────────────────────

  static List<HealthArticleModel> get articles => [
        // ── 1. Diabetes ──────────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-1', categoryId: 'cat-1', categoryName: 'Diseases',
          categorySlug: 'diseases', categoryColor: '#F97316',
          title: 'Understanding Diabetes: Causes, Symptoms & Prevention',
          slug: 'understanding-diabetes', language: 'en',
          summary: 'Learn how diabetes develops, early warning signs, and proven prevention strategies.',
          emoji: '🩸', readTimeMin: 5, isFeatured: true,
          viewCount: 1240, bookmarkCount: 87,
          tags: ['diabetes', 'sugar', 'chronic disease', 'prevention'],
          content: r'''## What is Diabetes? 🩸

Diabetes is a chronic condition where the body cannot properly regulate blood sugar (glucose) levels. It affects over **422 million people** worldwide and is one of the leading causes of kidney failure, blindness, and heart disease.

## Types of Diabetes

| Type | Description | % of Cases |
|---|---|---|
| **Type 1** | Autoimmune — insulin-producing cells destroyed | 5–10% |
| **Type 2** | Body resists insulin — lifestyle-linked | 90–95% |
| **Gestational** | Occurs during pregnancy | 2–10% |

## Causes & Risk Factors
- Genetics and family history
- Obesity (BMI > 25)
- Physical inactivity
- Poor diet high in refined carbohydrates and sugar
- Age above 45
- History of gestational diabetes

## Symptoms to Watch For 🔍
- Frequent urination (especially at night)
- Excessive thirst and dry mouth
- Unexplained weight loss
- Blurry vision and slow-healing wounds
- Tingling or numbness in hands/feet
- Extreme fatigue

## Prevention Strategy ✅
1. **Maintain healthy weight** — BMI 18.5–24.9
2. **Exercise daily** — 30 minutes brisk walking 5 days/week
3. **Eat smart** — Whole grains, vegetables, lean proteins
4. **Avoid** sugary drinks, white bread, processed snacks
5. **Regular checkups** — Fasting blood sugar every 1–2 years after 40

## Blood Sugar Targets
- Fasting: 70–100 mg/dL (normal)
- After meals (2 hrs): < 140 mg/dL

## 🚨 Emergency Signs
Seek immediate care for: extreme confusion, fruity breath odor, difficulty breathing, or loss of consciousness (diabetic ketoacidosis).''',
        ),

        // ── 2. Malaria ───────────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-2', categoryId: 'cat-1', categoryName: 'Diseases',
          categorySlug: 'diseases', categoryColor: '#F97316',
          title: 'Malaria Prevention and Treatment Guide',
          slug: 'malaria-prevention', language: 'en',
          summary: 'Essential guide on malaria causes, prevention with mosquito nets, and treatment.',
          emoji: '🦟', readTimeMin: 4, isFeatured: true,
          viewCount: 980, bookmarkCount: 65,
          tags: ['malaria', 'mosquito', 'fever', 'prevention', 'rural health'],
          content: r'''## What is Malaria? 🦟

Malaria is a **life-threatening disease** caused by *Plasmodium* parasites, transmitted through infected female Anopheles mosquito bites. It causes over **600,000 deaths annually**, mostly in children under 5.

## How It Spreads
- Bite of infected female Anopheles mosquito (active dusk to dawn)
- **NOT** spread person-to-person (except blood transfusion/mother to child)

## Symptoms (Appear 10–15 Days After Bite)
- High fever (39–41°C) with chills and sweating cycles
- Severe headache and muscle pain
- Nausea and vomiting
- Fatigue and general weakness

## Prevention Checklist ✅
1. **Sleep under insecticide-treated bed nets (ITNs)** — most effective
2. Use mosquito repellent (DEET-based) on exposed skin
3. Wear long-sleeved clothes and full pants at dusk/dawn
4. Close windows and doors at night; use screen nets
5. Eliminate standing water (pots, buckets, tyres) near home
6. Use indoor residual spraying (IRS) in high-risk areas

## Treatment 💊
- **Artemisinin-based Combination Therapy (ACT)** is first-line
- Seek medical care **within 24 hours** of symptom onset
- Complete the full treatment even if you feel better

## Malaria in Pregnancy ⚠️
Pregnant women are at high risk. Use preventive treatment (IPTp) as prescribed by your doctor.

## 🚨 Emergency Signs
Convulsions, difficulty breathing, dark/black urine, severe anaemia — go to hospital **immediately**.''',
        ),

        // ── 3. Nutrition in Pregnancy ────────────────────────────────────────
        HealthArticleModel(
          id: 'art-3', categoryId: 'cat-2', categoryName: 'Nutrition',
          categorySlug: 'nutrition', categoryColor: '#2ECC8B',
          title: 'Nutrition During Pregnancy: What to Eat for a Healthy Baby',
          slug: 'pregnancy-nutrition', language: 'en',
          summary: 'A complete pregnancy nutrition guide covering essential nutrients, meal plans, and foods to avoid.',
          emoji: '🤰', readTimeMin: 6, isFeatured: true,
          viewCount: 1450, bookmarkCount: 112,
          tags: ['pregnancy', 'nutrition', 'maternal health', 'diet'],
          content: r'''## Why Nutrition Matters in Pregnancy 🤰

Good nutrition during pregnancy ensures **healthy fetal growth**, prevents birth defects, and keeps the mother strong. Calorie needs increase by ~300 kcal/day in the second and third trimesters.

## Key Nutrients & Sources

| Nutrient | Why It Matters | Best Food Sources |
|---|---|---|
| **Folic Acid** | Prevents neural tube defects | Spinach, lentils, fortified cereals |
| **Iron** | Prevents anaemia | Red meat, beans, dried apricots |
| **Calcium** | Bone & teeth development | Milk, yogurt, tofu, ragi |
| **Iodine** | Brain & thyroid development | Iodized salt, dairy, eggs |
| **Protein** | Fetal tissue growth | Eggs, fish, chicken, dal |
| **Omega-3** | Brain development | Fish, flaxseed, walnuts |
| **Vitamin D** | Calcium absorption | Sunlight, fortified milk |

## Recommended Daily Foods ✅
- Dark leafy vegetables (spinach, fenugreek, methi)
- Whole grains (brown rice, oats, whole wheat roti)
- Legumes (lentils, chickpeas, kidney beans)
- Fresh fruits (banana, papaya, guava, orange)
- Dairy (milk, curd, paneer — calcium & protein)
- Nuts & seeds (handful daily)

## Foods to Strictly Avoid ❌
- Raw or undercooked meat, fish, and eggs
- Unpasteurized dairy products
- More than 200 mg caffeine/day (2 small cups)
- Alcohol — completely avoid
- Processed foods, excess salt, and junk food

## Sample Daily Meal Plan 🍽️
- **Breakfast:** Oats porridge + banana + 1 glass milk
- **Mid-morning snack:** Handful of nuts + seasonal fruit
- **Lunch:** Dal + rice + sabzi (vegetables) + curd
- **Evening snack:** Boiled egg / sprouts chaat
- **Dinner:** 2 rotis + green vegetable sabzi + dal soup

## Weight Gain Guide
- Underweight (BMI <18.5): Gain 12–18 kg total
- Normal weight: Gain 11–16 kg total
- Overweight: Gain 7–11 kg total''',
        ),

        // ── 4. Vaccination Schedule ──────────────────────────────────────────
        HealthArticleModel(
          id: 'art-4', categoryId: 'cat-3', categoryName: 'Vaccination',
          categorySlug: 'vaccination', categoryColor: '#4F94FF',
          title: 'BCG, Polio & Childhood Vaccination Schedule',
          slug: 'childhood-vaccination-schedule', language: 'en',
          summary: 'Complete childhood vaccination schedule from birth to 5 years with dose timing.',
          emoji: '💉', readTimeMin: 5, isFeatured: true,
          viewCount: 870, bookmarkCount: 73,
          tags: ['vaccination', 'children', 'BCG', 'polio', 'immunization'],
          content: r'''## Why Vaccinate Your Child? 💉

Vaccines protect children from **life-threatening diseases** before they are exposed. Every rupee spent on vaccination saves many more in treatment costs and prevents long-term disability.

## National Immunization Schedule (0–5 Years)

| Age | Vaccine | Disease Protected Against |
|---|---|---|
| **At Birth** | BCG | Tuberculosis |
| **At Birth** | OPV-0 | Polio |
| **At Birth** | Hep B (1st) | Hepatitis B |
| **6 Weeks** | DPT + Hib + HepB | Diphtheria, Pertussis, Tetanus |
| **6 Weeks** | OPV | Polio |
| **6 Weeks** | PCV (1st) | Pneumonia |
| **6 Weeks** | Rotavirus (1st) | Diarrhoea |
| **10 Weeks** | DPT + Hib + HepB (2nd) | Booster |
| **14 Weeks** | DPT + Hib + HepB (3rd) | Booster |
| **9–12 Months** | MR / MMR | Measles, Rubella |
| **9–12 Months** | JE | Japanese Encephalitis |
| **16–24 Months** | DPT Booster | Booster |
| **5 Years** | DPT Booster | Final childhood booster |

## Normal Side Effects (Nothing to Worry About)
- Mild fever for 1–2 days — give paracetamol if needed
- Redness or slight swelling at injection site
- Baby may be fussy — comfort feeds help

## When to Call the Doctor ⚠️
- Fever above 39°C that does not settle within 24 hours
- Seizures or convulsions
- Difficulty breathing or severe swelling at site
- Baby becomes limp or unresponsive

## ✅ Key Tips for Parents
1. Keep your vaccination card safe — never lose it
2. All vaccines in India's national program are **FREE** at government centers
3. Even if a dose is delayed, complete the schedule — do not restart from scratch
4. Vaccinate even during mild illness (cold, mild fever is fine)''',
        ),

        // ── 5. Hand Washing ──────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-5', categoryId: 'cat-6', categoryName: 'Hygiene',
          categorySlug: 'hygiene', categoryColor: '#18C8C8',
          title: 'Hand Washing: The Most Powerful Disease Prevention Tool',
          slug: 'hand-washing-guide', language: 'en',
          summary: 'Learn the correct 7-step hand washing technique that prevents diarrhea, cholera, and flu.',
          emoji: '🧼', readTimeMin: 3, isFeatured: false,
          viewCount: 640, bookmarkCount: 42,
          tags: ['hygiene', 'hand washing', 'disease prevention', 'sanitation'],
          content: r'''## Why Hand Washing Saves Lives 🧼

Proper hand washing is the **single most cost-effective health intervention** available. It reduces:
- Diarrheal disease by **40%**
- Respiratory infections (cold, flu) by **20%**
- Risk of food-borne illness significantly

## The 7-Step WHO Hand Washing Technique

**Step 1** 💧 Wet hands with clean running water (warm or cold)
**Step 2** 🧴 Apply enough soap to cover all hand surfaces
**Step 3** 🤲 Rub palms together vigorously
**Step 4** 🖐️ Rub back of each hand with interlaced fingers
**Step 5** 🤞 Interlock fingers and clean between them
**Step 6** 👍 Rub each thumb in a rotating motion
**Step 7** 🔃 Rub fingertips against opposite palm in circles

> ⏱️ **Total time: At least 20 seconds** (sing Happy Birthday twice!)

## When You Must Wash Hands ✅
- Before eating or preparing food
- After using the toilet
- After touching animals or garbage
- After coughing, sneezing, or blowing nose
- Before and after caring for a sick person
- Before feeding a baby or child

## When Soap & Water Unavailable
Use **alcohol-based hand sanitiser** (minimum 60% alcohol):
- Apply to palm of one hand
- Rub hands together covering all surfaces
- Rub until hands feel dry (~20 seconds)

## Making Handwashing a Habit for Kids 🧒
- Use coloured/scented soap to make it fun
- Post illustrated steps near the sink
- Use reward sticker charts
- Lead by example — wash hands WITH them''',
        ),

        // ── 6. Hypertension ──────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-6', categoryId: 'cat-9', categoryName: 'Heart Health',
          categorySlug: 'heart-health', categoryColor: '#EF4444',
          title: 'Managing High Blood Pressure (Hypertension) Naturally',
          slug: 'hypertension-management', language: 'en',
          summary: 'Understand what raises your blood pressure and how diet, exercise, and stress management can help.',
          emoji: '❤️', readTimeMin: 5, isFeatured: true,
          viewCount: 1100, bookmarkCount: 91,
          tags: ['hypertension', 'blood pressure', 'heart health', 'lifestyle'],
          content: r'''## What is Hypertension? ❤️

Blood pressure **above 130/80 mmHg consistently** is hypertension — often called the "silent killer" because it usually has no symptoms until serious damage occurs.

## Blood Pressure Categories

| Category | Systolic | Diastolic |
|---|---|---|
| **Normal** | < 120 | < 80 |
| **Elevated** | 120–129 | < 80 |
| **Stage 1 Hypertension** | 130–139 | 80–89 |
| **Stage 2 Hypertension** | ≥ 140 | ≥ 90 |
| **Crisis** 🚨 | > 180 | > 120 |

## Risk Factors
- High salt diet (> 5g/day)
- Obesity and physical inactivity
- Smoking and excessive alcohol
- Chronic stress and poor sleep
- Family history of hypertension
- Age above 40, diabetes, and kidney disease

## Lifestyle Changes That Work ✅

**1. DASH Diet** 🥗
- Fruits, vegetables, whole grains, low-fat dairy
- Limit red meat, sweets, and sodium

**2. Reduce Salt** 🧂
- Target: less than 5g (1 teaspoon) per day
- Avoid pickles, papad, namkeen, processed foods

**3. Exercise** 🏃
- 30 minutes of brisk walking, 5 days a week
- Yoga and pranayama also effective

**4. Stop Smoking** 🚭
- Each cigarette raises BP for 30 minutes
- Quitting shows immediate vascular benefit

**5. Manage Stress** 🧘
- Deep breathing (4-7-8 technique)
- Meditation and mindfulness apps
- Adequate sleep (7–8 hours/night)

**6. Monitor Regularly** 📊
- Affordable home BP monitors available
- Check morning (before medication) and evening

## 🚨 Hypertensive Crisis
BP > 180/120 WITH chest pain, severe headache, visual disturbance, or difficulty breathing → **Call emergency immediately**.''',
        ),

        // ── 7. Child Fever ───────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-7', categoryId: 'cat-5', categoryName: 'Child Health',
          categorySlug: 'child-health', categoryColor: '#FFB829',
          title: 'Child Fever: When to Worry and Home Care Guide',
          slug: 'child-fever-guide', language: 'en',
          summary: 'Practical guide for parents to manage child fever safely at home and know when to rush to hospital.',
          emoji: '👶', readTimeMin: 4, isFeatured: false,
          viewCount: 760, bookmarkCount: 58,
          tags: ['child fever', 'pediatric', 'children health', 'home care'],
          content: r'''## Understanding Fever in Children 👶

A temperature above **38°C (100.4°F)** is considered a fever. Fever itself is NOT dangerous — it is the body's natural immune response fighting infection.

## Taking Temperature Accurately 🌡️
| Method | Fever Threshold | Notes |
|---|---|---|
| **Rectal** | ≥ 38°C | Most accurate for infants |
| **Oral** | ≥ 37.8°C | For children 4+ years |
| **Armpit** | ≥ 37.5°C | Less accurate, add 0.5°C |
| **Forehead strip** | — | Least accurate |

## Home Care for Mild Fever (38–38.9°C) ✅
- **Hydration is most important** — water, ORS, breast milk, coconut water
- Dress lightly — do not wrap child in blankets
- Keep room cool with ventilation
- Lukewarm sponge bath (NOT cold water or ice)
- Paracetamol: **10–15 mg/kg** every 4–6 hours (if needed)
- Do NOT give aspirin to children under 16

## Soft Foods During Fever 🍌
- ORS (Oral Rehydration Solution) for hydration
- Khichdi, rice porridge (easy to digest)
- Banana and cooked apple
- Avoid forcing food if child refuses

## When to See a Doctor 🏥
- Fever ≥ 39°C not reducing after 2 doses of paracetamol
- Any fever in child **under 3 months**
- Fever lasting more than **3 days**
- Child has skin rash, stiff neck, or ear pain
- Child is unusually drowsy or not responding normally
- Signs of dehydration: no tears, dry mouth, no urination in 8 hours

## 🚨 Emergency Signs — Go to Hospital NOW
- Febrile seizures (child shaking/convulsing)
- Difficulty breathing or bluish lips
- Extreme difficulty waking the child
- Severe abdominal pain with fever''',
        ),

        // ── 8. Mental Health ─────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-8', categoryId: 'cat-8', categoryName: 'Mental Health',
          categorySlug: 'mental-health', categoryColor: '#7C3AED',
          title: 'Mental Wellness for Rural Communities',
          slug: 'mental-wellness-rural', language: 'en',
          summary: 'Practical mental health strategies for rural communities facing stigma, stress, and limited access.',
          emoji: '🧠', readTimeMin: 5, isFeatured: false,
          viewCount: 520, bookmarkCount: 38,
          tags: ['mental health', 'depression', 'anxiety', 'rural', 'wellness'],
          content: r'''## Mental Health in Rural Areas 🧠

Rural communities face **unique mental health challenges**: geographic isolation, agricultural stress, social stigma, and very limited access to mental health professionals. 1 in 5 people globally experience a mental health condition.

## Common Mental Health Conditions

**Depression** 😔
- Persistent sadness and hopelessness for 2+ weeks
- Loss of interest in activities once enjoyed
- Changes in sleep, appetite, and energy

**Anxiety Disorders** 😟
- Excessive worry that is hard to control
- Physical symptoms: heart racing, sweating, trembling
- Avoidance of social situations

**Farmer Stress & Burnout** 🌾
- Triggered by crop failures, debt, climate uncertainty
- Often leads to alcohol use and family conflict

## Warning Signs You Should Not Ignore
- Feeling sad or worthless most of the day
- Withdrawing from family and friends
- Thoughts of suicide or self-harm — **seek help immediately**
- Sleeping too much or unable to sleep
- Concentration and memory problems

## Self-Care Strategies That Work ✅
1. **Talk to someone you trust** — a friend, family member, or community leader
2. **Physical activity** — even 20–30 minutes of walking daily dramatically improves mood
3. **Sleep hygiene** — consistent wake and sleep times
4. **Connect spiritually** — prayer, meditation, community rituals
5. **Limit alcohol and tobacco** — both worsen mental health
6. **Attend community events** — social connection is protective

## For Families: How to Help
- Listen without judgment
- Help with daily tasks when they are struggling
- Gently encourage professional help
- Remove potential means of self-harm if risk is high

## Free & Affordable Help 📞
- **iCall (TISS):** 9152987821
- **Vandrevala Foundation:** 1860-2662-345 (24/7)
- **NIMHANS Helpline:** 080-46110007
- **National Mental Health Helpline:** 1800-599-0019 (toll-free)''',
        ),

        // ── 9. Breastfeeding ─────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-9', categoryId: 'cat-4', categoryName: 'Maternal Health',
          categorySlug: 'maternal-health', categoryColor: '#E879A0',
          title: 'Breastfeeding: Benefits and Best Practices for New Mothers',
          slug: 'breastfeeding-guide', language: 'en',
          summary: 'Everything a new mother needs to know about breastfeeding, positions, and overcoming challenges.',
          emoji: '🤱', readTimeMin: 6, isFeatured: true,
          viewCount: 890, bookmarkCount: 67,
          tags: ['breastfeeding', 'maternal health', 'newborn', 'infant nutrition'],
          content: r'''## Why Breastfeed? 🤱

Breast milk is the **perfect food for infants** — it provides complete nutrition and immunity for the first 6 months of life. WHO recommends exclusive breastfeeding for 6 months, then continued with complementary foods **up to 2 years**.

## Benefits for Baby 👶
- Full protection against infections (diarrhea, pneumonia, ear infections)
- Optimal brain development (DHA naturally present in breast milk)
- Lower risk of allergies, childhood obesity, and type 2 diabetes
- Emotional bonding and sense of security

## Benefits for Mother 💕
- Helps uterus return to normal size faster (oxytocin release)
- Reduces risk of breast and ovarian cancer
- Natural contraceptive during exclusive breastfeeding (LAM method)
- Burns ~500 extra calories per day
- Saves significant money on formula

## Achieving a Good Latch 🔑
1. Hold baby with tummy facing your tummy (no gap)
2. Support baby's head and neck (not the back of the head)
3. Tickle baby's lower lip with nipple to open mouth wide
4. Bring baby **to breast** — not breast to baby
5. ✅ Good latch: no pain, baby's chin touches breast, you hear swallowing

## Common Positions
- **Cradle hold** — most common, baby lies across your abdomen
- **Football hold** — baby tucked under arm; ideal after C-section
- **Side-lying** — both mother and baby lie down; great for night feeds

## Solving Common Problems 💡
| Problem | Solution |
|---|---|
| Sore nipples | Re-check latch; apply expressed breast milk to heal |
| Low milk supply | Feed more often; ensure proper hydration; skin-to-skin contact |
| Engorgement | Nurse or pump regularly; warm compress before feeding |
| Cracked nipples | Allow nipples to air dry; use lanolin cream |

## Red Flags — See a Lactation Consultant
- Baby not regaining birth weight by 2 weeks
- Fewer than 6 wet diapers per day after day 4
- Baby constantly crying/never satisfied after feeds
- Severe breast pain or fever (mastitis)''',
        ),

        // ── 10. Tuberculosis ─────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-10', categoryId: 'cat-1', categoryName: 'Diseases',
          categorySlug: 'diseases', categoryColor: '#F97316',
          title: 'Tuberculosis (TB): Facts, Prevention, and Treatment',
          slug: 'tuberculosis-guide', language: 'en',
          summary: 'Complete guide on TB spread, DOTS treatment, and prevention for households and communities.',
          emoji: '🫁', readTimeMin: 5, isFeatured: false,
          viewCount: 690, bookmarkCount: 49,
          tags: ['tuberculosis', 'TB', 'respiratory', 'DOTS', 'treatment'],
          content: r'''## What is Tuberculosis? 🫁

TB is a **bacterial infection** caused by *Mycobacterium tuberculosis*, primarily affecting the lungs. It is the world's leading infectious disease killer — 1.6 million deaths per year.

## How TB Spreads (and Does NOT Spread)

✅ **Spreads through:** Air (coughing, sneezing, speaking — tiny droplets)
❌ **Does NOT spread through:** Handshakes, sharing food/utensils, touching surfaces

You need **prolonged close contact** (household or workplace) to be at risk.

## Symptoms — The COUGH Rule 🔍
- **C**ough lasting **2+ weeks** (most important sign)
- **O**cean of sweat at night (night sweats)
- **U**nexplained weight loss
- **G**oing off food (loss of appetite)
- **H**emoptysis (coughing up blood)
- Also: chest pain, fatigue, low-grade fever

## Risk Factors
- HIV infection (30x higher risk)
- Malnutrition and underweight
- Overcrowded/poorly ventilated living conditions
- Smoking, alcohol, diabetes
- Healthcare workers

## Treatment: DOTS Program 💊

TB is **100% curable** when treated correctly:

| Phase | Duration | Drugs |
|---|---|---|
| **Intensive** | 2 months | RHZE (4 drugs) |
| **Continuation** | 4 months | RH (2 drugs) |

> ⚠️ **CRITICAL:** Complete all 6 months even if feeling better. Stopping early creates **drug-resistant TB (MDR-TB)** which is much harder and costlier to treat.

## Prevention ✅
- BCG vaccination at birth (protects children from severe TB)
- Good ventilation in homes and workplaces
- Cough etiquette — cover mouth with elbow, not hands
- Early diagnosis and isolation until non-infectious

## Free Treatment 🇮🇳
All TB diagnosis and treatment is **FREE** at government health centers under the **National TB Elimination Programme (NTEP)**. India aims to eliminate TB by 2025.''',
        ),

        // ── 11. Diarrhoea & ORS ──────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-11', categoryId: 'cat-5', categoryName: 'Child Health',
          categorySlug: 'child-health', categoryColor: '#FFB829',
          title: 'Diarrhoea in Children: ORS, Zinc & Prevention',
          slug: 'child-diarrhoea-ors', language: 'en',
          summary: 'How to prepare ORS at home, use zinc supplements, and prevent deadly dehydration in children.',
          emoji: '🥛', readTimeMin: 4, isFeatured: false,
          viewCount: 820, bookmarkCount: 61,
          tags: ['diarrhoea', 'ORS', 'zinc', 'child health', 'dehydration', 'home remedy'],
          content: r'''## Diarrhoea: A Leading Child Killer 🥛

Diarrhoea kills **500,000 children under 5** every year worldwide — almost all deaths are due to **dehydration**, not the infection itself. Simple ORS saves lives.

## Signs of Diarrhoea
- 3 or more loose/watery stools in 24 hours
- May be accompanied by vomiting, fever, and stomach cramps

## Levels of Dehydration

| Level | Signs | Action |
|---|---|---|
| **None** | Normal, playful | Continue ORS at home |
| **Mild** | Slightly less active, mildly dry mouth | ORS 50–100 mL/kg over 3–4 hours |
| **Severe** 🚨 | Sunken eyes, no tears, very lethargic | Hospital immediately |

## How to Make ORS at Home 🏠
**Recipe:** 1 litre of clean water + 6 level teaspoons of sugar + ½ teaspoon of salt

1. Boil and cool 1 litre of water
2. Add 6 level teaspoons (not heaped) of sugar
3. Add half a teaspoon of salt
4. Mix well until fully dissolved
5. Give small frequent sips — do not force large amounts

> ✅ Ready-made ORS packets from any pharmacy are even better.

## Zinc Supplementation 💊
- WHO recommends **zinc tablets** for 10–14 days during diarrhoea
- Under 6 months: 10 mg/day
- Over 6 months: 20 mg/day
- Reduces severity and prevents future episodes for 3 months

## Continue Feeding During Diarrhoea ✅
- **Do NOT stop breast milk** — continue breastfeeding
- Offer soft foods: khichdi, banana, rice water
- Avoid sugary drinks (fruit juice, soft drinks) — worsen diarrhoea

## Prevention
1. Exclusive breastfeeding for 6 months
2. Proper hand washing before feeding and after toilet
3. Safe drinking water (boil if unsure)
4. Rotavirus vaccine at 6 and 10 weeks
5. Ensure child has received all vaccines on schedule''',
        ),

        // ── 12. Anaemia ──────────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-12', categoryId: 'cat-11', categoryName: "Women's Health",
          categorySlug: 'womens-health', categoryColor: '#EC4899',
          title: 'Anaemia in Women: Iron Deficiency, Symptoms & Iron-Rich Diet',
          slug: 'anaemia-women-iron', language: 'en',
          summary: 'Why anaemia is so common in women, how to recognize it, and the best dietary and supplementation strategies.',
          emoji: '🩷', readTimeMin: 5, isFeatured: true,
          viewCount: 1050, bookmarkCount: 88,
          tags: ['anaemia', 'iron deficiency', 'womens health', 'diet', 'pregnancy'],
          content: r'''## Anaemia: India's Biggest Nutritional Crisis 🩷

**Over 50% of women** in India have anaemia — a condition where blood lacks enough healthy red blood cells to carry oxygen throughout the body. It is especially dangerous in pregnancy.

## Causes
- **Iron deficiency** (most common) — insufficient iron intake or absorption
- Vitamin B12 deficiency
- Blood loss (heavy periods, childbirth)
- Malaria and other infections
- Poor diet and malabsorption

## Symptoms 🔍
- Persistent fatigue and weakness
- Pale or yellowish skin, gums, and nails
- Shortness of breath on mild exertion
- Rapid heartbeat and dizziness
- Cold hands and feet
- Brittle nails and hair loss
- Difficulty concentrating

## Diagnosis
A simple blood test (CBC) measuring **haemoglobin level**:
- Normal women: Hb ≥ 12 g/dL
- Pregnant women: Hb ≥ 11 g/dL
- Anaemia: Hb < 11 g/dL (mild: 10–11, moderate: 7–10, severe: <7)

## Best Iron-Rich Foods 🥗

| High Iron Foods | Iron Content |
|---|---|
| Chicken liver | 12 mg per 100g |
| Spinach (cooked) | 3.6 mg per 100g |
| Lentils (masoor dal) | 3.3 mg per 100g |
| Rajma (kidney beans) | 2.9 mg per 100g |
| Tofu | 2.7 mg per 100g |
| Ragi (finger millet) | 3.9 mg per 100g |

## Enhance Iron Absorption ✅
- Eat iron-rich foods WITH Vitamin C (lemon, orange, guava, amla)
- **Avoid** tea/coffee for 1 hour before and after iron-rich meals (tannins block absorption)
- Cook in iron cookware — adds iron to food naturally

## Iron Supplements
- IFA (Iron & Folic Acid) tablets are FREE at government health centers
- Take on empty stomach for best absorption (take with food if stomach upset)
- Normal to have dark/black stools — harmless side effect''',
        ),

        // ── 13. Snake Bite First Aid ──────────────────────────────────────────
        HealthArticleModel(
          id: 'art-13', categoryId: 'cat-10', categoryName: 'First Aid',
          categorySlug: 'first-aid', categoryColor: '#F43F5E',
          title: 'Snake Bite First Aid: Do\'s, Don\'ts & Emergency Response',
          slug: 'snake-bite-first-aid', language: 'en',
          summary: 'Critical first aid steps for snake bites, dangerous myths to avoid, and when to reach hospital fast.',
          emoji: '🐍', readTimeMin: 4, isFeatured: true,
          viewCount: 1180, bookmarkCount: 95,
          tags: ['snake bite', 'first aid', 'emergency', 'rural health', 'poison'],
          content: r'''## Snake Bite Emergency Response 🐍

In India, **58,000+ people die** from snake bites annually — most deaths are preventable with the right first aid and timely anti-venom at hospital.

## IMMEDIATE Steps — The "Do's" ✅

1. **Stay calm** — panic increases heart rate and speeds venom spread
2. **Immobilize the bitten limb** — keep it below heart level
3. **Remove jewellery and tight clothing** near the bite (for swelling)
4. **Mark the edge of swelling** with a pen and note the time
5. **Get to hospital FAST** — anti-venom is the ONLY cure
6. **If possible, photograph or describe the snake** — helps identify venom type

## Critical DON'Ts ❌
- ❌ Do NOT cut the wound and suck out venom (causes infection)
- ❌ Do NOT apply a tourniquet (cuts off blood, causes gangrene)
- ❌ Do NOT apply ice (causes tissue damage)
- ❌ Do NOT give alcohol or traditional remedies
- ❌ Do NOT let the person walk if avoidable (carry them)
- ❌ Do NOT waste time with traditional healers — go to hospital

## Signs of Envenomation 🚨
- Severe local pain, swelling, and bruising
- Drooping eyelids and blurred vision (neurotoxic snake)
- Difficulty swallowing or breathing
- Bleeding from bite site or gums

## At Hospital
Anti-snake venom (ASV) is available **FREE** at all government hospitals. The earlier ASV is given, the better the outcome.

## Prevention in Rural Areas
- Wear thick footwear (boots/chappals) when walking in fields at night
- Use a torch after dark
- Do NOT put hands in dark holes or under stones
- Clear bushes and debris around homes
- Snakes are most active during monsoon season''',
        ),

        // ── 14. Eye Care ─────────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-14', categoryId: 'cat-12', categoryName: 'Eye & Ear Care',
          categorySlug: 'eye-ear-care', categoryColor: '#0EA5E9',
          title: 'Protecting Your Eyesight: Common Eye Problems & Prevention',
          slug: 'eye-care-guide', language: 'en',
          summary: 'Guide to common eye conditions including cataracts, glaucoma, and digital eye strain, with prevention tips.',
          emoji: '👁️', readTimeMin: 5, isFeatured: false,
          viewCount: 560, bookmarkCount: 41,
          tags: ['eye care', 'cataract', 'glaucoma', 'vision', 'eye health'],
          content: r'''## Protecting Your Precious Eyesight 👁️

**2.2 billion people** globally have vision impairment — half of these cases are preventable. Regular eye care is as important as dental care.

## Common Eye Conditions in India

**Cataracts** 👓
- Leading cause of blindness in India (80% of cases)
- Lens becomes cloudy — blurry, foggy vision
- **Treatment:** Simple 15-minute surgery completely cures it — FREE at government hospitals
- Prevention: UV-protection sunglasses, avoid smoking

**Glaucoma** 🔴
- "Silent thief of sight" — no symptoms until significant damage
- Increased pressure damages the optic nerve
- Annual eye check after age 40 is essential
- Treatment: Eye drops, laser, or surgery can halt progression

**Refractive Errors** (Short/Long Sight, Astigmatism)
- Most common vision problem — corrected with glasses or contact lenses
- Children: Untreated short-sightedness affects learning in school

**Diabetic Retinopathy**
- Affects 1 in 3 diabetics — blood vessels in retina damaged
- Annual dilated eye exam is mandatory for ALL diabetic patients
- Control blood sugar to prevent or slow progression

## Digital Eye Strain — The Modern Problem 💻
Symptoms: Tired eyes, blurring, headaches, dry eyes from screen use

**The 20-20-20 Rule:**
Every **20 minutes**, look at something **20 feet away** for **20 seconds**

Additional tips:
- Position screen at arm's length, slightly below eye level
- Increase font size; reduce glare with matte screen protector
- Blink consciously (we blink 3x less when staring at screens)
- Use lubricating eye drops for dryness

## Eye-Protective Nutrition 🥕
- **Vitamin A:** Carrots, sweet potato, papaya (prevents night blindness)
- **Lutein & Zeaxanthin:** Spinach, kale (protects against macular degeneration)
- **Omega-3:** Fish (reduces dry eye risk)

## When to See an Eye Doctor Urgently 🚨
- Sudden vision loss or blurring in one eye
- Sudden onset of multiple floaters or flashes of light
- Eye injury or chemical splash — rinse immediately with clean water for 15 mins''',
        ),

        // ── 15. Safe Drinking Water ──────────────────────────────────────────
        HealthArticleModel(
          id: 'art-15', categoryId: 'cat-6', categoryName: 'Hygiene',
          categorySlug: 'hygiene', categoryColor: '#18C8C8',
          title: 'Safe Drinking Water: Purification Methods for Rural Homes',
          slug: 'safe-drinking-water', language: 'en',
          summary: 'Practical guide to making water safe at home using boiling, chlorination, and solar disinfection.',
          emoji: '💧', readTimeMin: 4, isFeatured: false,
          viewCount: 730, bookmarkCount: 52,
          tags: ['water safety', 'WASH', 'sanitation', 'cholera', 'typhoid', 'rural'],
          content: r'''## Safe Water Saves Lives 💧

Contaminated water causes **cholera, typhoid, dysentery, and diarrhoea** — together responsible for **2 million deaths** annually, mostly children. Yet safe water is achievable at home with simple methods.

## Method 1: Boiling 🔥 (Most Effective)
1. Fill a clean pot with water
2. Bring to a **rolling boil for 1 full minute** (3 minutes at high altitude >2000m)
3. Cover and let cool naturally — do NOT add ice
4. Store in a covered clean container
5. **Cost:** Free (fuel only). Kills ALL pathogens.

## Method 2: Chlorination 💊
- Add **2 drops** of sodium hypochlorite solution (bleach, 5%) per litre
- Stir and wait **30 minutes** before drinking
- Water should smell faintly of chlorine — if not, add 2 more drops
- Cheap and effective for large quantities

## Method 3: Solar Disinfection (SODIS) ☀️
- Fill **clear PET plastic bottles** (not green or brown) with water
- Place in direct sunlight for **6 hours** (or 2 days if cloudy)
- Water is safe to drink after treatment
- **Cost:** Completely free. Works well in sunny regions.

## Method 4: Filtration + Boiling 🏺
- Pour water through clean cloth or sand filter to remove particles
- Then boil — removing sediment first makes boiling more effective

## Water Storage Rules ✅
- Store in narrow-neck containers (prevents hands going in)
- Keep covered at all times
- Use a clean ladle or cup — do NOT dip dirty hands
- Replace stored water every 24–48 hours
- Clean storage containers weekly with dilute bleach

## Signs Your Water May Be Contaminated
- Unusual colour, smell, or taste
- Diarrhoea/illness in multiple family members
- Nearby open defecation or chemical spill
- Flooding (contaminates wells and borewells)

## Simple Water Quality Test 🧪
If you cannot afford test kits, **boiling is always the safest option**.''',
        ),

        // ── 16. Heart Attack Recognition ────────────────────────────────────
        HealthArticleModel(
          id: 'art-16', categoryId: 'cat-9', categoryName: 'Heart Health',
          categorySlug: 'heart-health', categoryColor: '#EF4444',
          title: 'Heart Attack Warning Signs & Immediate Action Steps',
          slug: 'heart-attack-warning-signs', language: 'en',
          summary: 'Learn to recognize heart attack symptoms before they become fatal and what to do in the critical first minutes.',
          emoji: '🫀', readTimeMin: 4, isFeatured: true,
          viewCount: 1350, bookmarkCount: 118,
          tags: ['heart attack', 'cardiac emergency', 'heart health', 'CPR', 'first aid'],
          content: r'''## Recognise a Heart Attack — Every Minute Counts 🫀

A heart attack (myocardial infarction) occurs when blood supply to part of the heart muscle is blocked. **Brain damage begins within 4 minutes** of cardiac arrest. Knowing the signs can save a life.

## Classic Heart Attack Symptoms
- **Chest pain or pressure** — feels like squeezing, heaviness, or tightness
- Pain radiating to **left arm, jaw, neck, or back**
- **Sweating** (cold, clammy sweat without exertion)
- **Shortness of breath** even at rest
- Nausea, vomiting, or indigestion-like discomfort
- Sudden extreme fatigue (especially in women)
- Feeling of impending doom

## Warning: Women's Symptoms Are Often Different
Women commonly experience:
- Unusual fatigue for days before
- Shortness of breath WITHOUT chest pain
- Jaw pain, neckache, or upper back pain
- Nausea and lightheadedness

## IMMEDIATE Action — Call for Help NOW 📞
1. **Call 112 (India emergency)** or 108 immediately
2. Have the person sit or lie comfortably
3. Loosen tight clothing around neck and chest
4. If they have prescribed nitroglycerin, help them take it
5. If the person is unconscious and not breathing, start CPR

## Basic CPR (Hands-Only) 💪
1. Place heel of hand on center of chest (lower half of sternum)
2. Place other hand on top, interlace fingers
3. Press down **hard and fast** — 5–6 cm deep, 100–120 times per minute
4. Continue until ambulance arrives or person regains consciousness

## Risk Factors You Can Control ✅
- Stop smoking (risk halves within 1 year of quitting)
- Control blood pressure, cholesterol, and diabetes
- Exercise regularly and maintain healthy weight
- Reduce stress and improve sleep quality

## Risk Factors You Cannot Change
- Family history of early heart disease
- Age (men > 45, women > 55)
- Male gender (higher lifetime risk)''',
        ),

        // ── 17. Sleep Health ─────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-17', categoryId: 'cat-7', categoryName: 'Lifestyle',
          categorySlug: 'healthy-lifestyle', categoryColor: '#926EFF',
          title: 'Sleep Your Way to Better Health: Sleep Hygiene Guide',
          slug: 'sleep-hygiene-guide', language: 'en',
          summary: 'Why quality sleep is as important as diet and exercise, and practical habits for better rest.',
          emoji: '😴', readTimeMin: 5, isFeatured: false,
          viewCount: 680, bookmarkCount: 53,
          tags: ['sleep', 'insomnia', 'lifestyle', 'mental health', 'wellness'],
          content: r'''## Sleep: The Foundation of All Health 😴

During sleep, your body **repairs muscles, consolidates memory, balances hormones, and resets the immune system**. Chronic sleep deprivation is linked to obesity, diabetes, heart disease, and depression.

## How Much Sleep Do You Need?

| Age Group | Recommended Sleep |
|---|---|
| Newborns (0–3 months) | 14–17 hours |
| Infants (4–11 months) | 12–16 hours |
| Toddlers (1–2 years) | 11–14 hours |
| School children (6–12) | 9–12 hours |
| **Adults (18–64)** | **7–9 hours** |
| Older adults (65+) | 7–8 hours |

## Signs of Poor Sleep Quality
- Difficulty falling asleep (> 30 minutes)
- Waking up multiple times per night
- Feeling tired even after 8 hours
- Needing caffeine to function
- Difficulty concentrating and irritability
- Falling asleep unintentionally during the day

## Sleep Hygiene: 10 Science-Backed Tips ✅

1. **Fixed schedule** — Same wake time every day (even weekends)
2. **Dark, cool, quiet room** — 18–22°C is ideal sleep temperature
3. **No screens 1 hour before bed** — Blue light suppresses melatonin
4. **No caffeine after 2 PM** — Caffeine has 5–6 hour half-life
5. **Exercise daily** — But not within 2 hours of bedtime
6. **Wind-down routine** — Reading, light stretching, warm bath
7. **No large meals within 2–3 hours** of sleep
8. **Reserve bed for sleep only** — Trains brain association
9. **Get morning sunlight** — Sets your circadian clock naturally
10. **Limit alcohol** — Disrupts REM sleep even if helps you fall asleep

## Natural Sleep Aids 🌿
- **Chamomile tea** — Mild sedative effect
- **Ashwagandha** (adaptogen) — Reduces cortisol, improves sleep quality
- **Magnesium-rich foods** — Banana, dark chocolate, almonds
- **Breathing technique:** 4-7-8 (inhale 4s, hold 7s, exhale 8s)

## When to Seek Help
If sleep problems persist > 4 weeks despite good sleep hygiene, speak to a doctor about CBT-I (Cognitive Behavioral Therapy for Insomnia) — more effective than sleeping pills long-term.''',
        ),

        // ── 18. Dengue ───────────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-18', categoryId: 'cat-1', categoryName: 'Diseases',
          categorySlug: 'diseases', categoryColor: '#F97316',
          title: 'Dengue Fever: Symptoms, Warning Signs & Home Management',
          slug: 'dengue-fever-guide', language: 'en',
          summary: 'How to recognize dengue fever early, manage it safely at home, and spot the dangerous warning signs.',
          emoji: '🦠', readTimeMin: 5, isFeatured: true,
          viewCount: 1020, bookmarkCount: 82,
          tags: ['dengue', 'fever', 'mosquito', 'platelet', 'tropical disease'],
          content: r'''## What is Dengue Fever? 🦠

Dengue is caused by **4 dengue virus serotypes** spread by the *Aedes aegypti* mosquito — a **day-biting mosquito** that breeds in clean stagnant water. India reports 200,000+ cases annually.

## Symptoms — The Dengue Triad 🔍
**Days 1–3 (Febrile Phase):**
- Sudden high fever (39–40°C)
- Severe headache behind the eyes
- Intense joint and muscle pain ("breakbone fever")
- Skin rash (flat red patches progressing to raised spots)
- Nausea and vomiting

**Days 4–5 (Critical Phase) ⚠️:**
This is the MOST dangerous window — platelet count drops.

## 🚨 Warning Signs Requiring IMMEDIATE Hospital Admission
- Abdominal pain or tenderness
- Persistent vomiting (3+ times in 24 hours)
- Bleeding from gums, nose, or under skin
- Blood in urine, stool, or vomit
- Extreme fatigue or restlessness
- Rapid breathing, cold/clammy skin

## Home Management for Uncomplicated Dengue ✅
- **Rest completely** — no vigorous activity
- **Hydration is critical** — minimum 8–10 glasses water/day; ORS, coconut water, fresh juice
- **Paracetamol** for fever — NEVER aspirin or ibuprofen (increase bleeding risk)
- Monitor platelet count daily if prescribed by doctor
- Platelet count < 20,000/µL or any warning sign = hospitalize immediately

## Prevention 🛡️
- Aedes mosquitoes breed in **clean, stagnant water** — check and empty:
  - Flower pots and trays, water coolers
  - Overhead tanks, tyres, buckets
- Use mosquito repellent, long sleeves during daytime
- Window and door screens
- Mosquito coils and nets at all hours (Aedes bites during the day)''',
        ),

        // ── 19. Exercise & Fitness ───────────────────────────────────────────
        HealthArticleModel(
          id: 'art-19', categoryId: 'cat-7', categoryName: 'Lifestyle',
          categorySlug: 'healthy-lifestyle', categoryColor: '#926EFF',
          title: 'Physical Activity for Health: A Beginner\'s Exercise Guide',
          slug: 'exercise-beginners-guide', language: 'en',
          summary: 'How much exercise you actually need, the best types for different health goals, and how to start safely.',
          emoji: '🏃', readTimeMin: 5, isFeatured: false,
          viewCount: 720, bookmarkCount: 56,
          tags: ['exercise', 'fitness', 'lifestyle', 'weight loss', 'heart health'],
          content: r'''## Why Physical Activity is Medicine 🏃

Regular physical activity is the closest thing we have to a "magic pill" for health. It prevents and manages **heart disease, diabetes, hypertension, depression, and 13 types of cancer**.

## WHO Recommendations

| Age Group | Weekly Target |
|---|---|
| Adults (18–64) | **150–300 min moderate** or 75–150 min vigorous |
| Children (5–17) | 60 min/day moderate-to-vigorous |
| Older adults (65+) | Same as adults + balance exercises |

> 💡 Anything is better than nothing. Even 10 minutes 3x/day counts!

## Types of Exercise & Benefits

**Aerobic/Cardio** 🫀
- Walking, jogging, cycling, swimming, dancing
- Benefits: Heart health, weight management, mood boost
- Target: At least 150 min/week

**Strength Training** 💪
- Bodyweight squats, push-ups, lifting
- Benefits: Muscle mass, bone density, metabolism
- Target: 2 sessions/week, all major muscle groups

**Flexibility** 🧘
- Yoga, stretching
- Benefits: Reduces injury risk, improves posture, relieves back pain

**Balance** 🦵
- Single-leg stand, tai chi
- Benefits: Prevents falls (critical for elderly)

## Starting Safe: The FITT Principle ✅
- **F**requency — Start 3 days/week, build to 5
- **I**ntensity — Start easy (can hold a conversation while exercising)
- **T**ime — Start 15 min, increase by 5 min each week
- **T**ype — Choose something you enjoy

## No Gym Needed! Free Exercises at Home
- Brisk walking (30 min = 200 calories burned)
- Sun Salutations (Surya Namaskar) — 12 steps = full body workout
- Bodyweight squats, lunges, push-ups, plank
- Jump rope — incredible cardio for minimal cost

## When to Avoid Exercise ⚠️
- Fever or active infection — rest completely
- Chest pain, dizziness during exercise — stop and see doctor
- Very high blood pressure (> 180/110) — get controlled first
- Fresh injury — RICE method (Rest, Ice, Compression, Elevation)''',
        ),

        // ── 20. Antenatal Care ───────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-20', categoryId: 'cat-4', categoryName: 'Maternal Health',
          categorySlug: 'maternal-health', categoryColor: '#E879A0',
          title: 'Antenatal Care: Essential Pregnancy Check-ups & Tests',
          slug: 'antenatal-care-checkups', language: 'en',
          summary: 'The minimum 4 ANC visits every pregnant woman needs, what tests to expect, and danger signs to know.',
          emoji: '🏥', readTimeMin: 6, isFeatured: false,
          viewCount: 870, bookmarkCount: 71,
          tags: ['antenatal', 'ANC', 'pregnancy', 'maternal health', 'prenatal care'],
          content: r'''## Why Antenatal Care Saves Lives 🏥

Antenatal Care (ANC) visits allow healthcare workers to monitor mother and baby, prevent complications, and prepare for safe delivery. WHO recommends **minimum 8 ANC visits** (India minimum: 4).

## Recommended ANC Schedule

| Visit | When | Purpose |
|---|---|---|
| **1st** | < 12 weeks | Confirm pregnancy, baseline tests, folate/iron start |
| **2nd** | 14–26 weeks | Anomaly scan, blood sugar screening |
| **3rd** | 28–32 weeks | Check fetal growth, Hb test |
| **4th** | 36–40 weeks | Birth planning, check presentation |

## Tests You Should Expect ✅
- **Blood tests:** Haemoglobin (Hb), blood group, HIV, VDRL (syphilis), blood sugar
- **Urine test:** Protein and sugar in urine (pre-eclampsia screening)
- **Blood pressure** at every visit
- **Ultrasound scans:** Dating scan (6–10 weeks), anomaly scan (18–20 weeks), growth scan
- **Tetanus Toxoid (TT):** 2 doses in first pregnancy, 1 booster in subsequent

## Mandatory Supplements 💊
All FREE at government health centers:
- **IFA tablets** (Iron + Folic Acid) — take daily from first trimester
- **Calcium tablets** — 1g/day from 2nd trimester
- **Albendazole** (deworming) — once in 2nd trimester

## Danger Signs During Pregnancy 🚨
Go to hospital IMMEDIATELY if:
- Heavy vaginal bleeding at any stage
- Severe headache with blurred vision (pre-eclampsia)
- Sudden swelling of face, hands, or legs
- Reduced or absent fetal movement after 28 weeks
- High fever
- Rupture of membranes before 37 weeks

## Birth Planning Checklist ✅
- Identify nearest facility for delivery
- Arrange transport in advance (day AND night option)
- Save blood donors' contact numbers (same blood group)
- Save money for delivery expenses
- Know danger signs for you and your newborn''',
        ),

        // ── 21. Cholesterol ──────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-21', categoryId: 'cat-9', categoryName: 'Heart Health',
          categorySlug: 'heart-health', categoryColor: '#EF4444',
          title: 'Understanding Cholesterol: Good vs Bad & Diet Changes',
          slug: 'cholesterol-guide', language: 'en',
          summary: 'What cholesterol numbers mean, which foods raise bad cholesterol, and what to eat to protect your heart.',
          emoji: '🫀', readTimeMin: 5, isFeatured: false,
          viewCount: 610, bookmarkCount: 47,
          tags: ['cholesterol', 'heart health', 'LDL', 'HDL', 'diet', 'atherosclerosis'],
          content: r'''## Cholesterol: Not All Bad 🫀

Cholesterol is a fatty substance in the blood — the body needs it for cell membranes and hormones. But too much of the **wrong type** clogs arteries and causes heart attacks and strokes.

## Understanding Your Lipid Profile

| Type | Target | Role |
|---|---|---|
| **Total Cholesterol** | < 200 mg/dL | Overall indicator |
| **LDL ("Bad")** | < 100 mg/dL | Deposits in artery walls |
| **HDL ("Good")** | > 60 mg/dL | Removes cholesterol from arteries |
| **Triglycerides** | < 150 mg/dL | Another fat — raised by sugar & alcohol |

> Higher HDL is BETTER. Higher LDL is WORSE.

## Foods That Raise Bad Cholesterol (Limit These) 🔴
- **Trans fats** — vanaspati (partially hydrogenated oil), commercial fried snacks, bakery items
- **Saturated fats** — excess ghee, butter, red meat, full-fat dairy
- **Refined carbohydrates** — white bread, sugary foods raise triglycerides

## Foods That Lower Bad Cholesterol ✅ (Eat More)
- **Oats and barley** — beta-glucan fibre actively lowers LDL
- **Beans and lentils** — soluble fibre traps cholesterol
- **Nuts** — walnuts, almonds lower LDL by 5–10%
- **Fatty fish** — salmon, mackerel, sardines (omega-3 lowers triglycerides)
- **Olive oil / mustard oil** — better than coconut or palm oil
- **Flaxseed** — ground flaxseed in roti or dal

## Lifestyle Changes 🏃
- **Exercise** raises HDL ("good") cholesterol
- **Lose weight** — 5–10 kg weight loss significantly improves all lipid values
- **Stop smoking** — damages HDL
- **Limit alcohol** — raises triglycerides

## When to Start Medication
If LDL > 190 mg/dL, or LDL > 70 with established heart disease, your doctor may prescribe statins. **Never stop cholesterol medication without consulting your doctor** — levels return quickly.''',
        ),

        // ── 22. Oral Health ──────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-22', categoryId: 'cat-6', categoryName: 'Hygiene',
          categorySlug: 'hygiene', categoryColor: '#18C8C8',
          title: 'Oral Health: Brushing, Flossing & Preventing Gum Disease',
          slug: 'oral-health-guide', language: 'en',
          summary: 'Simple daily habits to prevent tooth decay, gum disease, and how oral health connects to heart and diabetes risk.',
          emoji: '🦷', readTimeMin: 4, isFeatured: false,
          viewCount: 490, bookmarkCount: 36,
          tags: ['oral health', 'teeth', 'brushing', 'gum disease', 'dental hygiene'],
          content: r'''## Oral Health = Overall Health 🦷

Poor oral health is **not just a cosmetic issue** — gum disease bacteria can enter the bloodstream and increase risk of heart disease, diabetes complications, and preterm birth. 

## Correct Brushing Technique ✅
1. Use a **soft-bristled toothbrush** (hard bristles damage gums)
2. Apply pea-sized amount of fluoride toothpaste
3. Hold brush at **45-degree angle** to gum line
4. Gentle circular or short back-and-forth strokes
5. Brush all surfaces: outer, inner, and chewing surfaces
6. Gently brush the tongue (removes bacteria causing bad breath)
7. **Duration: 2 minutes, twice daily** (morning and before bed)
8. Replace toothbrush every 3 months

## Flossing: The Step Most People Skip 🧵
- Floss **once daily** — removes plaque where brushes cannot reach
- Slide gently between teeth in a C-shape
- If floss not available: interdental brushes or water flossers work too

## Diet for Healthy Teeth 🥗
✅ **Good for teeth:**
- Crunchy vegetables (carrots, cucumber) — natural cleaners
- Dairy (cheese, paneer) — calcium and phosphorus strengthen enamel
- Plain water — washes away food particles and acids

❌ **Harmful for teeth:**
- Sugary foods and drinks — feed acid-producing bacteria
- Carbonated/soft drinks — erode enamel (even diet versions)
- Frequent snacking — constant acid exposure

## Warning Signs — See a Dentist
- Toothache or sensitivity to hot/cold
- Gums that bleed when brushing (early gum disease)
- Loose teeth or receding gums
- Ulcers that do not heal in 2 weeks (oral cancer screening)
- White or red patches in mouth

## For Rural Communities
- **Neem twig (datun)** — traditional toothbrush; anti-bacterial; effective when used correctly
- **Salt water rinse** — helps with minor gum inflammation
- **Free dental camps** — government hospitals and dental colleges offer free treatment days''',
        ),

        // ── 23. Pneumonia ────────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-23', categoryId: 'cat-1', categoryName: 'Diseases',
          categorySlug: 'diseases', categoryColor: '#F97316',
          title: 'Pneumonia in Children: Recognition, Treatment & Prevention',
          slug: 'child-pneumonia-guide', language: 'en',
          summary: 'Pneumonia kills more children than any other disease. Learn to recognize it early and seek treatment fast.',
          emoji: '🌬️', readTimeMin: 4, isFeatured: false,
          viewCount: 760, bookmarkCount: 55,
          tags: ['pneumonia', 'child health', 'respiratory', 'breathing', 'infection'],
          content: r'''## Pneumonia: The No.1 Child Killer 🌬️

Pneumonia kills **over 700,000 children under 5** every year — more than AIDS, malaria, and tuberculosis combined. Yet it is **preventable and treatable**.

## What is Pneumonia?
Infection of the lungs causing air sacs to fill with fluid or pus. Can be caused by bacteria (*Streptococcus pneumoniae* most common), viruses, or rarely fungi.

## How to Recognise Pneumonia in Children 🔍

**Key Sign: Fast Breathing**
- Under 2 months: ≥ 60 breaths/minute
- 2–12 months: ≥ 50 breaths/minute
- 1–5 years: ≥ 40 breaths/minute

**Other Signs:**
- Fever (may be high or even lower than normal in infants)
- Chest in-drawing (skin pulling in below ribs with each breath)
- Blue lips or fingernails (cyanosis) — severe sign
- Grunting sound with each breath
- Inability to drink or breastfeed

## 🚨 Go to Hospital Immediately If:
- Child has fast breathing AND chest in-drawing
- Blue lips or extreme lethargy
- Cannot drink or is vomiting everything
- Child is under 2 months with any fever

## Treatment 💊
- **Bacterial pneumonia:** Antibiotics (amoxicillin) cure most cases in 5–7 days
- Antibiotics are FREE at government health centers
- Continue full antibiotic course even if child improves
- **Viral pneumonia:** Supportive care (fluids, fever management) — antibiotics won't help

## Prevention Checklist ✅
1. **Vaccines** — PCV (pneumococcal), Hib, influenza vaccines
2. **Exclusive breastfeeding** for 6 months — massive protection
3. **Reduce indoor air pollution** — improve ventilation, use smokeless chulha
4. **Good nutrition** — prevent malnutrition which increases risk 4x
5. **Avoid secondhand smoke** — doubles pneumonia risk in children''',
        ),

        // ── 24. Cancer Warning Signs ─────────────────────────────────────────
        HealthArticleModel(
          id: 'art-24', categoryId: 'cat-7', categoryName: 'Lifestyle',
          categorySlug: 'healthy-lifestyle', categoryColor: '#926EFF',
          title: '7 Cancer Warning Signs You Should Never Ignore',
          slug: 'cancer-warning-signs', language: 'en',
          summary: 'The universal early warning signs of cancer and which risk factors you can actually control to prevent it.',
          emoji: '🔬', readTimeMin: 5, isFeatured: false,
          viewCount: 840, bookmarkCount: 73,
          tags: ['cancer', 'prevention', 'early detection', 'screening', 'lifestyle'],
          content: r'''## Cancer: Early Detection Saves Lives 🔬

When detected early, many cancers are **curable**. Knowing the warning signs and acting quickly is the difference between cure and terminal illness.

## The 7 Warning Signs of Cancer (CAUTION)

**C** — Change in bowel or bladder habits
**A** — A sore that does not heal (especially in mouth)
**U** — Unusual bleeding or discharge
**T** — Thickening or lump in breast or anywhere
**I** — Indigestion or difficulty swallowing that persists
**O** — Obvious change in wart or mole
**N** — Nagging cough or hoarseness lasting > 3 weeks

> ⚠️ Having one of these signs does NOT mean you have cancer — but you MUST get it checked.

## Most Common Cancers in India

| Cancer | Main Risk Factors |
|---|---|
| **Oral/Mouth** | Tobacco (chewing/smoking), betel nut, alcohol |
| **Cervical** | HPV infection, multiple partners, poor hygiene |
| **Breast** | Age, family history, obesity, alcohol |
| **Lung** | Smoking (90% of cases), indoor air pollution |
| **Colorectal** | Low fibre diet, red/processed meat, inactivity |

## Lifestyle Changes for Cancer Prevention ✅
1. **Stop all tobacco use** — causes 22% of all cancer deaths
2. **Limit alcohol** — linked to 7 cancer types
3. **Maintain healthy weight** — obesity linked to 13 cancers
4. **Physical activity** — reduces risk of colon, breast, uterine cancers
5. **Sun protection** — use sunscreen outdoors (skin cancer)
6. **Eat plant-rich diet** — fruits, vegetables, whole grains, fibre

## Screening Saves Lives 🏥
- **Cervical cancer:** PAP smear every 3 years for women 25–65 (free at government hospitals)
- **Breast cancer:** Monthly self-examination; mammogram every 2 years after 40
- **Oral cancer:** Inspect mouth monthly, dental checkup annually (high tobacco users)
- **Colorectal:** Stool occult blood test annually after 50''',
        ),

        // ── 25. Newborn Care ─────────────────────────────────────────────────
        HealthArticleModel(
          id: 'art-25', categoryId: 'cat-5', categoryName: 'Child Health',
          categorySlug: 'child-health', categoryColor: '#FFB829',
          title: 'Essential Newborn Care: First 28 Days Guide for Parents',
          slug: 'newborn-care-guide', language: 'en',
          summary: 'Everything parents need for the critical first 28 days of a newborn\'s life — warmth, feeding, cord care, and danger signs.',
          emoji: '🍼', readTimeMin: 6, isFeatured: true,
          viewCount: 960, bookmarkCount: 79,
          tags: ['newborn', 'infant care', 'child health', 'cord care', 'baby'],
          content: r'''## The Critical First 28 Days 🍼

The neonatal period (first 28 days) is the **most vulnerable time in a child's life** — 75% of under-5 deaths occur in this period. Good newborn care drastically reduces this risk.

## Warmth: Preventing Hypothermia 🌡️
Newborns lose heat rapidly — **hypothermia is a silent killer**.

- Dry baby immediately after birth and wrap in warm cloth
- **Kangaroo Mother Care (KMC):** Skin-to-skin contact between mother and baby
  - Place naked baby on mother's bare chest
  - Cover both with blanket
  - KMC for at least 2 hours/day dramatically improves survival in small babies
- Room temperature should be 25–28°C
- Delay first bath for at least **24 hours** (ideally 48–72 hours)

## Feeding: Breast Milk Only ✅
- Initiate breastfeeding **within 1 hour of birth**
- Give colostrum (first yellowish milk) — extremely rich in antibodies
- **NO water, sugar water, or formula** unless medically indicated
- Feed on demand — approximately 8–12 times in 24 hours
- Signs of adequate feeding: 6+ wet nappies/day after day 4, weight gain

## Cord Care 🩹
- Keep cord stump **dry and clean**
- Do NOT apply anything (ash, oil, mud, turmeric) — causes infection
- Fold nappy below cord stump to air dry
- Cord falls off naturally in 7–14 days
- **Danger sign:** Redness around cord base, pus, or foul smell — see doctor

## Routine Newborn Care 💉
- **Vitamin K injection** at birth (prevents bleeding)
- **BCG and OPV-0** vaccines at birth
- Eye drops (antibiotic prophylaxis)
- Newborn screening for metabolic disorders (heel prick test)

## Normal Newborn Behaviour (Nothing to Worry About) 
- Hiccups — normal, harmless
- Sneezing — normal (clearing nasal passages)
- Jaundice appearing days 2–3 — usually physiological; monitor
- Hands and feet appearing blue when cold — normal

## 🚨 Danger Signs in Newborns — Hospital Immediately
- Not breastfeeding or drinking for 6+ hours
- Convulsions/shaking
- Fast breathing (> 60/min) or severe chest in-drawing
- Temperature < 35.5°C or > 38°C
- Yellow colour on palms and soles (severe jaundice)
- Bleeding from umbilicus
- Pus or redness around eyes''',
        ),
      ];

  // ── Convenience accessors ──────────────────────────────────────────────────

  static List<HealthArticleModel> get featuredArticles =>
      articles.where((a) => a.isFeatured).toList();

  static List<HealthArticleModel> get recommendedArticles {
    final sorted = List<HealthArticleModel>.from(articles);
    sorted.sort((a, b) =>
        (b.viewCount + b.bookmarkCount * 3)
            .compareTo(a.viewCount + a.bookmarkCount * 3));
    return sorted.take(10).toList();
  }

  static List<HealthArticleModel> articlesByCategory(String slug) =>
      articles.where((a) => a.categorySlug == slug).toList();

  static List<HealthArticleModel> search(String query) {
    final q = query.toLowerCase();
    return articles
        .where((a) =>
            a.title.toLowerCase().contains(q) ||
            (a.summary?.toLowerCase().contains(q) ?? false) ||
            a.tags.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }

  static HealthArticleModel? byId(String id) {
    try {
      return articles.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
