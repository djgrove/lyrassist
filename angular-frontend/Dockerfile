FROM node

RUN mkdir -p /usr/src/app
RUN npm i -g @angular/cli

WORKDIR /usr/src/app

#COPY package.json /usr/src/app
#RUN npm install

EXPOSE 4200

CMD ["ng serve --host 0.0.0.0"]