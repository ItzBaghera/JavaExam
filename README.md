# Java Exam Code-Server Setup

Questo progetto fornisce un ambiente d'esame sicuro e controllato per corsi di programmazione Java, utilizzando Docker e Safe Exam Browser (SEB) con Code-Server (una versione di VS Code basata su browser).

## Prerequisiti

Prima di iniziare, assicurati di avere installato quanto segue sul tuo sistema (preferibilmente Windows, utilizzando Git Bash per gli script):

* **Docker Desktop:** Assicurati che sia installato e che il motore Docker sia in esecuzione.
* **Git Bash (su Windows):** Per eseguire gli script Bash.
* **Python 3:** Con il gestore di pacchetti `pip`.
* **Safe Exam Browser (SEB) Config Tool:** Installato sul tuo computer per generare i file di configurazione SEB. Gli allievi avranno bisogno di Safe Exam Browser installato sul loro PC.

## Struttura del Progetto

```
.
├── Dockerfile                  # Definisce l'immagine Docker di Code-Server con Java
├── Main.java                   # Il file Java di esempio per gli esami
├── settings.json               # Configurazione predefinita di Code-Server per gli allievi
├── prepare_student_dirs.sh     # Script per creare le directory degli allievi sul host
├── start_exams.sh              # Script per avviare i container Docker degli allievi
├── stop_exams.sh               # Script per fermare e rimuovere i container
├── generate_seb_configs.py     # Script Python per generare i file .seb personalizzati
├── configurazione_base.seb     # File .seb di base (generato una volta con SEB Config Tool)
└── seb_configs/                # Cartella dove verranno salvati i file .seb per ogni allievo
```

## Guida Passo-Passo all'Utilizzo

Segui questi passaggi per configurare e avviare l'ambiente d'esame.

### Passo 1: Configurazione Iniziale e Preparazione dei File

1.  **Clona o scarica il progetto:** Ottieni tutti i file del progetto nella tua directory di lavoro locale (es. `C:\Users\TuoUtente\IdeaProjects\JavaExam`).
2.  **Verifica i file script:**
    * Apri `start_exams.sh` e `generate_seb_configs.py` con un editor di testo.
    * **Imposta l'indirizzo IP del tuo server:**
        * Trova l'indirizzo IP del tuo computer (quello su cui esegui Docker). Apri il `Prompt dei comandi` (CMD) su Windows e digita `ipconfig`. Cerca l' "Indirizzo IPv4" della tua connessione di rete attiva (es. `192.168.1.100`).
        * Modifica la riga `SERVER_IP="localhost"` in `start_exams.sh` in `SERVER_IP="<IL_TUO_IP_SERVER>"` (es. `SERVER_IP="192.168.1.100"`).
        * Modifica la riga `server_ip = "192.168.1.100"` in `generate_seb_configs.py` con il tuo IP reale.
    * Assicurati che `NUM_STUDENTS` e `STUDENT_START_PORT` siano uguali in entrambi gli script (`start_exams.sh` e `generate_seb_configs.py`).
    * Assicurati che la `EXAM_PASSWORD` in `start_exams.sh` sia quella che vuoi usare per accedere a Code-Server.
    * **Salva tutti gli script con terminazioni di riga LF e codifica UTF-8 (senza BOM).** Puoi farlo con editor come VS Code, Notepad++, Sublime Text.

### Passo 2: Pulizia e Costruzione dell'Immagine Docker

1.  **Apri Git Bash** (o un terminale WSL) nella directory principale del progetto (es. `C:\Users\TuoUtente\IdeaProjects\JavaExam`).
2.  **Pulisci l'ambiente Docker esistente:**
    ```bash
    ./stop_exams.sh
    rm -rf ./student_data
    docker rmi java-exam-codeserver:latest
    # Se ricevi "image in use", potresti dover rimuovere container orfani con:
    # docker system prune -f
    ```
3.  **Costruisci l'immagine Docker:**
    ```bash
    docker build -t java-exam-codeserver:latest .
    ```
    * Verifica che la costruzione avvenga senza errori.

### Passo 3: Preparazione delle Directory Studente

1.  **Prepara le directory dati degli allievi:**
    ```bash
    ./prepare_student_dirs.sh
    ```
    * Questo creerà una cartella `student_data` nella directory del progetto, con sottocartelle per ogni allievo (es. `student_data/allievo1`) e copierà `Main.java` e `settings.json` al loro interno.
    * **Verifica manuale:** Controlla che le cartelle siano state create correttamente (es. `C:\Users\TuoUtente\IdeaProjects\JavaExam\student_data\allievo1`) e che contengano `Main.java` e `settings.json`. Assicurati che non ci siano nomi di cartelle strani come `allievo1;C`.

### Passo 4: Avvio degli Ambienti Code-Server

1.  **Avvia i container Code-Server per gli allievi:**
    ```bash
    ./start_exams.sh
    ```
    * Lo script ti mostrerà gli URL per ogni allievo (es. `http://<IL_TUO_IP_SERVER>:8080`, `http://<IL_TUO_IP_SERVER>:8081`).
    * Verrà anche generato un file `exam_credentials.csv` con gli URL.
    * **Verifica Docker:** Esegui `docker ps -a` per assicurarti che tutti i container `exam-allievoX` siano in stato `Up`.

### Passo 5: Test del Funzionamento di Code-Server (Senza SEB)

1.  **Testa gli URL in un browser normale:**
    * Apri un browser web (Chrome, Firefox, Edge) e vai a uno degli URL degli allievi (es. `http://<IL_TUO_IP_SERVER>:8080`).
    * Ti verrà chiesta la password (`EXAM_PASSWORD` impostata in `start_exams.sh`).
    * **Verifica:**
        * L'URL nella barra degli indirizzi non deve contenere percorsi strani come `C:/Program Files/Git`.
        * All'interno di Code-Server, dovresti vedere l'explorer sulla sinistra e il file `Main.java` (e `settings.json`) visibile e apribile.
        * **Se in questo passaggio vedi ancora "Workspace does not exist" o percorsi errati nell'URL, ferma tutto e ricontrolla i passaggi precedenti con attenzione.** Il problema non è SEB, ma la configurazione di Docker.

### Passo 6: Generazione dei File di Configurazione SEB (.seb)

1.  **Crea il file `configurazione_base.seb`:**
    * Apri l'applicazione **"SEB Configuration Tool"** sul tuo computer.
    * Nella scheda **"General"**:
        * `Use SEB settings file for...`: Seleziona `configuring a client`.
        * `Settings password`: Imposta una password per proteggere il file di configurazione SEB stesso (es. `LaMiaPasswordSEB`).
    * Nella scheda **"Browser"** (l'icona a mappamondo):
        * `Start URL`: Inserisci l'URL del **primo allievo** (es. `http://<IL_TUO_IP_SERVER>:8080`).
        * `Allow reload in exam`: `true`.
        * `Enable browser context menu`: `false`.
        * `Allow downloading files`: `false` (consigliato per esami).
        * `Allow uploading files`: `false` (consigliato per esami).
        * `Allow opening links in a new browser window`: `false`.
    * Nella scheda **"User Interface"** (l'icona con 3 icone):
        * `Show Quit Button`: Disabilita.
        * `Quit Password`: **IMPOSTA UNA PASSWORD FORTE QUI!** Questa è la password per uscire da SEB (es. `UscitaSEB2025!`).
    * Nella scheda **"Exam"** (l'icona a esagono con "E"):
        * **`Enable URL Filtering`**: **ABILIITALO (spunta)!**
        * `Filter Mode`: Seleziona `Allow to load only configured URLs`.
        * `Permitted URLs`: Clicca `Add` e aggiungi l'URL del primo allievo (es. `http://<IL_TUO_IP_SERVER>:8080`).
    * Nella scheda **"Hooked Keys"** (l'icona a chiave):
        * **`Enable Alt+Tab`**: **Disabilita (togli la spunta)!**
    * **Salva:** Vai su `File > Save Settings As...` e salva il file come **`configurazione_base.seb`** nella **stessa directory** dello script `generate_seb_configs.py`.

2.  **Genera i file `.seb` per ogni allievo:**
    * Nel tuo terminale Git Bash (nella directory del progetto), esegui lo script Python:
        ```bash
        python generate_seb_configs.py
        ```
    * Verrà creata una cartella `seb_configs/` contenente `esame_allievo1.seb`, `esame_allievo2.seb`, ecc.

### Passo 7: Distribuzione e Test Finale con Safe Exam Browser

1.  **Distribuisci:** Ogni allievo dovrà ricevere il proprio file `.seb` (es. `esame_allievo1.seb` per l'allievo 1). Assicurati che abbiano Safe Exam Browser installato.
2.  **Simulazione Allievo:**
    * Sul computer di un allievo (o un PC di test), fai doppio clic sul file `.seb` destinato a quell'allievo.
    * SEB si avvierà e tenterà di connettersi all'URL di Code-Server.
    * Inserisci la password di Code-Server (`EXAM_PASSWORD`).
    * **Verifica finale:**
        * L'interfaccia di Code-Server deve caricarsi correttamente, mostrando `Main.java` e il workspace.
        * Prova a uscire da SEB (dovrebbe chiedere la `Quit Password`).
        * Prova ad aprire altre applicazioni o navigare su altri siti (dovrebbe essere bloccato da SEB).

---

Con questi passaggi, dovresti avere un ambiente d'esame Java con Code-Server e Safe Exam Browser completamente funzionale.