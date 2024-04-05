################################################################################
# builder
################################################################################
FROM node:18.19.0 as builder

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    ts-node \
    tzdata

WORKDIR /npm/
RUN npm install -g typescript ts-node
COPY ./package*.json /npm/
RUN npm install

################################################################################
# development
################################################################################
FROM node:18.19.0 as dev

COPY --from=builder /usr/bin /usr/bin
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /usr/share /usr/share
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /npm/node_modules /workspace/node_modules

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    ca-certificates \
    git

RUN git config --global --add safe.directory /workspace

################################################################################
# testing
################################################################################
FROM node:18.19.0 as test

ENV TZ Asia/Tokyo

COPY --from=builder /usr/bin /usr/bin
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /usr/share /usr/share
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /npm/node_modules /app/node_modules
RUN npm install --save-dev jest ts-jest @types/jest typescript

COPY ./app/src /app/src
COPY ./app/assets /app/assets
COPY ./app/test /app/test
CMD ["npm", "test"]

################################################################################
# production
################################################################################
FROM node:18.19.0 as prod

ENV TZ Asia/Tokyo

COPY --from=builder /usr/bin /usr/bin
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /usr/share /usr/share
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /npm/node_modules /app/node_modules

WORKDIR /app/
COPY ./app/src /app/src
COPY ./app/assets /app/assets
CMD ["echo", "app is running correctly."]
