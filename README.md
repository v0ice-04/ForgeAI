# ForgeAI - Frontend

This is the Flutter frontend for the ForgeAI application, an AI-powered website builder.

## Project Structure

The project follows a standard feature-based directory structure inside `lib/`:

### `lib/screens/`
- **`home_screen.dart`**: The main entry point for users. Contains the form to input project details (name, category, theme).
- **`preview_screen.dart`**: The core workspace. It displays the AI chat on the left and a live `<iframe>` preview of the generated website on the right.
- **`generate_project_screen.dart`**: A simplified screen used for testing api connectivity.

### `lib/services/`
- **`api_service.dart`**: Singleton service handling low-level HTTP requests using `http` package. Manages JSON parsing and error handling.
- **`forge_service.dart`**: A wrapper service specifically for generation-related endpoints, mapping responses to strongly-typed models.

### `lib/widgets/`
- **`web_preview/`**: Contains the platform-specific implementations for the web view. Since this is a Flutter Web app, it uses `dart:ui_web` to render an `<iframe>`.

### `lib/models/`
- Contains data classes (`ProjectRequest`, `GenerationResponse`, etc.) to communicate with the backend.

## Key Features
- **Neon/Dark Theme**: Configured globally in `main.dart`.
- **Live Preview**: Uses a split-screen layout to allow real-time iteration on the generated website.
- **Job Polling**: The frontend initiates a job and then polls the backend for status updates to avoid HTTP timeouts.
