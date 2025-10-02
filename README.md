# 🚏 Tranzit

Tranzit is a smart transit booking platform that allows users to book tickets, verify them via QR codes, and manage travel seamlessly.  
It consists of a Flutter-based mobile app and a TypeScript backend powered by Cloud Run and Cloud SQL.

---

## ✨ Features

### Mobile App (Flutter)
- 🔐 **Firebase Authentication** (Email/Phone/Google login)
- 📲 **Intuitive booking flow** with clean UI
- 🎟️ **Ticket booking** with QR code generation & verification
- 🔔 **Push notifications** via Firebase Cloud Messaging
- 🗣️ **AI-powered voice ticket booking** (Vertex AI integration)
- 🌐 **Runs on Android & iOS**

### Backend (TypeScript + Node.js)
- 🛠️ **Built with TypeScript + Express**
- 📦 **Prisma ORM with PostgreSQL** (Cloud SQL)
- 🔑 **Role-based access** (Admin, User, Service Desk)
- 🚀 **Deployed on Google Cloud Run**
- 🧠 **Text embeddings** (Gemini / Vertex AI) for intelligent query processing
- ✅ **REST APIs** for ticket booking, QR validation, and user management

---

## 🛠️ Tech Stack

### Frontend (Mobile App)
- Flutter
- Dart
- Firebase Auth & FCM
- QR Code integration (`qr_flutter`)

### Backend
- Node.js + TypeScript
- Express.js
- Prisma ORM
- PostgreSQL (Cloud SQL)
- Google Cloud Run
- Vertex AI / Gemini APIs

---

## 📁 Project Structure
tranzit/
  - tranzit-app/                # Flutter mobile app
      - lib/                    # Dart source code
      - pubspec.yaml            # Flutter dependencies
  
  - tranzit-ts-backend/         # TypeScript backend
      - src/
          - controller/         # API controllers
          - services/           # Business logic
          - repository/         # DB access via Prisma
          - utils/              # Helper functions
      - prisma/                 # Prisma schema & migrations
      - package.json
      - tsconfig.json
  
  - README.md

---

## 📸 Architecture

<img width="1217" height="1216" alt="Image" src="https://github.com/user-attachments/assets/4a82e013-27f4-483f-85b2-d24e30e961aa" />

---

## 📸 ScreenShots
<p align="center">
  <img width="45%" alt="Screenshot 1" src="https://github.com/user-attachments/assets/910013d7-4193-4083-8432-8f73a96e4e84" />
  &nbsp;&nbsp;&nbsp;
  <img width="45%" alt="Screenshot 2" src="https://github.com/user-attachments/assets/b94287cf-bcd2-483b-80f0-4bd9d7a73716" />
</p>
<p align="center">
  <img width="45%" alt="Screenshot 3" src="https://github.com/user-attachments/assets/41f0c45a-e44b-4247-8c20-1b6a115642c9" />
  &nbsp;&nbsp;&nbsp;
  <img width="45%" alt="Screenshot 4" src="https://github.com/user-attachments/assets/2cde0ccb-400a-48fb-8104-386b55f46158" />
</p>
<p align="center">
  <img width="45%" alt="Screenshot 5" src="https://github.com/user-attachments/assets/03e8387e-8bdb-43da-9c96-0623c9e1a274" />
   &nbsp;&nbsp;&nbsp;
 <img width="45%"  alt="Screenshot 6" src="https://github.com/user-attachments/assets/d5547d9e-df48-434c-891b-5138da390dfb" />
</p>

---


