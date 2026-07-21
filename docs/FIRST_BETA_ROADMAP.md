# Datamoons Online - Roadmap do Primeiro Beta

## Objetivo

Preparar uma primeira experiencia jogavel, curta e validavel, com foco em:

- onboarding claro para novos jogadores;
- mapa central com progressao simples;
- dois Datamoons completos para combate inicial;
- dungeon diaria funcional;
- loops basicos de hatch, craft, cooking, archive, combate e guild bloqueada por item futuro;
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
- duplicacao eventual de mensagem privada em troca de worker;
- estado de party member offline/remoto deve continuar mostrando corretamente;
- blur no editor pode depender do zoom do viewport, mas runtime deve ficar limpo;
- input pode segurar por alguns segundos em troca de worker se houver latencia.

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
- [ ] Guild creation bloqueada por item indisponivel.
- [ ] Client sem blur relevante em runtime.
- [ ] Server, gateway, auth e mysqlapi atualizados em `pbe`.
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
- duracao do reset diario da dungeon, provavelmente por dia calendario do servidor;
- nome do item necessario para criar guild no futuro;
- se a dungeon pode ser feita solo no beta ou se party sera recomendada.

---

## Decisao Atual

O primeiro beta deve priorizar uma fatia vertical pequena, clara e completa.

O objetivo nao e mostrar volume de conteudo, mas provar que:

- o jogador entende o mundo;
- o jogador aprende os sistemas principais;
- o combate base funciona;
- a troca de workers funciona;
- a dungeon diaria fecha um ciclo de recompensa;
- a base tecnica suporta evolucao para P2/P3.
