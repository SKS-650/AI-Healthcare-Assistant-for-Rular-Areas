"""
Prompt Builder - Creates structured prompts for the LLM
"""
from typing import List, Dict, Any, Optional
from datetime import datetime

from ..utils.constants import MEDICAL_DISCLAIMER, EMERGENCY_DISCLAIMER


class PromptBuilder:
    """Builds prompts for different chatbot scenarios"""
    
    # System prompt - core instructions for the AI
    SYSTEM_PROMPT = """You are a helpful medical information assistant for rural healthcare.

**Your Role:**
- Provide general health education and information
- Explain symptoms, diseases, and medicines in simple terms
- Offer first aid guidance and healthy lifestyle tips
- Be supportive, friendly, and easy to understand

**Critical Rules - YOU MUST NEVER:**
- Diagnose any disease or condition
- Prescribe any medication or treatment
- Recommend specific medicine dosages
- Tell users to stop their medications
- Replace professional medical advice
- Guarantee any health outcomes

**Always:**
- Use phrases like "This could be...", "It may be...", "Possibly..."
- Recommend consulting a qualified healthcare professional
- Keep responses short, simple, and clear (2-3 paragraphs max)
- Use everyday language, avoid complex medical jargon
- Be empathetic and supportive
- Mention when emergency care is needed

**Remember:** You are providing education, not medical advice. Users should always consult healthcare professionals for diagnosis and treatment.
"""
    
    def __init__(self):
        """Initialize prompt builder"""
        pass
    
    def build_chat_prompt(
        self,
        user_question: str,
        conversation_history: Optional[List[Dict[str, str]]] = None,
        knowledge_context: Optional[Dict[str, Any]] = None,
        user_context: Optional[Dict[str, Any]] = None
    ) -> str:
        """
        Build complete prompt for chat response
        
        Args:
            user_question: Current user question
            conversation_history: Recent conversation messages
            knowledge_context: Relevant dataset information
            user_context: User's additional context (symptom results, etc.)
            
        Returns:
            Complete prompt string
        """
        prompt_parts = []
        
        # 1. System instructions
        prompt_parts.append(self.SYSTEM_PROMPT)
        prompt_parts.append("\n---\n")
        
        # 2. Knowledge context (if available)
        if knowledge_context:
            prompt_parts.append(self._format_knowledge_context(knowledge_context))
            prompt_parts.append("\n---\n")
        
        # 3. User context (symptom checker results, etc.)
        if user_context:
            prompt_parts.append(self._format_user_context(user_context))
            prompt_parts.append("\n---\n")
        
        # 4. Conversation history (recent messages)
        if conversation_history:
            prompt_parts.append(self._format_conversation_history(conversation_history))
            prompt_parts.append("\n---\n")
        
        # 5. Current question
        prompt_parts.append(f"**User Question:**\n{user_question}\n\n")
        
        # 6. Response instructions
        prompt_parts.append(self._get_response_instructions())
        
        return "".join(prompt_parts)
    
    def _format_knowledge_context(self, knowledge: Dict[str, Any]) -> str:
        """Format knowledge base information"""
        parts = ["**Medical Knowledge Base:**\n"]
        
        if knowledge.get("disease_info"):
            disease = knowledge["disease_info"]
            parts.append(f"\n**Disease: {disease.get('name', 'Unknown')}**\n")
            if disease.get("description"):
                parts.append(f"Description: {disease['description']}\n")
            if disease.get("symptoms"):
                parts.append(f"Common Symptoms: {', '.join(disease['symptoms'][:5])}\n")
            if disease.get("precautions"):
                parts.append(f"General Precautions: {', '.join(disease['precautions'][:4])}\n")
        
        if knowledge.get("symptom_info"):
            symptoms = knowledge["symptom_info"]
            if symptoms:
                parts.append(f"\n**Related Symptoms:** {', '.join(symptoms[:5])}\n")
        
        if knowledge.get("general_info"):
            parts.append(f"\n**Additional Information:**\n{knowledge['general_info']}\n")
        
        return "".join(parts)
    
    def _format_user_context(self, context: Dict[str, Any]) -> str:
        """Format user-specific context"""
        parts = ["**User Context:**\n"]
        
        if context.get("symptom_check_result"):
            result = context["symptom_check_result"]
            parts.append(f"\nRecent Symptom Check Result:\n")
            parts.append(f"- Predicted Condition: {result.get('predicted_disease', 'Unknown')}\n")
            parts.append(f"- Confidence: {result.get('confidence', 0):.0%}\n")
            if result.get('symptoms'):
                parts.append(f"- Reported Symptoms: {', '.join(result['symptoms'][:5])}\n")
        
        if context.get("location"):
            location = context["location"]
            parts.append(f"\nUser Location: {location.get('city', 'Unknown')}\n")
        
        return "".join(parts)
    
    def _format_conversation_history(self, history: List[Dict[str, str]]) -> str:
        """Format conversation history"""
        if not history:
            return ""
        
        parts = ["**Recent Conversation:**\n"]
        
        for msg in history[-10:]:  # Last 10 messages
            sender = msg.get("sender", "unknown")
            message = msg.get("message", "")
            
            if sender == "user":
                parts.append(f"\nUser: {message}\n")
            elif sender == "assistant":
                parts.append(f"Assistant: {message}\n")
        
        return "".join(parts)
    
    def _get_response_instructions(self) -> str:
        """Get response format instructions"""
        return """**Your Response Guidelines:**
1. Answer the user's question clearly and simply
2. Use the knowledge base information provided above
3. Reference the conversation context if relevant
4. Keep your response concise (2-3 short paragraphs)
5. Always include disclaimer about consulting healthcare professionals
6. If symptoms are serious, recommend seeing a doctor immediately
7. Use empathetic and supportive tone

**Now provide your response:**
"""
    
    def build_symptom_explanation_prompt(self, symptom: str, context: Optional[str] = None) -> str:
        """Build prompt for explaining a symptom"""
        prompt = f"""{self.SYSTEM_PROMPT}

**Task:** Explain the symptom "{symptom}" in simple terms.

**Include:**
- What this symptom means
- Possible common causes (non-diagnostic)
- When it might be concerning
- General self-care tips
- When to see a doctor

{f"**Additional Context:** {context}" if context else ""}

**Remember:** Provide education, not diagnosis. Keep it simple and brief.

**Your Response:**
"""
        return prompt
    
    def build_disease_explanation_prompt(self, disease: str, info: Optional[Dict] = None) -> str:
        """Build prompt for explaining a disease"""
        prompt = f"""{self.SYSTEM_PROMPT}

**Task:** Explain "{disease}" in simple, easy-to-understand terms.

"""
        if info:
            prompt += f"""**Available Information:**
- Description: {info.get('description', 'Not available')}
- Common Symptoms: {', '.join(info.get('symptoms', [])[:5])}
- Precautions: {', '.join(info.get('precautions', [])[:4])}

"""
        
        prompt += """**Include in your explanation:**
- What this condition is (in simple terms)
- Common symptoms people experience
- General prevention tips
- Why it's important to see a doctor
- Basic lifestyle considerations

**Keep it:**
- Simple and clear
- Non-technical
- Encouraging and supportive
- 2-3 short paragraphs

**Your Response:**
"""
        return prompt
    
    def build_medicine_explanation_prompt(self, medicine: str) -> str:
        """Build prompt for explaining a medicine"""
        prompt = f"""{self.SYSTEM_PROMPT}

**Task:** Provide general information about "{medicine}".

**CRITICAL:** You must NOT prescribe dosages or recommend taking this medicine.

**Include:**
- What type of medicine it generally is
- What conditions it's commonly used for (general knowledge)
- General precautions people should know
- Importance of following doctor's instructions
- Why self-medication is dangerous

**Emphasize:**
- This medicine should only be taken as prescribed by a doctor
- Dosage must be determined by healthcare professionals
- User should consult a pharmacist or doctor for specific advice

**Keep it educational and safe.**

**Your Response:**
"""
        return prompt
    
    def build_first_aid_prompt(self, situation: str) -> str:
        """Build prompt for first aid guidance"""
        prompt = f"""{self.SYSTEM_PROMPT}

**Task:** Provide basic first aid guidance for: "{situation}"

**Include:**
- Immediate steps to take
- What to do and what NOT to do
- When to call emergency services
- How to stay calm and safe

**Important:**
- Keep instructions simple and clear
- Emphasize calling emergency services if serious
- Mention this is basic guidance, not professional care
- Use numbered steps for clarity

**Format:**
1. Assess the situation
2. [Specific steps]
3. Call for help if needed

**Your Response:**
"""
        return prompt
    
    def build_lifestyle_advice_prompt(self, topic: str) -> str:
        """Build prompt for healthy lifestyle advice"""
        prompt = f"""{self.SYSTEM_PROMPT}

**Task:** Provide healthy lifestyle advice about: "{topic}"

**Include:**
- Why this is important for health
- Practical, simple tips anyone can follow
- Benefits people can expect
- Common mistakes to avoid
- Encouragement to start small

**Keep it:**
- Positive and motivating
- Realistic and achievable
- Based on general health knowledge
- Culturally appropriate for rural areas

**Your Response:**
"""
        return prompt
    
    def add_emergency_context(self, prompt: str) -> str:
        """Add emergency context to prompt"""
        emergency_note = f"""

**EMERGENCY SITUATION DETECTED**

The user's message contains emergency keywords. In your response:
1. Immediately tell them to call emergency services (108 in India)
2. Tell them to go to the nearest hospital
3. Provide only critical first aid steps if relevant
4. Keep response very brief and focused on getting help

{EMERGENCY_DISCLAIMER}

"""
        return prompt + emergency_note
    
    def get_fallback_response(self, reason: str = "general") -> str:
        """Get safe fallback response"""
        fallback_responses = {
            "general": (
                "I apologize, but I'm having trouble providing a specific answer right now. "
                "For your health concerns, I strongly recommend consulting a qualified healthcare professional. "
                "They can provide personalized advice based on your specific situation.\n\n"
                f"{MEDICAL_DISCLAIMER}"
            ),
            "technical": (
                "I'm experiencing technical difficulties at the moment. "
                "Please consult a healthcare professional for medical advice. "
                "If this is urgent, please call emergency services or visit your nearest clinic."
            ),
            "unclear": (
                "I'm not quite sure I understand your question. "
                "Could you please rephrase it or provide more details? "
                "For immediate medical concerns, please consult a healthcare professional."
            ),
            "out_of_scope": (
                "I apologize, but I'm not able to provide information on that topic. "
                "I'm designed to provide general health education only. "
                "Please consult a qualified healthcare professional for specific medical advice.\n\n"
                f"{MEDICAL_DISCLAIMER}"
            )
        }
        
        return fallback_responses.get(reason, fallback_responses["general"])


# Example usage:
# builder = PromptBuilder()
# prompt = builder.build_chat_prompt(
#     user_question="What are symptoms of diabetes?",
#     knowledge_context={"disease_info": {...}},
#     conversation_history=[...]
# )
