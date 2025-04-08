FROM debian:bookworm-slim

ARG SCRIPT_NAME="my_script.py"
ENV SCRIPT_NAME=$SCRIPT_NAME

RUN apt-get update -y \
  && apt-get install -y python3-pip curl unzip python3.11-venv \
  && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install

RUN useradd --create-home --shell /bin/bash runner

USER runner

WORKDIR /home/runner

COPY src/$SCRIPT_NAME .
COPY src/requirements.txt .
COPY entrypoint.sh .
USER root
RUN chmod +x /home/runner/entrypoint.sh
USER runner

RUN python3 -m venv venv \
  && venv/bin/pip install -r requirements.txt

ENTRYPOINT [ "/bin/sh", "/home/runner/entrypoint.sh" ]
CMD ["--help"]
