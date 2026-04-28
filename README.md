# 🏋️‍♂️ Be Fit Real - AI Fitness Club

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Gemini AI](https://img.shields.io/badge/Google%20Gemini-8E75B2?style=for-the-badge&logo=google&logoColor=white)

**Be Fit Real** es un "club digital privado" desarrollado como Proyecto de Fin de Ciclo (DAM). La aplicación fusiona el entrenamiento personal exclusivo con el poder de la Inteligencia Artificial (Google Gemini), generando rutinas hiper-personalizadas basadas en el equipamiento real del usuario y sus lesiones.

---

## ✨ Características Principales

* 🔒 **Acceso Exclusivo:** Sistema de registro blindado mediante Códigos de Invitación validados en tiempo real contra Firestore.
* 🤖 **Entrenador IA:** Integración con *Google Gemini 2.5 Flash* a través de *Prompt Engineering* para generar rutinas formateadas dinámicamente.
* 📦 **Gestor de Inventario:** Panel de Administración (CRUD) para que el gestor del club añada o elimine material deportivo.
* 💎 **UI/UX Premium:** Interfaz basada en *Glassmorphism* (efecto cristal) y transiciones fluidas.
* 🛡️ **Tolerancia a fallos:** Sanitizador automático de expresiones regulares (RegExp) para corregir alucinaciones de formato de la IA y gestión de Error 503 (Saturación de servidores).

---

## 🛠️ Arquitectura y Tecnologías

* **Frontend:** Flutter & Dart (Arquitectura Limpia).
* **Backend (BaaS):** Firebase Auth y Cloud Firestore (NoSQL).
* **IA:** Google Generative AI API.
* **Seguridad:** Gestión de credenciales locales con `flutter_dotenv`.
* **Testing:** Suite de 11 pruebas (Unit Test & Widget Test).

---

## 🚀 Manual de Instalación y Configuración

Sigue estos pasos para compilar y ejecutar el proyecto en un entorno local:

### 1. Requisitos Previos
* SDK de Flutter instalado (v3.2.0 o superior).
* Emulador de Android/iOS o dispositivo físico conectado.

### 2. Clonar el repositorio
```bash
git clone [https://github.com/JesusMartinRobles/be_fit_real_dam.git](https://github.com/JesusMartinRobles/be_fit_real_dam.git)
cd be_fit_real_dam
```

### 3. Configuración Crítica (Variables de Entorno)
Por motivos de seguridad, la clave de la IA no está subida al repositorio. Debes crear un archivo llamado `.env` en la **raíz del proyecto** con la siguiente estructura:

```env
GEMINI_API_KEY=AIzaSyA_TU_CLAVE_AQUI
```

### 4. Instalación de dependencias y ejecución
```bash
flutter clean
flutter pub get
flutter run
```

---

## 🧪 Entorno de Pruebas (Credenciales)

Para evaluar el proyecto, puedes utilizar los siguientes datos de acceso de prueba:

* **Administrador (Gestión de club):** `admin@befit.com` / `123456`
* **Atleta (Usuario estándar):** `test1@befit.com` / `123456`
* **Código de Invitación (Para nuevos registros):** `DAM_PROYECTO`

### Ejecución de la Batería de Pruebas
Para comprobar la integridad de los modelos de datos y la interfaz, ejecuta:
```bash
flutter test
```

---

## 👤 Autor
**Jesús Martín Robles** - Estudiante de Desarrollo de Aplicaciones Multiplataforma (DAM) - 2026.