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

# Jalankan aplikasi React
CMD ["npm", "start"]

# Expose port untuk aplikasi
EXPOSE 3000
