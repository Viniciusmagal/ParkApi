<div align="center">

# 🅿️ ParkingAPI

**Sistema de gerenciamento de estacionamento com API REST, aplicativo Flutter, solicitação de vagas com QR Code e painel administrativo.**

![Java](https://img.shields.io/badge/Backend-Java%2017-orange?style=for-the-badge&logo=openjdk)
![Spring Boot](https://img.shields.io/badge/Framework-Spring%20Boot-6DB33F?style=for-the-badge&logo=springboot)
![H2](https://img.shields.io/badge/Database-H2-1021FF?style=for-the-badge)
![Flutter](https://img.shields.io/badge/App-Flutter-02569B?style=for-the-badge&logo=flutter)


</div>

---

## 🖼 Sobre

O **ParkingAPI** é um sistema de gerenciamento de estacionamento desenvolvido como parte do Projeto Semestral do curso de Análise e Desenvolvimento de Sistemas — IFSP.

O motorista chega ao estacionamento, solicita a vaga pelo aplicativo e recebe um **QR Code** com os dados do ticket. Na saída, o atendente lê o QR Code, o sistema calcula o valor e libera a vaga. O administrador acompanha tudo por um painel com indicadores em tempo real.

---

## 🚀 Funcionalidades

### 🚗 Motorista (perfil CLIENTE)

- Cadastro e login com autenticação JWT
- Solicitação de vaga com formulário curto: nome e CPF apenas na primeira vez, depois somente placa, marca, modelo e cor
- Alocação automática de uma vaga livre
- **QR Code** do ticket com recibo, vaga, placa, nome, CPF mascarado e horário de entrada
- Aba **Minha vaga** com ticket, permanência e valor estimado atualizado em tempo real
- Aba **Histórico** com todas as visitas, total pago e relatório em PDF
- Aceita placas no padrão antigo (`ABC-1234`) e Mercosul (`ABC1D23`)
- Bloqueio de duas vagas simultâneas para o mesmo cliente ou a mesma placa

### 🔐 Administrador (perfil ADMIN)

- **Dashboard**: taxa de ocupação, vagas livres e ocupadas, entradas e saídas do dia, faturamento do dia e total, usuários, clientes, gráfico dos últimos 7 dias e últimas movimentações, com atualização automática
- **Vagas**: mapa em grade com status, placa e motorista de cada vaga ocupada, e cadastro de novas vagas
- **No pátio**: veículos estacionados, busca por placa, vaga ou motorista e check-out
- **Ler QR**: leitura do QR Code pela câmera ou digitação do recibo, com check-out e valor final
- **Usuários**: usuários do sistema e clientes cadastrados
- **Check-in manual** para clientes que não usaram o aplicativo

### 💰 Tabela de preços

| Permanência | Valor |
| --- | --- |
| Até 15 minutos | R$ 5,00 |
| Até 1 hora | R$ 9,25 |
| Cada 15 minutos adicionais | R$ 1,75 |
| A cada 10 estacionamentos concluídos | 30% de desconto |

---

## 🛠 Tecnologias Utilizadas

| Camada | Tecnologias |
| --- | --- |
| Backend | Java 17, Spring Boot 3.2, Spring Security + JWT, Spring Data JPA / Hibernate, Bean Validation |
| Banco de dados | H2 em memória (dados recriados a cada inicialização) |
| Documentação da API | Springdoc / Swagger UI |
| Relatórios | JasperReports (PDF) |
| Aplicativo | Flutter + Dart (Web, Android, iOS, Windows), `qr_flutter`, `mobile_scanner`, `printing` |
| Deploy | Vercel (aplicativo web) e Docker (API) |

---

## 📂 Estrutura do Projeto

```text
ParkApi/
├── api/                         API REST em Spring Boot
│   ├── src/main/java/com/mballem/demoparkapi/
│   │   ├── config/              segurança, auditoria e dados iniciais
│   │   ├── entity/              entidades JPA
│   │   ├── jwt/                 autenticação JWT
│   │   ├── repository/          repositórios e projeções
│   │   ├── service/             regras de negócio e dashboard
│   │   └── web/                 controllers, DTOs e tratamento de erros
│   ├── src/main/resources/      configurações, mensagens e relatórios
│   ├── Dockerfile
│   └── pom.xml
├── park_app/                    aplicativo Flutter
│   ├── lib/
│   │   ├── models/              ticket e cálculo de valores
│   │   ├── screens/cliente/     telas do motorista
│   │   ├── screens/admin/       painel administrativo
│   │   ├── services/            API e sessão
│   │   ├── theme/               cores e estilos
│   │   └── widgets/             componentes reutilizáveis
│   └── pubspec.yaml
├── scripts/                     build do aplicativo na Vercel
├── vercel.json                  deploy do aplicativo web
├── render.yaml                  deploy da API
├── SPEC.md
└── README.md
```

---

## 🔧 Como rodar em qualquer máquina

### 1. Instale os pré-requisitos

| Ferramenta | Versão | Como verificar |
| --- | --- | --- |
| [Git](https://git-scm.com/downloads) | qualquer | `git --version` |
| [JDK](https://adoptium.net/temurin/releases/?version=17) | 17 ou superior | `java -version` |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | 3.x estável (Dart 3.12+) | `flutter --version` |
| Google Chrome | qualquer | necessário para rodar o app no navegador |

> Não é preciso instalar Maven nem banco de dados: o projeto usa o Maven Wrapper (`mvnw`) e o banco H2 em memória.

Depois de instalar o Flutter, rode `flutter doctor` e confirme que o item **Chrome** aparece com ✓.

### 2. Clone o repositório

```bash
git clone https://github.com/Viniciusmagal/ParkApi.git
cd ParkApi
```

### 3. Suba a API (terminal 1)

**Windows (PowerShell ou CMD)**

```powershell
cd api
.\mvnw.cmd spring-boot:run
```

**Linux / macOS**

```bash
cd api
chmod +x mvnw
./mvnw spring-boot:run
```

A primeira execução baixa as dependências e pode levar alguns minutos. A API está pronta quando aparecer no terminal:

```text
Dados iniciais prontos: 12 vagas, admin@park.com e cliente@park.com com senha 123456
```

| Recurso | Endereço |
| --- | --- |
| API | http://localhost:8080 |
| Swagger (documentação interativa) | http://localhost:8080/docs-park.html |
| Console do banco H2 | http://localhost:8080/h2-console (JDBC URL `jdbc:h2:mem:demo_park`, usuário `root`, senha `root`) |

### 4. Rode o aplicativo (terminal 2)

```bash
cd park_app
flutter pub get
flutter run -d chrome
```

O navegador abre automaticamente com a tela de login.

### 5. Entre com os usuários de teste

| Perfil | E-mail | Senha |
| --- | --- | --- |
| Administrador | `admin@park.com` | `123456` |
| Motorista | `cliente@park.com` | `123456` |

Também é possível criar novos motoristas pela opção **Criar conta** (a senha deve ter exatamente 6 caracteres).

### 6. Roteiro rápido de teste

1. Entre como **motorista**, toque em **Solicitar vaga**, preencha o formulário e veja o ticket com QR Code na aba **Minha vaga**.
2. Saia e entre como **administrador**: o dashboard mostra a vaga ocupada e a entrada do dia.
3. Na aba **Ler QR**, aponte a câmera para o QR Code do motorista ou digite o número do recibo exibido no ticket.
4. Clique em **Registrar saída e cobrar** para ver o valor final e liberar a vaga.

### Rodando em outros dispositivos

| Onde o app roda | Comando |
| --- | --- |
| Navegador (Chrome) | `flutter run -d chrome` |
| Emulador Android | `flutter run` (o app usa `http://10.0.2.2:8080` automaticamente) |
| Celular físico na mesma rede Wi-Fi | `flutter run --dart-define=API_BASE_URL=http://IP_DO_COMPUTADOR:8080` |
| API hospedada em outro servidor | `flutter run -d chrome --dart-define=API_BASE_URL=https://endereco-da-api` |

Para descobrir o IP do computador: `ipconfig` no Windows ou `ip addr` / `ifconfig` no Linux e macOS.

### Rodando a API com Docker (opcional)

```bash
cd api
docker build -t parkapi .
docker run -p 8080:8080 parkapi
```

### Testes

```bash
cd park_app
flutter test

cd ../api
./mvnw test
```

### Problemas comuns

| Sintoma | Solução |
| --- | --- |
| "Falha de conexão com a API" no app | Confirme que a API está rodando no terminal 1 e acessível em http://localhost:8080/docs-park.html |
| `Port 8080 was already in use` | Feche o programa que usa a porta 8080 ou rode a API com `--server.port=8081` e o app com `--dart-define=API_BASE_URL=http://127.0.0.1:8081` |
| `JAVA_HOME is not set` | Configure a variável `JAVA_HOME` apontando para a pasta do JDK 17 |
| `permission denied: ./mvnw` (Linux/macOS) | Rode `chmod +x mvnw` |
| Câmera não abre na aba Ler QR | O navegador só libera a câmera em `localhost` ou `https`; use a digitação do recibo como alternativa |
| Dados sumiram | O banco H2 é em memória e é recriado a cada reinício da API |

---

## ☁️ Deploy

### Aplicativo web na Vercel

O arquivo `vercel.json` já configura o build: a Vercel instala o Flutter, compila o app web e publica a pasta `park_app/build/web`.

1. Na Vercel, clique em **Add New → Project** e importe este repositório do GitHub.
2. Mantenha **Root Directory** na raiz do repositório (as configurações de build são lidas do `vercel.json`).
3. Em **Environment Variables**, crie `API_BASE_URL` com o endereço público da API (por exemplo `https://parkapi.onrender.com`).
4. Clique em **Deploy**. A cada novo push na branch principal a Vercel publica uma nova versão.

### API

A Vercel hospeda apenas o aplicativo web. A API é publicada no [Render](https://render.com) a partir do arquivo `render.yaml`:

1. No Render, clique em **New → Blueprint** e selecione este repositório.
2. Confirme a criação do serviço `parkapi-api` (plano gratuito, build pelo `api/Dockerfile`).
3. Copie o endereço gerado (por exemplo `https://parkapi-api.onrender.com`) e use-o na variável `API_BASE_URL` da Vercel.

No plano gratuito o serviço hiberna após um período sem acesso; a primeira requisição depois disso leva cerca de um minuto. Como o banco é em memória, os dados voltam ao estado inicial a cada reinício.

A API também pode ser publicada em qualquer outro serviço que rode contêineres Docker usando o `api/Dockerfile`. A porta é lida da variável `PORT` quando o serviço a define.

---

## 🔗 Principais Endpoints

| Operação | Endpoint |
| --- | --- |
| Login | `POST /api/v1/auth` |
| Cadastro de usuários | `POST /api/v1/usuarios` |
| Clientes | `/api/v1/clientes` |
| Consulta de vaga | `GET /api/v1/vagas/{codigo}` |
| Check-in | `POST /api/v1/estacionamentos/check-in` |
| Consulta por recibo | `GET /api/v1/estacionamentos/check-in/{recibo}` |
| Check-out | `PUT /api/v1/estacionamentos/check-out/{recibo}` |
| Histórico | `GET /api/v1/estacionamentos` |
| Relatório PDF | `GET /api/v1/estacionamentos/relatorio` |
| Solicitar vaga (cliente) | `POST /api/v1/estacionamentos/solicitar` |
| Ticket ativo do cliente | `GET /api/v1/estacionamentos/ativo` |
| Veículos no pátio | `GET /api/v1/estacionamentos/ativos` |
| Histórico geral | `GET /api/v1/estacionamentos/todos` |
| Lista de vagas | `GET /api/v1/vagas` |
| Disponibilidade | `GET /api/v1/vagas/disponibilidade` |
| Dashboard | `GET /api/v1/dashboard` |

---

## 👨‍💻 Autores

Projeto desenvolvido com 💜 por estudantes do IFSP.

<table align="center">
  <tr>
    <td align="center" width="200px">
      <img src="https://avatars.githubusercontent.com/u/155771396?v=4" width="100" height="100" style="border-radius:50%; object-fit:cover;"/><br>
      <b>Geisiele Oliveira</b><br>
      <a href="https://github.com/GeisieleOliveira" target="_blank">
        <img src="https://img.shields.io/badge/GitHub-GeisieleOliveira-black?style=for-the-badge&logo=github"/>
      </a>
    </td>
    <td align="center" width="200px">
      <img src="https://avatars.githubusercontent.com/juayumi" width="100" height="100" style="border-radius:50%; object-fit:cover;"/><br>
      <b>Juliana Ayumi</b><br>
      <a href="https://github.com/juayumi" target="_blank">
        <img src="https://img.shields.io/badge/GitHub-juayumi-black?style=for-the-badge&logo=github"/>
      </a>
    </td>
    <td align="center" width="200px">
      <img src="https://avatars.githubusercontent.com/Thiagolvc" width="100" height="100" style="border-radius:50%; object-fit:cover;"/><br>
      <b>Thiago Oliveira</b><br>
      <a href="https://github.com/Thiagolvc" target="_blank">
        <img src="https://img.shields.io/badge/GitHub-Thiagolvc-black?style=for-the-badge&logo=github"/>
      </a>
    </td>
    <td align="center" width="200px">
      <img src="https://avatars.githubusercontent.com/Viniciusmagal" width="100" height="100" style="border-radius:50%; object-fit:cover;"/><br>
      <b>Vinicius Magalhães</b><br>
      <a href="https://github.com/Viniciusmagal" target="_blank">
        <img src="https://img.shields.io/badge/GitHub-Viniciusmagal-black?style=for-the-badge&logo=github"/>
      </a>
    </td>
  </tr>
</table>
