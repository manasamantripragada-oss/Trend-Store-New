FROM nginx:alphine
COPY dist/ /usr/share/nginx/html
EXPOSE 80