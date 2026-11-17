# Projeto Água Viva

Aplicativo receptor multiplataforma (Android e Windows) e firmware ESP32 para monitoramento de Triagem Físico-Química da água em tempo real e consulta de histórico offline via cartão SD.

Sensores monitorados:
- **pH**
- **Temperatura**
- **Condutividade Elétrica / TDS**
- **Turbidez**

---

## Instalação

Você pode baixar a versão mais recente pronta para uso diretamente na página de **[GitHub Releases](https://github.com/leonardo-pauli/Agua_Viva-Estacao_Flutuante/releases)**:

👉 **[Acessar Releases do Projeto Água Viva](https://github.com/leonardo-pauli/Agua_Viva-Estacao_Flutuante/releases/latest)**

### 📱 Android (`.apk`)
1. Na página de Releases, baixe o arquivo `.apk` da versão desejada.
2. Abra o arquivo no seu celular Android e conclua a instalação *(habilite a permissão para instalar aplicativos de fontes desconhecidas, se solicitado)*.

### 💻 Windows Desktop (`.zip`)
1. Na página de Releases, baixe o arquivo `.zip` da versão para Windows.
2. **Extraia todo o conteúdo** do `.zip` para uma pasta no seu computador *(não execute o `.exe` diretamente de dentro do arquivo compactado, pois ele depende das DLLs e da pasta `data` ao lado)*.
3. Execute o arquivo `.exe` dentro da pasta extraída.

---

## Como conectar à boia (ESP32)

1. Ligue a boia com o ESP32.
2. No celular ou computador, conecte-se à rede Wi-Fi **`AguaViva`** (Access Point criado pelo ESP32).
3. Abra o aplicativo **Água Viva** — a conexão WebSocket com a boia será iniciada automaticamente.

---

## Principais funcionalidades

- **Monitoramento ao vivo:** leitura contínua dos 4 sensores via WebSocket com gráficos em tempo real.
- **Histórico no cartão SD:** gravação automática no cartão SD da boia e sincronização com o aplicativo.
- **Exportação CSV:** exporte as leituras para análise externa no formato `.csv`.
- **Modo de simulação:** gere leituras de teste no aplicativo mesmo sem a boia conectada.

---
