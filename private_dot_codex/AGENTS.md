# Global Rules

These are global rules for Codex. Follow them unless explicitly overridden.
Source of truth: mirrored from `private_dot_claude/rules/`.
Skills are mirrored under `private_dot_codex/skills/`.

## Coding Style Rules

### Comments
- Express "what" through code itself
- Comments should explain "why" the code is needed (context not evident from code)
- If you need to name and explain logic, extract it into a function for encapsulation

### Connascence
Design to minimize connascence.

#### Return Values
- When multiple return values are needed, use structs (dataclass, etc.) instead of position-dependent tuples
- Lower connascence from "position" to "type"

#### Arguments
- For functions with multiple arguments, prefer named arguments over positional
- Lower connascence from "position" to "name"

### Functional Style
- Prefer immutable (minimize side effects)
- Prioritize generating new values over mutating state

---

## Python: Production Implementation

### Basic Principles
- Assume Python 3.12+
- Follow PEP style guides (PEP8, PEP257, etc.)
- Use type hints actively

### Type Hints
- Follow PEP585: Use built-in generics (`list[int]`, `dict[str, int]`) instead of `typing` module equivalents (`List[int]`, `Dict[str, int]`)
- Use constructors where possible (type annotations are sufficient, no need for factories like `list[int]()`) 
- Argument types: Use minimal abstract types needed for processing (`collections.abc.Sequence` over `list`, `collections.abc.Mapping` over `dict`, etc.)
- Return types: Use concrete types (exception: when you want to constrain caller's type for loose coupling)

### Docstrings
- Write docstrings for public functions, classes, and modules (PEP257)
- When modifying function signatures (arguments, return types, exceptions), always update the corresponding docstring
- Keep docstrings in sync with the actual implementation

### Code Style
- Use comprehensions (simple, traceable, good performance)
- `functools` and `itertools` are allowed
- Prioritize readability and performance over excessive functional features

### Validation and Domain Models
- Boundary layer validation: Use pydantic with `frozen=True`
- Domain models: Use `dataclasses.dataclass` with `frozen=True`
- After validation, use DTO functions like `to_<domain_model>()` to convert to domain models

```python
# Example
from pydantic import BaseModel
from dataclasses import dataclass

class UserInput(BaseModel, frozen=True):
    name: str
    email: str

@dataclass(frozen=True)
class User:
    name: str
    email: str

def to_user(input: UserInput) -> User:
    return User(name=input.name, email=input.email)
```

---

## Python: Machine Learning Experiments

Rules for ML experiments (e.g., under `src/exp/`).

### Experiment Iteration Philosophy

ML experiments follow a hypothesis-driven iteration cycle:

```
EDA -> Hypothesis -> Experiment -> Logging -> Analysis/Discussion -> (Additional Analysis) -> Hypothesis -> ...
```

Core principles:
- Every experiment starts with a hypothesis derived from prior learnings
- Results are documented in `README.md` within each experiment directory
- Before starting a new experiment, read related experiment READMEs to inform decisions
- Analysis leads to next hypotheses, not just conclusions

README.md structure for each experiment:
```markdown
# exp003: [Experiment Title]

## Background / Related Experiments
- exp001: [Key learnings]
- exp002: [Key learnings]

## Hypothesis
- What we expect and why

## Experiment Design
- What we're testing
- Variables changed

## Results
- Metrics, observations

## Analysis / Discussion
- Interpretation of results
- Why did this happen?

## Next Actions
- Follow-up experiments
- New hypotheses
```

### Directory Structure
- Each experiment in `src/exp/exp000/`, `src/exp/exp001/`, etc.
- Share common utilities in `src/exp/common/` or `src/lib/`
- Each experiment has its own `README.md`

### Basic Principles
- Prioritize experiment iteration speed over code robustness
- Focus on discovery
- Keep it simple, but allow performance optimization when needed
- Some code messiness is acceptable
- Avoid copy-paste bloat: Extract shared logic early

### Error Handling
- Don't use exception handling
- Crash immediately on invalid state (Fail Fast)

### Configuration Management
- Centralize experiment config in a dataclass named `Config`
- Map to dedicated dataclasses for arguments needed by each module/class

```python
@dataclass
class Config:
    learning_rate: float
    batch_size: int
    model_name: str

@dataclass
class TrainerConfig:
    learning_rate: float
    batch_size: int
```

### CLI with tyro
- Use tyro when available
- Boolean flags: `--flag` (True) / `--no-flag` (False)
- Lists: Use space-separated values, NOT comma-separated

```python
import tyro
from dataclasses import dataclass

@dataclass
class Config:
    # Boolean flag: --debug or --no-debug
    debug: bool = False

    # List: --layers 64 128 256 (NOT --layers 64,128,256)
    layers: list[int] = (64, 128)

    # Optional with None default
    checkpoint: str | None = None

config = tyro.cli(Config)
```

Tyro gotchas:
- Lists use space separation: `--items a b c` -> `["a", "b", "c"]`
- Tuple defaults for mutable: use `tuple` not `list` for default values
- Nested configs: use `tyro.conf.FlagConversionOff` if bool conversion causes issues

### Train/Inference Consistency
- Shared preprocessing: Extract to common module, use same function for train and inference
- Allowed differences: Batch size, dropout disabled, augmentation off
- Must be identical: Feature extraction, normalization params, tokenization

```python
# Good: shared preprocessing
from exp.common.preprocess import preprocess_input

# train.py
data = preprocess_input(raw_data, augment=True)

# inference.py
data = preprocess_input(raw_data, augment=False)
```

---

## Integration Strength

Integration Strength is a coupling framework from Vlad Khononov's "Balancing Coupling in Software Design". Use this for design decisions and code reviews.

### Three Dimensions of Coupling

| Dimension | Description | Goal |
|-----------|-------------|------|
| Strength | Amount of knowledge shared between modules | Minimize |
| Distance | Physical, organizational, ownership boundaries | Consider context |
| Volatility | How frequently modules change | Isolate volatile parts |

Higher strength + longer distance + higher volatility = higher risk of cascading changes.

### Four Levels of Integration Strength

From strongest (worst) to weakest (best):

#### 1. Intrusive Coupling (Avoid)

Integration through private interfaces or implementation details.

```python
# BAD: Accessing private implementation
class OrderService:
    def process(self, cart: ShoppingCart):
        # Directly accessing internal state
        items = cart._items  # Private!
        total = cart._calculate_subtotal()  # Private method!
```

Problems: Breaks encapsulation, highly sensitive to upstream changes.

#### 2. Functional Coupling (Minimize)

Sharing knowledge about functionalities across modules.

```python
# BAD: Duplicated validation logic
# frontend/validation.ts
def validate_email(email: str) -> bool:
    return "@" in email and "." in email

# backend/validation.py
def validate_email(email: str) -> bool:
    return "@" in email and "." in email  # Same logic duplicated!
```

Problems: Changes require updates in multiple places, easy to get out of sync.

#### 3. Model Coupling (Acceptable with caution)

Components share a domain model directly.

```python
# Shared domain model
@dataclass(frozen=True)
class User:
    id: str
    name: str
    email: str
    created_at: datetime

# Service A uses User directly
class UserService:
    def get_user(self, id: str) -> User: ...

# Service B also uses User directly
class NotificationService:
    def notify(self, user: User): ...  # Coupled to User model
```

Problems: Model changes cascade to all consumers.

#### 4. Contract Coupling (Preferred)

Integration through dedicated contracts that abstract internal models.

```python
# Internal domain model (rich, can change freely)
@dataclass
class User:
    id: str
    name: str
    email: str
    password_hash: str
    created_at: datetime
    settings: UserSettings

# Contract for external integration (stable, minimal)
@dataclass(frozen=True)
class UserDTO:
    id: str
    display_name: str

def to_user_dto(user: User) -> UserDTO:
    return UserDTO(id=user.id, display_name=user.name)
```

Benefits: Internal model can evolve independently, minimal knowledge sharing.

### Design Guidelines

#### When Writing Code
1. Default to Contract Coupling
   - Create DTOs/contracts for module boundaries
   - Keep internal models private

2. Identify Integration Boundaries
   - Between layers (API <-> Domain <-> Infrastructure)
   - Between modules/services
   - Between your code and external systems

3. Apply "Model of a Model" Principle
   - Contract should expose only what consumers need
   - Hide implementation details

4. Consider Volatility
   - Stable interfaces for volatile implementations
   - Put abstractions between you and things that change

### Connascence Quick Reference

Static connascence (compile-time, easier to manage):
- Name: Components must agree on names
- Type: Components must agree on types
- Meaning: Components must agree on value interpretation
- Position: Components must agree on order (avoid with named args/structs)
- Algorithm: Components must agree on algorithm

Dynamic connascence (runtime, harder to manage):
- Execution: Operations must occur in specific order
- Timing: Operations must occur at specific times
- Values: Values must be coordinated
- Identity: Must reference same instance (most problematic)

Rule: Prefer static over dynamic. Lower connascence is better.

### Code Review Checklist

- Intrusive coupling: Accessing private members or implementation details?
- Functional duplication: Same logic implemented in multiple places?
- Model leakage: Internal models exposed at boundaries?
- Missing contracts: Direct model sharing where DTOs would be better?
- High connascence: Position-dependent code? Shared mutable state?
- Volatility isolation: Are stable parts protected from volatile parts?

### Questions to Ask
1. If the upstream module changes internally, will this code break?
2. How much does this module need to know about its dependencies?
3. Is this coupling at the appropriate boundary?
4. Could we reduce shared knowledge with a contract?

---

## Security Rules

### Secret Management
- Never hardcode secrets (API keys, passwords, tokens) in code
- Use environment variables or dedicated secret management tools (dotenv, vault, etc.)
- Include `.env` files in `.gitignore`
- Never commit files that may contain secrets

### Security Checks

#### Input Validation
- Always validate external input (user input, APIs, files)
- Prevent SQL injection, XSS, and command injection
- Use parameterized queries (never build SQL with string concatenation)

#### Dependencies
- Pin dependency versions
- Don't use dependencies with known vulnerabilities
- Regularly check dependencies for vulnerabilities

#### Authentication and Authorization
- Store credentials securely (never in plain text)
- Apply principle of least privilege
- Handle session management properly

#### Logging and Errors
- Never log secrets
- Don't expose stack traces to users in production
- Don't include internal information in error messages
