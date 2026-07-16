import '../models/health_article_model.dart';
import '../models/health_category_model.dart';

/// Offline-first fallback data. Mirrors the 10 seeded backend articles.
/// Used when the API is unreachable (guest mode / no internet).
class EducationDummyData {
  EducationDummyData._();

  // ── Categories ─────────────────────────────────────────────────────────────

  static List<HealthCategoryModel> get categories => [
        const HealthCategoryModel(id: 'cat-1', name: 'Diseases',          slug: 'diseases',         icon: '🩺', colorHex: '#F97316', sortOrder: 1, isActive: true),
        const HealthCategoryModel(id: 'cat-2', name: 'Nutrition',          slug: 'nutrition',         icon: '🥗', colorHex: '#2ECC8B', sortOrder: 2, isActive: true),
        const HealthCategoryModel(id: 'cat-3', name: 'Vaccination',        slug: 'vaccination',       icon: '💉', colorHex: '#4F94FF', sortOrder: 3, isActive: true),
        const HealthCategoryModel(id: 'cat-4', name: 'Maternal Health',    slug: 'maternal-health',   icon: '🤰', colorHex: '#8B5CF6', sortOrder: 4, isActive: true),
        const HealthCategoryModel(id: 'cat-5', name: 'Child Health',       slug: 'child-health',      icon: '👶', colorHex: '#FFB829', sortOrder: 5, isActive: true),
        const HealthCategoryModel(id: 'cat-6', name: 'Hygiene',            slug: 'hygiene',           icon: '🧼', colorHex: '#18C8C8', sortOrder: 6, isActive: true),
        const HealthCategoryModel(id: 'cat-7', name: 'Healthy Lifestyle',  slug: 'healthy-lifestyle', icon: '🏃', colorHex: '#926EFF', sortOrder: 7, isActive: true),
        const HealthCategoryModel(id: 'cat-8', name: 'Mental Health',      slug: 'mental-health',     icon: '🧠', colorHex: '#8B5CF6', sortOrder: 8, isActive: true),
        const HealthCategoryModel(id: 'cat-9', name: 'Heart Health',       slug: 'heart-health',      icon: '💙', colorHex: '#0891B2', sortOrder: 9, isActive: true),
      ];

  // ── Articles ───────────────────────────────────────────────────────────────

  static List<HealthArticleModel> get articles => [
        HealthArticleModel(
          id: 'art-1', categoryId: 'cat-1', categoryName: 'Diseases',
          categorySlug: 'diseases', categoryColor: '#F97316',
          title: 'Understanding Diabetes: Causes, Symptoms & Prevention',
          slug: 'understanding-diabetes', language: 'en',
          summary: 'Learn how diabetes develops, early warning signs, and proven prevention strategies.',
          emoji: '🩸', readTimeMin: 5, isFeatured: true,
          viewCount: 1240, bookmarkCount: 87, tags: ['diabetes', 'sugar', 'chronic disease', 'prevention'],
          content: '''## What is Diabetes?
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
Seek immediate care for: extreme confusion, difficulty breathing, or loss of consciousness.''',
        ),
        HealthArticleModel(
          id: 'art-2', categoryId: 'cat-1', categoryName: 'Diseases',
          categorySlug: 'diseases', categoryColor: '#F97316',
          title: 'Malaria Prevention and Treatment Guide',
          slug: 'malaria-prevention', language: 'en',
          summary: 'Essential guide on malaria causes, prevention with mosquito nets, and treatment.',
          emoji: '🦟', readTimeMin: 4, isFeatured: true,
          viewCount: 980, bookmarkCount: 65, tags: ['malaria', 'mosquito', 'fever', 'rural health'],
          content: '''## What is Malaria?
Malaria is a life-threatening disease caused by *Plasmodium* parasites, transmitted through infected Anopheles mosquito bites.

## Symptoms
- High fever (39–41°C) with chills and sweating
- Headache, muscle pain, nausea
- Symptoms appear 10–15 days after mosquito bite

## Prevention
1. Sleep under insecticide-treated bed nets (ITN)
2. Use mosquito repellent (DEET-based)
3. Wear long-sleeved clothes at dusk/dawn
4. Eliminate standing water near homes

## Treatment
- Artemisinin-based Combination Therapy (ACT) is first-line
- Seek medical care within 24 hours of symptom onset

## Emergency Signs 🚨
Convulsions, difficulty breathing, or dark urine — go to hospital immediately.''',
        ),
        HealthArticleModel(
          id: 'art-3', categoryId: 'cat-2', categoryName: 'Nutrition',
          categorySlug: 'nutrition', categoryColor: '#2ECC8B',
          title: 'Nutrition During Pregnancy: What to Eat for a Healthy Baby',
          slug: 'pregnancy-nutrition', language: 'en',
          summary: 'A complete pregnancy nutrition guide covering essential nutrients, meal plans, and foods to avoid.',
          emoji: '🤰', readTimeMin: 6, isFeatured: true,
          viewCount: 1450, bookmarkCount: 112, tags: ['pregnancy', 'nutrition', 'maternal health', 'diet'],
          content: '''## Why Nutrition Matters in Pregnancy
Proper nutrition ensures healthy fetal growth, prevents birth defects, and keeps the mother strong.

## Key Nutrients
| Nutrient | Why It Matters | Sources |
|---|---|---|
| Folic Acid | Prevents neural tube defects | Leafy greens, lentils |
| Iron | Prevents anemia | Red meat, spinach, beans |
| Calcium | Bone development | Milk, yogurt, tofu |
| Protein | Tissue growth | Eggs, fish, chicken |

## Recommended Foods
- Dark leafy vegetables (spinach, fenugreek)
- Whole grains (brown rice, oats)
- Legumes (lentils, chickpeas)
- Fresh fruits (banana, papaya, guava)

## Foods to Avoid
- Raw/undercooked meat and fish
- Unpasteurized dairy
- Excess caffeine (>200 mg/day)
- Alcohol completely

## Daily Meal Plan
- **Breakfast:** Oats with banana + 1 glass milk
- **Lunch:** Dal + rice + vegetables + curd
- **Dinner:** Roti + sabzi + dal soup''',
        ),
        HealthArticleModel(
          id: 'art-4', categoryId: 'cat-3', categoryName: 'Vaccination',
          categorySlug: 'vaccination', categoryColor: '#4F94FF',
          title: 'BCG, Polio & Childhood Vaccination Schedule',
          slug: 'childhood-vaccination-schedule', language: 'en',
          summary: 'Complete childhood vaccination schedule from birth to 5 years with dose timing.',
          emoji: '💉', readTimeMin: 5, isFeatured: true,
          viewCount: 870, bookmarkCount: 73, tags: ['vaccination', 'children', 'BCG', 'polio', 'immunization'],
          content: '''## Why Vaccinate Children?
Vaccines protect children from life-threatening diseases before exposure.

## Vaccination Schedule (0–5 Years)
| Vaccine | Disease | When |
|---|---|---|
| BCG | Tuberculosis | At birth |
| OPV-0 | Polio | At birth |
| Hepatitis B | Hepatitis B | At birth |
| DPT + Hib | Diphtheria, Pertussis, Tetanus | 6, 10, 14 weeks |
| Rotavirus | Diarrhea | 6, 10 weeks |
| MR | Measles, Rubella | 9–12 months |
| DPT Booster | Booster | 16–24 months |

## Normal Side Effects
- Mild fever for 1–2 days
- Redness at injection site

## When to See a Doctor
High fever >39°C, seizures, or breathing difficulty after vaccination.''',
        ),
        HealthArticleModel(
          id: 'art-5', categoryId: 'cat-6', categoryName: 'Hygiene',
          categorySlug: 'hygiene', categoryColor: '#18C8C8',
          title: 'Hand Washing: The Most Powerful Disease Prevention Tool',
          slug: 'hand-washing-guide', language: 'en',
          summary: 'Learn the correct 7-step hand washing technique that prevents diarrhea, cholera, and flu.',
          emoji: '🧼', readTimeMin: 3, isFeatured: false,
          viewCount: 640, bookmarkCount: 42, tags: ['hygiene', 'hand washing', 'disease prevention', 'sanitation'],
          content: '''## Why Hand Washing Saves Lives
Proper hand washing can reduce diarrheal disease by 40%.

## The 7-Step WHO Technique
1. Wet hands with clean running water
2. Apply soap and lather both palms
3. Rub back of hands and between fingers
4. Interlock fingers and scrub
5. Clean thumbs by rotating
6. Scrub fingertips and nails on palms
7. Rinse thoroughly and dry with clean cloth

**Duration: At least 20 seconds**

## When to Wash Hands
- Before eating or preparing food
- After using toilet
- After touching animals
- Before feeding a baby''',
        ),
        HealthArticleModel(
          id: 'art-6', categoryId: 'cat-9', categoryName: 'Heart Health',
          categorySlug: 'heart-health', categoryColor: '#0891B2',
          title: 'Managing High Blood Pressure (Hypertension) Naturally',
          slug: 'hypertension-management', language: 'en',
          summary: 'Understand what raises your blood pressure and how diet, exercise, and stress management can help.',
          emoji: '❤️', readTimeMin: 5, isFeatured: true,
          viewCount: 1100, bookmarkCount: 91, tags: ['hypertension', 'blood pressure', 'heart health', 'lifestyle'],
          content: '''## What is Hypertension?
Blood pressure above 130/80 mmHg consistently is considered hypertension — the "silent killer".

## Risk Factors
- High salt diet
- Obesity and physical inactivity
- Smoking and alcohol
- Chronic stress

## Lifestyle Changes That Work
1. DASH Diet – Fruits, vegetables, whole grains
2. Reduce salt – Less than 5g (1 teaspoon) per day
3. Exercise – 30 minutes brisk walking, 5 days/week
4. Stop smoking – Immediate benefit to blood vessels
5. Manage stress – Yoga, meditation, deep breathing

## Emergency Signs 🚨
BP > 180/120 with chest pain or severe headache — call emergency immediately.''',
        ),
        HealthArticleModel(
          id: 'art-7', categoryId: 'cat-5', categoryName: 'Child Health',
          categorySlug: 'child-health', categoryColor: '#FFB829',
          title: 'Child Fever: When to Worry and Home Care Guide',
          slug: 'child-fever-guide', language: 'en',
          summary: 'Practical guide for parents to manage child fever safely at home and know when to rush to hospital.',
          emoji: '👶', readTimeMin: 4, isFeatured: false,
          viewCount: 760, bookmarkCount: 58, tags: ['child fever', 'pediatric', 'children health', 'home care'],
          content: '''## What is Fever in Children?
A temperature above 38°C (100.4°F) is a fever.

## Home Care for Mild Fever (38–38.9°C)
- Keep child well-hydrated (water, ORS, breast milk)
- Dress lightly — do not wrap in blankets
- Lukewarm sponge bath
- Paracetamol: 10–15 mg/kg every 4–6 hours

## When to See a Doctor 🏥
- Fever above 39°C not reducing with paracetamol
- Child under 3 months old
- Fever lasting more than 3 days
- Child has rash or difficulty breathing

## Emergency Signs 🚨
Febrile seizures, extreme difficulty breathing, blue lips — call emergency immediately.''',
        ),
        HealthArticleModel(
          id: 'art-8', categoryId: 'cat-8', categoryName: 'Mental Health',
          categorySlug: 'mental-health', categoryColor: '#8B5CF6',
          title: 'Mental Wellness for Rural Communities',
          slug: 'mental-wellness-rural', language: 'en',
          summary: 'Practical mental health strategies for rural communities facing stigma, stress, and limited access.',
          emoji: '🧠', readTimeMin: 5, isFeatured: false,
          viewCount: 520, bookmarkCount: 38, tags: ['mental health', 'depression', 'anxiety', 'rural', 'wellness'],
          content: '''## Mental Health in Rural Areas
Rural communities face unique challenges: isolation, agricultural stress, and social stigma.

## Common Mental Health Issues
- Depression – Persistent sadness, loss of interest
- Anxiety – Excessive worry, restlessness
- Farmer Stress – Crop failure, debt, climate uncertainty

## Self-Care Strategies
1. Talk to someone trusted
2. Physical activity – Even farming counts
3. Sleep hygiene – Regular sleep and wake times
4. Spiritual practice – Prayer, meditation
5. Limit alcohol – A major risk factor

## Free Help Available
- National Mental Health Helpline: 1800-599-0019
- NIMHANS Helpline: 080-46110007''',
        ),
        HealthArticleModel(
          id: 'art-9', categoryId: 'cat-4', categoryName: 'Maternal Health',
          categorySlug: 'maternal-health', categoryColor: '#8B5CF6',
          title: 'Breastfeeding: Benefits and Best Practices for New Mothers',
          slug: 'breastfeeding-guide', language: 'en',
          summary: 'Everything a new mother needs to know about breastfeeding, positions, and overcoming challenges.',
          emoji: '🤱', readTimeMin: 6, isFeatured: false,
          viewCount: 890, bookmarkCount: 67, tags: ['breastfeeding', 'maternal health', 'newborn', 'infant nutrition'],
          content: '''## Why Breastfeed?
Breast milk is the perfect food for infants — complete nutrition and immunity for the first 6 months.

## Benefits for Baby
- Protection against infections
- Optimal brain development
- Lower risk of allergies and obesity

## How to Breastfeed (Latch Technique)
1. Position baby tummy-to-tummy
2. Support baby's head and neck
3. Tickle baby's lip with nipple to open mouth
4. Bring baby to breast (not breast to baby)

## WHO Recommendation
Exclusive breastfeeding for 6 months, then continued with complementary foods up to 2 years.''',
        ),
        HealthArticleModel(
          id: 'art-10', categoryId: 'cat-1', categoryName: 'Diseases',
          categorySlug: 'diseases', categoryColor: '#F97316',
          title: 'Tuberculosis (TB): Facts, Prevention, and Treatment',
          slug: 'tuberculosis-guide', language: 'en',
          summary: 'Complete guide on TB spread, DOTS treatment, and prevention for households and communities.',
          emoji: '🫁', readTimeMin: 5, isFeatured: false,
          viewCount: 690, bookmarkCount: 49, tags: ['tuberculosis', 'TB', 'respiratory', 'DOTS', 'treatment'],
          content: '''## What is Tuberculosis?
TB is a bacterial infection caused by *Mycobacterium tuberculosis*, mainly affecting the lungs.

## How TB Spreads
TB spreads through the air when an infected person coughs or sneezes.

## Symptoms
- Persistent cough for 2+ weeks
- Coughing up blood
- Night sweats and fever
- Unexplained weight loss

## Treatment (DOTS)
TB is curable with a 6-month course of antibiotics.
- Phase 1 (2 months): 4 drugs
- Phase 2 (4 months): 2 drugs

**Critical:** Complete the full course — stopping early creates drug-resistant TB.

## Free Treatment
TB treatment is FREE at all government health centers under NTEP.''',
        ),
      ];

  // ── Convenience accessors ──────────────────────────────────────────────────

  static List<HealthArticleModel> get featuredArticles =>
      articles.where((a) => a.isFeatured).toList();

  static List<HealthArticleModel> get recommendedArticles {
    final sorted = List<HealthArticleModel>.from(articles);
    sorted.sort((a, b) =>
        (b.viewCount + b.bookmarkCount * 3).compareTo(a.viewCount + a.bookmarkCount * 3));
    return sorted.take(8).toList();
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
