#!/bin/bash

# --- CONFIGURAZIONE ---
NUM_STUDENTS=3
STUDENT_START_PORT=8080
# TEACHER_PORT=8888  <-- Rimuovi o commenta
SERVER_IP="localhost"
EXAM_PASSWORD="1234"
# ----------------------

echo "--- AVVIO AMBIENTI D'ESAME ---" # Messaggio aggiornato
echo "Numero di allievi: $NUM_STUDENTS"
echo "Porta iniziale per gli allievi: $STUDENT_START_PORT"
# echo "Porta per l'ambiente docente: $TEACHER_PORT" <-- Rimuovi o commenta
echo "IP del server: $SERVER_IP"
echo "Password per tutti gli ambienti: $EXAM_PASSWORD"
echo "----------------------------------------"

if [ -f "exam_credentials.csv" ]; then
    rm "exam_credentials.csv"
fi
echo "ID_Allievo,URL_Ambiente" > exam_credentials.csv

# Ottieni il percorso assoluto della directory corrente in formato Windows
CURRENT_DIR_WIN=$(pwd -W)

# --- Avvio dei container degli allievi ---
echo "Avvio degli ambienti Code-Server per gli allievi..."
for i in $(seq 1 $NUM_STUDENTS); do
    STUDENT_ID="allievo$i"
    HOST_PORT=$((STUDENT_START_PORT + i - 1))

    STUDENT_DATA_DIR_WIN="${CURRENT_DIR_WIN}\\student_data\\${STUDENT_ID}"

    CONTAINER_NAME="exam-${STUDENT_ID}"

    docker stop ${CONTAINER_NAME} > /dev/null 2>&1
    docker rm ${CONTAINER_NAME} > /dev/null 2>&1

    echo "Avvio di ${CONTAINER_NAME} sulla porta ${HOST_PORT} (dati in ${STUDENT_DATA_DIR_WIN})..."

    docker run -d \
        -p ${HOST_PORT}:8080 \
        -v "${STUDENT_DATA_DIR_WIN}":/home/examuser/project \
        --name "${CONTAINER_NAME}" \
        -e PASSWORD="${EXAM_PASSWORD}" \
        java-exam-codeserver:latest

    CURRENT_STUDENT_URL="http://${SERVER_IP}:${HOST_PORT}"
    echo "   URL per ${STUDENT_ID}: ${CURRENT_STUDENT_URL}"
    echo "${STUDENT_ID},${CURRENT_STUDENT_URL}" >> exam_credentials.csv
    echo "---------------------------------------------------------"
done

echo ""

echo "Tutti gli ambienti d'esame per gli allievi sono stati avviati." # Messaggio aggiornato
echo "Gli URL degli allievi e la password sono stati salvati in exam_credentials.csv e stampati sopra."
echo "I dati degli allievi sono salvati localmente in ./student_data/"
echo "Premi Ctrl+C per uscire da questo script, i container continueranno a girare in background."