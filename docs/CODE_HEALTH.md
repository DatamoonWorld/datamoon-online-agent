# Contrato De Qualidade E Performance

Este documento define o padrao permanente de qualidade. Status e melhorias
planejadas vivem em `FIRST_BETA_ROADMAP.md`; regras de implementacao vivem em
`../ai/CODE_RULES.md`.

## Objetivo

Uma alteracao deve reduzir complexidade, risco, custo de runtime ou duplicacao
sem esconder comportamento. Menos linhas, por si so, nao representam melhoria.

## Coesao

- Cada responsabilidade possui um repositorio e uma camada proprietaria.
- Regra de dominio possui uma implementacao autoritativa.
- IDs, payloads e estados usam nomes consistentes entre produtores e
  consumidores.
- Cenas compoem elementos visuais; JSON descreve conteudo; codigo coordena
  comportamento e estado dinamico.
- Modulos extraidos precisam ter fronteira real, lifecycle claro e API menor
  que o acoplamento removido.
- Documentos nao repetem status, formulas ou comandos pertencentes a outro
  proprietario.

## Limpeza

Classifique antes de remover:

- `ativo`: possui produtor e consumidor atuais;
- `preparado`: ainda sem fluxo final, mas possui decisao e uso futuro aprovado;
- `compatibilidade`: atende consumidor real durante migracao;
- `morto`: sem produtor, consumidor ou futuro aprovado;
- `desconhecido`: exige rastreamento antes de qualquer exclusao.

Somente codigo morto comprovado deve ser apagado imediatamente. Caminho
preparado precisa estar descrito em `GAMEPLAY_FEATURES.md`; compatibilidade
precisa de prazo no roadmap.

## Godot Hibrido

Use cenas para hierarquia visual, anchors, colisores, animacoes e composicoes
reutilizaveis. Use codigo para estado runtime, rede, regras, factories e
variacoes data-driven. Use JSON para stats, itens, skills, NPCs, spawns,
portais, quests, dungeons e receitas.

Evite cenas gigantes com dados embutidos, criacao visual integral por codigo,
nodes sem lifecycle e duplicacao da mesma entidade friend/enemy quando uma cena
parametrizada resolve com clareza.

## Client

- Processar apenas nodes ativos e visiveis.
- Respeitar VSync e pixel crisp no viewport definido.
- Precarregar recursos frequentes e evitar load sincrono durante combate.
- Usar pooling somente quando profiler demonstrar churn relevante.
- Interpolar entidades remotas; predizer apenas o dono local.
- Aplicar snapshots por versao/tick e descartar estado antigo.
- Nao fazer polling de UI quando sinais ou eventos resolvem.

## Server

- Manter estado quente em memoria e persistir por evento/checkpoint.
- Filtrar por worker, `space_id`, chunk e interesse antes de iterar entidades.
- Limitar pathfinding, percepcao, snapshots e trabalho caro por tick.
- Distribuir repath e tarefas periodicas para evitar picos de frame.
- Nao aguardar rede ou banco dentro da simulacao critica.
- Separar lifecycle visual de rewards persistentes idempotentes.
- Medir tick time, filas, entidades, bytes e operacoes antes de escalar workers.

## API E Banco

- Endpoint representa operacao de dominio e menor privilegio.
- Usar transacao, ownership, fence, request hash e `operation_id` onde cabivel.
- Indexar consultas reais, nao hipoteses.
- Reter auditorias por 180 dias por padrao e limpar por job controlado.
- Nunca executar escrita por movimento, frame ou ataque comum.
- Medir latencia p50/p95/p99, conexoes, locks e queries lentas.

## Rede

- Mensagens pequenas, tipadas, limitadas e validadas.
- Sequencias e versoes monotonicas protegem contra reorder e replay.
- Dados confiaveis apenas para eventos que nao podem ser perdidos.
- Baseline/delta e budget por peer limitam snapshots.
- Correcao visual nao pode mascarar divergencia autoritativa crescente.

## Fronteiras De Fragmentacao

As extracoes devem preservar as fachadas publicas e mover apenas uma
responsabilidade coesa:

- Client `worldstate_buffer.gd`: fila, rejeicao por tick e interpolacao de
  snapshots remotos.
- Client `movement_action_timing.gd`: duracoes derivadas de frames/payloads e
  consultas puras da predicao de movimento.
- Server `snapshot_interest.gd`: candidatos, prioridade e budget de entidades
  por peer.
- API `game_write_authorization.go`: ownership e fences compartilhados pelas
  escritas de personagem/Datamoon.
- API `guild_policy.go`: normalizacao, permissoes e auditoria de Guild.

`rpc_surface`, fachadas de portal, loaders de catalogo e brains de IA nao devem
ser partidos apenas por tamanho. Eles continuam sendo pontos de contrato ou
coordenacao; uma nova extracao exige consumidor real, testes de comportamento e
reducao comprovada de acoplamento.

## Observabilidade

- INFO para transicoes relevantes, bloqueios, erros e operacoes administrativas.
- DEBUG para snapshots completos e diagnostico temporario.
- `operation_id` somente em fluxos com varias etapas.
- Logs estruturados em journald, sem JSONL duplicado.
- Nunca logar senha, token, ticket ou conteudo normal do chat.

## Escala

A arquitetura e adequada a uma producao media somente depois de carga
representativa. Antes de aumentar capacidade, medir:

- CPU, memoria e swap por servico;
- tick time e atraso de loop do Server;
- jogadores e entidades por worker/space/chunk;
- snapshot bytes/s, fila e descartes;
- API p95/p99 e saturacao do pool;
- locks, slow queries e tamanho do banco;
- latencia, jitter, perda e reconnections.

## Gate De Entrega

- Formatadores e parsers passam.
- Projetos Godot importam em headless sem erro de script.
- Catalogos sincronizados passam no gate semantico.
- `git diff --check` nao encontra whitespace invalido.
- Nao ha segredo ou artefato gerado no diff.
- Documentacao proprietaria foi atualizada.
- Fluxo manual afetado foi executado e seus riscos residuais registrados.
