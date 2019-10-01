FROM gcr.io/google-containers/startup-script:v2

LABEL maintainer="YuriAstrakhan@gmail.com"

RUN apt-get update \
    && apt-get install -y \
        jq \
    && rm -rf /var/lib/apt/lists/*

COPY init_raid.sh .

ENV STARTUP_SCRIPT="source init_raid.sh"
