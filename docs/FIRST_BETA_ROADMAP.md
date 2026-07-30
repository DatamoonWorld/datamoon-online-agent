# Datamoons Online - Roadmap Principal de Gameplay

## Uso Deste Documento

Este e o unico painel operacional de ajustes e implementacoes do jogo. Os demais
documentos tematicos continuam sendo fonte de regras e contratos, mas nao devem
manter listas concorrentes de prioridade.

Toda mudanca relevante de gameplay deve atualizar aqui:

1. status atual;
2. proxima entrega;
3. decisoes ainda abertas;
4. criterio de validacao manual.

Status usados:

- `IMPLEMENTADO E VALIDADO`: existe no codigo e passou pela validacao manual;
- `IMPLEMENTADO`: existe no codigo, mas ainda requer validacao ou conteudo final;
- `PARCIAL`: apenas parte do fluxo esta pronta;
- `PROXIMO`: entrega priorizada;
- `IDEIA FUTURA`: direcao aceita para estudo, sem compromisso de implementacao;
- `FORA DE ESCOPO`: decisao explicita de nao implementar nesta etapa.

Ultima reconciliacao entre documentacao e codigo: **2026-07-29**.

Roadmap de entrega em foco: `roadmap_v0.04.md`. Alteracoes de escopo, status ou
prioridade da v0.04 devem atualizar os dois arquivos no mesmo commit.

---

## Painel Canonico

### Implementado E Validado

| Sistema | Estado confirmado |
| --- | --- |
| Login e conexao | Login seguro por WSS, Gateway, entrada no overworld e workers PBE validados. |
| Party e workers | Handoff overworld/dungeon, HUD remota acinzentada sem `OFFLINE`, remocao apos desconexao definitiva, reserva integral e rollback validados com dois Clients. |
| Chat | Antispam da quinta mensagem em dois segundos, timeout restante, mute/unmute e slow/normal mode persistentes validados. |
| Atividades | Fishing com sessao protegida, Hatchery idempotente e motor compartilhado de Craft/Cooking validados manualmente. |
| Guild | Estado persistente entre reconnects validado; criacao exige e consome `Guild Deploy Drive` de forma transacional e auditada. |
| Equipamentos | Unscan, stats aleatorios persistidos, tooltip, equipar/desequipar, Upgrade e Alternate pelo NPC validados. |
| Dungeon entre workers | Entrada, limite diario, Party, handoff e retorno ao overworld possuem fluxo funcional. |

### Implementado, Mas Ainda Nao Final

| Sistema | O que existe | O que falta |
| --- | --- | --- |
| Quest inicial | Seis quests data-driven existem; a sexta observa `complete_dungeon` da dungeon inicial. | Manter seis quests na v0.04 e ajustar EXP, pocoes, Unscan, textos e target para `moonlight_cavern`. |
| Slimmoon e Nocmoon | JSONs, cenas aliadas/inimigas, spawns, combate e skills existem. | Balanceamento final, animacoes, leitura visual, drops e revisao das duas versoes. |
| Mapas | Existe apenas `main_map.tscn`; `space_id` limpa entidades, mas nao troca a cena visual. | Implementar Digital Center e Moonlight Forest com map registry, colisao espelhada e portais azul/vermelho. |
| Dungeon diaria | `moonlight_cavern` possui instancia, mobs, boss Nocmoon, completude, rewards, reset e retorno seguro. | Ajustar mobs para 7-8, boss para 13 e rewards finais da v0.04. |
| Boss | O Server cria e rastreia uma instancia de boss usando a especie normal e conclui pela entidade rastreada. | Modificadores explicitos, `is_boss`/`boss_id`, nome localizado e HUD central por distancia ainda nao existem. |
| Projeteis e areas | Runtime autoritativo no Server possui alcance/duracao, ticks e deduplicacao de hit. | Representacao visual, telegraph e sincronizacao perceptiva final no Client. |
| Pixel crisp | Tema, fonte e varios assets foram atualizados. | Revisao completa em runtime de HUD, nomes, tooltips, tiles e movimento. |

### Proximas Entregas

1. Confirmar IDs finais e calibrar os multiplicadores iniciais documentados do
   boss. As pocoes recuperam 10% do HP/MP maximo efetivo. Upgrade e Alternate
   permanecem indisponiveis ate a v0.05 ou v0.06.
2. Implementar Digital Center, Moonlight Forest, troca visual por `space_id` e
   portais com listas data-driven de destinos/requisitos.
3. Ajustar Slimmoon 1-3, Nocmoon 3-6 e conteudo/NPCs ativos.
4. Ajustar as seis quests para Slimmoon antes de Nocmoon e progressao final
   entre os levels 12 e 13.
5. Converter a dungeon em Moonlight Cavern com mobs 7-8 e boss 13.
6. Implementar o contrato final de boss e sua HUD.
7. Corrigir sincronizacao visual de impacto/dano e impedir oscilacao de HP por
   snapshots antigos.
8. Finalizar visuais de projeteis/areas e revisar pixel crisp.
9. Rodar a bateria manual completa do Beta em PBE.

### Ideias Futuras, Ainda Nao Implementadas

| Ideia | Direcao registrada | Dependencia |
| --- | --- | --- |
| Descarte seguro | Confirmacao, quantidade para stacks, protecao de itens sensiveis, operacao autoritativa/idempotente e possivel recuperacao temporaria. | Inventario/rewards estabilizados. |
| Loja de NPC | Compra, venda e recompra atomicas, data-driven por `shop_id`, com auditoria. | Economia, moeda e descarte seguros. |
| Passe de temporada | Progresso por conta, trilhas gratuita/premium cosmeticas, sem poder comprado, objetivos e claims autoritativos. | Quests, rewards, auditoria, loja e economia estabilizados. |
| Evolucao | Contrato Code -> Nex -> Omega documentado, mas sem runtime de unlock/transformacao/regressao. | Conteudo e progressao posteriores ao Beta 1. |
| Aplicacao administrativa | Consultas de auditoria e comandos administrativos fora do jogo. | Ferramenta administrativa futura. |
| Escala MMO adicional | Indice espacial de alvos, indice global de presenca, mais workers e autoscaling. | Metricas reais de carga. |
| Producao endurecida | Recuperacao de senha, e-mail, backups/restauracao, alertas, WAF e Fail2ban. | Preparacao de producao. |

O passe de temporada e uma ideia futura, nao uma funcionalidade aprovada para o
Beta 1. Nenhum schema, rota, runtime ou UI de passe foi encontrado nos
repositorios em 2026-07-29.

## Registro Consolidado Por Sistema

Esta secao absorve o estado de implementacao antes espalhado pelos documentos
tematicos. Contratos detalhados continuam nesses documentos, mas status e
prioridade devem ser alterados somente aqui.

### Combate

Implementado:

- Server autoritativo para alvo, espaco, dano, buffs/debuffs e rewards;
- formula defensiva compartilhada
  `damage = (power * 100) / ((DEF * 2.5) + 100)`;
- ataque basico usa `ATK`, pode critar e recebe multiplicador de sistema;
- skill usa dano base/crescimento e escalas data-driven de ATK, HP, MP, DEF e
  valor fixo; skills nao critam;
- `skill_damage` multiplica o dano final de skills;
- dano positivo minimo de `1`, sem variacao aleatoria ou modificador oculto por
  diferenca de level;
- DOT captura ATK efetivo na aplicacao e preserva apenas a aplicacao mais forte
  dentro do mesmo grupo;
- equipamentos entram nos stats efetivos do Datamoon ativo;
- Bracelet e obrigatorio para atacar e troca de equipamento e bloqueada em
  combate;
- projeteis lineares e areas temporizadas possuem runtime autoritativo.

Pendente:

- alinhar `START`, `IMPACT` e `RECOVERY` ao frame percebido;
- ordenar HP por tick/sequencia para snapshot antigo nao restaurar vida;
- finalizar visuais/telegraphs de projeteis e areas;
- monitorar snap no inicio/fim de skills e lock apos handoff;
- adicionar politica data-driven `free`, `reduced` ou `locked` por skill e
  impedir restauracao da posicao antiga do inicio do cast;
- balancear inimigos comuns por perfil PvE de encontro, iniciando ataque em
  `0.25`, sem alterar a formula defensiva global ou inflar a DEF do jogador;
- separar lifecycle de acao da matematica de dano antes de ampliar
  `combat.gd`;
- Armor Penetration e acoes moveis/dash/channel ficam para uma etapa futura.

### Vantagem De Tipos

Implementado como contrato de combate:

- ciclo simples `Datacore > Patch > Glitch > Datacore`;
- vantagem altera dano sem substituir stats, build, skill ou decisao do player;
- Server e a unica autoridade para o multiplicador.

Pendente:

- calibracao final dos multiplicadores com Slimmoon/Nocmoon e futuras lutas PvP;
- feedback visual mais claro quando houver vantagem/desvantagem.

### Economia, Inventario E Equipamentos

Implementado:

- Bits, rewards de combate/quest/dungeon, drops, inventario limitado, Craft,
  Cooking e Hatchery;
- operacoes sensiveis transacionais, idempotentes e auditadas;
- Bracelet, Hood e Shoes com tres entradas de stats e caps por pool;
- IDs finais `digital_bracelet`, `digital_hood` e `digital_shoes`, com Unscan
  correspondente e migracao preservando inventario/equipamento;
- Unscan pelo contrato normal de container com gerador autoritativo;
- Upgrade `+1` a `+5` com chances `100/90/80/70/60%`;
- Alternate troca apenas o stat selecionado, preserva os demais e respeita caps;
- NPC de equipamento com referencias nao proprietarias aos itens do inventario;
- quantidade de material exibida como soma de todos os stacks compativeis;
- `Guild Deploy Drive` exigido na criacao de Guild.
- energias verde/azul com recuperacao autoritativa de 10% do HP/MP efetivo.

Pendente:

- definir origem/drop do `Guild Deploy Drive`;
- manter Hood/Shoes/Gloves/Shirt/Pants sem fonte na v0.04;
- fechar balanceamento dos valores de stats e impacto na economia;
- descarte seguro, loja NPC, compra/venda/recompra e passe de temporada;
- Critical Damage, Attack Speed, raridade e qualidade nao pertencem ao
  equipamento do Beta 1.

### Quests E Dialogos

Implementado:

- definicoes JSON, NPC giver/turn-in, persistencia na API, snapshot/UI e
  dependencias lineares;
- Quest Log global mostra apenas quests aceitas ativas/prontas, permite abandono
  autoritativo e exibe progresso do snapshot;
- objetivos observaveis `talk_to_npc`, `kill_enemy_type`, `collect_item` e
  `complete_dungeon`;
- seis quests iniciais atuais, terminando em `starter_moonlight_cavern`;
- conclusao da dungeon pode alimentar objetivo de quest.

Pendente:

- ajustar as seis quests existentes ao escopo final da v0.04;
- escrever textos finais em ambos os idiomas;
- fechar rewards, IDs e ordem definitiva;
- conceder/validar a recompensa final ligada a Q6;
- validar cancelamento de dialogo, reconnect e tentativa duplicada de turn-in.

### Dungeons E Bosses

Implementado:

- templates data-driven, selector de dungeon, instancias por `space_id`, timer,
  membership e ejection;
- handoff assinado entre workers, fencing, reserva integral/versionada da Party,
  rollback e logs por fase;
- completude pela morte da instancia de boss rastreada;
- `moonlight_cavern` concede um `Upgrade Chip` e possui 5% de chance independente
  de `Alternate Chip` em conclusao elegivel;
- limite diario persistente, reset as `03:00 UTC` e retorno seguro ao lado do
  portal.

Pendente:

- contrato completo de boss com modificadores de HP, ataque, defesa e
  `attack_speed`;
- `is_boss`, `boss_id`, nome localizado e HUD central superior por distancia;
- balanceamento solo/Party, reward final e validacao completa da Q6 na v0.04;
- revisar mensagens de bloqueio, reentrada e timeout.

### Social E Atividades

Implementado:

- Party versionada, convites persistentes com expiracao, presenca cross-worker,
  grace period, remocao offline e preservacao no handoff;
- Guild com permissoes centralizadas, convites, roles e auditoria;
- Chat com sanitizacao, mute administrativo, slow mode e antispam persistentes;
- Craft/Cooking em motor compartilhado;
- Fishing com session ID, timing e protecao contra replay;
- Hatchery com jobs e claims idempotentes;
- auditorias de inventario, moeda, rewards e administracao com retencao padrao
  de 180 dias.

Fora do escopo atual:

- chat-ban e reports;
- conteudo de chat em logs;
- ferramenta administrativa.

### Client, Server E API

Implementado:

- snapshots baseline/delta, budget, bootstrap de sessao e handshake de loading;
- labels de mundo hibridas usam valores autorados nas cenas e reaplicacao no
  runtime para entidades dinamicas/legadas;
- workers separados para overworld e dungeon, registry, leases e drain;
- catalogos data-driven com validacao semantica/fail-fast;
- logging estruturado no journald e deploy coordenado;
- infraestrutura social, atividades e operacoes de inventario parcialmente
  extraidas em modulos compartilhados.

Refatoracao futura:

- dividir sessao, lobby, handoff e gameplay no Client;
- extrair lifecycle de instancias/transferencias de `portal_manager.gd`;
- mover operacoes de item para servicos focados sem ampliar `inventory.gd`;
- dividir handlers grandes da API por agregado/use case;
- substituir polling social por relay/pub-sub apenas quando escala justificar;
- criar indice espacial de IA e indice eficiente de players online quando
  metricas demonstrarem necessidade.

### Evolucao, Link E Eventos

Implementado:

- Link, tipos e progressao possuem contratos de design;
- modelo de evolucao `Code -> Nex -> Omega` e primeira linha
  `Nocmoon -> Kainemoon -> Bathorymoon` estao documentados.

Ainda somente em design:

- persistencia de unlock por Datamoon;
- runtime de transformacao/regressao;
- cenas/stats/skills finais de Kainemoon e Bathorymoon;
- eventos mundiais e recompensas sazonais.

Nenhum desses itens bloqueia o Beta 1.

## Proposta Historica Do Primeiro Beta

As secoes abaixo preservam a proposta anterior de mapa central e dez quests
apenas como contexto. Elas foram substituidas para a entrega atual por
`roadmap_v0.04.md` e nao devem orientar implementacao sem serem reconciliadas
com o painel canonico acima.

## Objetivo

Preparar uma primeira experiencia jogavel, curta e validavel, com foco em:

- onboarding claro para novos jogadores;
- mapa central com progressao simples;
- dois Datamoons completos para combate inicial;
- dungeon diaria funcional;
- loops basicos de hatch, craft, cooking, archive, combate e guild bloqueada pelo
  item `Guild Deploy Drive`;
- estabilidade suficiente para um teste pequeno com jogadores reais.

Este roadmap deve guiar o que falta fazer antes do primeiro beta fechado.

---

## Escopo do Beta 1

### Experiencia esperada

O jogador deve conseguir:

- entrar no jogo e entender o contexto inicial;
- falar com o NPC principal;
- seguir uma quest line linear de introducao;
- aprender os sistemas basicos sem depender de explicacao externa;
- lutar contra Slimmoon em campo aberto;
- lutar contra Nocmoon em uma area com arvores;
- acessar o portal da dungeon no final do mapa central;
- completar uma dungeon diaria;
- receber rewards de completude da dungeon;
- testar party, chat, combate e movimentacao entre workers.

### Fora do escopo inicial

- guild criada livremente sem item;
- dungeon 2 ativa;
- teste de carga grande;
- IA complexa;
- grande variedade de Datamoons;
- economia aberta ou balanceamento final;
- quests ramificadas;
- progressao longa.

---

## Conteudo Principal

### 1. Quest line inicial - 10 quests

A quest line inicial deve ser linear e ensinar um sistema por vez.

#### Q01 - Bem-vindo ao Mundo dos Datamoons

Objetivo:

- falar com o NPC inicial.

Conteudo:

- NPC explica o mundo;
- apresenta o papel do Tamer;
- explica que Datamoons sao companheiros de batalha e progressao.

Criterio de pronto:

- quest aparece no log;
- dialogo funciona;
- quest completa ao falar com o NPC;
- proxima quest desbloqueia corretamente.

#### Q02 - Primeiro Hatching

Objetivo:

- interagir com o sistema de Hatching.

Conteudo:

- NPC explica DataEggs;
- explica que novos Datamoons podem nascer pelo Hatching.

Criterio de pronto:

- interacao com hatchery validada;
- UI abre e fecha corretamente;
- quest registra progresso por interacao ou fluxo minimo definido.

#### Q03 - Aprendendo Craft

Objetivo:

- interagir com a bancada de craft.

Conteudo:

- NPC explica que itens podem ser criados com materiais;
- introduz a ideia de receitas.

Criterio de pronto:

- craft station abre;
- quest registra interacao;
- mensagem/tutorial deixa claro o uso futuro.

#### Q04 - Aprendendo Cooking

Objetivo:

- interagir com a cooking station.

Conteudo:

- NPC explica cooking como sistema de preparacao/consumo futuro;
- reforca que cooking pode apoiar progresso e combate.

Criterio de pronto:

- cooking station abre;
- quest registra interacao;
- fluxo nao quebra ao mover/usar skill depois.

#### Q05 - Conhecendo o Archive

Objetivo:

- interagir com o Archive.

Conteudo:

- NPC explica que o Archive guarda informacoes de Datamoons, descobertas e progresso.

Criterio de pronto:

- archive abre;
- quest registra interacao;
- UI exibe informacao minima util.

#### Q06 - Fundamentos de Combate

Objetivo:

- falar com o NPC e/ou atacar um alvo de treino.

Conteudo:

- NPC explica combate com Datamoon;
- reforca que Tamer e mais voltado a interacao;
- Datamoon e o foco de batalha;
- explica HP, MP, ataque basico e skills.

Criterio de pronto:

- tutorial claro;
- ataque basico e skill podem ser usados;
- estado `is_in_combat` entra apenas ao causar ou receber dano.

#### Q07 - Controle de Campo: Slimmoon

Objetivo:

- derrotar 10 Slimmoon.

Conteudo:

- primeira quest de combate real;
- usa campo aberto do mapa central.

Criterio de pronto:

- objetivo `kill_enemy_type` funciona para Slimmoon;
- progresso incrementa corretamente;
- recompensa e turn-in funcionam.

#### Q08 - Controle de Campo: Nocmoon

Objetivo:

- derrotar 10 Nocmoon.

Conteudo:

- segunda quest de combate real;
- leva o jogador para area com arvores.

Criterio de pronto:

- objetivo `kill_enemy_type` funciona para Nocmoon;
- spawns de Nocmoon existem na area correta;
- dificuldade maior ou diferente de Slimmoon.

#### Q09 - O Portal da Dungeon

Objetivo:

- falar com o NPC e ir ate o portal da dungeon.

Conteudo:

- NPC explica que dungeons sao desafios instanciados;
- explica limite diario;
- explica que completar a dungeon da rewards de completude.

Criterio de pronto:

- portal fica no final do mapa central;
- tentativa de entrada valida se o jogador pode entrar;
- nao inicia loading se a entrada for bloqueada.

#### Q10 - Ajuda na Dungeon

Objetivo:

- entrar na dungeon e derrotar o boss.

Conteudo:

- NPC pede ajuda para eliminar o boss da dungeon;
- quest conclui quando os rewards de completude forem ganhos.

Criterio de pronto:

- dungeon diaria pode ser concluida;
- boss death dispara completion;
- rewards sao entregues uma vez por reset diario;
- quest marca completa apos reward de completude;
- reentrada respeita estado diario.

---

## Mapa Central

### Estrutura

O mapa central deve ter:

- area inicial segura com NPC principal;
- campo aberto com Slimmoon;
- area com arvores contendo Nocmoon;
- caminho visual ate o portal da dungeon;
- portal da dungeon no final do mapa.

### Requisitos

- colisoes do client e server devem estar espelhadas;
- portais devem usar cena/collision padronizada;
- spawns devem ter posicoes previsiveis e sem sobrepor o jogador;
- inimigos devem ter HUD visivel com level e HP;
- nomes de inimigos podem continuar ocultos durante testes se for decisao visual.

### Criterios de pronto

- jogador entende para onde ir sem mapa externo;
- Slimmoon e Nocmoon aparecem em areas distintas;
- portal da dungeon e visualmente reconhecivel;
- nao ha travas de input ao caminhar entre areas;
- nao ha tiles borrados ou seams visiveis em runtime.

---

## Datamoons do Beta

### Slimmoon

Deve estar fechado para beta com:

- sprite final ou placeholder aprovado;
- animacoes de idle, move, attack e skill;
- ataque basico funcional;
- pelo menos 1 skill funcional;
- stats definidos;
- drops/rewards definidos;
- versao inimiga no mapa;
- versao aliada controlavel.

### Nocmoon

Deve estar fechado para beta com:

- sprite final ou placeholder aprovado;
- animacoes de idle, move, attack e skill;
- ataque basico funcional;
- pelo menos 1 skill funcional;
- stats definidos;
- drops/rewards definidos;
- versao inimiga no mapa;
- versao aliada controlavel.

### Criterios gerais

- nomes e outlines padronizados;
- HUD inimigo padronizado;
- fontes e icones sem blur no runtime;
- ataques nao geram snap relevante;
- combate entra em estado `is_in_combat` apenas ao causar ou receber dano.

---

## Dungeon Diaria

### Regra de design

A dungeon do beta deve ser diaria.

Ela deve marcar completude quando o jogador ganhar os rewards de completude.

### Requisitos

- template da dungeon configurado;
- portal de entrada no mapa central;
- worker de dungeon ativo;
- boss configurado;
- rewards de completude definidos;
- persistencia de completion diaria;
- UI/mensagem clara quando ja completou no dia;
- retorno ao overworld funcionando.

### Criterios de pronto

- jogador entra na dungeon;
- jogador derrota o boss;
- reward e entregue uma unica vez por dia;
- quest Q10 completa depois do reward;
- jogador consegue sair/retornar sem travar em "connecting to game server";
- dungeon 2 permanece off por enquanto.

---

## Guild

### Regra de beta

Guild so pode ser criada usando um item especifico.

Esse item nao estara disponivel no beta 1.

### Requisitos

- botao/fluxo de criar guild deve validar item necessario;
- se o jogador nao tiver o item, mostrar mensagem clara;
- nao permitir criacao direta sem item;
- manter funcionalidades de visualizacao/social que ja forem seguras.

### Criterios de pronto

- jogador nao consegue criar guild sem item;
- mensagem explica que o item e necessario;
- sistema nao quebra caso a feature esteja parcialmente bloqueada.

---

## Sistemas Que Precisam Estar Validados

### Gameplay

- login e entrada no mundo;
- movimento;
- troca por TAB;
- controle de Tamer e Datamoon;
- combate basico;
- skill;
- hatch;
- craft;
- cooking;
- archive;
- quest log;
- portal;
- dungeon;
- chat;
- party;
- guild bloqueada por item.

### Tecnico

- client local em `pbe`;
- server em `pbe`;
- gateway em `pbe`;
- auth em `pbe`;
- mysqlapi em `pbe`;
- imports headless feitos em Godot;
- mysqlapi rebuildado quando houver alteracao Go;
- workers ativos: overworld e dungeon-1;
- dungeon-2 off por enquanto.

---

## Known Bugs / Pontos Para Monitorar

Estes pontos nao bloqueiam automaticamente o beta se estiverem raros e pequenos, mas devem ser monitorados:

- pequenos snaps/resyncs ao trocar entre overworld e dungeon;
- pequenos snaps em skill/ataque quando controlando Datamoon;
- o dano pode ser exibido antes do frame visual de impacto porque a hitbox do
  ataque basico e ativada imediatamente ao entrar no estado de ataque;
- o HP de um inimigo pode cair, voltar por poucos milissegundos e cair novamente
  quando o hit imediato e seguido por um worldstate interpolado mais antigo;
- duplicacao eventual de mensagem privada em troca de worker;
- estado de party member offline/remoto deve continuar mostrando corretamente;
- blur no editor pode depender do zoom do viewport, mas runtime deve ficar limpo;
- input pode segurar por alguns segundos em troca de worker se houver latencia.

## Backlog De Combate, Economia E Temporada

Itens discutidos e documentados em 2026-07-29. Nenhum deles deve ser
implementado apenas no Client; combate, inventario, moeda, rewards e progressao
permanecem autoritativos no Server.

### Sincronizacao De Ataque E Dano

Problema atual:

- a hitbox do ataque basico e ativada no inicio do estado de ataque;
- o Server pode aplicar e enviar o dano antes de o Client renderizar o frame de
  impacto da animacao.

Solucao implementada, pendente de validacao visual:

- dividir cada acao em `START`, `IMPACT` e `RECOVERY`;
- `START` inicia a animacao e bloqueia outra acao;
- `IMPACT` ativa a hitbox e calcula o dano no `impact_frame` configurado por
  ataque;
- `RECOVERY` encerra a acao e libera o proximo comando;
- enviar identificador da acao, tick autoritativo e timing resolvido em frames
  para o Client alinhar a animacao e reconciliar movimento;
- suportar `impact_times` para skills com multiplos hits;
- manter o Server como autoridade do impacto. Animation Call Method Track pode
  disparar efeitos visuais, mas nao deve decidir o dano no Server headless.

Criterios de pronto:

- dano e numero flutuante aparecem no frame de impacto percebido;
- latencia nao permite antecipar, repetir ou cancelar dano valido;
- ataques basicos e skills usam o mesmo modelo temporal;
- multiplos hits possuem sequencia deterministica e validada.

### Oscilacao De HP Apos Hit

Problema atual:

- o pacote imediato de combate aplica o HP novo;
- um worldstate interpolado mais antigo pode restaurar temporariamente o HP;
- um snapshot posterior aplica novamente o valor correto.

Solucao planejada:

- versionar atualizacoes de HP com `server_tick`, `hit_sequence` ou ambos;
- aplicar o hit imediato para preservar feedback rapido;
- ignorar snapshots de HP anteriores a ultima versao autoritativa aplicada;
- nunca corrigir o problema removendo a autoridade do Server ou atrasando todo
  feedback ate o proximo worldstate.

Criterios de pronto:

- barra de HP nao sobe entre o hit e o snapshot seguinte;
- cura, dano, DOT e morte respeitam a mesma ordenacao;
- reconnect e troca de worker conseguem estabelecer uma nova versao-base.

### Compra E Venda Em NPC

Sistema planejado:

- NPC referencia um `shop_id`; catalogo, precos e restricoes vivem no
  Server/MySQL API;
- compra valida proximidade/interacao, moeda, quantidade, estoque, limite e
  espaco de inventario em uma unica operacao atomica;
- venda valida posse, quantidade, estado equipado e flags de protecao antes de
  remover o item e conceder moeda;
- itens de quest, favoritos, equipados, bloqueados ou premium nao podem ser
  vendidos sem uma regra explicita;
- suportar quantidade, preco de compra, preco de venda e uma aba de recompra;
- registrar auditoria e usar operacoes idempotentes para moeda e inventario.

### Descarte De Item

Sistema planejado:

- arrastar para fora do inventario nao deve apagar automaticamente;
- usar uma area explicita de descarte ou abrir confirmacao ao soltar fora;
- stacks pedem quantidade; itens raros/equipamentos exigem confirmacao forte;
- itens de quest, equipados, favoritos, bloqueados ou premium sao protegidos;
- descarte e uma operacao autoritativa, idempotente e auditada no Server/API;
- considerar recuperacao temporaria para itens elegiveis.

### Passe De Temporada

Direcao recomendada:

- progresso por conta, nao por personagem ou Datamoon;
- trilha gratuita e trilha premium predominantemente cosmetica;
- nenhuma compra premium concede poder de combate;
- progresso vem de atividades normais, quests e objetivos diarios, semanais e
  permanentes;
- recompensas reclamadas, nivel do passe, entitlement premium e missoes ficam
  persistidos e validados no Server/API;
- oferecer recuperacao de objetivos perdidos e, preferencialmente, manter
  passes adquiridos disponiveis ou arquivados sem expiracao;
- reutilizar o pipeline autoritativo de quests e rewards, sem criar uma segunda
  implementacao de inventario/moeda.

Ordem recomendada:

1. corrigir sincronizacao de impacto e ordenacao de HP;
2. implementar descarte seguro;
3. implementar compra, venda e recompra em NPC;
4. construir o passe sobre quests, rewards e auditoria ja estabilizados.

## Validacao Manual Concluida

Validado em PBE em 2026-07-24, sem bugs visiveis:

- Web atualizado e Smithesyzer validada em login, cadastro e conta;
- Client `95f3d8e` validado em janelas, HUD, nomes e tooltips;
- Party entre overworld e dungeon;
- HUD de membro remoto acinzentada, sem texto `OFFLINE`;
- remocao de Party depois de desconexao definitiva;
- reserva integral da Party e rollback de handoff;
- antispam na quinta mensagem em dois segundos e feedback do tempo restante;
- mute/unmute e slow/normal mode persistentes;
- Fishing protegido contra replay/timing;
- Hatchery idempotente;
- motor compartilhado de Craft/Cooking;
- Guild preservada entre reconnects.

Esses fluxos saem da fila de implementacao principal. Devem continuar no roteiro
de regressao manual sempre que networking, persistencia ou UI social mudarem.

## Roteiro De Bosses Do Beta

Bosses reutilizam a cena, sprites e animacoes da especie normal. A identidade de
boss pertence aos dados do encontro, nao a uma copia da cena do Datamoon.

Ordem de implementacao:

1. adicionar ao JSON da dungeon um bloco `boss.modifiers` com multiplicadores de
   HP, ataque, defesa e `attack_speed`;
2. aplicar os multiplicadores somente na instancia criada como boss, depois dos
   stats normais por especie e level;
3. identificar a entidade no worldstate com `is_boss`, `boss_id` e nome
   localizado, sem tornar o Client autoridade;
4. criar uma HUD unica de boss no centro superior da tela;
5. mostrar a HUD somente quando o boss estiver vivo, no mesmo `space_id` e
   dentro da distancia configurada; ocultar ao afastar, morrer, sair da dungeon
   ou trocar de worker;
6. manter HUD local comum dos inimigos regulares e impedir duas HUDs de boss
   simultaneas no mesmo Client;
7. concluir a dungeon pela morte da instancia rastreada, nunca apenas pelo tipo
   da especie;
8. validar boss solo e em Party, reconnect, reset de combate, morte simultanea e
   handoff de retorno.

Os multiplicadores finais de Slimmoon/Nocmoon permanecem pendentes junto do
balanceamento, sprites, animacoes, skills e drops do beta. O reset diario ocorre
a meia-noite de Brasilia, correspondente a `03:00 UTC`. O retorno deve usar um
ponto seguro adjacente ao portal de entrada, persistido no handoff, e nunca a
posicao exata sobre o trigger do portal.

Baseline da primeira validacao manual do Nocmoon Boss:

- `max_hp: 12.0`;
- `attack: 0.65`;
- `defense: 0.9`.

O Server calcula a especie e o level antes desses multiplicadores. O worldstate
replica identidade, HP atual/maximo e versao monotona; o Client somente apresenta
a HUD. A dungeon conclui pela morte do `entity_id` registrado na instancia.
Bosses nao acumulam automaticamente perfis `wild_*` ou `dungeon_*`; seus
modificadores de encontro sao aplicados diretamente depois da especie e level.

## Pixel Crisp

`Pixel crisp` significa preservar a grade de pixels sem interpolacao ou
posicionamento fracionario. Sprites, fontes e HUDs devem usar filtro `nearest`,
escala inteira quando possivel e coordenadas alinhadas a pixels inteiros. O
resultado esperado e ausencia de blur, bordas tremidas, seams entre tiles e
mudanca de nitidez durante movimento ou zoom.

---

## Ordem Recomendada de Execucao

### Fase 1 - Consolidar Base Visual e Mapa

- fechar fonte e tamanhos;
- garantir `nearest`/pixel crisp em todos icones, sprites e HUDs;
- finalizar mapa central;
- posicionar NPC, Slimmoon, Nocmoon e portal;
- revisar colisoes espelhadas client/server.

### Fase 2 - Fechar Datamoons

- finalizar Slimmoon;
- finalizar Nocmoon;
- revisar stats;
- revisar ataques e skills;
- revisar rewards/drops;
- validar versoes aliadas e inimigas.

### Fase 3 - Implementar Quest Line

- criar as 10 quests no server;
- criar/ajustar dialogos;
- conectar objetivos observaveis;
- validar rewards e sequencia;
- garantir que Q10 depende da completude da dungeon.

### Fase 4 - Fechar Dungeon Diaria

- configurar daily completion;
- validar reward unico por dia;
- validar boss completion;
- validar retorno ao overworld;
- validar mensagens de bloqueio/reentrada.

### Fase 5 - Bloqueios e Polimento Beta

- bloquear guild creation por item;
- revisar mensagens de erro;
- revisar loading antes de portais/dungeon;
- revisar logs/metrics basicas;
- rodar bateria manual de gameplay.

---

## Checklist de Beta Ready

- [ ] Quest line com 10 quests implementada.
- [ ] NPC inicial com dialogos finais.
- [ ] Mapa central com campo de Slimmoon.
- [ ] Mapa central com floresta de Nocmoon.
- [ ] Portal da dungeon no final do mapa.
- [ ] Slimmoon finalizado para beta.
- [ ] Nocmoon finalizado para beta.
- [ ] Dungeon diaria funcional.
- [ ] Rewards de dungeon marcando completude.
- [x] Guild creation bloqueada pelo item `Guild Deploy Drive`.
- [ ] Client sem blur relevante em runtime.
- [ ] Server, gateway, auth e mysqlapi atualizados em `pbe`.
- [ ] Baseline SQL consolidada sem migrations de conversao de dados PBE.
- [ ] Baseline validada do zero em banco descartavel antes da janela de reset.
- [ ] Backup realizado e reset limpo autorizado explicitamente para o beta.
- [ ] Overworld e dungeon-1 ativos na VM.
- [ ] Dungeon-2 desligada.
- [ ] Teste manual completo aprovado.

---

## Informacoes Que Ainda Precisamos Definir

Para comecar a implementacao, ja temos escopo suficiente.

Ainda precisamos definir antes ou durante a execucao:

- texto final dos dialogos das 10 quests;
- rewards de cada quest;
- stats finais de Slimmoon e Nocmoon;
- skill final de Slimmoon e Nocmoon;
- boss da dungeon: especie, level, HP, ataque e reward;
- origem/drop futuro do item `Guild Deploy Drive`;
- se a dungeon pode ser feita solo no beta ou se party sera recomendada;
- duracao, quantidade de niveis e curva de XP de um futuro passe de temporada;
- catalogo gratuito/premium, preco, compra tardia e tratamento de passes antigos;
- se objetivos sazonais expirados podem ser recuperados integral ou parcialmente.

---

## Decisao Atual

O primeiro beta deve priorizar uma fatia vertical pequena, clara e completa.

### Ordem confirmada em 2026-07-25

- a rodada visual de nomes/guild, Party HUD e Enemy HUD foi validada
  manualmente pelo responsavel do projeto;
- Slimmoon e Nocmoon serao balanceados na proxima etapa de conteudo;
- a quest line sera criada pelo responsavel usando
  `docs/QUEST_AUTHORING_TEMPLATE.md`;
- a dungeon diaria sera finalizada depois do balanceamento dos Datamoons;
- campo de Slimmoon, floresta de Nocmoon, NPCs e portal serao consolidados na
  etapa final de mapa;
- polimento, mensagens, logs, metricas e bateria final permanecem documentados
  para o fechamento da beta.

Esta ordem nao marca os itens de beta como concluidos. Ela apenas registra a
sequencia de execucao escolhida.

O objetivo nao e mostrar volume de conteudo, mas provar que:

- o jogador entende o mundo;
- o jogador aprende os sistemas principais;
- o combate base funciona;
- a troca de workers funciona;
- a dungeon diaria fecha um ciclo de recompensa;
- a base tecnica suporta evolucao para P2/P3.
