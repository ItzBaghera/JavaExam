# Ambiente d'Esame Java Sicuro (Code-Server su Docker)

Questo progetto fornisce un ambiente d'esame isolato e controllato per esercizi di programmazione Java. È basato su [Code-Server](https://github.com/coder/code-server) (VS Code nel browser) containerizzato con Docker, con configurazioni specifiche per limitare l'accesso e prevenire comportamenti non etici durante gli esami.

## Caratteristiche Principali

* **Ambiente Isolato**: Ogni studente opera all'interno di un container Docker dedicato, garantendo isolamento e riproducibilità.
* **IDE Web (Code-Server)**: Gli studenti utilizzano un IDE completo e familiare direttamente nel browser, eliminando la necessità di installazioni locali.
* **Sicurezza e Anti-Barare**:
    * **Terminale Integrato Disabilitato**: Impedisce l'esecuzione di comandi di sistema o l'accesso a risorse esterne.
    * **Funzionalità Git Disabilitate**: Non è possibile clonare/pushare codice da repository esterni.
    * **Estensioni Bloccate**: Impedisce l'installazione o l'uso di estensioni non autorizzate.
    * **JavaDoc Integrata Disabilitata**: Gli studenti non possono visualizzare la documentazione API ufficiale all'interno dell'IDE.
    * **Autocomplete Abilitato**: Per supportare la produttività nella scrittura del codice, l'autocomplete (IntelliSense) è attivo.
    * **Explorer Pulito**: L'explorer dei file mostra solo i file di progetto rilevanti, nascondendo i file di configurazione interni.
* **File di Progetto Pregenerato**: Ognilog
* ambiente include un file `Main.java` precompilato con un punto di partenza per l'esame.

## Requisiti

* [Docker Desktop](https://www.docker.com/products/docker-desktop/) (per Windows/macOS) o [Docker Engine](https://docs.docker.com/engine/install/) (per Linux) installato e funzionante sul tuo sistema.

## Struttura del Progetto

```
JavaExam/
├── Dockerfile              # Definisce l'immagine Docker dell'ambiente.
├── Main.java               # File Java di template per l'esame.
└── settings.json           # Impostazioni di Code-Server/VS Code per l'ambiente d'esame.
```

## Come Costruire l'Immagine Docker

1.  **Naviga nella directory del progetto**: Apri il tuo terminale o prompt dei comandi e naviga nella directory `JavaExam` dove si trovano il `Dockerfile`, `Main.java` e `settings.json`.

    ```bash
    cd /percorso/alla/tua/cartella/JavaExam
    ```

2.  **Costruisci l'immagine Docker**: Esegui il seguente comando per costruire l'immagine. Questo processo potrebbe richiedere qualche minuto al primo avvio per scaricare tutte le dipendenze.

    ```bash
    docker build -t java-exam-codeserver:latest .
    ```
    * `-t java-exam-codeserver:latest`: Assegna il nome `java-exam-codeserver` e il tag `latest` all'immagine.
    * `.`: Indica che il `Dockerfile` si trova nella directory corrente.

## Come Avviare l'Ambiente d'Esame per gli Studenti

Per ogni studente o sessione d'esame, avvierai un container Docker separato.

1.  **Avvia un container per uno studente**:
    ```bash
    docker run -d -p 8080:8080 --name exam-student1 java-exam-codeserver:latest
    ```
    * `-d`: Avvia il container in modalità "detached" (in background).
    * `-p 8080:8080`: Mappa la porta 8080 del tuo host (la tua macchina) alla porta 8080 all'interno del container.
        * **IMPORTANTE**: Se devi avviare più container contemporaneamente (per più studenti), devi mappare su porte diverse sull'host per ogni container. Esempio per un secondo studente: `-p 8081:8080`.
    * `--name exam-student1`: Assegna un nome univoco al container per facilitarne la gestione (es. `exam-nomecognome` o `exam-matricola`).

2.  **Accedi all'IDE**: Una volta che il container è in esecuzione, lo studente può accedere all'IDE aprendo il browser all'indirizzo:
    * `http://localhost:8080` (se stai usando la porta 8080 sul tuo host)
    * `http://localhost:8081` (se hai mappato su 8081, ecc.)
    * Oppure, se il server Docker è su una macchina remota, `http://<IP_del_server>:8080`.

## Gestione dei Container

* **Visualizzare i container in esecuzione**:
    ```bash
    docker ps
    ```
* **Fermare un container**:
    ```bash
    docker stop <nome_o_ID_del_container>
    ```
* **Rimuovere un container (dopo averlo fermato)**:
    ```bash
    docker rm <nome_o_ID_del_container>
    ```
* **Visualizzare tutti i container (anche quelli fermi)**:
    ```bash
    docker ps -a
    ```
* **Visualizzare i log di un container (utile per il debugging)**:
    ```bash
    docker logs <nome_o_ID_del_container>
    ```

## Integrazione con Safe Exam Browser (SEB)

Questo ambiente è progettato per essere utilizzato in combinazione con Safe Exam Browser (SEB) per un controllo totale dell'ambiente d'esame dello studente.

1.  **Configurazione SEB**: Configura SEB per avviare l'URL dell'istanza di Code-Server (es. `http://<IP_del_server>:8080`).
2.  **Restrizioni SEB**: Utilizza le impostazioni di SEB per:
    * Bloccare l'accesso a tutte le altre applicazioni.
    * Disabilitare la navigazione web libera (limitare solo all'URL di Code-Server).
    * Bloccare scorciatoie da tastiera comuni (es. `Alt+Tab`, `Ctrl+C`, `Ctrl+V`).
    * (Opzionale) Disabilitare il tasto destro e le funzioni copia/incolla nel browser, a seconda delle tue esigenze d'esame.

## Personalizzazione

* **`Dockerfile`**: Puoi modificare il `Dockerfile` per:
    * Aggiornare la versione di Code-Server.
    * Installare estensioni VS Code Java aggiuntive (ma valuta attentamente l'impatto sulla sicurezza).
    * Cambiare la versione di JDK.
* **`settings.json`**: Modifica questo file per affinare le impostazioni di Code-Server, ad esempio per consentire o bloccare ulteriormente funzionalità specifiche dell'IDE.
* **`Main.java`**: Modifica questo file per personalizzare il punto di partenza dell'esame o includere istruzioni specifiche.

---
