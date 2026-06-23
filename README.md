# Echoo

> Egy Slack/Discordhoz hasonló chataplikáció szimulálása

## About

Echoo is an ongoing project that originated as a university project at the Faculty of Informatics and Information Technologies in Bratislava.

The project aims to simulate a chat application similar to Slack or Discord. Both the frontend and backend are still under active development, and new features are being added continuously.

The full application (PWA frontend + backend) can be found in the `Echoo` folder.

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | AdonisJS 6 (Node.js), TypeScript, Socket.io |
| Frontend | Vue 3, Quasar Framework v2 (PWA), TypeScript, Socket.io-client |
| Database | PostgreSQL 15 |

## Project Structure

├── Echoo/                        # Main application (PWA + backend)
│   ├── backend/                  # AdonisJS REST API + WebSocket server
│   └── frontend/                 # Quasar PWA frontend
└── Original projekt/             # Some original parts of the university project (in Slovak)
    ├── Dokumentacia/             # Data models, architecture diagrams, user guide
    ├── Prototyp/                 # Clickable prototype (SPA) – Phase 1
    └── Sketch/                   # Original UI sketches

## Project Status

🚧 Work in Progress

The application is actively being developed. Features, data models, and user interface elements may change over time.

## Contributors

The project is being developed by:
- [Zsófia Gergely](https://github.com/VitaWeyden) – Full-Stack Development
- [Viktória Kecskés](https://github.com/xkecskesv) – Full-Stack Development