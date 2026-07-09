"""
Alembic migration: Create Medical Chatbot tables

Revision ID: chatbot_001
Create Date: 2026-07-06
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers
revision = 'chatbot_001'
down_revision = None  # Update this to the latest revision in your main migrations
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Create medical chatbot tables"""
    
    # Create conversations table
    op.create_table(
        'conversations',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('uuid', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('session_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('title', sa.String(length=255), nullable=False),
        sa.Column('language', sa.String(length=10), nullable=False, server_default='en'),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('metadata', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('uuid')
    )
    
    # Create indexes for conversations
    op.create_index('idx_conversation_user_created', 'conversations', ['user_id', 'created_at'])
    op.create_index('idx_conversation_session', 'conversations', ['session_id'])
    op.create_index(op.f('ix_conversations_uuid'), 'conversations', ['uuid'], unique=True)
    
    # Create messages table
    op.create_table(
        'messages',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('conversation_id', sa.Integer(), nullable=False),
        sa.Column('sender', sa.String(length=20), nullable=False),
        sa.Column('message', sa.Text(), nullable=False),
        sa.Column('tokens_used', sa.Integer(), nullable=True),
        sa.Column('response_time', sa.Float(), nullable=True),
        sa.Column('confidence', sa.Float(), nullable=True),
        sa.Column('emergency_detected', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('citations', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('recommendations', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('follow_up_questions', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('metadata', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
        sa.ForeignKeyConstraint(['conversation_id'], ['conversations.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    
    # Create indexes for messages
    op.create_index('idx_message_conversation_created', 'messages', ['conversation_id', 'created_at'])
    op.create_index('idx_message_sender', 'messages', ['sender'])
    op.create_index('idx_message_emergency', 'messages', ['emergency_detected'])
    
    # Create chatbot_feedback table
    op.create_table(
        'chatbot_feedback',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('conversation_id', sa.Integer(), nullable=False),
        sa.Column('message_id', sa.Integer(), nullable=True),
        sa.Column('rating', sa.Integer(), nullable=False),
        sa.Column('feedback_text', sa.Text(), nullable=True),
        sa.Column('feedback_type', sa.String(length=50), nullable=True),
        sa.Column('metadata', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
        sa.ForeignKeyConstraint(['conversation_id'], ['conversations.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['message_id'], ['messages.id'], ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id')
    )
    
    # Create indexes for feedback
    op.create_index('idx_feedback_conversation', 'chatbot_feedback', ['conversation_id'])
    op.create_index('idx_feedback_rating', 'chatbot_feedback', ['rating'])
    op.create_index('idx_feedback_created', 'chatbot_feedback', ['created_at'])
    
    # Create chatbot_sessions table
    op.create_table(
        'chatbot_sessions',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('session_uuid', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('device', sa.String(length=100), nullable=True),
        sa.Column('ip_address', sa.String(length=45), nullable=True),
        sa.Column('user_agent', sa.Text(), nullable=True),
        sa.Column('location', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('started_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
        sa.Column('last_activity', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
        sa.Column('ended_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('metadata', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('session_uuid')
    )
    
    # Create indexes for sessions
    op.create_index('idx_session_user_activity', 'chatbot_sessions', ['user_id', 'last_activity'])
    op.create_index('idx_session_active', 'chatbot_sessions', ['is_active'])
    op.create_index(op.f('ix_chatbot_sessions_session_uuid'), 'chatbot_sessions', ['session_uuid'], unique=True)


def downgrade() -> None:
    """Drop medical chatbot tables"""
    op.drop_index(op.f('ix_chatbot_sessions_session_uuid'), table_name='chatbot_sessions')
    op.drop_index('idx_session_active', table_name='chatbot_sessions')
    op.drop_index('idx_session_user_activity', table_name='chatbot_sessions')
    op.drop_table('chatbot_sessions')
    
    op.drop_index('idx_feedback_created', table_name='chatbot_feedback')
    op.drop_index('idx_feedback_rating', table_name='chatbot_feedback')
    op.drop_index('idx_feedback_conversation', table_name='chatbot_feedback')
    op.drop_table('chatbot_feedback')
    
    op.drop_index('idx_message_emergency', table_name='messages')
    op.drop_index('idx_message_sender', table_name='messages')
    op.drop_index('idx_message_conversation_created', table_name='messages')
    op.drop_table('messages')
    
    op.drop_index(op.f('ix_conversations_uuid'), table_name='conversations')
    op.drop_index('idx_conversation_session', table_name='conversations')
    op.drop_index('idx_conversation_user_created', table_name='conversations')
    op.drop_table('conversations')
