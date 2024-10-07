ARG ORG="Org-GitHub-Copilot"
ARG CLIENT_ID="Iv23lip1abgCH82FG6QQ"
ARG INSTALLATION_ID="54538407"

FROM oraclelinux:9-slim
RUN microdnf makecache
COPY secrets/gh-copilot-usage-metrics.2024-09-05.private-key.pem /key.pem
COPY generate_jwt.sh /
RUN microdnf install openssl git jq

ARG ORG
ENV ORG=${ORG}
ARG CLIENT_ID
ENV CLIENT_ID=${CLIENT_ID}
ARG INSTALLATION_ID
ENV INSTALLATION_ID=${INSTALLATION_ID}
# RUN git clone https://github.com/asmild/copilot-metrics-exporter

RUN export JWT=$(./generate_jwt.sh key.pem $CLIENT_ID 600|tail -1)
RUN export TOKEN=$(curl -s -X POST -H "Authorization: Bearer $JWT" -H "Accept: application/vnd.github.v3+json" https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens|jq '.token'|tr -d \")
RUN curl \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/orgs/${ORG}/copilot/usage