import xml.etree.ElementTree as ET
import os

# NUOVA IMPORT: Importa etree da lxml
try:
    from lxml import etree
except ImportError:
    print("Avviso: La libreria 'lxml' non è installata o non è accessibile. L'XML generato potrebbe non essere 'pretty printed'.")
    print("Installa con: pip install lxml")
    etree = None # Fallback se lxml non è disponibile


def update_seb_config(input_file, output_file, ip_address, port):
    """
    Aggiorna il file di configurazione SEB (.seb) con il nuovo URL e lo salva.
    """
    # Usa lxml.etree se disponibile, altrimenti fallback a xml.etree.ElementTree
    parser = etree.XMLParser(remove_blank_text=True) if etree else None
    tree = (etree.parse(input_file, parser=parser) if etree else ET.parse(input_file))
    root = tree.getroot()

    # Trova e aggiorna la chiave startURL (deve essere definita nel tuo .seb base)
    # Se il tuo .seb base non ha ancora startURL, dovrai aggiungerla manualmente la prima volta
    # usando SEB Config Tool, poi questo script la modificherà.
    # L'XML di SEB è un PropertyList, quindi le chiavi sono sotto <key> e i valori sotto il tag successivo.

    # Cerchiamo il dict principale
    main_dict = root.find('dict')

    # Aggiorna lo Start URL
    found_start_url = False
    for i, element in enumerate(main_dict):
        if element.tag == 'key' and element.text == 'startURL':
            if main_dict[i + 1].tag == 'string':
                main_dict[i + 1].text = f"http://{ip_address}:{port}"
                found_start_url = True
                print(f"  - Aggiornato startURL a {main_dict[i+1].text}")
                break
    if not found_start_url:
        print("  - ERRORE: startURL non trovato nel file di configurazione base. Assicurati di averlo impostato manualmente in SEB Config Tool e salvato.")
        print("    Verrà comunque tentato di aggiungere, ma è meglio che sia presente nel template.")
        # Se startURL non esiste, aggiungilo (assicurati che sia nel posto giusto, ad esempio all'inizio del dict)
        new_key = ET.Element('key')
        new_key.text = 'startURL'
        new_string = ET.Element('string')
        new_string.text = f"http://{ip_address}:{port}"
        # Aggiungi all'inizio del dict per coerenza con il formato PropertyList tipico
        main_dict.insert(0, new_key)
        main_dict.insert(1, new_string) # Inserisci dopo la chiave


    # Aggiorna i Permitted URLs nel filtro (se abilitato e configurato correttamente)
    # Questa parte è più complessa perché è una lista di dicts.
    # Assicurati che 'URLFilterEnable' sia true nel tuo file base.
    url_filter_rules_key_index = -1
    for i, element in enumerate(main_dict):
        if element.tag == 'key' and element.text == 'URLFilterRules':
            url_filter_rules_key_index = i
            break

    if url_filter_rules_key_index != -1:
        url_filter_rules_array = main_dict[url_filter_rules_key_index + 1] # Questo dovrebbe essere il tag <array>
        if url_filter_rules_array.tag == 'array':
            # Rimuovi le vecchie regole se presenti
            # Consideriamo di rimuovere solo le regole che corrispondono al pattern del nostro esame
            rules_to_remove = []
            for rule_dict in list(url_filter_rules_array): # Crea una copia della lista per iterare e modificare
                if rule_dict.tag == 'dict':
                    for i_rule, rule_element in enumerate(rule_dict):
                        if rule_element.tag == 'key' and rule_element.text == 'url':
                            # Controlla se l'URL inizia con il nostro IP (evita di eliminare altre regole che potrebbero esserci)
                            if main_dict[i_rule + 1].text.startswith(f"http://{ip_address}"):
                                rules_to_remove.append(rule_dict)
                            break # Esci dal for interno dopo aver controllato la chiave 'url'

            for rule_dict in rules_to_remove:
                url_filter_rules_array.remove(rule_dict)

            # Aggiungi la nuova regola per l'URL specifico dell'allievo
            new_rule_dict = ET.Element('dict')
            new_rule_dict.append(ET.Element('key'))
            new_rule_dict[-1].text = 'active'
            new_rule_dict.append(ET.Element('true')) # Value for 'active'

            new_rule_dict.append(ET.Element('key'))
            new_rule_dict[-1].text = 'regex'
            new_rule_dict.append(ET.Element('false')) # Value for 'regex'

            new_rule_dict.append(ET.Element('key'))
            new_rule_dict[-1].text = 'url'
            new_rule_dict.append(ET.Element('string'))
            new_rule_dict[-1].text = f"http://{ip_address}:{port}" # Value for 'url'

            new_rule_dict.append(ET.Element('key'))
            new_rule_dict[-1].text = 'forceAllow'
            new_rule_dict.append(ET.Element('true')) # Value for 'forceAllow'

            url_filter_rules_array.append(new_rule_dict)
            print(f"  - Aggiornate URLFilterRules per {ip_address}:{port}")
        else:
            print("  - Avviso: URLFilterRules non è un tag <array> come previsto.")
    else:
        print("  - Avviso: Chiave 'URLFilterRules' non trovata. Il filtraggio URL potrebbe non essere configurato. Assicurati che sia presente nel file base.")


    # Scrivi il file XML
    if etree:
        # Usa lxml per pretty print e doctype
        tree.write(output_file, encoding='utf-8', xml_declaration=True, pretty_print=True, doctype='<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">')
    else:
        # Fallback a ElementTree standard senza pretty_print
        tree.write(output_file, encoding='utf-8', xml_declaration=True)
        # E per il doctype, dovresti aggiungerlo manualmente se necessario all'inizio del file
        # Oppure gestire la plist con plistlib se diventa un problema.
        # Per ora, il doctype potrebbe essere perso o non formattato perfettamente con ET.write() standard.

    print(f"Generato file SEB per l'allievo su porta {port}: {output_file}")


if __name__ == "__main__":
    # Assicurati che questo script sia nella stessa directory del tuo file .seb base
    # (es. configurazione_base_allievo1.seb che salverai dal SEB Config Tool)
    base_seb_file = "configurazione_base.seb" # Nome del file .seb che creerai
    output_dir = "seb_configs" # Cartella dove salveremo i file .seb generati

    # L'IP del tuo server Docker (il computer che esegue i container)
    # *** MODIFICA QUESTO CON IL TUO IP REALE ***
    server_ip = "192.168.1.100"

    # Numero di allievi (deve corrispondere a quello in start_exams.sh)
    num_students = 3

    # Porta iniziale per gli allievi (deve corrispondere a quella in start_exams.sh)
    start_port = 8080

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    print(f"Generando file SEB per {num_students} allievi...")

    # Assicurati di aver creato "configurazione_base.seb" usando l'interfaccia di SEB Configuration Tool
    # con l'URL dell'allievo 1 (es. http://192.168.1.100:8080) e tutte le impostazioni di sicurezza.
    if not os.path.exists(base_seb_file):
        print(f"ERRORE: File '{base_seb_file}' non trovato. Crealo prima usando SEB Config Tool.")
        print(f"1. Apri SEB Config Tool.")
        print(f"2. Configura tutte le impostazioni desiderate (Start URL: http://{server_ip}:{start_port}).")
        print(f"3. Salva come '{base_seb_file}' nella stessa cartella di questo script.")
        exit(1)


    for i in range(num_students):
        student_port = start_port + i
        student_id = f"allievo{i + 1}"
        output_seb_file = os.path.join(output_dir, f"esame_{student_id}.seb")

        print(f"Generando configurazione per {student_id} (Porta: {student_port})...")
        update_seb_config(base_seb_file, output_seb_file, server_ip, student_port)

    print("\nGenerazione dei file SEB completata.")
    print(f"Puoi trovare i file generati nella cartella '{output_dir}'.")