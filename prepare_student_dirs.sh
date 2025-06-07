#!/bin/bash

NUM_STUDENTS=3

echo "Preparazione delle directory dati per $NUM_STUDENTS allievi..."

mkdir -p student_data

for i in $(seq 1 $NUM_STUDENTS); do
    STUDENT_ID="allievo$i"
    STUDENT_DATA_PATH="./student_data/${STUDENT_ID}"

    mkdir -p "${STUDENT_DATA_PATH}"

    if [ ! -f "${STUDENT_DATA_PATH}/Main.java" ]; then
        cp ./Main.java "${STUDENT_DATA_PATH}/Main.java"
        echo "Copiato Main.java in ${STUDENT_DATA_PATH}"
    else
        echo "Main.java già presente in ${STUDENT_DATA_PATH}, saltato."
    fi
done

echo "Tutte le directory dati degli allievi sono state preparate."