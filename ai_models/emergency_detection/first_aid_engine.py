"""
First Aid Engine — maps an emergency category to step-by-step guidance.

All guidance is static (offline-safe) and medically conservative.
Content is provided in English and Hindi.  Additional languages can be
added by extending the _FIRST_AID_DATA dict.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, List, Optional

from ai_models.emergency_detection.emergency_rules import EmergencyCategory


@dataclass
class FirstAidGuide:
    category:           EmergencyCategory
    title:              str
    emoji:              str
    steps:              List[str]
    do_not_steps:       List[str]
    call_to_action:     str
    recommended_dept:   str


# ─── First Aid Data ───────────────────────────────────────────────────────────

_FIRST_AID_DATA: Dict[EmergencyCategory, FirstAidGuide] = {

    EmergencyCategory.CARDIAC: FirstAidGuide(
        category=EmergencyCategory.CARDIAC,
        title="Heart Attack / Cardiac Emergency",
        emoji="🫀",
        steps=[
            "Call emergency services (102 / 108) immediately — do not delay.",
            "Help the person sit or lie down in a comfortable position.",
            "Loosen tight clothing around the neck, chest, and waist.",
            "Give aspirin (300 mg) to chew — ONLY if not allergic and conscious.",
            "Monitor breathing and pulse every minute.",
            "If the person becomes unresponsive and stops breathing, begin CPR.",
            "Stay with the person until emergency services arrive.",
        ],
        do_not_steps=[
            "Do NOT let the person drive themselves to the hospital.",
            "Do NOT give food or water.",
            "Do NOT leave them alone.",
            "Do NOT give ibuprofen or naproxen.",
        ],
        call_to_action="Call 102 (Ambulance) or 112 immediately.",
        recommended_dept="Cardiology Emergency Unit / Cardiac ICU",
    ),

    EmergencyCategory.STROKE: FirstAidGuide(
        category=EmergencyCategory.STROKE,
        title="Stroke — Act FAST",
        emoji="🧠",
        steps=[
            "Remember FAST: Face drooping, Arm weakness, Speech difficulty, Time to call.",
            "Call emergency services (102 / 108) immediately — note the exact time.",
            "Help the person lie down with head and shoulders slightly elevated.",
            "Keep the person calm and do not give food or water.",
            "If unconscious but breathing, place in recovery position.",
            "Do not give aspirin — stroke may be bleeding type.",
        ],
        do_not_steps=[
            "Do NOT give aspirin — stroke type must be confirmed by a doctor.",
            "Do NOT give food or water.",
            "Do NOT leave the person alone.",
            "Do NOT wait to see if symptoms improve.",
        ],
        call_to_action="Call 102 immediately. Every minute of delay causes ~2 million neuron deaths.",
        recommended_dept="Neurology Emergency / Stroke Unit",
    ),

    EmergencyCategory.RESPIRATORY: FirstAidGuide(
        category=EmergencyCategory.RESPIRATORY,
        title="Breathing Emergency",
        emoji="🫁",
        steps=[
            "Call emergency services (102 / 108) immediately.",
            "Help the person sit upright — do not lay them flat.",
            "Loosen any tight clothing around the neck and chest.",
            "If they have an inhaler (asthma), help them use it.",
            "If they stop breathing and have no pulse, begin CPR.",
            "Do not leave the person alone.",
        ],
        do_not_steps=[
            "Do NOT lay the person flat if they are conscious.",
            "Do NOT give food or water.",
            "Do NOT panic — keep reassuring the person.",
        ],
        call_to_action="Call 102 immediately. Breathing emergencies can be fatal within minutes.",
        recommended_dept="Emergency / Respiratory ICU",
    ),

    EmergencyCategory.SEVERE_BLEEDING: FirstAidGuide(
        category=EmergencyCategory.SEVERE_BLEEDING,
        title="Severe Bleeding",
        emoji="🩸",
        steps=[
            "Wear gloves or use a clean cloth as a barrier if available.",
            "Apply firm, direct pressure to the wound with a clean cloth.",
            "If cloth becomes soaked, add more on top — do not remove it.",
            "Elevate the injured limb above the level of the heart if possible.",
            "If bleeding is from a limb and is life-threatening, apply a tourniquet 5-7 cm above the wound.",
            "Call emergency services (102) immediately.",
            "Keep the person warm and calm — monitor for shock symptoms.",
        ],
        do_not_steps=[
            "Do NOT remove objects embedded in the wound.",
            "Do NOT apply tourniquet to the neck, chest, or abdomen.",
            "Do NOT probe or explore the wound.",
        ],
        call_to_action="Call 102. Severe blood loss can be fatal within minutes.",
        recommended_dept="Trauma / Emergency Surgery",
    ),

    EmergencyCategory.POISONING: FirstAidGuide(
        category=EmergencyCategory.POISONING,
        title="Poisoning",
        emoji="☠️",
        steps=[
            "Call emergency services or Poison Control immediately.",
            "Identify the substance — keep the container for emergency responders.",
            "If inhaled: move the person to fresh air immediately.",
            "If on skin or eyes: flush with large amounts of water for 15-20 minutes.",
            "Keep the person awake and calm.",
            "Monitor breathing and be ready to perform CPR.",
        ],
        do_not_steps=[
            "Do NOT induce vomiting unless specifically instructed by poison control.",
            "Do NOT give milk or anything to eat/drink without expert guidance.",
            "Do NOT leave the person alone.",
        ],
        call_to_action="Call 102 and Poison Control. Bring the poison container.",
        recommended_dept="Emergency / Toxicology",
    ),

    EmergencyCategory.OVERDOSE: FirstAidGuide(
        category=EmergencyCategory.OVERDOSE,
        title="Drug / Medicine Overdose",
        emoji="💊",
        steps=[
            "Call emergency services (102) immediately.",
            "Tell them exactly what was taken, how much, and when.",
            "Keep the person awake and talking if possible.",
            "If unconscious and breathing, place in recovery position (on their side).",
            "If not breathing, begin CPR immediately.",
            "Collect all medicine bottles or containers for the paramedics.",
        ],
        do_not_steps=[
            "Do NOT induce vomiting.",
            "Do NOT give coffee, energy drinks, or attempt to 'walk it off'.",
            "Do NOT leave the person alone.",
        ],
        call_to_action="Call 102 immediately. Bring all medication containers.",
        recommended_dept="Emergency / Toxicology / ICU",
    ),

    EmergencyCategory.SNAKEBITE: FirstAidGuide(
        category=EmergencyCategory.SNAKEBITE,
        title="Snake Bite",
        emoji="🐍",
        steps=[
            "Keep the person calm and as still as possible.",
            "Keep the bitten limb immobilised and at or below heart level.",
            "Remove rings, watches, and tight clothing from the bitten area.",
            "Mark the boundary of swelling with a pen and note the time.",
            "Call emergency services (102) or go to the nearest hospital immediately.",
            "If possible, photograph the snake safely from a distance for identification.",
        ],
        do_not_steps=[
            "Do NOT cut the wound or try to suck out venom.",
            "Do NOT apply a tourniquet or ice.",
            "Do NOT give alcohol or pain relievers.",
            "Do NOT allow the person to walk — carry them.",
        ],
        call_to_action="Go to hospital immediately. Anti-venom is time-critical.",
        recommended_dept="Emergency / Toxicology",
    ),

    EmergencyCategory.UNCONSCIOUS: FirstAidGuide(
        category=EmergencyCategory.UNCONSCIOUS,
        title="Unconscious Person",
        emoji="😶",
        steps=[
            "Call emergency services (102) immediately.",
            "Check for breathing — tilt head back, lift chin, look/listen/feel for 10 seconds.",
            "If breathing: place in recovery position (on their side).",
            "If NOT breathing: begin CPR — 30 chest compressions then 2 rescue breaths.",
            "Continue CPR until emergency services arrive or the person starts breathing.",
            "Do not move the person if a spinal injury is suspected.",
        ],
        do_not_steps=[
            "Do NOT give food or water.",
            "Do NOT leave the person alone.",
            "Do NOT slap or shake vigorously.",
        ],
        call_to_action="Call 102 immediately. Begin CPR if not breathing.",
        recommended_dept="Emergency / ICU",
    ),

    EmergencyCategory.HIGH_FEVER: FirstAidGuide(
        category=EmergencyCategory.HIGH_FEVER,
        title="High Fever",
        emoji="🌡️",
        steps=[
            "Measure the temperature accurately.",
            "Give paracetamol at the correct dose for age/weight if no contraindication.",
            "Apply a cool (not ice cold) damp cloth to the forehead.",
            "Ensure the person drinks adequate fluids — water, ORS, juice.",
            "Remove excessive clothing and keep the room cool.",
            "Seek emergency care if: fever > 39.5°C with convulsions, confusion, stiff neck, or rash.",
        ],
        do_not_steps=[
            "Do NOT use ice or cold water immersion — this causes shivering.",
            "Do NOT give aspirin to children under 16.",
            "Do NOT ignore fever above 104°F (40°C) — seek medical care.",
        ],
        call_to_action="Go to hospital if fever > 40°C or accompanied by seizures.",
        recommended_dept="Emergency / Pediatrics (for children)",
    ),

    EmergencyCategory.SEVERE_ALLERGY: FirstAidGuide(
        category=EmergencyCategory.SEVERE_ALLERGY,
        title="Severe Allergic Reaction (Anaphylaxis)",
        emoji="🤧",
        steps=[
            "Call emergency services (102) immediately.",
            "If the person has an epinephrine auto-injector (EpiPen), use it on the outer thigh.",
            "Help them lie down with legs elevated (unless breathing is difficult — then sit up).",
            "If breathing stops, begin CPR.",
            "A second dose of epinephrine may be given after 5-15 minutes if available.",
        ],
        do_not_steps=[
            "Do NOT leave the person alone.",
            "Do NOT allow them to stand or walk.",
            "Do NOT give antihistamine as the only treatment — it is not fast enough.",
        ],
        call_to_action="Call 102. Anaphylaxis is life-threatening — act within minutes.",
        recommended_dept="Emergency / Allergy & Immunology",
    ),

    EmergencyCategory.CHOKING: FirstAidGuide(
        category=EmergencyCategory.CHOKING,
        title="Choking",
        emoji="😮",
        steps=[
            "Ask 'Are you choking?' — if they can cough, encourage them to cough forcefully.",
            "If they cannot cough, speak, or breathe: give 5 firm back blows between shoulder blades.",
            "Then give 5 abdominal thrusts (Heimlich maneuver): stand behind, hands below ribcage, firm inward-upward thrust.",
            "Alternate back blows and abdominal thrusts until the object is cleared.",
            "If the person becomes unconscious, call 102 and begin CPR.",
        ],
        do_not_steps=[
            "Do NOT perform blind finger sweeps in the mouth.",
            "Do NOT perform abdominal thrusts on pregnant women or infants — use back blows only.",
        ],
        call_to_action="Call 102 if obstruction not cleared within 1-2 minutes.",
        recommended_dept="Emergency",
    ),

    EmergencyCategory.TRAUMA: FirstAidGuide(
        category=EmergencyCategory.TRAUMA,
        title="Trauma / Accident",
        emoji="🚗",
        steps=[
            "Call emergency services (102) immediately.",
            "Do not move the person if a spinal or head injury is suspected.",
            "Control bleeding with direct pressure.",
            "Keep the person warm to prevent shock.",
            "Check and monitor airway, breathing, and circulation.",
            "Do not remove helmets, impaled objects, or large dressings.",
        ],
        do_not_steps=[
            "Do NOT move the person unless they are in immediate danger.",
            "Do NOT remove impaled objects.",
            "Do NOT give food or water.",
        ],
        call_to_action="Call 102. Do not attempt to move the person.",
        recommended_dept="Trauma / Emergency Surgery",
    ),

    EmergencyCategory.PREGNANCY: FirstAidGuide(
        category=EmergencyCategory.PREGNANCY,
        title="Pregnancy Emergency",
        emoji="🤰",
        steps=[
            "Call emergency services (102) immediately.",
            "Help the woman lie on her left side to reduce pressure on major blood vessels.",
            "If heavy bleeding: apply a clean pad/cloth — do not pack the vagina.",
            "Keep her calm and warm.",
            "Note the frequency and duration of contractions if in labour.",
            "Do not attempt to deliver the baby without medical training.",
        ],
        do_not_steps=[
            "Do NOT give aspirin or ibuprofen.",
            "Do NOT leave her alone.",
            "Do NOT delay — pregnancy emergencies can be fatal within minutes.",
        ],
        call_to_action="Call 102. Pregnancy emergencies require immediate hospital care.",
        recommended_dept="Obstetrics Emergency / Labour Ward",
    ),
}

# Fallback guide for unclassified emergencies
_DEFAULT_GUIDE = FirstAidGuide(
    category=EmergencyCategory.GENERAL,
    title="General Emergency",
    emoji="🚨",
    steps=[
        "Call emergency services (102 / 108) immediately.",
        "Keep the person calm and comfortable.",
        "Do not give food or water unless instructed.",
        "Monitor breathing and consciousness.",
        "Stay with the person until help arrives.",
    ],
    do_not_steps=[
        "Do NOT panic.",
        "Do NOT leave the person alone.",
    ],
    call_to_action="Call 102 or go to the nearest hospital emergency department.",
    recommended_dept="Emergency Department",
)


# ─── Public API ───────────────────────────────────────────────────────────────

def get_first_aid(category: Optional[EmergencyCategory] = None) -> FirstAidGuide:
    """Return the first aid guide for a given category (or the generic guide)."""
    if category is None:
        return _DEFAULT_GUIDE
    return _FIRST_AID_DATA.get(category, _DEFAULT_GUIDE)


def get_all_guides() -> List[FirstAidGuide]:
    """Return all available first aid guides."""
    return list(_FIRST_AID_DATA.values())
