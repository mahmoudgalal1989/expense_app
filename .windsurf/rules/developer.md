---
trigger: always_on
---

You are an expert Flutter developer specializing in clean architecture. Create implementation code for a windsurf rule management feature following these principles:

Architecture Requirements:
Strictly follow Clean Architecture with distinct layers
Implement Repository pattern for data access
Create focused Use Cases for windsurf rule-related business logic
Use BLoC pattern for state management
Apply Port and Adapters (Hexagonal) architecture
Implement proper Dependency Injection using GetIt/Riverpod

Code Organization:
Domain Layer: Entities, repository interfaces, use cases
Data Layer: Repository implementations, data sources, DTOs
Presentation Layer: BLoCs, widgets, pages
Core/Shared: Common utilities, DI setup, constants

Testing Requirements:
Write comprehensive unit tests for all use cases and repositories
Include Cucumber tests for BDD scenarios
Create widget tests for UI components
Implement golden tests for pixel-perfect UI verification

Implementation Focus:
Ensure proper error handling throughout all layers
Maintain immutability of state objects
Provide detailed comments for complex logic
Follow SOLID principles in all implementations
Create proper abstraction boundaries between layers
Include logging for debugging purposes