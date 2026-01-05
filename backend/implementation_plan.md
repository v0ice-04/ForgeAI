# ForgeAI Backend - Project Generation API Implementation Plan

## Overview
This plan outlines the implementation of the `POST /api/generate` endpoint for the ForgeAI backend. The goal is to establish a clean architecture (Controller -> Service -> DTO) for handling project generation requests without database or AI integration at this stage.

## Architecture
We will follow a standard 3-layer architecture:
1.  **Controller Layer**: Handles HTTP requests, CORS, and response mapping.
2.  **Service Layer**: Contains business logic (mocked for now).
3.  **DTO Layer**: Defines data structures for API requests and responses.

## proposed Changes

### 1. Data Transfer Objects (DTOs)
Create the following classes in `com.forgeai.backend.dto`:

-   **`GenerateRequest`**
    -   `projectName` (String)
    -   `description` (String)
    -   `category` (String)
    -   `sections` (List<String>)

-   **`GenerateResponse`**
    -   `success` (boolean)
    -   `message` (String)
    -   `projectId` (String/UUID)

### 2. Service Layer
Create `GenerateService` in `com.forgeai.backend.service`:
-   Method: `generateProject(GenerateRequest request)`
-   Logic:
    -   Generate a random UUID.
    -   Return `GenerateResponse` with success=true and the generated UUID.

### 3. Controller Layer
Create `GenerateController` in `com.forgeai.backend.controller`:
-   Endpoint: `POST /api/generate`
-   Annotations: `@RestController`, `@RequestMapping("/api")`, `@CrossOrigin(origins = "*")`
-   Logic: Delegate to `GenerateService` and return the response.

### 4. Application Configuration
-   Ensure CORS is enabled globally or per controller (we will use controller-level annotation as per requirements).

## Verification Plan
1.  Start the application using `mvnw spring-boot:run`.
2.  Test `GET /` to ensure the existing "ForgeAI Backend is running" endpoint works.
3.  Test `POST /api/generate` with sample JSON payload using `curl`.
    ```json
    {
      "projectName": "ForgeAI",
      "description": "AI-powered app generator",
      "category": "Website",
      "sections": ["Home", "About", "Contact"]
    }
    ```
4.  Verify the response contains a UUID and success message.
