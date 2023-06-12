#!/bin/bash

# Función para instalar las dependencias en Termux
install_dependencies() {
    # Actualizar repositorios
    pkg update

    # Instalar tshark
    pkg install tshark -y

    # Instalar whois
    pkg install whois -y

    echo "La instalación de tshark y whois se ha completado."
}

# Función para ejecutar el análisis de tráfico
run_traffic_analysis() {
    filter=$(tshark -i eth0 -T fields -f "udp" -e ip.dst -Y "ip.dst!=192.168.0.0/16 and ip.dst!=10.0.0.0/8 and ip.dst!=172.16.0.0/12" -c 100 | sort -u | xargs | sed "s/ / and ip.dst!=/g" | sed "s/^/ip.dst!=/g")

    echo "Presiona Enter y llama a tu objetivo."
    read -r line

    tshark -i eth0 -l -T fields -f "udp" -e ip.dst -Y "$filter" -Y "ip.dst!=192.168.0.0/16 and ip.dst!=10.0.0.0/8 and ip.dst!=172.16.0.0/12" | while read -r line; do
        whois "$line" > /tmp/b

        filter=$(cat /tmp/b | xargs | egrep -iv "facebook|google" | wc -l)

        if [ "$filter" -gt 0 ]; then
            targetinfo=$(cat /tmp/b | egrep -iw "OrgName:|NetName:|Country:")
            echo "$line --- $targetinfo"
        fi
    done
}

# Función para mostrar el menú
show_menu() {
    echo "1. Instalar dependencias (tshark y whois)"
    echo "2. Ejecutar análisis de tráfico"
    echo "3. Salir"

    read -p "Ingrese la opción deseada: " choice

    case $choice in
        1) install_dependencies ;;
        2) run_traffic_analysis ;;
        3) exit ;;
        *) echo "Opción no válida. Inténtalo de nuevo." ;;
    esac
}

# Mostrar el menú
show_menu
