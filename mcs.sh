#!/bin/bash

sudo systemctl start zerotier-one > /dev/null 2>&1

network_choice=""
while [[ -z "$network_choice" ]]; do
    read -p "Выберите сеть для подключения (1 - Максим, 2 - Арсений): " network_choice
done

if [ "$network_choice" -eq 1 ]; then
    network_id="fada62b015e76362"
elif [ "$network_choice" -eq 2 ]; then
    network_id="e4da7455b2238b6a"
else
    exit 1
fi

# Присоединение к сети
sudo zerotier-cli join "$network_id" > /dev/null 2>&1

host_choice=""
while [[ -z "$host_choice" ]]; do
    read -p "Хотите хостить Mumble сервер? (да/нет): " host_choice
done

# Получение IP-адреса ZeroTier
ip_address=$(sudo zerotier-cli listnetworks | grep -oP '10\.\d{1,3}\.\d{1,3}\.\d{1,3}' | head -n 1)

# Проверка, найден ли IP-адрес
if [[ -z "$ip_address" ]]; then
    echo "Не удалось получить IP-адрес ZeroTier."
    exit 1
fi

# Вывод IP-адреса и копирование в буфер обмена
echo "Ваш IP-адрес: $ip_address"
echo "$ip_address" | wl-copy

if [[ "$host_choice" == "да" ]]; then
    sudo systemctl start mumble-server > /dev/null 2>&1
else
    if ! systemctl is-active --quiet mumble-server; then
        sudo systemctl start mumble-server > /dev/null 2>&1
    fi
fi

mumble "$ip_address" > /dev/null 2>&1 &

disown
