"""
Performance Optimization Utilities
Simple optimizations for college project
"""
import time
import functools
from typing import Any, Callable, Dict, Optional
from datetime import datetime, timedelta


class SimpleCache:
    """
    Simple in-memory cache for datasets and prompt templates
    
    Note: For production with multiple servers, use Redis
    """
    
    def __init__(self, ttl: int = 3600):
        """
        Initialize cache
        
        Args:
            ttl: Time-to-live in seconds (default: 1 hour)
        """
        self._cache: Dict[str, Dict[str, Any]] = {}
        self._ttl = ttl
    
    def get(self, key: str) -> Optional[Any]:
        """Get value from cache"""
        if key not in self._cache:
            return None
        
        entry = self._cache[key]
        
        # Check if expired
        if datetime.now() > entry["expires_at"]:
            del self._cache[key]
            return None
        
        entry["last_accessed"] = datetime.now()
        entry["hits"] += 1
        return entry["value"]
    
    def set(self, key: str, value: Any, ttl: Optional[int] = None):
        """Set value in cache"""
        expires_at = datetime.now() + timedelta(seconds=ttl or self._ttl)
        
        self._cache[key] = {
            "value": value,
            "created_at": datetime.now(),
            "expires_at": expires_at,
            "last_accessed": datetime.now(),
            "hits": 0
        }
    
    def clear(self):
        """Clear all cache entries"""
        self._cache.clear()
    
    def delete(self, key: str):
        """Delete specific cache entry"""
        if key in self._cache:
            del self._cache[key]
    
    def get_stats(self) -> Dict[str, Any]:
        """Get cache statistics"""
        total_entries = len(self._cache)
        total_hits = sum(entry["hits"] for entry in self._cache.values())
        
        return {
            "total_entries": total_entries,
            "total_hits": total_hits,
            "entries": [
                {
                    "key": key,
                    "hits": entry["hits"],
                    "created_at": entry["created_at"],
                    "expires_at": entry["expires_at"]
                }
                for key, entry in self._cache.items()
            ]
        }


# Global cache instances
dataset_cache = SimpleCache(ttl=3600)  # 1 hour for datasets
prompt_cache = SimpleCache(ttl=1800)   # 30 minutes for prompts
response_cache = SimpleCache(ttl=300)  # 5 minutes for responses


def cached(cache_key: str, ttl: Optional[int] = None, cache_instance: Optional[SimpleCache] = None):
    """
    Decorator to cache function results
    
    Example:
        @cached("knowledge_data", ttl=3600)
        def load_knowledge_data():
            # expensive operation
            return data
    """
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            cache = cache_instance or dataset_cache
            
            # Try to get from cache
            cached_value = cache.get(cache_key)
            if cached_value is not None:
                return cached_value
            
            # Execute function
            result = func(*args, **kwargs)
            
            # Store in cache
            cache.set(cache_key, result, ttl)
            
            return result
        
        return wrapper
    return decorator


async def async_cached(cache_key: str, ttl: Optional[int] = None, cache_instance: Optional[SimpleCache] = None):
    """
    Decorator to cache async function results
    
    Example:
        @async_cached("user_data", ttl=300)
        async def get_user_data(user_id):
            # async operation
            return data
    """
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            cache = cache_instance or dataset_cache
            
            # Create cache key with args
            key = f"{cache_key}_{str(args)}_{str(kwargs)}"
            
            # Try to get from cache
            cached_value = cache.get(key)
            if cached_value is not None:
                return cached_value
            
            # Execute function
            result = await func(*args, **kwargs)
            
            # Store in cache
            cache.set(key, result, ttl)
            
            return result
        
        return wrapper
    return decorator


def measure_time(func: Callable) -> Callable:
    """
    Decorator to measure function execution time
    
    Example:
        @measure_time
        def expensive_operation():
            pass
    """
    @functools.wraps(func)
    async def async_wrapper(*args, **kwargs):
        start_time = time.time()
        result = await func(*args, **kwargs)
        execution_time = time.time() - start_time
        
        # Log execution time
        from .logger import logger
        logger.debug(f"{func.__name__} executed in {execution_time:.4f}s")
        
        return result
    
    @functools.wraps(func)
    def sync_wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        execution_time = time.time() - start_time
        
        # Log execution time
        from .logger import logger
        logger.debug(f"{func.__name__} executed in {execution_time:.4f}s")
        
        return result
    
    # Return appropriate wrapper based on function type
    import asyncio
    if asyncio.iscoroutinefunction(func):
        return async_wrapper
    else:
        return sync_wrapper


class ConversationHistoryLimiter:
    """
    Limit conversation history to recent messages
    Prevents sending too much context to LLM
    """
    
    @staticmethod
    def limit_history(
        messages: list,
        max_messages: int = 20,
        max_tokens: int = 2000
    ) -> list:
        """
        Limit conversation history by message count and token count
        
        Args:
            messages: List of message dictionaries
            max_messages: Maximum number of messages to keep
            max_tokens: Approximate maximum token count
            
        Returns:
            Limited list of messages
        """
        # Keep only recent messages
        recent_messages = messages[-max_messages:]
        
        # Rough token estimation (4 chars ≈ 1 token)
        total_chars = sum(len(msg.get("message", "")) for msg in recent_messages)
        estimated_tokens = total_chars // 4
        
        # If still too many tokens, reduce further
        while estimated_tokens > max_tokens and len(recent_messages) > 2:
            # Remove oldest message (but keep at least 2)
            recent_messages = recent_messages[1:]
            total_chars = sum(len(msg.get("message", "")) for msg in recent_messages)
            estimated_tokens = total_chars // 4
        
        return recent_messages


class DatasetPreloader:
    """
    Preload datasets at startup to avoid repeated loading
    """
    
    _preloaded_data: Dict[str, Any] = {}
    
    @classmethod
    def preload(cls, name: str, loader_func: Callable):
        """
        Preload dataset
        
        Args:
            name: Dataset name
            loader_func: Function to load dataset
        """
        if name not in cls._preloaded_data:
            cls._preloaded_data[name] = loader_func()
    
    @classmethod
    def get(cls, name: str) -> Optional[Any]:
        """Get preloaded dataset"""
        return cls._preloaded_data.get(name)
    
    @classmethod
    def clear(cls):
        """Clear all preloaded data"""
        cls._preloaded_data.clear()


class BatchProcessor:
    """
    Process multiple requests in batch for efficiency
    """
    
    @staticmethod
    async def process_batch(
        items: list,
        processor: Callable,
        batch_size: int = 10
    ) -> list:
        """
        Process items in batches
        
        Args:
            items: List of items to process
            processor: Async function to process each item
            batch_size: Size of each batch
            
        Returns:
            List of processed results
        """
        results = []
        
        for i in range(0, len(items), batch_size):
            batch = items[i:i + batch_size]
            
            # Process batch concurrently
            import asyncio
            batch_results = await asyncio.gather(
                *[processor(item) for item in batch],
                return_exceptions=True
            )
            
            results.extend(batch_results)
        
        return results


def optimize_prompt_length(prompt: str, max_length: int = 4000) -> str:
    """
    Optimize prompt length by trimming if too long
    
    Args:
        prompt: Original prompt
        max_length: Maximum allowed length
        
    Returns:
        Optimized prompt
    """
    if len(prompt) <= max_length:
        return prompt
    
    # Keep beginning and end, remove middle
    keep_chars = max_length // 2
    
    beginning = prompt[:keep_chars]
    end = prompt[-keep_chars:]
    
    return f"{beginning}\n\n[... content trimmed for length ...]\n\n{end}"


def rate_limiter(max_calls: int, time_window: int):
    """
    Simple rate limiter decorator
    
    Args:
        max_calls: Maximum number of calls allowed
        time_window: Time window in seconds
        
    Example:
        @rate_limiter(max_calls=10, time_window=60)
        async def api_call():
            pass
    """
    calls = []
    
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            now = time.time()
            
            # Remove old calls outside time window
            nonlocal calls
            calls = [call_time for call_time in calls if now - call_time < time_window]
            
            # Check rate limit
            if len(calls) >= max_calls:
                raise Exception(f"Rate limit exceeded: {max_calls} calls per {time_window}s")
            
            # Record this call
            calls.append(now)
            
            return await func(*args, **kwargs)
        
        return wrapper
    return decorator


# Performance monitoring
class PerformanceMonitor:
    """Simple performance monitoring"""
    
    _metrics: Dict[str, list] = {}
    
    @classmethod
    def record(cls, metric_name: str, value: float):
        """Record a metric value"""
        if metric_name not in cls._metrics:
            cls._metrics[metric_name] = []
        
        cls._metrics[metric_name].append({
            "value": value,
            "timestamp": datetime.now()
        })
        
        # Keep only recent metrics (last 1000)
        if len(cls._metrics[metric_name]) > 1000:
            cls._metrics[metric_name] = cls._metrics[metric_name][-1000:]
    
    @classmethod
    def get_stats(cls, metric_name: str) -> Dict[str, float]:
        """Get statistics for a metric"""
        if metric_name not in cls._metrics or not cls._metrics[metric_name]:
            return {}
        
        values = [m["value"] for m in cls._metrics[metric_name]]
        
        return {
            "count": len(values),
            "min": min(values),
            "max": max(values),
            "avg": sum(values) / len(values),
            "latest": values[-1]
        }
    
    @classmethod
    def get_all_stats(cls) -> Dict[str, Dict[str, float]]:
        """Get all metric statistics"""
        return {
            metric: cls.get_stats(metric)
            for metric in cls._metrics.keys()
        }
