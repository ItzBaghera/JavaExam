# Usa un'immagine base leggera con Java Development Kit (JDK)
FROM eclipse-temurin:17-jdk-focal

LABEL authors="Fortu"

# Installazione di Code-Server
# Puoi trovare l'ultima versione su https://github.com/coder/code-server/releases
ARG CODE_SERVER_VERSION="4.22.0"

RUN wget https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-amd64.tar.gz -O /tmp/code-server.tar.gz \
    && tar -xzf /tmp/code-server.tar.gz -C /usr/local/lib \
    && mv /usr/local/lib/code-server-${CODE_SERVER_VERSION}-linux-amd64 /usr/local/lib/code-server \
    && rm /tmp/code-server.tar.gz

# Variabili d'ambiente per Code-Server
ENV SHELL=/bin/bash
ENV PATH="/usr/local/lib/code-server/bin:${PATH}"

# Installazione di estensioni VS Code essenziali per Java
RUN code-server --install-extension redhat.java \
    --install-extension vscjava.vscode-java-debug \
    --install-extension vscjava.vscode-java-test \
    --install-extension ms-vscode.vscode-typescript-next \
    --install-extension donjayamanne.githistory \
    --install-extension esbenp.prettier-vscode \
    --install-extension golang.go

# Creazione di un utente non root per sicurezza
RUN useradd -m examuser
USER examuser


# Copia il file Java pregenerato nella home directory dell'utente
COPY --chown=examuser:examuser ./Main.java /home/examuser/Main.java

WORKDIR /home/examuser

# Configurazione di base per Code-Server (disabilita alcune funzionalità)
COPY --chown=examuser:examuser ./settings.json /home/examuser/.local/share/code-server/User/settings.json

# Espone la porta di Code-Server
EXPOSE 8080

# Comando per avviare Code-Server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "--disable-telemetry", "/home/examuser"]