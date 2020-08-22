# added the builder as the stage name to be referrenced in the future
FROM node:alpine as builder
WORKDIR '/app'
COPY package.json .
RUN npm install
COPY . .
RUN npm run build
# This will build out all the assets and put it in the /build folder


FROM nginx
# --from stagename
# nginx is defaulted to serve the folder /urs/share/nginx/html
COPY --from=builder /app/build /usr/share/nginx/html
# The nginx container will automatically start up nginx for us
# so we don't need to start it explictly