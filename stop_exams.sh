#!/bin/bash

# --- CONFIGURAZIONE ---
# Modifica questo valore in base al numero di allievi (deve corrispondere a start_exams.sh)
NUM_STUDENTS=3

echo "--- ARRESTO AMBIENTI D'ESAME ---" # Messaggio aggiornato

# --- Arresto dei container degli allievi ---
echo "Fermando e rimuovendo i container degli allievi..."
for i in $(seq 1 $NUM_STUDENTS); do
    STUDENT_ID="allievo$i"
    CONTAINER_NAME="exam-${STUDENT_ID}"
    echo "Fermando e rimuovendo ${CONTAINER_NAME}..."
    docker stop ${CONTAINER_NAME} > /dev/null 2>&1
    docker rm ${CONTAINER_NAME} > /dev/null 2>&1
done

echo "----------------------------------------"
echo "Tutti gli ambienti d'esame per gli allievi sono stati fermati e rimossi." # Messaggio aggiornato
echo "I dati degli allievi sono stati preservati in ./student_data/"
echo "----------------------------------------"