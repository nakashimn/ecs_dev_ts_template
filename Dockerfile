################################################################################
# builder
################################################################################
FROM node:18.19.0 as builder

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    tzdata

WORKDIR /npm/
COPY ./package.json /npm/package.json
RUN npm config set prefix "/npm/"
RUN npm install --prefix "/npm/"

################################################################################
# development
################################################################################
FROM node:18.19.0 as dev

ARG GIT_USERNAME
ARG GIT_EMAIL_ADDRESS

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /npm/node_modules /npm/node_modules

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    ca-certificates \
    git

RUN npm config set prefix "/npm/"

RUN git config --global --add safe.directory /workspace
RUN git config --global user.name ${GIT_USERNAME}
RUN git config --global user.email ${GIT_EMAIL_ADDRESS}

################################################################################
# production
################################################################################
FROM node:18.19.0 as prod

ENV TZ Asia/Tokyo

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /npm/node_modules /npm/node_modules

RUN npm config set prefix "/npm/"

COPY ./app /workspace/app
CMD ["echo", "app is running correctly."]
