# Code Health And Performance Contract

Ultima revisao estrutural: 2026-07-31.

## Finalidade

Este documento define como manter o codigo coeso, seguro e eficiente. Ele nao e
um backlog. Prioridades, bloqueios e criterios de release vivem somente em
`FIRST_BETA_ROADMAP.md`.

Reducao de linhas nao e objetivo isolado. Uma mudanca e boa quando reduz pelo
menos um destes custos sem esconder comportamento:

- decisoes duplicadas;
- acoplamento;
- processamento ocioso;
- alocacao;
- trafego;
- round-trips;
- superficie de ataque;
- caminhos legados sem consumidor.

## Baseline Arquitetural

A direcao atual deve ser preservada:

- Client cuida de input, prediction, reconciliacao, animacao e apresentacao;
- Server e autoridade de movimento, combate, inventario, rewards e mundo;
- Auth cuida de credenciais e sessao;
- Gateway cuida de entrada, handshake e selecao de worker;
- MySQL API concentra persistencia e operacoes transacionais;
- MySQL nao participa do loop por frame ou por ataque;
- Overworld e dungeons possuem workers separados;
- `space_id` e chunks limitam interesse;
- snapshots usam baseline/delta, 20 Hz e budget por peer;
- operacoes economicas sensiveis sao idempotentes e auditadas;
- deploy e observabilidade sao coordenados pelo Agent.

Essa base e adequada para beta pequena. Ela ainda nao prova capacidade de MMO
em larga escala; isso exige carga representativa, metas e perfil.

## Cobertura Da Revisao

A revisao de 2026-07-31 inventariou todos os repositorios e todos os arquivos de
codigo, cena e dados rastreados. Foram executados:

- contagem e ranking de arquivos grandes;
- busca global por legado, fallback, TODO, segredo e endpoint inseguro;
- inventario de loops `_process` e `_physics_process`;
- verificacao de referencias de cenas e formatos JSON atuais;
- comparacao byte a byte do contrato RPC espelhado;
- import/parse headless de Client, Server, Auth e Gateway;
- verificacao de diff e whitespace;
- leitura profunda dos caminhos de movimento, snapshots, catalogos, rate limit,
  tokens internos, preloading, spawn, NPC e portal.

Uma revisao estatica integral encontra incoerencias e hotspots provaveis, mas
nao substitui profiler, teste manual ou carga. Nao declarar um sistema
"otimizado" sem medida de runtime.

## Correcoes Estruturais Aplicadas

- removido o token interno compartilhado como fallback;
- tokens de Auth, Gateway, Server e Web precisam ser distintos e fortes;
- rate limit Web conta falhas de login e toda tentativa de cadastro; sucesso de
  login nao apaga o historico de falhas do IP;
- entradas expiradas do limiter sao limpas periodicamente;
- removido RPC antigo de direcao; movimento usa apenas comandos sequenciados;
- removidos fallbacks para catalogos agregados inexistentes;
- removidos formatos antigos de skill unica e servico unico de NPC;
- formato atual de Bits deixou de ser chamado incorretamente de legado;
- hotbar, loading e resource preloader nao processam quando ociosos;
- respawn, timeout de instancia e range de NPC usam polling limitado;
- estado completo do mundo e coletado na taxa de snapshot, nao tres vezes mais;
- VSync e o padrao do Client para evitar renderizacao irrestrita.

## Regras De Refatoracao

1. Preservar contratos de RPC, API, JSON e persistencia em mudancas mecanicas.
2. Separar alteracao funcional de movimentacao/extracao de codigo.
3. Nao criar abstracao generica sem dois consumidores estaveis.
4. Nao dividir um arquivo apenas pelo numero de linhas.
5. Extrair quando houver responsabilidades, lifecycle ou dependencias distintas.
6. Remover fallback somente depois de provar que nao ha produtor nem consumidor.
7. Manter logs correlacionaveis para fluxos multi-etapa.
8. Nunca ampliar tolerancias para esconder divergencia de simulacao.
9. Medir antes e depois de uma otimizacao relevante.
10. Reverter uma otimizacao se legibilidade ou jogabilidade piorar sem ganho real.

Arquivos grandes atuais devem ser divididos por fronteira, nao por tamanho:

- `movement_controller.gd`: input history, simulacao e apresentacao;
- `portal_manager.gd`: catalogo, instancia e handoff;
- `datamoon_enemy.gd`: IA, combate e replicacao;
- `inventory.gd`: uso, equipamento, rewards e operacoes;
- handlers Go: agregado e use case.

Essas extracoes devem ocorrer depois do release gate quando o fluxo afetado ja
possuir um roteiro manual reproduzivel.

## Estrategia Godot Hibrida

### Cenas

Preferir cenas para estruturas visuais e autoradas:

- entidades;
- mapas e colisoes;
- janelas e componentes de UI;
- AnimationTree;
- anchors e markers;
- shaders e materiais;
- variantes visuais reutilizaveis.

Uma cena deve tornar hierarquia e contrato visual legiveis no editor. Evitar
cenas duplicadas que diferem apenas por cor ou valor de catalogo.

### Codigo

Preferir codigo para comportamento dinamico:

- rede;
- prediction e reconciliacao;
- autoridade;
- state machines;
- streaming;
- pooling;
- lifecycle;
- validacao;
- persistencia;
- composicao runtime orientada por dados.

Nao montar por codigo uma arvore visual estavel que seria mais clara e barata de
manter como cena.

### JSON

Preferir dados para conteudo ajustavel:

- stats e timings;
- drops e rewards;
- quests;
- receitas;
- portais;
- spawns;
- NPCs;
- disponibilidade;
- presets e paletas.

JSON nao deve conter autoridade secreta que o Client possa alterar para obter
vantagem. O Server carrega e valida o contrato canonico.

## Performance Do Client

Metas iniciais de perfil:

- 60 FPS sustentados em hardware alvo;
- frame de CPU e GPU abaixo de 16,67 ms no p95;
- sem stutter perceptivel em troca de mapa;
- memoria estabiliza depois de carregar/descarregar conteudo;
- nenhuma fila de recursos permanece processando quando vazia.

Cuidados:

- palette swap compartilha shader e atualiza uniforms apenas quando a aparencia
  muda;
- camadas de personagem aumentam draw calls; ocultar camadas vazias e evitar
  materiais unicos sem necessidade;
- usar nearest e alinhamento inteiro para pixel art;
- carregar por mapa/manifesto quando o catalogo crescer;
- pool apenas quando o profiler mostrar churn em projeteis, efeitos ou textos;
- VSync fica ligado por padrao e um limite configuravel pode ser adicionado;
- renderer Compatibility so deve substituir Forward Plus depois de comparar
  shaders, visual, GPU e compatibilidade em hardware real.

## Performance Do Server

Metas iniciais de perfil:

- physics tick sem overruns;
- snapshot build abaixo do budget de tick;
- trafego limitado por peer;
- nenhuma operacao MySQL no caminho por frame;
- memoria por worker estabiliza apos cleanup de instancia;
- filas de API e logs permanecem limitadas.

Cuidados:

- atualizar estado replicado na frequencia realmente publicada;
- manter interest management por chunk e `space_id`;
- evitar scan global por evento de combate;
- batch de presenca quando a escala justificar;
- indice espacial adicional somente quando scans aparecerem no profiler;
- manter Dungeon 1 apenas no PBE enquanto nao houver necessidade de capacidade;
- nao aumentar snapshot rate para mascarar interpolacao ou prediction incorreta.

## Performance Da API E Banco

- tokens por servico e comparacao em tempo constante;
- endpoints especificos, nunca SQL generico;
- transacoes curtas e idempotentes;
- pool de conexoes limitado;
- indices guiados por consultas reais;
- cleanup de auditoria em batches;
- sem persistencia por frame, movimento ou ataque;
- medir p50, p95, p99, erros e saturacao antes de ampliar pool;
- usar slow-query log durante teste de carga, nao logging detalhado permanente.

## Observabilidade

INFO registra transicoes importantes, bloqueios e operacoes sensiveis. DEBUG
pode conter snapshots completos temporarios. Nunca registrar:

- senha;
- token;
- ticket;
- conteudo de chat;
- movimento por frame;
- cada ataque aceito.

Metricas prioritarias:

- frame/tick time;
- entidades e peers;
- bytes e tamanho de snapshot;
- fila e latencia da API;
- conexoes e slow queries;
- memoria por worker;
- handoff por resultado;
- reconciliacao por distancia aplicada.

## Gate De Qualidade

Antes de publicar uma alteracao:

- `git diff --check`;
- import/parse Godot nos repos afetados;
- JSON valido e referencias existentes;
- RPC espelhado quando alterado;
- `gofmt`, `go vet ./...` e `go build ./...` para API;
- sintaxe Node para Web;
- roteiro manual do fluxo afetado;
- logs sem erro novo;
- documentacao contratual e roadmap atualizados quando aplicavel.

O projeto nao mantem arquivos de teste automatizado por decisao atual. Build,
parse, analise estatica e validacao manual continuam obrigatorios.
