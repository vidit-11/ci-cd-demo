# === Build Stage ===
FROM node:20-alpine AS builder
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --prefer-offline --no-audit

COPY . .
RUN npm run build

# === Runtime Stage ===
FROM nginxinc/nginx-unprivileged:alpine AS runtime
WORKDIR /usr/share/nginx/html

# Clear default assets
RUN rm -rf ./*

# Copy assets from builder
COPY --from=builder /app/dist .

# Switch to root just to configure, then back to nginx
USER root

RUN printf 'server {\n\
    listen 8080;\n\
    server_name _;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
    location ~* \.(?:ico|css|js|gif|jpe?g|png|woff2?|eot|ttf|svg)$ {\n\
        expires 6M;\n\
        access_log off;\n\
        add_header Cache-Control "public";\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf && \
chown nginx:nginx /etc/nginx/conf.d/default.conf

USER nginx

EXPOSE 8080

HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -q -O - http://localhost:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
