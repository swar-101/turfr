# Project Structure and Best Practices

This Flutter project follows a feature-based structure for maintainability and scalability, especially with Riverpod state management.

## /lib Structure

- **core/**: Shared utilities, base models, constants, etc.
- **features/**: Each feature has its own folder, organized as follows:
  - **data/**: Repositories, models, data sources
  - **domain/**: Business logic, use cases
  - **presentation/**: UI widgets, screens
  - **providers/**: Riverpod providers for state management
- **main.dart**: App entry point, global providers setup

## Example Feature Structure

```
features/
  auth/
    data/
    domain/
    presentation/
    providers/
  feed/
    data/
    domain/
    presentation/
    providers/
  update/
    data/
    domain/
    presentation/
    providers/
```

## Riverpod Best Practices
- Place providers in the providers/ folder for each feature.
- Keep UI, business logic, and data layers separate.
- Use core/ for shared code.

## How to Add a New Feature
1. Create a new folder in features/.
2. Add data/, domain/, presentation/, and providers/ subfolders.
3. Place files in the appropriate layer.

---
This structure makes it easy to maintain, test, and extend your app.

