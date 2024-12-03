# Gunakan image Node.js versi LTS
FROM node:lts-buster-slim

# Tentukan working directory di dalam container
WORKDIR /app

# Salin file package.json dan package-lock.json ke dalam container
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Salin seluruh isi folder proyek ke dalam container
COPY . .

# Build aplikasi React
RUN npm run build

# Install serve untuk menyajikan aplikasi
RUN npm install -g serve

# Jalankan aplikasi React menggunakan serve
CMD ["serve", "-s", "build", "-l", "3000"]

# Expose port untuk aplikasi
EXPOSE 3000
