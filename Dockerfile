FROM node:8-alpine as builder

ENV WORKDIR /home/app
WORKDIR $WORKDIR

RUN apk update && apk add git yarn python

COPY package.json .
COPY yarn.lock .
COPY bh bh

RUN yarn install --network-timeout 1000000

COPY . .

ARG API_BASE_URL
ARG BOTHUB_NLP_BASE_URL
ARG BOTHUB_WEBAPP_BASE_URL
ARG SUPPORTED_LANGUAGES
ARG MAILCHIMP_LOGIN
ARG MAILCHIMP_DATACENTER
ARG MAILCHIMP_USER_ID
ARG MAILCHIMP_LIST_ID
ARG VERSION_ENABLED
ARG BOTHUB_WEBAPP_USE_SENTRY
ARG BOTHUB_WEBAPP_SENTRY
ARG BOTHUB_WEBAPP_USE_HOTJAR
ARG BOTHUB_WEBAPP_HOTJAR_ID
ARG BOTHUB_WEBAPP_LIGHTHOUSE_KEY
ARG BOTHUB_WEBAPP_LIGHTHOUSE_ALGORITHM_ARTICLE_ID

ENV API_BASE_URL "${API_BASE_URL}"
ENV BOTHUB_NLP_BASE_URL "${BOTHUB_NLP_BASE_URL}"
ENV BOTHUB_WEBAPP_BASE_URL "${BOTHUB_WEBAPP_BASE_URL}"
ENV SUPPORTED_LANGUAGES "${SUPPORTED_LANGUAGES}"
ENV MAILCHIMP_LOGIN "${MAILCHIMP_LOGIN}"
ENV MAILCHIMP_DATACENTER "${MAILCHIMP_DATACENTER}"
ENV MAILCHIMP_USER_ID "${MAILCHIMP_USER_ID}"
ENV MAILCHIMP_LIST_ID "${MAILCHIMP_LIST_ID}"
ENV VERSION_ENABLED "${VERSION_ENABLED}"
ENV BOTHUB_WEBAPP_USE_SENTRY "${OTHUB_WEBAPP_USE_SENTRY}"
ENV BOTHUB_WEBAPP_SENTRY "${BOTHUB_WEBAPP_SENTRY}"
ENV BOTHUB_WEBAPP_USE_HOTJAR "${BOTHUB_WEBAPP_USE_HOTJAR}"
ENV BOTHUB_WEBAPP_HOTJAR_ID "${BOTHUB_WEBAPP_HOTJAR_ID}"
ENV BOTHUB_WEBAPP_LIGHTHOUSE_KEY "${BOTHUB_WEBAPP_LIGHTHOUSE_KEY}"
ENV BOTHUB_WEBAPP_LIGHTHOUSE_ALGORITHM_ARTICLE_ID "${BOTHUB_WEBAPP_LIGHTHOUSE_ALGORITHM_ARTICLE_ID}"

RUN yarn build

FROM nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /home/app/dist /usr/share/nginx/html/bothub-webapp
