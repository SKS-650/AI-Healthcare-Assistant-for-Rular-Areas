"""
Phase 05 Part 3 - Final Verification Script
Verifies that all components of the chatbot module are complete and working
"""
import os
import sys
from pathlib import Path
from typing import Dict, List, Tuple

# Color codes for terminal output
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'


def print_header(text: str):
    """Print section header"""
    print(f"\n{BLUE}{'='*60}{RESET}")
    print(f"{BLUE}{text:^60}{RESET}")
    print(f"{BLUE}{'='*60}{RESET}\n")


def print_success(text: str):
    """Print success message"""
    print(f"{GREEN}✓ {text}{RESET}")


def print_error(text: str):
    """Print error message"""
    print(f"{RED}✗ {text}{RESET}")


def print_warning(text: str):
    """Print warning message"""
    print(f"{YELLOW}⚠ {text}{RESET}")


def check_file_exists(filepath: str) -> bool:
    """Check if file exists"""
    return Path(filepath).exists()


def check_directory_structure() -> Tuple[bool, List[str]]:
    """Verify directory structure"""
    print_header("Checking Directory Structure")
    
    required_dirs = [
        "api",
        "services",
        "repositories",
        "database",
        "schemas",
        "utils",
        "knowledge_base",
        "prompts",
        "safety",
        "tests",
        "config"
    ]
    
    missing_dirs = []
    for dir_name in required_dirs:
        if check_file_exists(dir_name):
            print_success(f"Directory: {dir_name}/")
        else:
            print_error(f"Missing directory: {dir_name}/")
            missing_dirs.append(dir_name)
    
    return len(missing_dirs) == 0, missing_dirs


def check_api_layer() -> Tuple[bool, List[str]]:
    """Verify API layer files"""
    print_header("Checking API Layer")
    
    required_files = [
        "api/__init__.py",
        "api/routes.py",
        "api/controller.py",
        "api/dependencies.py"
    ]
    
    missing_files = []
    for filepath in required_files:
        if check_file_exists(filepath):
            print_success(f"File: {filepath}")
        else:
            print_error(f"Missing file: {filepath}")
            missing_files.append(filepath)
    
    return len(missing_files) == 0, missing_files


def check_service_layer() -> Tuple[bool, List[str]]:
    """Verify service layer files"""
    print_header("Checking Service Layer")
    
    required_files = [
        "services/__init__.py",
        "services/chatbot_service.py",
        "services/llm_service.py",
        "services/knowledge_service.py",
        "services/prompt_builder.py",
        "services/response_validator.py"
    ]
    
    missing_files = []
    for filepath in required_files:
        if check_file_exists(filepath):
            print_success(f"File: {filepath}")
        else:
            print_error(f"Missing file: {filepath}")
            missing_files.append(filepath)
    
    return len(missing_files) == 0, missing_files


def check_repository_layer() -> Tuple[bool, List[str]]:
    """Verify repository layer files"""
    print_header("Checking Repository Layer")
    
    required_files = [
        "repositories/__init__.py",
        "repositories/conversation_repository.py",
        "repositories/feedback_repository.py"
    ]
    
    missing_files = []
    for filepath in required_files:
        if check_file_exists(filepath):
            print_success(f"File: {filepath}")
        else:
            print_error(f"Missing file: {filepath}")
            missing_files.append(filepath)
    
    return len(missing_files) == 0, missing_files


def check_database_layer() -> Tuple[bool, List[str]]:
    """Verify database layer files"""
    print_header("Checking Database Layer")
    
    required_files = [
        "database/__init__.py",
        "database/models.py"
    ]
    
    missing_files = []
    for filepath in required_files:
        if check_file_exists(filepath):
            print_success(f"File: {filepath}")
        else:
            print_error(f"Missing file: {filepath}")
            missing_files.append(filepath)
    
    # Check for migrations
    if check_file_exists("database/migrations"):
        print_success("Directory: database/migrations/")
    else:
        print_warning("Missing migrations directory (will be created by Alembic)")
    
    return len(missing_files) == 0, missing_files


def check_schemas() -> Tuple[bool, List[str]]:
    """Verify schema files"""
    print_header("Checking Schemas")
    
    required_files = [
        "schemas/__init__.py",
        "schemas/request.py",
        "schemas/response.py"
    ]
    
    missing_files = []
    for filepath in required_files:
        if check_file_exists(filepath):
            print_success(f"File: {filepath}")
        else:
            print_error(f"Missing file: {filepath}")
            missing_files.append(filepath)
    
    return len(missing_files) == 0, missing_files


def check_utilities() -> Tuple[bool, List[str]]:
    """Verify utility files"""
    print_header("Checking Utilities")
    
    required_files = [
        "utils/__init__.py",
        "utils/exceptions.py",
        "utils/logger.py",
        "utils/helpers.py",
        "utils/constants.py",
        "utils/security.py",
        "utils/performance.py"
    ]
    
    missing_files = []
    for filepath in required_files:
        if check_file_exists(filepath):
            print_success(f"File: {filepath}")
        else:
            print_error(f"Missing file: {filepath}")
            missing_files.append(filepath)
    
    return len(missing_files) == 0, missing_files


def check_tests() -> Tuple[bool, List[str]]:
    """Verify test files"""
    print_header("Checking Tests")
    
    required_files = [
        "tests/__init__.py",
        "tests/conftest.py",
        "tests/test_services.py",
        "tests/test_routes.py",
        "tests/test_llm_service.py",
        "tests/test_knowledge_service.py",
        "tests/test_prompt_builder.py",
        "tests/test_response_validator.py",
        "tests/test_integration.py",
        "tests/test_utils.py"
    ]
    
    missing_files = []
    for filepath in required_files:
        if check_file_exists(filepath):
            print_success(f"File: {filepath}")
        else:
            print_error(f"Missing file: {filepath}")
            missing_files.append(filepath)
    
    return len(missing_files) == 0, missing_files


def check_documentation() -> Tuple[bool, List[str]]:
    """Verify documentation files"""
    print_header("Checking Documentation")
    
    required_files = [
        "README.md",
        "AI_IMPLEMENTATION.md",
        "EXAMPLES.md",
        "QUICK_START.md",
        "VERIFICATION_CHECKLIST.md"
    ]
    
    missing_files = []
    for filepath in required_files:
        if check_file_exists(filepath):
            print_success(f"File: {filepath}")
        else:
            print_error(f"Missing file: {filepath}")
            missing_files.append(filepath)
    
    return len(missing_files) == 0, missing_files


def check_configuration() -> Tuple[bool, List[str]]:
    """Verify configuration files"""
    print_header("Checking Configuration")
    
    required_files = [
        "config/__init__.py",
        "config/settings.py"
    ]
    
    missing_files = []
    for filepath in required_files:
        if check_file_exists(filepath):
            print_success(f"File: {filepath}")
        else:
            print_error(f"Missing file: {filepath}")
            missing_files.append(filepath)
    
    return len(missing_files) == 0, missing_files


def check_docker_support() -> Tuple[bool, List[str]]:
    """Verify Docker support files"""
    print_header("Checking Docker Support")
    
    # Go to root directory
    root_files = [
        "../../../docker-compose.yml",
        "../../../.env.example",
        "../../Dockerfile",
        "../../.dockerignore"
    ]
    
    missing_files = []
    for filepath in root_files:
        if check_file_exists(filepath):
            print_success(f"File: {Path(filepath).name}")
        else:
            print_error(f"Missing file: {Path(filepath).name}")
            missing_files.append(filepath)
    
    return len(missing_files) == 0, missing_files


def check_deployment_guide() -> Tuple[bool, List[str]]:
    """Verify deployment guide"""
    print_header("Checking Deployment Guide")
    
    guide_path = "../../../DEPLOYMENT_GUIDE.md"
    
    if check_file_exists(guide_path):
        print_success("DEPLOYMENT_GUIDE.md exists")
        return True, []
    else:
        print_error("DEPLOYMENT_GUIDE.md missing")
        return False, [guide_path]


def check_imports() -> bool:
    """Check if critical imports work"""
    print_header("Checking Python Imports")
    
    try:
        # Try importing critical modules
        from ..services import chatbot_service
        print_success("Import: chatbot_service")
        
        from ..services import llm_service
        print_success("Import: llm_service")
        
        from ..services import knowledge_service
        print_success("Import: knowledge_service")
        
        from ..api import routes
        print_success("Import: routes")
        
        from ..repositories import conversation_repository
        print_success("Import: conversation_repository")
        
        from ..database import models
        print_success("Import: models")
        
        return True
        
    except ImportError as e:
        print_error(f"Import error: {str(e)}")
        return False


def print_summary(results: Dict[str, Tuple[bool, List[str]]]):
    """Print verification summary"""
    print_header("Verification Summary")
    
    total_checks = len(results)
    passed_checks = sum(1 for success, _ in results.values() if success)
    failed_checks = total_checks - passed_checks
    
    print(f"\nTotal Checks: {total_checks}")
    print(f"{GREEN}Passed: {passed_checks}{RESET}")
    print(f"{RED}Failed: {failed_checks}{RESET}")
    
    if failed_checks > 0:
        print(f"\n{RED}❌ Verification FAILED{RESET}")
        print("\nMissing components:")
        for check_name, (success, missing) in results.items():
            if not success:
                print(f"\n{YELLOW}{check_name}:{RESET}")
                for item in missing:
                    print(f"  - {item}")
    else:
        print(f"\n{GREEN}✅ All checks PASSED!{RESET}")
        print(f"\n{GREEN}🎉 Phase 05 Part 3 is COMPLETE!{RESET}")


def main():
    """Run all verification checks"""
    print(f"\n{BLUE}{'='*60}{RESET}")
    print(f"{BLUE}Phase 05 Part 3 - Final Verification{RESET}")
    print(f"{BLUE}Medical Chatbot Module - Completion Check{RESET}")
    print(f"{BLUE}{'='*60}{RESET}")
    
    results = {}
    
    # Run all checks
    results["Directory Structure"] = check_directory_structure()
    results["API Layer"] = check_api_layer()
    results["Service Layer"] = check_service_layer()
    results["Repository Layer"] = check_repository_layer()
    results["Database Layer"] = check_database_layer()
    results["Schemas"] = check_schemas()
    results["Utilities"] = check_utilities()
    results["Tests"] = check_tests()
    results["Documentation"] = check_documentation()
    results["Configuration"] = check_configuration()
    results["Docker Support"] = check_docker_support()
    results["Deployment Guide"] = check_deployment_guide()
    
    # Check imports (doesn't return missing items)
    import_success = check_imports()
    results["Python Imports"] = (import_success, [])
    
    # Print summary
    print_summary(results)
    
    # Exit with appropriate code
    all_passed = all(success for success, _ in results.values())
    sys.exit(0 if all_passed else 1)


if __name__ == "__main__":
    main()
