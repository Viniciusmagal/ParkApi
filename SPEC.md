# SPEC — Solicitação de Vaga com QR Code e Painel Administrativo

## 1. Contexto atual

| Camada | Estado encontrado |
| --- | --- |
| Backend (`api`) | Spring Boot 3.2, JWT, H2 em memória, perfis `ADMIN` e `CLIENTE`. Check-in só pode ser feito pelo ADMIN informando o CPF de um cliente previamente cadastrado. Não existe listagem de vagas, visão de estacionamentos ativos nem dashboard. |
| App (`park_app`) | Flutter (rodando na Web). Telas: Login, Cadastro, Home e Check-in. Todos os perfis caem na mesma Home. |

### Problemas encontrados durante a análise

1. `home_screen.dart` lê o token na chave `token`, mas o login salva em `jwt_token` → a Home sempre recebe 401 e mostra 0 vagas.
2. A Home chama `GET /api/v1/vagas`, endpoint que não existe.
3. O cadastro aceita senha com 6 ou mais caracteres, mas a API exige **exatamente 6** → senhas maiores falham com 422.
4. As datas são serializadas com `hh` (formato 12h) → 14:00 aparece como 02:00.
5. `GET /clientes/detalhes` devolve 500 quando o usuário ainda não tem cliente cadastrado.
6. `SpringJpaAuditingConfig` retorna `null` em vez de `Optional.empty()` quando não há usuário autenticado.
7. Mensagem de CPF duplicado diz "não registrado" quando deveria dizer "já cadastrado".
8. Não existe usuário administrador inicial — não é possível testar o perfil ADMIN sem mexer no banco.

## 2. Objetivo

1. O motorista, ao chegar ao estacionamento, **solicita a vaga pelo app** com um formulário curto.
2. O sistema aloca automaticamente uma vaga livre e gera um **QR Code** com os dados do ticket.
3. O motorista passa a ter uma aba **"Minha vaga"** com o ticket, QR Code, tempo decorrido e valor estimado.
4. O administrador tem um **painel próprio**: dashboard, mapa de vagas, estacionamentos em aberto, leitura do QR Code / check-out, usuários e clientes.

## 3. Fluxos

### 3.1 Motorista (perfil CLIENTE)

```
Login → Início (vagas livres) → [Solicitar vaga] → Formulário → Ticket com QR Code
                                                              ↓
                                         Aba "Minha vaga" (sempre disponível até o check-out)
```

Formulário (poucos campos):

| Campo | Regra |
| --- | --- |
| Nome | obrigatório — só pedido na 1ª vez |
| CPF | obrigatório, válido — só pedido na 1ª vez |
| Placa | `ABC-1234` (antiga) ou `ABC1D23` (Mercosul) |
| Marca | obrigatório |
| Modelo | obrigatório |
| Cor | obrigatório |

Regras de negócio:
- Na primeira solicitação o cadastro de **Cliente** é criado automaticamente com nome e CPF; nas próximas, só os dados do carro são pedidos.
- Um cliente não pode ter duas vagas em aberto (409).
- Uma mesma placa não pode estar estacionada duas vezes (409).
- Sem vaga livre → mensagem "Não há vaga disponível" (404).

### 3.2 Conteúdo do QR Code

JSON compacto, lido pelo módulo do administrador:

```json
{"app":"ParkAPI","recibo":"20260927-143012","vaga":"A-03","placa":"ABC1D23","nome":"Maria","cpf":"***.***.*89-01","entrada":"2026-09-27 14:30:12"}
```

O CPF vai mascarado no QR; o recibo é a chave usada para consultar a API.

### 3.3 Administrador (perfil ADMIN)

| Aba | Conteúdo |
| --- | --- |
| Dashboard | Vagas totais / livres / ocupadas, taxa de ocupação, veículos no pátio, entradas e saídas do dia, faturamento do dia e total, usuários e clientes, gráfico de entradas dos últimos 7 dias, últimas movimentações |
| Vagas | Mapa em grade (verde = livre, vermelho = ocupada) com placa/cliente da vaga ocupada; cadastro de nova vaga |
| Em aberto | Lista de todos os veículos no pátio com tempo decorrido e botão de check-out |
| Ler QR | Câmera lendo o QR Code do motorista (ou digitação do recibo) → detalhes do ticket → check-out com valor final |
| Usuários | Lista de usuários (perfil) e de clientes cadastrados |
| + | Check-in manual (tela já existente) |

## 4. Backend — alterações

### Novos endpoints

| Método | Rota | Perfil | Descrição |
| --- | --- | --- | --- |
| POST | `/api/v1/estacionamentos/solicitar` | CLIENTE | Solicita vaga (cria cliente se necessário) e retorna o ticket |
| GET | `/api/v1/estacionamentos/ativo` | CLIENTE | Ticket em aberto do usuário logado (204 se não houver) |
| GET | `/api/v1/estacionamentos/ativos` | ADMIN | Todos os veículos no pátio |
| GET | `/api/v1/estacionamentos/todos` | ADMIN | Histórico geral paginado |
| GET | `/api/v1/vagas` | ADMIN | Lista de vagas |
| GET | `/api/v1/vagas/disponibilidade` | autenticado | Total, livres e ocupadas |
| GET | `/api/v1/dashboard` | ADMIN | Indicadores do painel |

### Arquivos

- `web/dto/SolicitacaoVagaDto.java`, `web/dto/DashboardDto.java`, `web/dto/DisponibilidadeDto.java`
- `web/controller/DashboardController.java`
- `service/DashboardService.java`
- `exception/SolicitacaoVagaException.java` (+ handler 409/422)
- `config/DataInitializer.java` — cria vagas A-01…A-06 / B-01…B-06, `admin@park.com` e `cliente@park.com` (senha `123456`) quando `app.seed.enabled=true` (desligado nos testes).
- Ajustes: `EstacionamentoService`, `ClienteVagaRepository`, `VagaRepository`, `UsuarioRepository`, `VagaService`, `ClienteService`, `EstacionamentoResponseDto` (+`clienteNome`), `ClienteVagaProjection` (+`clienteNome`), formatos de data `HH`, `SpringJpaAuditingConfig`, `messages.properties`.

## 5. App Flutter — alterações

```
lib/
├── main.dart
├── theme/app_colors.dart
├── services/api_service.dart      (URL via --dart-define, tratamento de erros)
├── services/session.dart          (token, perfil e e-mail; lê o perfil do JWT)
├── models/ticket.dart
├── widgets/ticket_card.dart       (ticket + QR Code)
├── widgets/stat_card.dart
└── screens/
    ├── login_screen.dart          (redireciona por perfil)
    ├── register_screen.dart       (senha de 6 caracteres)
    ├── checkin_screen.dart        (check-in manual do admin)
    ├── cliente/cliente_shell.dart  · inicio_tab · solicitar_vaga_screen · minha_vaga_tab · historico_tab
    └── admin/admin_shell.dart      · dashboard_tab · vagas_tab · ativos_tab · validar_qr_tab · usuarios_tab
```

Pacotes novos: `qr_flutter` (gera o QR) e `mobile_scanner` (lê o QR pela câmera).

Identidade visual mantida: fonte padrão do app (Material/Roboto), azul `#1D4ED8` / `#1E3A8A`, fundo `#F8FAFC`, campos `#F1F5F9` com bordas arredondadas de 12.

## 6. Restrições

- Nenhum comentário no código.
- Mesma fonte e estilo visual já usados.
- Testes de integração existentes do backend devem continuar passando.

## 7. Plano de execução

1. Backend: correções (itens 4–8 da seção 1) e seed.
2. Backend: solicitação de vaga, ativos, vagas, disponibilidade e dashboard.
3. Backend: compilar e rodar `mvnw test`.
4. App: sessão, API e roteamento por perfil; correções 1–3.
5. App: telas do motorista (Início, Solicitar, Minha vaga com QR, Histórico).
6. App: telas do administrador (Dashboard, Vagas, Em aberto, Ler QR, Usuários).
7. `flutter analyze`, build web e teste ponta a ponta com a API rodando.
8. Atualizar o README com credenciais e forma de execução.

## 8. Sugestões além do pedido (incluídas)

- Aceitar placa Mercosul na solicitação.
- CPF mascarado no QR Code (LGPD).
- Valor estimado em tempo real na aba "Minha vaga", usando a mesma tabela de preços da API.
- Bloqueio de dupla solicitação por cliente/placa.

## 9. Sugestões futuras (não incluídas)

- Trocar H2 em memória por MySQL (os dados somem ao reiniciar a API).
- Tirar a chave JWT do código e ler de variável de ambiente.
- Permitir senhas maiores que 6 caracteres.
- Reserva antecipada com expiração e pagamento via Pix no check-out.
