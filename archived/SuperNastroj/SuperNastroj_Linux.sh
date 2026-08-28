#!/bin/bash
# SUPER NÁSTROJ v5.0 - Linux Edition
# FatalErorr69 - Multiplatformní verze

# ==================================================
# INICIALIZACE
# ==================================================
clear
echo
echo "=================================================="
echo "     🚀 SUPER NÁSTROJ v5.0 - LINUX EDITION"
echo "=================================================="
echo

# Kontrola root práv (varování, ne ukončení)
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  Pro plnou funkcionalitu spusťte jako root (sudo)"
    echo
fi

# Vytvoření složek
mkdir -p SuperNastroj_Logs SuperNastroj_Tools SuperNastroj_Backups

# Logování
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" >> SuperNastroj_Logs/system.log
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >> SuperNastroj_Logs/system.log
}

# ==================================================
# POMOCNÉ FUNKCE
# ==================================================
check_command() {
    if command -v $1 &> /dev/null; then
        return 0
    else
        return 1
    fi
}

install_package() {
    local pkg=$1
    if check_command apt-get; then
        apt-get install -y $pkg
    elif check_command yum; then
        yum install -y $pkg
    elif check_command dnf; then
        dnf install -y $pkg
    elif check_command pacman; then
        pacman -S --noconfirm $pkg
    else
        echo "❌ Nelze nainstalovat $pkg - žádný správce balíčků"
        return 1
    fi
}

# ==================================================
# HLAVNÍ MENU
# ==================================================
show_menu() {
    clear
    echo
    echo "=================================================="
    echo "     🚀 SUPER NÁSTROJ v5.0 - LINUX EDITION"
    echo "=================================================="
    echo
    echo "1)  🛠️  Rychlá oprava systému"
    echo "2)  🔍 Diagnostika systému"
    echo "3)  🌐 Síťové nástroje"
    echo "4)  🛡️  Bezpečnost a firewall"
    echo "5)  💾 Správa disků"
    echo "6)  📦 Správa balíčků"
    echo "7)  🔧 Nástroje pro vývojáře"
    echo "8)  🚀 Boot a recovery"
    echo "9)  ⚙️  Nastavení systému"
    echo "10) ❌ Konec"
    echo
    read -p "Vyberte možnost [1-10]: " choice
}

# ==================================================
# RYCHLÁ OPRAVA SYSTÉMU - OPRAVENO
# ==================================================
quick_repair() {
    echo
    echo "🛠️  PROVÁDÍM RYCHLOU OPRAVU SYSTÉMU..."
    echo
    
    # Kontrola a oprava souborového systému
    echo "🔍 Kontroluji souborový systém..."
    if [ "$EUID" -eq 0 ]; then
        fsck -f / 2>/dev/null || echo "ℹ️  Kontrola FS vyžaduje unmount"
    else
        echo "ℹ️  Kontrola FS vyžaduje root práva"
    fi
    
    # Oprava oprávnění
    echo "🔧 Opravuji oprávnění souborů..."
    if [ "$EUID" -eq 0 ]; then
        find /etc -type f -exec chmod 644 {} \; 2>/dev/null
        find /usr/bin -type f -exec chmod 755 {} \; 2>/dev/null
    else
        echo "ℹ️  Oprava oprávnění vyžaduje root práva"
    fi
    
    # Čištění cache
    echo "🧹 Čistím systémovou cache..."
    if check_command apt-get; then
        apt-get clean 2>/dev/null
    elif check_command yum; then
        yum clean all 2>/dev/null
    elif check_command dnf; then
        dnf clean all 2>/dev/null
    elif check_command pacman; then
        pacman -Scc --noconfirm 2>/dev/null
    fi
    
    # Čištění dočasných souborů
    echo "🗑️  Čistím dočasné soubory..."
    if [ "$EUID" -eq 0 ]; then
        rm -rf /tmp/* /var/tmp/* 2>/dev/null
    else
        rm -rf /tmp/* 2>/dev/null
    fi
    
    # Obnova síťových nastavení
    echo "🌐 Obnovuji síťová nastavení..."
    if [ "$EUID" -eq 0 ]; then
        systemctl restart NetworkManager 2>/dev/null
        systemctl restart networking 2>/dev/null
        systemctl restart systemd-resolved 2>/dev/null
    fi
    
    echo "✅ Rychlá oprava dokončena!"
    log_info "Quick repair completed"
    read -p "Stiskněte Enter pro pokračování..."
}

# ==================================================
# DIAGNOSTIKA SYSTÉMU - OPRAVENO
# ==================================================
system_diagnostics() {
    echo
    echo "🔍 SPOUŠTÍM DIAGNOSTIKU SYSTÉMU..."
    echo
    
    # Informace o systému
    echo "🖥️  INFORMACE O SYSTÉMU:"
    if check_command lsb_release; then
        echo "Distribuce: $(lsb_release -d | cut -f2)"
    elif [ -f "/etc/os-release" ]; then
        echo "Distribuce: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
    else
        echo "Distribuce: Nelze zjistit"
    fi
    echo "Jádro: $(uname -r)"
    echo "Architektura: $(uname -m)"
    echo "Hostname: $(hostname)"
    echo
    
    # Využití zdrojů
    echo "🔥 VYUŽITÍ ZDROJŮ:"
    echo "CPU: $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"% využití"}')"
    echo "Paměť: $(free -h | grep Mem | awk '{print $3 "/" $2 " použito"}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
    echo "Uptime: $(uptime -p)"
    echo
    
    # Teplota (pokud je dostupná)
    if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
        TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
        echo "🌡️  Teplota CPU: $((TEMP/1000))°C"
    elif check_command sensors; then
        echo "🌡️  Teplota: $(sensors | grep -E "Core|Package" | head -1)"
    fi
    
    # Běžící procesy
    echo "📈 BĚŽÍCÍ PROCESY: $(ps aux | wc -l)"
    echo "📊 TOP 5 procesů podle CPU:"
    ps aux --sort=-%cpu | head -6 | awk '{print $2, $11}' | column -t
    echo
    
    # Síťová rozhraní
    echo "🌐 SÍŤOVÁ ROZHRANÍ:"
    ip addr show | grep "inet " | awk '{print "  " $2 " na " $NF}' | head -5
    echo
    
    # Načtení systému
    echo "📈 POSLEDNÍ NAČTENÍ SYSTÉMU:"
    who | head -3
    echo
    
    log_info "System diagnostics completed"
    read -p "Stiskněte Enter pro pokračování..."
}

# ==================================================
# SÍŤOVÉ NÁSTROJE - OPRAVENO
# ==================================================
network_tools() {
    while true; do
        clear
        echo
        echo "=================================================="
        echo "          🌐 SÍŤOVÉ NÁSTROJE - LINUX"
        echo "=================================================="
        echo
        echo "1) Síťová diagnostika"
        echo "2) Skenování sítě"
        echo "3) Test rychlosti připojení"
        echo "4) Firewall a bezpečnost"
        echo "5) DNS a síťová konfigurace"
        echo "6) Monitorování sítě"
        echo "7) Zpět do hlavního menu"
        echo
        read -p "Vyberte možnost [1-7]: " net_choice
        
        case $net_choice in
            1)
                echo
                echo "🌐 SÍŤOVÁ DIAGNOSTIKA..."
                echo
                echo "📊 Síťová rozhraní:"
                ip link show
                echo
                echo "🔄 Test připojení:"
                ping -c 4 8.8.8.8
                echo
                echo "🛣️  Směrování:"
                ip route
                ;;
            2)
                echo
                echo "🔍 SKENOVÁNÍ SÍTĚ..."
                read -p "Zadejte síť (např. 192.168.1.0/24): " network
                if [ -z "$network" ]; then
                    network="192.168.1.0/24"
                fi
                if check_command nmap; then
                    nmap -sn $network
                else
                    echo "📥 Nmap není nainstalován."
                    read -p "Chcete nainstalovat? [y/N]: " install_nmap
                    if [ "$install_nmap" = "y" ] || [ "$install_nmap" = "Y" ]; then
                        install_package nmap
                    fi
                fi
                ;;
            3)
                echo
                echo "🚀 TEST RYCHLOSTI PŘIPOJENÍ..."
                if check_command speedtest-cli; then
                    speedtest-cli --simple
                else
                    echo "📥 Speedtest-cli není nainstalován."
                    read -p "Chcete nainstalovat? [y/N]: " install_speedtest
                    if [ "$install_speedtest" = "y" ] || [ "$install_speedtest" = "Y" ]; then
                        install_package speedtest-cli
                    fi
                fi
                ;;
            4)
                echo
                echo "🛡️  FIREWALL A BEZPEČNOST..."
                if check_command ufw; then
                    ufw status verbose
                elif check_command iptables; then
                    iptables -L -n
                elif check_command firewall-cmd; then
                    firewall-cmd --state
                    firewall-cmd --list-all
                else
                    echo "ℹ️  Firewall není konfigurován nebo není dostupný"
                fi
                ;;
            5)
                echo
                echo "🔧 DNS A SÍŤOVÁ KONFIGURACE..."
                echo "DNS servery:"
                cat /etc/resolv.conf | grep nameserver
                echo
                echo "Hosts:"
                cat /etc/hosts | head -10
                echo
                echo "📡 Síťové služby:"
                systemctl status NetworkManager 2>/dev/null || \
                systemctl status networking 2>/dev/null || \
                echo "ℹ️  Síťový manažer není dostupný"
                ;;
            6)
                echo
                echo "📊 MONITOROVÁNÍ SÍTĚ..."
                echo "Aktivní spojení:"
                netstat -tun | grep ESTABLISHED | head -10
                echo
                echo "Síťová rozhraní:"
                ip -s link
                ;;
            7)
                return
                ;;
            *)
                echo "❌ Neplatná volba!"
                ;;
        esac
        echo
        read -p "Stiskněte Enter pro pokračování..."
    done
}

# ==================================================
# BEZPEČNOST A FIREWALL - OPRAVENO
# ==================================================
security_tools() {
    echo
    echo "🛡️  BEZPEČNOSTNÍ NÁSTROJE..."
    echo
    
    # Kontrola běžících služeb
    echo "🔍 KONTROLA SLUŽEB:"
    netstat -tulpn | grep LISTEN | head -10
    
    # Kontrola sudo přístupů
    echo
    echo "🔐 SUDO PŘÍSTUPY:"
    if [ -f "/etc/sudoers" ]; then
        grep -v '^#\|^$' /etc/sudoers | head -10
    else
        echo "ℹ️  Soubor sudoers není přístupný"
    fi
    
    # Kontrola fail2ban
    if check_command fail2ban-client; then
        echo
        echo "🚫 FAIL2BAN STATUS:"
        fail2ban-client status
    fi
    
    # Kontrola SELinux/AppArmor
    echo
    echo "🛡️  MANDATORY ACCESS CONTROL:"
    if check_command sestatus; then
        sestatus | head -3
    elif check_command aa-status; then
        aa-status | head -5
    else
        echo "ℹ️  Žádný MAC systém není aktivní"
    fi
    
    # Bezpečnostní doporučení
    echo
    echo "💡 BEZPEČNOSTNÍ DOPORUČENÍ:"
    echo "1. Pravidelně aktualizovat systém"
    echo "2. Používat silná hesla"
    echo "3. Konfigurovat firewall"
    echo "4. Vypnout nepotřebné služby"
    echo "5. Monitorovat logy"
    echo "6. Používat SSH klíče místo hesel"
    echo "7. Pravidelně zálohovat"
    
    log_info "Security check completed"
    read -p "Stiskněte Enter pro pokračování..."
}

# ==================================================
# SPRÁVA DISKŮ - OPRAVENO
# ==================================================
disk_management() {
    echo
    echo "💾 SPRÁVA DISKŮ..."
    echo
    
    # Informace o discích
    echo "📊 INFORMACE O DISCÍCH:"
    lsblk
    echo
    echo "📈 VYUŽITÍ DISKŮ:"
    df -h
    
    # SMART data (pokud je dostupné)
    if check_command smartctl; then
        echo
        echo "🔍 SMART DATA:"
        for disk in $(lsblk -d -o NAME | grep -v NAME); do
            if [ -e "/dev/$disk" ]; then
                echo "Disk /dev/$disk:"
                smartctl -H /dev/$disk 2>/dev/null | grep "SMART overall-health" || true
            fi
        done
    fi
    
    # IO stat
    echo
    echo "⚡ I/O STATISTIKA:"
    iostat -x 1 1 2>/dev/null || echo "ℹ️  iostat není k dispozici"
    
    # Doporučení pro údržbu
    echo
    echo "💡 DOPORUČENÍ PRO ÚDRŽBU:"
    echo "1. Pravidelné zálohování"
    echo "2. Kontrola integrity souborů"
    echo "3. Monitorování volného místa"
    echo "4. Čištění dočasných souborů"
    echo "5. Pravidelné kontroly disků"
    
    read -p "Stiskněte Enter pro pokračování..."
}

# ==================================================
# NOVÉ FUNKCE - DOPLNĚNÍ CHYBEJÍCÍCH
# ==================================================

# Správa balíčků
package_management() {
    echo
    echo "📦 SPRÁVA BALÍČKŮ..."
    echo
    
    if check_command apt; then
        echo "🎯 APT (Debian/Ubuntu):"
        apt update
        echo
        echo "📊 Aktualizovatelné balíčky:"
        apt list --upgradable 2>/dev/null | head -10
    elif check_command yum; then
        echo "🎯 YUM (RHEL/CentOS):"
        yum check-update
    elif check_command dnf; then
        echo "🎯 DNF (Fedora):"
        dnf check-update
    elif check_command pacman; then
        echo "🎯 PACMAN (Arch):"
        pacman -Qu
    else
        echo "❌ Není podporován žádný správce balíčků"
    fi
    
    echo
    echo "💡 PŘÍKAZY PRO SPRÁVU BALÍČKŮ:"
    echo "Debian/Ubuntu: apt update && apt upgrade"
    echo "RHEL/CentOS: yum update"
    echo "Fedora: dnf upgrade"
    echo "Arch: pacman -Syu"
    
    read -p "Stiskněte Enter pro pokračování..."
}

# Nástroje pro vývojáře
developer_tools() {
    echo
    echo "🔧 NÁSTROJE PRO VÝVOJÁŘE..."
    echo
    
    echo "🐍 PYTHON:"
    if check_command python3; then
        python3 --version
    elif check_command python; then
        python --version
    else
        echo "❌ Python není nainstalován"
    fi
    
    echo
    echo "📦 NODE.JS:"
    if check_command node; then
        node --version
        npm --version 2>/dev/null || echo "ℹ️  NPM není dostupný"
    else
        echo "❌ Node.js není nainstalován"
    fi
    
    echo
    echo "☕ JAVA:"
    if check_command java; then
        java -version
    else
        echo "❌ Java není nainstalována"
    fi
    
    echo
    echo "🐘 PHP:"
    if check_command php; then
        php --version | head -1
    else
        echo "❌ PHP není nainstalováno"
    fi
    
    echo
    echo "🗄️  GIT:"
    if check_command git; then
        git --version
    else
        echo "❌ Git není nainstalován"
    fi
    
    read -p "Stiskněte Enter pro pokračování..."
}

# Boot a recovery
boot_recovery() {
    echo
    echo "🚀 BOOT A RECOVERY..."
    echo
    
    echo "📋 BOOT INFORMATION:"
    if [ -d "/boot" ]; then
        ls -la /boot/ | head -10
    else
        echo "ℹ️  Složka /boot není přístupná"
    fi
    
    echo
    echo "🔧 GRUB KONFIGURACE:"
    if [ -f "/etc/default/grub" ]; then
        grep -v '^#\|^$' /etc/default/grub | head -10
    else
        echo "ℹ️  GRUB konfigurace není dostupná"
    fi
    
    echo
    echo "📊 SYSTEMD BOOT ČAS:"
    if check_command systemd-analyze; then
        systemd-analyze time
    fi
    
    echo
    echo "💡 RECOVERY PŘÍKAZY:"
    echo "• Oprava GRUB: grub-install /dev/sda"
    echo "• Obnova balíčků: dpkg --configure -a"
    echo "• FS kontrola: fsck -y /dev/sda1"
    echo "• Chroot rescue: chroot /mnt/sysimage"
    
    read -p "Stiskněte Enter pro pokračování..."
}

# Nastavení systému
system_settings() {
    echo
    echo "⚙️  NASTAVENÍ SYSTÉMU..."
    echo
    
    echo "🌍 ČASOVÉ PÁSMO:"
    timedatectl status 2>/dev/null || date
    
    echo
    echo "🔧 LOCALE:"
    locale 2>/dev/null | grep -E "LANG|LC_"
    
    echo
    echo "💾 SWAP:"
    free -h | grep Swap
    
    echo
    echo "📋 UŽIVATELÉ:"
    cat /etc/passwd | wc -l | awk '{print "Počet uživatelů: " $1}'
    
    echo
    echo "🚦 SLUŽBY:"
    systemctl list-units --type=service --state=running | head -5
    
    read -p "Stiskněte Enter pro pokračování..."
}

# ==================================================
# HLAVNÍ SMYČKA - OPRAVENO
# ==================================================
log_info "SuperNastroj Linux edition started"

while true; do
    show_menu
    case $choice in
        1) quick_repair ;;
        2) system_diagnostics ;;
        3) network_tools ;;
        4) security_tools ;;
        5) disk_management ;;
        6) package_management ;;
        7) developer_tools ;;
        8) boot_recovery ;;
        9) system_settings ;;
        10)
            echo
            echo "Děkuji za použití SuperNástroje!"
            echo "FatalErorr69 Linux Edition"
            log_info "Application closed normally"
            exit 0
            ;;
        *)
            echo "❌ Neplatná volba!"
            read -p "Stiskněte Enter pro pokračování..."
            ;;
    esac
done
