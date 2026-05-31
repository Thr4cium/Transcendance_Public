# 🏓 transcendence

A modern, secure multiplayer Pong game with real-time features, built as part of the 42 school curriculum.

## 🏓 transcendence — Overview

Transcendence is a modern multiplayer Pong game with real-time features, designed to be secure and modular (microservices). This README provides everything needed to run the project locally, understand the architecture, and contribute.

## 🚀 Quick start

1. Clone the repository and change into the project directory:

```bash
git clone https://github.com/maxenceguy/transcendence.git
cd transcendence
```

2. Copy the environment example and fill in the secrets:

```bash
cp .env.example .env
# Edit .env and generate secure secrets if needed:
# openssl rand -base64 32
```

3. Generate the SSL certificates (script provided):

```bash
./generate-certs.sh
```

4. Start the services with Docker Compose:

```bash
docker compose up -d --build
```

5. Access the application:

https://localhost:8443

> External access port (nginx reverse proxy): 8443 (docker-compose maps 8443:443)


## 🏗️ Architecture

Simplified diagram of components and ports (default values used by docker-compose / services):

```
            [host:8443] ←── HTTPS ── nginx (container:443)
                                       │
                                       ▼
                              gateway :3000
                                       │
        ┌──────────────┬───────────────┼──────────────┬──────────────┐
        │              │               │              │              │
 auth-service   user-service   matchmaking   chat-service   game-server
        :3001         :3002           :3003         :3004         :3005

 frontend (Vite dev) :5173  ←─── nginx reverse-proxy for SPA
```

Important points:
- External access is handled by the Nginx reverse proxy exposed on host port 8443 (docker-compose maps 8443:443).
- The gateway (API gateway) listens by default on port 3000 and proxies all APIs to the internal services.
- The microservices ports (3001..3005) are defaults and can be configured via environment variables.


## 📁 Repository structure

Root:

```
transcendence/
├── auth-service/         # Auth (JWT, 2FA, OAuth)
├── user-service/         # Profiles, avatars, user data
├── chat-service/         # WebSocket / real-time chat
├── matchmaking-service/  # Matchmaking & tournaments
├── gateway/              # Fastify reverse-proxy / auth middleware
├── frontend/             # Vite + TypeScript SPA
├── server/               # Game server (Pong game logic)
├── nginx/                # Reverse-proxy configuration
└── docker-compose.yml
```


## 🔧 Exposed Ports (Main)

- Host → Container
    - 8443:443 (nginx HTTPS)
    - 8080:80  (nginx HTTP redirection)
    - 3000:3000 (gateway - local access enabled)

- Internal ports (default in services) :
    - auth-service : 3001
    - user-service : 3002
    - matchmaking-service : 3003
    - chat-service : 3004
    - game-server : 3005
    - frontend (Vite) : 5173



## 🔐 Security & Best Practices

- Authentication via JWT (access + refresh), with refresh token rotation.
- 2FA (TOTP) available in the `auth-service`.
- Rate limiting and protection of authentication endpoints.
- Secure cookies (HttpOnly, Secure, SameSite) for tokens.



## ⚙️ Environment Variables

Copy `.env.example` → `.env` and fill in the critical variables:

- JWT_SECRET, JWT_REFRESH_SECRET, JWT_CHALLENGE_SECRET
- SERVICE_TOKEN (for inter-service communication)
- FRONTEND_URL (default: https://localhost:8443)

Generate strong secrets:

```bash
openssl rand -base64 32
```



## 🛠️ Useful Development Commands

Show logs:

```bash
docker compose logs -f <service-name>
```

Rebuild a service:

```bash
docker compose build <service-name> --no-cache
```

Stop and remove containers:

```bash
docker compose down
```

## 👥 Contributors

- [maxenceguy](https://github.com/maxenceguy)
- [mojosama](https://github.com/mojosama)
- [Thr4cium](https://github.com/Thr4cium)
- [toji-42](https://github.com/toji-42)


---
