# Coding Style Rules

## Comments

- Express "what" through code itself
- Comments should explain "why" the code is needed (context not evident from code)
- If you need to name and explain logic, extract it into a function for encapsulation

## Connascence

Design to minimize connascence.

### Return Values
- When multiple return values are needed, use structs (dataclass, etc.) instead of position-dependent tuples
- Lower connascence from "position" to "type"

### Arguments
- For functions with multiple arguments, prefer named arguments over positional
- Lower connascence from "position" to "name"

## Functional Style

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
- **Argument types**: Use minimal abstract types needed for processing (`collections.abc.Sequence` over `list`, `collections.abc.Mapping` over `dict`, etc.)
- **Return types**: Use concrete types (exception: when you want to constrain caller's type for loose coupling)

### Docstrings
- Write docstrings for public functions, classes, and modules (PEP257)
- When modifying function signatures (arguments, return types, exceptions), always update the corresponding docstring
- Keep docstrings in sync with the actual implementation

### Code Style
- Use comprehensions (simple, traceable, good performance)
- `functools` and `itertools` are allowed
- Prioritize readability and performance over excessive functional features

### Validation and Domain Models
- **Boundary layer validation**: Use pydantic with `frozen=True`
- **Domain models**: Use `dataclasses.dataclass` with `frozen=True`
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

### Directory Structure
- Each experiment in `src/exp/exp000/`, `src/exp/exp001/`, etc.
- Share common utilities in `src/exp/common/` or `src/lib/`

### Basic Principles
- Prioritize experiment iteration speed over code robustness
- Focus on discovery
- Keep it simple, but allow performance optimization when needed
- Some code messiness is acceptable
- **Avoid copy-paste bloat**: Extract shared logic early

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
- **Boolean flags**: `--flag` (True) / `--no-flag` (False)
- **Lists**: Use space-separated values, NOT comma-separated

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

**tyro gotchas:**
- Lists use space separation: `--items a b c` → `["a", "b", "c"]`
- Tuple defaults for mutable: use `tuple` not `list` for default values
- Nested configs: use `tyro.conf.FlagConversionOff` if bool conversion causes issues

### Train/Inference Consistency
- **Shared preprocessing**: Extract to common module, use same function for train and inference
- **Allowed differences**: Batch size, dropout disabled, augmentation off
- **Must be identical**: Feature extraction, normalization params, tokenization

```python
# Good: shared preprocessing
from exp.common.preprocess import preprocess_input

# train.py
data = preprocess_input(raw_data, augment=True)

# inference.py
data = preprocess_input(raw_data, augment=False)
```

```python
# Bad: duplicated logic that can drift
# train.py
data = normalize(raw_data, mean=0.5, std=0.2)

# inference.py
data = normalize(raw_data, mean=0.5, std=0.25)  # Bug: different std!
```
