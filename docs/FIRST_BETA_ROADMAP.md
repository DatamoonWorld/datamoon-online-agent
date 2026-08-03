# Datamoons Online - Roadmap Principal

Ultima consolidacao: 2026-07-31.

## Uso Deste Documento

Este e o unico backlog operacional do jogo. Toda prioridade, status, bloqueio e
criterio de aceite deve existir aqui. Documentos tematicos continuam definindo
contratos duraveis de combate, mundo, economia, Link, quests, dungeons,
personagens e operacao, mas nao mantem filas de trabalho concorrentes.

Estados usados:

- `VALIDADO`: implementado e aprovado manualmente no PBE;
- `IMPLEMENTADO`: existe, mas ainda precisa do aceite final;
- `EM ANDAMENTO`: alteracao local ainda nao publicada ou nao validada;
- `PENDENTE`: necessario para a entrega atual;
- `FUTURO`: nao bloqueia a v0.04;
- `DESATIVADO`: codigo preservado, sem fonte de acesso no conteudo atual.

## Objetivo Da v0.04

Entregar uma fatia vertical curta e coerente:

1. login;
2. criacao completa de personagem;
3. escolha do Datamoon inicial;
4. entrada no Digital Center;
5. onboarding pelo Devmoon;
6. progressao na Moonlight Forest;
7. conclusao da Moonlight Cavern;
8. encerramento da linha inicial entre os levels 12 e 13.

O beta e pequeno e controlado. A arquitetura deve continuar segura e preparada
para crescer, mas nao receber abstracoes ou infraestrutura de grande escala sem
uma metrica que justifique o custo.

## Painel Executivo

### Validado No PBE

- login WSS com TLS valido, ticket curto e selecao de worker;
- Overworld e Dungeon 1 em processos separados; Dungeon 2 desativada;
- movimento autoritativo com prediction, ACK, replay e reconciliacao suave;
- controle direto do Player e do Datamoon;
- combate, critico, defesa, equipamentos, Link e persistencia de HP/MP;
- Party cross-worker, handoff, HUD acinzentada e remocao offline;
- Chat com mute, slow mode e antispam;
- Fishing contra replay/timing;
- Hatchery idempotente;
- Craft/Cooking em motor compartilhado;
- Guild, permissoes, convites e auditoria;
- equipamentos Unscan, Upgrade e Alternate;
- deploy coordenado, logs estruturados e auditoria com retencao de 180 dias;
- snapshots baseline/delta, limite por peer, chunks e `space_id`.

### Implementado, Com Aceite Final Pendente

- sete quests iniciais e rewards idempotentes;
- Moonlight Cavern, boss rastreado e retorno seguro;
- Slimmoon e Nocmoon com personalidade de IA por especie, grupos por area e combat profile data-driven;
- portais de mapa e dungeon data-driven;
- poções autoritativas de 10% de HP/MP, arredondadas para cima;
- projeteis e areas autoritativos;
- sincronizacao de impacto por frames;
- conteudo desativado por `enabled: false`;
- Link aplicando de 10% a 100% dos stats de equipamento;
- hashes de catalogo entre Client, Server e API.

### Em Andamento Nesta Revisao

- remocao do RPC antigo de movimento e de fallbacks de catalogo inexistentes;
- tokens internos obrigatoriamente distintos e com no minimo 32 caracteres;
- rate limit Web contabilizando falhas de login e toda tentativa de cadastro,
  com limpeza de entradas expiradas;
- processamento ocioso reduzido em hotbar, loading e resource preloader;
- refresh do estado de mundo alinhado aos snapshots de 20 Hz;
- polling de respawn, instancias e sessao de NPC desacelerado;
- VSync habilitado por padrao no Client;
- consolidacao de documentos e inventario de performance.

## Conteudo Canonico Da v0.04

### Mapas

- `digital_center`: hub inicial, Devmoon e portais principais;
- `moonlight_forest`: Slimmoon 1-3, Nocmoon 3-6 e acesso a dungeon;
- `moonlight_cavern`: Nocmoon 7-8 e boss Nocmoon level 13.

Digital Center, Moonlight Forest e Moonlight Cavern ainda precisam receber
TileMaps, colisoes e composicao visual finais. Cada mapa deve ser uma cena
propria. O registro `space_id -> PackedScene` e o fluxo de troca ja existem.

### Portais

Uma unica cena compartilhada recebe comportamento data-driven:

- portal principal de cidade lista destinos de mapa autorizados;
- portal de retorno leva ao ponto seguro do portal principal;
- portal mapa-a-mapa declara destino direto;
- portal de dungeon lista templates, requisitos e disponibilidade;
- portal vermelho fica oculto ate o desbloqueio por quest.

O Server e a autoridade para `enabled`, level, limite diario, Party, origem,
destino e transferencia. O Client apenas apresenta opcoes e estado visual.

### Inimigos E Boss

- Slimmoon de campo: `wild_easy`, `slimmoon_coward`, sem skills;
- Nocmoon de campo: `wild_easy`, `nocmoon_territorial`, sem skills;
- Nocmoon de dungeon: `dungeon_easy`, `nocmoon_territorial`, sem skills;
- boss: stats solo fixos, sem escala por quantidade da Party;
- boss: HP x12, ATK x0.65, DEF x0.9 e attack speed 2.0;
- boss: grace inicial de 1.8 s;
- Fang Strike abaixo de 40% de HP, cooldown de 10 s;
- boss: 5% de `data_nocmoon_dna` como drop proprio;
- conclusao depende da entidade exata do boss da instancia;
- saida automatica ocorre 10 s depois da conclusao.

`ai_behavior` seleciona a personalidade autoritativa da especie. Slimmoon usa
panico coletivo ao receber dano; Nocmoon usa aggro territorial coletivo ao
detectar ou receber dano. Estados e autoria estao definidos em
`docs/ENEMY_AI.md`.

### Quests

| Quest | Requisito | Objetivo | Reward |
| --- | --- | --- | --- |
| Q1 | Level 1 | Falar com Devmoon | 332 EXP |
| Q2 | Level 3 + Q1 | Falar com Devmoon | 2.379 EXP |
| Q3 | Level 5 + Q2 | Falar com Devmoon | 7.204 EXP, Starter Bracelet, 10 energias verdes e 10 azuis |
| Q4 | Level 7 + Q3 | Derrotar 3 Slimmoon | 15.532 EXP |
| Q5 | Level 9 + Q4 | Derrotar 3 Nocmoon | 27.000 EXP |
| Q6 | Level 10 + Q5 | Completar Moonlight Cavern | 35.000 EXP e Unscan Digital Bracelet |
| Q7 | Level 12 + Q6 | Explicacao de Link/evolucao | Sem reward |

Rewards de quest sao operacoes autoritativas e idempotentes. Turn-in duplicado
nao pode conceder reward novamente.

### Dungeon

Reward de conclusao diaria elegivel:

- 10.000 EXP;
- 100 Link EXP;
- 500 Bits;
- 1 Upgrade Chip;
- 5% de chance de 1 Alternate Chip.

O reset e `03:00 UTC`, equivalente a `00:00 America/Sao_Paulo` sem horario
de verao vigente. O retorno deve usar o portal de origem e um ponto seguro ao
lado dele.

### Conteudo Ativo

- Devmoon;
- Starter Bracelet;
- Digital Bracelet e seu Unscan;
- Upgrade Chip e Alternate Chip como rewards;
- energias verde e azul;
- Slimmoon, Nocmoon e materiais aprovados;
- Moonlight Cavern.

### Conteudo Preservado E Desativado

Nao apagar estes sistemas ou catalogos:

- Archive;
- Hatchery;
- Craft;
- Cooking;
- Equipment NPC;
- Fishing;
- Guild;
- Hood, Shoes, Gloves, Shirt e Pants;
- receitas, DataEggs e consumiveis futuros.

Eles ficam sem NPC, portal, receita ou fonte de obtencao ativa. Fishing tambem
fica inacessivel porque a Rod nao possui fonte na v0.04. Itens nao precisam de
`enabled`; disponibilidade e controlada pelas fontes autoritativas.

## Criacao De Personagem

Status: `PENDENTE` e bloqueia a experiencia final da v0.04.

Fluxo aprovado:

1. login;
2. draft local de nome e aparencia;
3. escolha do Datamoon inicial;
4. confirmacao unica;
5. transacao idempotente cria personagem, Datamoon e baseline;
6. entrada no jogo.

Nada e persistido antes da confirmacao final. Fechar ou desconectar descarta o
rascunho.

Opcoes:

- body masculino ou feminino;
- tres paletas predefinidas de pele;
- cabelo e tres ou quatro paletas;
- olhos e tres ou quatro paletas;
- roupa casual ou urbana.

Aparencia e composta por body, hair, eyes, head, shirt, pants, gloves, shoes e
bracelet. A roupa inicial e um preset, mas suas camadas sao persistidas
separadamente para permitir substituicao visual futura por equipamento.

Body, cabelo, olhos e roupa inicial nao sao itens. O personagem nasce sem
bracelet visual; a camada aparece quando o Bracelet recebido na quest e
equipado. Fishing Rod continua sendo item, mas nao e obtida na v0.04.

O Client usa cenas para composicao visual estavel e shader de palette swap com
cores predefinidas. O Server valida IDs e persiste escolhas; nao recebe RGB
arbitrario nem confia na composicao visual enviada pelo Client.

Contrato detalhado: `CHARACTER_CREATION.md`.

## Pendencias De Codigo

Bloqueiam ou precisam ser resolvidas antes do release candidate:

- implementar persistencia atomica da nova criacao de personagem;
- implementar composicao visual por camadas no Client;
- integrar equipamento visual sem transformar roupa inicial em inventario;
- configurar frames finais de Fang Strike;
- implementar HUD central do boss por distancia;
- fechar pontos autoritativos dos portais com os mapas finais;
- consolidar a baseline SQL limpa antes do reset do banco;
- executar `go vet ./...` e `go build ./...` na VM/CI com Go disponivel;
- validar sintaxe/build Web e imports Godot em ambiente gravavel;
- atualizar a versao do Client de `0.03` para `0.04` somente no release candidate.

Nao bloqueiam a v0.04:

- dividir arquivos grandes sem mudanca funcional;
- substituir chat polling por pub/sub;
- dividir overworld em varios workers;
- criar indice espacial adicional antes de perfil de carga;
- migrar renderer sem comparacao visual e de frame time.

## Pendencias Visuais

- criar as tres cenas finais de mapa;
- finalizar TileMaps, colisoes e pontos de entrada/retorno;
- finalizar Player, Slimmoon, Nocmoon e Fang Strike;
- produzir camadas e mascaras da criacao de personagem;
- criar HUD superior do boss;
- posicionar Devmoon, spawns e portais;
- revisar pixel crisp em nomes, tiles, HUD, tooltips e movimento;
- corrigir o texto de dano do Slimmoon, que surge abaixo do sprite e salta para
  cima antes de seguir sua animacao de subida;
- confirmar que somente conteudo ativo aparece.

Pixel crisp significa manter sprites e camera alinhados a pixels inteiros,
filtro nearest, escalas inteiras quando possivel e evitar subpixel em elementos
que devem permanecer nitidos.

## Validacao Manual Final

### Conta Nova

- criar conta;
- login WSS;
- criar personagem sem persistencia parcial;
- escolher Datamoon;
- entrar no Digital Center;
- relogar e confirmar aparencia e stats.

### Progressao

- concluir Q1-Q7;
- confirmar Slimmoon antes de Nocmoon;
- terminar aproximadamente entre levels 12 e 13;
- validar todos os rewards uma unica vez;
- equipar/desequipar e confirmar HP/MP atual e maximo;
- validar Link de 10% a 100%.

### Combate E Rede

- Player e Datamoon controlados separadamente;
- basic e Slime Spikes em movimento;
- soltar input logo depois da skill;
- dano no frame de impacto;
- nenhum snapshot antigo restaurando HP;
- reconectar no mesmo mapa;
- testar latencia e perda simuladas antes de alterar thresholds.

### Dungeon E Party

- solo e Party;
- reserva integral da Party;
- handoff Overworld -> Dungeon 1;
- membro remoto acinzentado sem texto OFFLINE;
- reconnect durante handoff;
- morte do boss exato;
- rewards e limite diario;
- retorno ao portal de origem;
- Dungeon 2 permanece desativada.

### Operacao

- hashes Client/Server/API iguais;
- API `/ready`;
- logs sem erros de startup;
- Overworld e Dungeon 1 ativos;
- Web, Auth e Gateway ativos;
- journal dentro da retencao;
- nenhum segredo ou dado sensivel em logs.

## Lancamento Do Banco

Executar somente quando o usuario autorizar explicitamente o lancamento.

Decisao atual:

- nao fazer backup dos dados PBE;
- parar aplicacoes antes do reset;
- recriar Auth e Game;
- usar baseline composta apenas por `CREATE TABLE`, indices e seeds finais;
- incorporar alteracoes estruturais antigas na criacao final;
- remover migrations de conversao de IDs PBE;
- nao transportar auditorias, inventarios, personagens ou hotbars de teste;
- recriar apenas a conta administrativa necessaria;
- subir tudo pelo deploy coordenado;
- validar migrations, healthcheck e logs.

Nunca montar ou executar o runbook destrutivo com nomes de banco presumidos. Os
nomes reais devem vir dos envs da VM na janela de lancamento.

## Performance E Escala

### Base Que Deve Ser Preservada

- Server autoritativo;
- snapshots a 20 Hz;
- interest management por chunk e `space_id`;
- baseline/delta e budget por peer;
- API interna com backpressure e circuit breaker;
- MySQL fora do loop de movimento/combate;
- checkpoints e operacoes idempotentes;
- workers separados para zonas e instancias;
- logs estruturados sem registrar cada movimento ou ataque.

### Proximas Medicoes

Antes de uma refatoracao de performance, medir:

- frame time de CPU e GPU do Client;
- draw calls, CanvasItems visiveis e memoria de texturas;
- tempo de build/compressao de snapshot por peer;
- bytes por peer por segundo;
- quantidade de entidades por chunk;
- tempo de physics tick do Server;
- requests, fila e latencia da API;
- conexoes e slow queries MySQL;
- memoria por worker e tempo de handoff.

### Melhorias Condicionadas A Metricas

- carregar recursos por mapa/manifesto em vez de ampliar preload global;
- pool de projeteis e floating text se alocacao aparecer no profiler;
- batch de heartbeat/presenca quando houver dezenas de jogadores por worker;
- indice espacial para IA e busca de peers quando scans se tornarem hotspot;
- compartilhar trabalho de serializacao entre peers com deltas equivalentes;
- dividir `movement_controller.gd`, `portal_manager.gd`,
  `datamoon_enemy.gd` e handlers grandes por responsabilidade;
- considerar renderer Compatibility apenas depois de validar shaders, visual e
  ganho em hardware alvo;
- adicionar limite de FPS configuravel alem do VSync.

Nao reduzir linhas por objetivo numerico. Reduzir decisoes duplicadas,
processamento ocioso, acoplamento e caminhos de compatibilidade comprovadamente
mortos.

## Backlog Pos-v0.04

### Gameplay

- habilitar Archive, Hatchery, Craft, Cooking, Equipment e Fishing por conteudo;
- adicionar Hood, Shoes, Gloves, Shirt e Pants como fontes reais;
- evolucao Code -> Nex -> Omega;
- mais mapas, dungeons e dificuldades;
- eventos mundiais;
- guild creation por `guild_deploy_drive`;
- vendor, compra, venda e descarte seguro;
- skills e projeteis adicionais;
- administracao de login separada de moderacao de chat.

### Temporada

Passe de temporada permanece somente como ideia futura. Antes de implementar,
definir temporada, duracao, XP, trilha gratuita/premium, rewards, catch-up,
prevencao de abuso, expiracao e impacto economico. Nenhuma regra de temporada
deve entrar silenciosamente na v0.04.

### Producao

- recuperacao de senha, validacao e alteracao de e-mail implementadas; falta
  deploy, acesso de producao do SES e validacao manual completa;
- backup automatico e restauracao testada;
- alarmes essenciais CloudWatch/SNS configurados; ampliar somente por necessidade;
- Grafana/Prometheus;
- Fail2ban versionado e pendente de instalacao/validacao na VM; WAF futuro;
- rotacao operacional de credenciais;
- ferramenta administrativa para consultas de auditoria;
- teste de carga com metas definidas.

## Divisao Cena, Codigo E Dados

Usar cenas para:

- composicao visual de entidades;
- mapas, colisoes e markers;
- janelas e componentes de UI;
- AnimationTree, shaders e anchors;
- variantes visuais reutilizaveis.

Usar codigo para:

- autoridade e validacao;
- rede, prediction e reconciliacao;
- state machines;
- streaming, pooling e lifecycle;
- persistencia e transacoes;
- composicao runtime orientada por dados.

Usar JSON para:

- IDs e disponibilidade;
- stats, timings, rewards e drops;
- spawns, portais, NPCs, quests e receitas;
- presets de aparencia e paletas permitidas.

Nao criar uma cena por combinacao de cor, regra de gameplay escondida em cena
visual ou entidade critica inteiramente montada por codigo quando uma cena
reutilizavel torna o contrato mais claro.

## Criterio Beta Ready

A v0.04 esta pronta quando:

- nao ha persistencia parcial na criacao;
- mapas e assets finais estao integrados;
- Q1-Q7 fecham a progressao aprovada;
- boss, dungeon e rewards funcionam solo e em Party;
- movimento e combate nao exibem snaps recorrentes;
- hashes e baseline SQL estao consistentes;
- deploy limpo passa;
- logs nao mostram erros criticos;
- banco PBE foi recriado na janela aprovada;
- o roteiro manual foi aprovado por uma conta nova.

A decisao final de release e manual. Nenhum status historico substitui esse
checklist.
