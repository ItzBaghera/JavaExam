# Usa un'immagine base leggera con Java Development Kit (JDK)
FROM eclipse-temurin:17-jdk-focal

# Installazione di Code-Server
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
RUN useradd -m examuser && \
    mkdir -p /home/examuser/.config/code-server/User && \
    chown -R examuser:examuser /home/examuser

USER examuser

# Imposta la home directory dell'utente come WORKDIR.
WORKDIR /home/examuser

# Crea la directory del progetto all'interno della home dell'utente
RUN mkdir -p /home/examuser/project && \
    chown examuser:examuser /home/examuser/project

# Copia il file Java pregenerato nella directory del progetto all'interno del container.
COPY --chown=examuser:examuser ./Main.java /home/examuser/project/Main.java

# Configurazione di base per Code-Server (disabilita alcune funzionalità)
COPY --chown=examuser:examuser ./settings.json /home/examuser/.local/share/code-server/User/settings.json

# Espone la porta di Code-Server
EXPOSE 8080

# === CAMBIO CRUCIALE QUI: NESSUNA OPZIONE --password e percorso workspace esplicito ===
# La password verrà passata tramite la variabile d'ambiente $PASSWORD da docker run.
# L'ultimo argomento è il percorso del workspace all'interno del container.
ENTRYPOINT ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "password", "--disable-telemetry", "/home/examuser/project"]