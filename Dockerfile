
# ---------- Stage 1: Builder ----------
# Node.js image (pinned tag) used only to build the site
FROM node:22-alpine AS builder

# Set working directory inside the container
WORKDIR /app

# Copy package files first so the npm ci layer is cached
COPY package*.json ./

# Install exact dependency versions from package-lock.json
RUN npm ci

# Copy website source and styles
COPY src/ ./src/
COPY styles/ ./styles/

# Build static pages into /app/dist
RUN npm run build

# ---------- Stage 2: Runtime ----------
# Small Nginx image (pinned tag) to serve the static files
FROM nginx:1.27-alpine

# Copy only the built files from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Nginx listens on port 80
EXPOSE 80

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]