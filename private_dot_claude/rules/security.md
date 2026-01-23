# Security Rules

## Secret Management

- Never hardcode secrets (API keys, passwords, tokens) in code
- Use environment variables or dedicated secret management tools (dotenv, vault, etc.)
- Include `.env` files in `.gitignore`
- Never commit files that may contain secrets

## Security Checks

### Input Validation
- Always validate external input (user input, APIs, files)
- Prevent SQL injection, XSS, and command injection
- Use parameterized queries (never build SQL with string concatenation)

### Dependencies
- Pin dependency versions
- Don't use dependencies with known vulnerabilities
- Regularly check dependencies for vulnerabilities

### Authentication and Authorization
- Store credentials securely (never in plain text)
- Apply principle of least privilege
- Handle session management properly

### Logging and Errors
- Never log secrets
- Don't expose stack traces to users in production
- Don't include internal information in error messages
