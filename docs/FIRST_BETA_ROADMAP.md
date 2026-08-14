# Roadmap Principal - Beta v0.04

Este e o unico documento de status do projeto. Contratos e formulas pertencem
aos documentos tematicos; o desenho completo das funcionalidades pertence a
`GAMEPLAY_FEATURES.md`.

## Estados

- `Validado`: implementado e aprovado manualmente no PBE.
- `Em validacao`: implementado, mas ainda depende de aceite final.
- `Em progresso`: fluxo incompleto ou dependente de conteudo.
- `Futuro`: fora do escopo imediato.

## Objetivo

Entregar uma primeira jornada jogavel e segura com conta verificada, criacao de
personagem, escolha de Datamoon, Digital Center, Moonlight Forest, sete quests,
Moonlight Cavern, progressao inicial, Party e operacao recuperavel.

O jogador enfrenta Slimmoon antes de Nocmoon e termina a jornada por volta dos
niveis 12-13. O Beta pode sofrer wipe completo; a conta e a elegibilidade ao
pacote comemorativo serao preservadas conforme os termos publicados.

## Validado

- Login, Gateway, selecao de worker e deploy coordenado.
- Persistencia autoritativa de conta, personagem, Datamoon e inventario.
- Chat com antispam, mute/unmute e slow/normal mode persistentes.
- Party entre Overworld e dungeon, HUD remota, handoff e remocao offline.
- Fishing protegido contra replay, Hatchery idempotente e receitas
  compartilhadas de Craft/Cooking.
- Guild, Archive e Equipment NPC preservados para conteudo futuro.
- Equipamentos gerados, Upgrade, Alternate, Link e recálculo de stats.
- Prediction/reconciliation, HP versionado e impacto por timing de combate.
- Recuperacao de senha, verificacao de e-mail, alteracoes autenticadas,
  helpdesk, termos e privacidade na Web.
- Link Levels, tooltips especializados, buffs/debuffs e hotbar `1-9`/`F1-F9`.
- Unlock persistente da evolucao Slimmoon para Slimmoon Fighter Mode.

## Em Validacao

- Persistencia de HP/MP derivados de Link e equipamentos em login, equipar e
  desequipar.
- Movimento durante ataque/skill sob latencia e perda de pacotes.
- IA com navegacao, wander, flee, leash, evade e retorno emergencial.
- Unlock de evolucao consumindo Blueprint e elevando o limite de Link.
- Tooltips responsivos sem corte, exceto quebra permitida na descricao.

## Em Progresso

### Jornada Jogavel

- Criar cenas finais de `digital_center`, `moonlight_forest` e
  `moonlight_cavern`.
- Espelhar no Server colisao, NavigationRegion, spawns, pontos de entrada,
  portais e retorno seguro dos mapas finais.
- Posicionar apenas Devmoon e o conteudo habilitado da v0.04.
- Fechar as sete quests e percorrer a progressao com conta nova.
- Ligar a dungeon e recompensas definitivas a quest correspondente.

### Conteudo Do Beta

- Slimmoon selvagem nivel 1-3 antes de Nocmoon nivel 3-6.
- Nocmoon nivel 7-8 na Moonlight Cavern e boss Nocmoon nivel 13.
- Conclusao da dungeon: 10.000 EXP, 100 Link EXP, 500 Bits, 1 Upgrade
  Chip e 5% de Alternate Chip.
- Boss: 5% de `data_nocmoon_dna` e drops configurados no encontro.
- Somente `digital_bracelet` e seu Unscan entram na progressao de equipamento
  inicial. Sistemas futuros permanecem preservados, sem fonte ativa.

### Evolucao

- Concluir Transform e Regress entre Slimmoon e Slimmoon Fighter Mode.
- Criar Slimmoon Warrior Mode e sua transicao apos os assets ficarem prontos.
- Bloquear acao durante a apresentacao e trocar a entidade sem perder estado,
  ownership ou ordenacao de snapshots.
- Criar a quest futura que libera Link MAX depois da ultima evolucao.

### Boss E Dungeon

- Implementar HUD central do boss por distancia.
- Configurar frames da Fang Strike do Nocmoon.
- Encerrar a instancia pela entidade exata do boss, impedir respawn depois da
  conclusao e retornar a Party apos o timer final.

## Dependencias Visuais

- Mapas e tilesets finais de Digital Center, Moonlight Forest e Moonlight
  Cavern.
- Sprites, colisao, spawn, death, ataques e skills de Slimmoon e Nocmoon.
- Sprites e animacoes de Slimmoon Fighter Mode e Warrior Mode.
- Camadas da criacao de personagem: body, skin, hair, eyes, shirt, pants,
  gloves e shoes.
- HUD do boss, portais, nomes, combat text, pixel crisp e leitura em fullscreen.

## Validacao Final

- Criar conta, verificar e-mail, aceitar documentos, criar personagem e escolher
  Datamoon sem estado parcial.
- Completar as sete quests e confirmar nivel, rewards e idempotencia.
- Testar combate, morte, reconnect, troca de controle e evolucao.
- Completar Moonlight Cavern solo e em Party, incluindo reconnect, handoff,
  recompensa diaria e retorno.
- Conferir hashes de catalogo entre Client, Server e API.
- Validar baseline SQL em banco descartavel.
- Recriar o banco PBE na janela de lancamento, sem backup de dados de teste.
- Confirmar Overworld e Dungeon 1 ativos e Dungeon 2 desativada.
- Revisar logs, consumo da VM e ausencia de erros novos.

## Beta Ready

A v0.04 esta pronta quando a jornada completa funciona em um Client novo, os
resultados economicos sao idempotentes, o Server permanece autoridade, os
mapas finais estao espelhados, nenhum conteudo desabilitado possui fonte de
acesso e o roteiro de validacao final passa sem bloqueador.

## Futuro

Archive, Hatchery, Craft, Cooking, Equipment NPC, Fishing, Guild, Trade,
Rarity, Vendors, Passe de Batalha, Anomalias e Datapedia evoluem pelo desenho de
`GAMEPLAY_FEATURES.md`. Producao inclui backup externo com restauracao testada,
metricas p95/p99, alertas, seguranca de borda e teste de carga.
