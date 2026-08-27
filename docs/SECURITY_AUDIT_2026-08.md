# Auditoria De Seguranca - 2026-08

## Escopo

Auditoria estática dos contratos entre Client, Gateway, Auth, MySQL API e Game
Server, com foco em autenticação, sessões, autoridade, operações persistentes,
rate limit, logs e referências legadas. O Agent e os arquivos operacionais
também foram verificados após a reorganização local do workspace.

## Fluxo Atual

1. O Client envia credenciais ao Gateway por RPC confiável.
2. O Gateway valida limites básicos, versão do Client e cooldown por conexão;
   o Auth encaminha a operação sem decidir estado de jogo.
3. O Auth consulta a API com token interno próprio. A API valida credenciais
   com bcrypt, exige e-mail verificado, aceite legal quando aplicável e emite
   sessão assinada com `credential_version`.
4. Para entrar no jogo, a API emite um ticket curto, de audiência específica,
   persistido por hash. O Server consome o ticket uma vez e cria a sessão.
5. O Server valida estado da conexão, payload, categoria de RPC, ownership,
   lease e fencing token antes de executar operações.
6. A API é a autoridade de persistência para personagens, inventário,
   progressão, recompensas, evolução, presença, chat e handoff. Operações
   econômicas usam transação, lock e/ou idempotência.
7. O Client replica estado autorizado e apresenta UI, animação, predição e
   interpolação. Nenhum resultado de combate ou recompensa deve ser aceito do
   Client como autoridade.

## Controles Confirmados

- Tokens internos separados para Auth, Gateway, Server e Web, com comprimento
  mínimo, unicidade e comparação em tempo constante.
- API configurada para escutar em loopback por padrão; endpoints de health e
  readiness são os únicos públicos sem autenticação de serviço.
- JSON limitado a 1 MiB, sem campos desconhecidos e sem conteúdo após o objeto.
- Senhas com bcrypt cost 12, mínimo de 10 caracteres e limite de 72 bytes.
- Login usa hash dummy para reduzir enumeração por diferença de tempo e retorna
  resposta genérica para credenciais inválidas.
- Tokens de verificação, reset e mudança de e-mail são aleatórios, armazenados
  somente por hash, expiram e são consumidos uma única vez.
- Alteração de senha/e-mail incrementa `credential_version`, invalidando
  sessões antigas.
- Sessões de personagem usam lease, fencing e checkpoints monotônicos para
  evitar escrita atrasada de worker antigo.
- Rotas de suporte filtram tickets por proprietário e exigem `is_admin` para
  moderação ou atualização administrativa.
- RPC admission guard limita estado, categoria, tamanho e taxa de payloads;
  violações estruturais podem encerrar a conexão.
- Logs operacionais não devem conter senhas, tokens, e-mails ou corpo de
  chamados; conteúdo de suporte permanece no banco.

## Correcoes Aplicadas Nesta Auditoria

- O fallback fixo de rota do Gateway deixou de ser automático. O registry é
  sempre tentado primeiro; em falha, a conexão é recusada por padrão.
- O fallback antigo só pode ser habilitado explicitamente com
  `DATAMOON_ALLOW_OVERWORLD_FALLBACK=true`, para recuperação controlada e
  temporária.
- Os gates do Agent agora detectam tanto o layout da VM quanto o layout local
  `datamoon_online`, evitando checks falsamente ignorados ou caminhos mortos.
- O texto residual `Teste Warning` foi removido da cena, mantendo o painel de
  avisos funcional.

## Limpeza E Referencias Legadas

Não foi removido nenhum script de runtime apenas porque contém `debug`,
`fallback`, callback vazio ou migration antiga. Esses itens têm consumidores
dinâmicos, uso operacional, compatibilidade de dados ou são necessários para
diagnóstico. As únicas remoções seguras nesta passada foram o texto de teste e
o caminho rígido obsoleto dos gates.

Os arquivos de exportação com `debug/export_console_wrapper`, cores de debug do
editor, métricas DEBUG e migrations históricas não são lixo por si só. Devem
ser removidos somente quando o fluxo que os consome deixar de existir e houver
uma migração ou release que preserve os dados necessários.

## Pendencias De Producao

- Rotacionar imediatamente qualquer credencial que tenha sido exposta em
  terminal, chat, ticket ou histórico de trabalho.
- Manter o fallback desativado e validar o registry de workers antes de abrir
  novas regiões ou workers.
- Implementar backup MySQL criptografado fora da VM e testar restauração.
- Adicionar alertas externos para falhas de autenticação, tickets, economia,
  handoff, leases, rate limit e indisponibilidade de workers.
- Substituir limites locais por limiter compartilhado/WAF quando houver mais de
  uma instância Web ou Gateway.
- Executar testes de carga e revisar retenção de logs, auditoria e dados
  pessoais antes do lançamento público.

## Validacao

- `go test ./...` no MySQL API: aprovado.
- Importação headless Godot 4.7.1 em Client, Server, Auth e Gateway: aprovada.
- Catálogos Server/API: 38 definições sincronizadas.
- Contrato de movimento: 35 constantes sincronizadas.
- `git diff --check` nos repositórios alterados: aprovado.
