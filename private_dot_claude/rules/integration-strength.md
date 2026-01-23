# Integration Strength

Integration Strength is a coupling framework from Vlad Khononov's "Balancing Coupling in Software Design". Use this for design decisions and code reviews.

## Three Dimensions of Coupling

| Dimension | Description | Goal |
|-----------|-------------|------|
| **Strength** | Amount of knowledge shared between modules | Minimize |
| **Distance** | Physical, organizational, ownership boundaries | Consider context |
| **Volatility** | How frequently modules change | Isolate volatile parts |

Higher strength + longer distance + higher volatility = higher risk of cascading changes.

## Four Levels of Integration Strength

From strongest (worst) to weakest (best):

### 1. Intrusive Coupling (Avoid)

Integration through private interfaces or implementation details.

```python
# BAD: Accessing private implementation
class OrderService:
    def process(self, cart: ShoppingCart):
        # Directly accessing internal state
        items = cart._items  # Private!
        total = cart._calculate_subtotal()  # Private method!
```

**Problems**: Breaks encapsulation, highly sensitive to upstream changes.

### 2. Functional Coupling (Minimize)

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

**Problems**: Changes require updates in multiple places, easy to get out of sync.

### 3. Model Coupling (Acceptable with caution)

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

**Problems**: Model changes cascade to all consumers.

### 4. Contract Coupling (Preferred)

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

**Benefits**: Internal model can evolve independently, minimal knowledge sharing.

## Design Guidelines

### When Writing Code

1. **Default to Contract Coupling**
   - Create DTOs/contracts for module boundaries
   - Keep internal models private

2. **Identify Integration Boundaries**
   - Between layers (API ↔ Domain ↔ Infrastructure)
   - Between modules/services
   - Between your code and external systems

3. **Apply "Model of a Model" Principle**
   - Contract should expose only what consumers need
   - Hide implementation details

4. **Consider Volatility**
   - Stable interfaces for volatile implementations
   - Put abstractions between you and things that change

### Connascence Quick Reference

Static connascence (compile-time, easier to manage):
- **Name**: Components must agree on names
- **Type**: Components must agree on types
- **Meaning**: Components must agree on value interpretation
- **Position**: Components must agree on order (avoid with named args/structs)
- **Algorithm**: Components must agree on algorithm

Dynamic connascence (runtime, harder to manage):
- **Execution**: Operations must occur in specific order
- **Timing**: Operations must occur at specific times
- **Values**: Values must be coordinated
- **Identity**: Must reference same instance (most problematic)

**Rule**: Prefer static over dynamic. Lower connascence is better.

## Code Review Checklist

When reviewing code, check for:

- [ ] **Intrusive coupling**: Accessing private members or implementation details?
- [ ] **Functional duplication**: Same logic implemented in multiple places?
- [ ] **Model leakage**: Internal models exposed at boundaries?
- [ ] **Missing contracts**: Direct model sharing where DTOs would be better?
- [ ] **High connascence**: Position-dependent code? Shared mutable state?
- [ ] **Volatility isolation**: Are stable parts protected from volatile parts?

### Questions to Ask

1. "If the upstream module changes internally, will this code break?"
2. "How much does this module need to know about its dependencies?"
3. "Is this coupling at the appropriate boundary?"
4. "Could we reduce shared knowledge with a contract?"
