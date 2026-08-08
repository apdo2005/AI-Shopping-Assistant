<<<<<<< HEAD
# 🛒 AI Shopping Assistant

An intelligent e-commerce mobile application built with **Flutter** that enhances the online shopping experience by integrating **Generative AI** into product discovery and purchasing decisions.

---

## 📖 Project Overview
Instead of browsing hundreds of products manually, users can describe their needs in natural language, and the AI recommends the most suitable products available in the store. The project is designed with robust state management and strict adherence to **Clean Architecture**.

## 🎯 Objectives
- Develop a modern, high-performance e-commerce mobile application.
- Implement secure authentication and user management.
- Integrate AI-powered product recommendations seamlessly.
- Provide a personalized and intuitive shopping experience.
- Demonstrate advanced AI integration (Gemini/Genkit) within Flutter applications.

## ✨ Main Features
- **User Authentication:** Secure login and registration.
- **Product Discovery:** Comprehensive Product Catalog, Categories, Search, and Filters.
- **Shopping Experience:** Product Details, Shopping Cart, Wishlist, and Order Management.
- **User Engagement:** User Profile, Product Reviews, and Order History.

## 🤖 AI Features (Powered by Gemini)
The core differentiator of this application is the AI-driven search and recommendation engine. Users can input natural language queries such as:
- *"Recommend a gaming laptop under $1000."*
- *"Find the best smartphone for photography."*
- *"Suggest gifts for a software engineer."*

**How it works:** The AI analyzes product information, cross-references it with user queries, and recommends the most suitable options accompanied by clear explanations for *why* the product fits the user's needs.

## 🛠 Technologies & Architecture

### **Frontend**
- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** BLoC (Business Logic Component)
- **Network Interface:** Dio
- **Architecture:** Clean Architecture (Domain, Data, Presentation layers)

### **Backend & AI**
- **Authentication:** Firebase Authentication
- **Database:** Supabase / Firestore
- **Storage:** Firebase Storage
- **AI Integration:** Firebase Genkit & Gemini AI

---

## 🏗️ Architecture Overview (Clean Architecture)
This project strictly follows Clean Architecture principles to ensure scalability, maintainability, and testability.
```text
lib/
 ├── core/              # Core functionality, errors, network, utils
 ├── features/          # Feature-based folder structure
 │    ├── auth/         # Domain, Data, and Presentation for Authentication
 │    ├── ai_search/    # AI Integration and Chat/Search interface
 │    ├── products/     # Product catalog and details
 │    ├── cart/         # Shopping cart logic
 │    └── profile/      # User management
 └── main.dart          # Entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest stable version)
- Dart SDK
- Firebase CLI & Configured Firebase Project
- Supabase Account (if used as the primary database)
- Gemini API Key / Firebase Genkit setup

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/ai-shopping-assistant.git
   ```
2. Navigate to the project directory:
   ```bash
   cd ai-shopping-assistant
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

---
*Developed as a Graduation Project for ITI (Information Technology Institute).*
=======
# ai_shopping_assistant

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
>>>>>>> 2c984e4 (home screen first work)
