# Gunakan image Node.js versi LTS
FROM node:lts-buster-slim

# Tentukan working directory di dalam container
WORKDIR /app

# Salin file package.json dan package-lock.json ke dalam container
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Tambahkan variabel lingkungan untuk mengatasi error OpenSSL
ENV NODE_OPTIONS=--openssl-legacy-provider

# Salin seluruh isi folder proyek ke dalam container
COPY . .

# Bangun aplikasi React
RUN npm run build

# Jalankan aplikasi React menggunakan server statis
CMD ["npx", "serve", "-s", "build", "-l", "3000"]

# Expose port untuk aplikasi
EXPOSE 3000
