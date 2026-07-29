# Datamoons Online - Roadmap Beta v0.04

## Objetivo

Entregar uma fatia vertical curta e coerente:

1. iniciar no Digital Center;
2. receber orientacao e quests do Devmoon;
3. atravessar um portal azul para Moonlight Forest;
4. combater Slimmoon e Nocmoon ate o level necessario;
5. atravessar um portal vermelho para Moonlight Cavern;
6. concluir a dungeon, receber materiais de equipamento e encerrar a linha
   inicial entre os levels 12 e 13.

Este documento detalha apenas a v0.04. Status geral e prioridades continuam
sincronizados em `FIRST_BETA_ROADMAP.md`.

## Regra De Sincronizacao

- Atualizar este arquivo sempre que o escopo da v0.04 mudar.
- Atualizar em paralelo o painel de `FIRST_BETA_ROADMAP.md`.
- Contratos gerais continuam em `COMBAT_SYSTEM.md`, `ECONOMY.md`,
  `QUEST_DESIGN.md` e `DUNGEON_RULES.md`.
- IDs, rewards e conteudo ativo descritos aqui vencem descricoes antigas do
  primeiro beta quando houver conflito explicito.

## Status

- `MANTER`: existe e atende a v0.04.
- `AJUSTAR`: existe, mas diverge do escopo.
- `IMPLEMENTAR`: nao existe.
- `DESATIVAR`: mecanica permanece no codigo, mas nao aparece no conteudo v0.04.
- `FUTURO`: nao implementar nesta entrega.

## Resumo Do Gap Atual

| Area | Estado atual | Acao v0.04 |
| --- | --- | --- |
| Mapas | Um unico `main_map.tscn`; mudanca de `space_id` nao troca TileMap. | `IMPLEMENTAR` Digital Center e Moonlight Forest como cenas/espacos distintos. |
| Portais | Cena compartilhada e portal de dungeon data-driven. | `AJUSTAR` variantes azul para mapa e vermelha para dungeon. |
| Dungeon | `training_cavern`, Nocmoon level 5-6 e boss level 11. | `AJUSTAR` para `moonlight_cavern`, mobs 7-8 e boss 13. |
| Quests | Seis quests funcionais e lineares. | `AJUSTAR` IDs de dungeon, EXP e rewards. |
| NPCs | Seis NPCs/estacoes ativos no overworld. | `DESATIVAR` todos exceto Devmoon no conteudo v0.04. |
| Equipamentos | Bracelet, Hood e Shoes gerados. | `AJUSTAR` Bracelet; demais ficam sem fonte/fora do beta. |
| Pocoes | Nao existem. | `IMPLEMENTAR` energia verde e azul. |
| Boss | Instancia rastreada, sem identidade/HUD final de boss. | `IMPLEMENTAR` modificadores e HUD central. |

## Decisoes De ID

Usar IDs canonicos em `snake_case`, independentes do nome localizado:

| Conteudo | ID recomendado |
| --- | --- |
| Digital Center | `digital_center` |
| Moonlight Forest | `moonlight_forest` |
| Moonlight Cavern | `moonlight_cavern` |
| Digital Bracelet | `digital_bracelet` |
| Unscan Digital Bracelet | `unscan_digital_bracelet` |
| Nocmoon DNA | `data_nocmoon_dna` |
| Slimmoon DNA | `data_slimmoon_dna` |
| Small Green Digital Energy | `small_digital_energy_green` |
| Small Blue Digital Energy | `small_digital_energy_blue` |

Usar `moonlight_cavern`, e nao `moonlight_cave`, para manter nome, ID da quest e
template consistentes.

Renomear IDs de itens persistidos exige:

- atualizar catalogos do Server e MySQL API;
- atualizar recipes, drops, quests e Client lang/assets;
- migrar `dm_inventory_items.itemid` quando houver dados PBE que devam ser
  preservados;
- nao reescrever IDs em auditorias historicas;
- publicar Server/API/Client no mesmo deploy para evitar catalog mismatch.

Antes do beta publico, a alternativa mais simples e limpar apenas os itens PBE
de teste e adotar os IDs finais. Isso nao deve ser feito automaticamente em
producao.

## Mapas

### Digital Center

Status: `IMPLEMENTAR`.

Conteudo:

- area inicial entre mundo real e Dataworld;
- spawn inicial e retorno de login;
- Devmoon como unico NPC ativo;
- portal azul para Moonlight Forest;
- portal vermelho reservado para dungeons, se houver acesso direto;
- Archive, Hatchery, Craft, Cooking e Upgrade nao aparecem nesta versao.

Alteracoes:

- criar `scenes/maps/digital_center.tscn`;
- definir colisao autorada e limites equivalentes no Server;
- mover Devmoon para `space_id: digital_center`;
- definir spawn e safe return points;
- retirar as estacoes atuais do catalogo ativo por flag generica
  `enabled: false`, sem
  apagar scripts, cenas ou APIs;
- adicionar variante visual `blue` aos portais de mapa;
- adicionar variante visual `red` aos portais de dungeon.

### Moonlight Forest

Status: `IMPLEMENTAR` a apresentacao final e `AJUSTAR` spawns existentes.

Conteudo:

- area menos densa: Slimmoon levels 1-3;
- area mais densa: Nocmoon levels 3-6;
- portal azul de retorno ao Digital Center;
- portal vermelho para Moonlight Cavern no final da floresta.

Alteracoes:

- criar `scenes/maps/moonlight_forest.tscn`;
- separar visualmente floresta leve e densa;
- mover spawns atuais para `space_id: moonlight_forest`;
- alterar Slimmoon de level 4-6 para 1-3;
- alterar Nocmoon de level 1-2 para 3-6;
- revisar raio, quantidade, respawn, aggro/flee e reset distance;
- espelhar colisao e navegacao entre Client e Server.

### Troca Real De Mapas

Status: `IMPLEMENTAR`.

Hoje o Client limpa entidades ao trocar `space_id`, mas continua exibindo
`main_map.tscn`. Criar:

- catalogo `space_id -> PackedScene`;
- carregamento/troca de mapa no Client durante loading;
- preservacao de UI/HUD/camera;
- bloqueio de input ate cena, colisao e snapshot estarem prontos;
- aplicacao do snapshot somente depois de a cena confirmar que esta pronta;
- fallback seguro para `digital_center`;
- worldstate filtrado por `space_id`;
- portais data-driven com identidade visual e uma lista propria de destinos;
- cada destino de mapa define `target_space`, `target_position` e
  `return_position`;
- cada destino de dungeon define `template_id`, requisitos, limite diario e
  texto localizado;
- portal azul lista somente destinos de mapas habilitados;
- portal vermelho lista somente dungeons habilitadas e mostra seus requisitos;
- cores sao variantes da mesma cena e do mesmo script, nunca implementacoes
  separadas.

Digital Center e Moonlight Forest continuam no worker overworld na v0.04. A
dungeon permanece no worker `dungeon-1`.

## Dungeon: Moonlight Cavern

Status: `AJUSTAR`.

Substituir o conteudo `training_cavern` por:

- template `moonlight_cavern`;
- Nocmoon comuns levels 7-8;
- Nocmoon Boss level 13;
- timeout inicialmente igual ao atual, 540 segundos, ate novo balanceamento;
- entrada pelo portal vermelho de Moonlight Forest;
- retorno ao safe point ao lado desse portal;
- completude pela morte da instancia rastreada do boss.

### Reward De Conclusao

- 10.000 Datamoon EXP;
- 100 Link EXP;
- 500 Bits fixos;
- 1 Upgrade Chip garantido;
- 5% de chance de 1 Alternate Chip.

Remover da conclusao:

- intervalo aleatorio de 200-600 Bits;
- drop de `nocmoon_fang`;
- reward antigo de 3.000 EXP.

Decidir antes da implementacao se mobs e boss mantem rewards individuais. Para
controle da progressao inicial, recomendacao v0.04:

- mobs mantem EXP/Link EXP pequenos;
- boss possui 5% de chance de `data_nocmoon_dna`; mobs comuns e conclusao nao
  concedem esse item;
- reward principal e aplicado uma vez pela operacao idempotente de conclusao.

### Boss

Status: `PARCIAL`.

Manter a cena/sprites normais de Nocmoon e implementar no encontro:

- `is_boss`;
- `boss_id`;
- multiplicadores data-driven de HP, ataque e defesa;
- nome localizado;
- HUD de HP no centro superior;
- HUD visivel apenas vivo, no mesmo espaco e dentro da distancia configurada;
- ocultar em morte, distancia, saida, reconnect ou troca de worker.

O boss nao escala HP, ataque ou defesa pela quantidade de membros da Party na
v0.04. Ele e balanceado primeiro para solo; Party recebe a vantagem natural de
levar mais jogadores.

Contrato inicial recomendado no template da dungeon:

```json
{
  "boss": {
    "boss_id": "moonlight_cavern_nocmoon",
    "species_id": "nocmoon",
    "level": 13,
    "name_key": "boss.moonlight_cavern_nocmoon.name",
    "modifiers": {
      "max_hp": 12.0,
      "attack": 0.65,
      "defense": 0.9,
      "attack_speed": 2.0
    },
    "first_attack_grace": 1.8,
    "skill": {
      "enabled_below_hp_percent": 40,
      "cooldown": 10.0,
      "replaces_basic_attack": true
    },
    "hud_distance": 900
  }
}
```

O Server calcula primeiro os stats normais de Nocmoon no level 13 e aplica os
multiplicadores somente a essa entidade. O ataque reduzido compensa o level do
boss e busca deixa-lo um pouco abaixo da forca ofensiva esperada do jogador,
enquanto o HP alto sustenta a luta. Os numeros sao baseline para validacao
manual, nao balanceamento definitivo.

`attack_speed` continua sendo o intervalo em segundos entre ataques no template
da especie. O modificador do encontro multiplica esse intervalo; Nocmoon com
`1.0` e boss com `2.0` resulta em um ataque a cada `2.0s`, sem alterar a duracao
da animacao. A skill so entra abaixo de 40% de HP, substitui o ataque basico do
ciclo e possui cooldown de 10 segundos.

O worldstate replica `is_boss`, `boss_id`, `name_key`, HP atual/maximo e uma
versao monotona. O Client usa esses dados apenas para apresentacao. A conclusao
permanece vinculada ao `entity_id` registrado pela instancia da dungeon, e nao
apenas a especie Nocmoon.

## Quests

Status: `AJUSTAR`.

As seis quests atuais permanecem como base. Todas usam Devmoon, dependem da
anterior e nao sao repetiveis.

| # | Level | Objetivo | Reward de EXP recomendado | Outros rewards |
| --- | ---: | --- | ---: | --- |
| Q1 | 1 | Conversar com Devmoon | 332 | - |
| Q2 | 3 | Conversar com Devmoon | 2.379 | - |
| Q3 | 5 | Conversar com Devmoon | 7.204 | `starter_bracelet`, 10 energias verdes e 10 azuis |
| Q4 | 7 | Derrotar 3 Slimmoon | 15.532 | - |
| Q5 | 9 | Derrotar 3 Nocmoon | 27.000 | - |
| Q6 | 10 | Completar `moonlight_cavern` | 35.000 | `unscan_digital_bracelet` |

Esses valores correspondem aos intervalos exatos da curva atual:

- level 1 -> 3: 332 EXP;
- level 3 -> 5: 2.379 EXP;
- level 5 -> 7: 7.204 EXP;
- Q4 preserva o intervalo level 7 -> 9 com 15.532 EXP;
- Q5 concede 27.000 EXP como quest de combate mais avancada;
- Q6 concede 35.000 EXP como conclusao da linha inicial.

Importante: rewards de combate e os 10.000 EXP da dungeon fazem o jogador
ultrapassar o inicio do level-alvo. As quests somam 87.447 EXP; com os 10.000
EXP de conclusao da dungeon, o total base chega a 97.447 EXP. O level 13 inicia
em 98.414 EXP, portanto kills obrigatorias e inimigos da dungeon devem levar o
jogador ao final da linha entre os levels 12 e 13.

Alteracoes:

- substituir os requisitos e rewards atuais pelos gates reduzidos e pela progressao final 12-13;
- manter rewards fixos e aceitar EXP excedente de combate;
- inverter os objetivos de campo: primeiro 3 Slimmoon, depois 3 Nocmoon;
- trocar `training_cavern` por `moonlight_cavern` na Q6;
- adicionar os dois consumiveis na Q3;
- adicionar `unscan_digital_bracelet` na Q6;
- revisar textos PT-BR/EN-US para Digital Center, Moonlight Forest e Moonlight
  Cavern;
- validar recompensa somente apos turn-in e impedir duplicacao.

### Regra De Balanceamento Para Quests Futuras

Nao definir toda quest como "EXP exata para subir de level". Esse modelo funciona
no tutorial, mas cresce rapido demais com a curva exponencial e elimina o valor
de combate, dungeon e exploracao.

Cada arco deve declarar:

- level inicial esperado;
- level final esperado;
- EXP total disponivel no intervalo;
- tempo e quantidade esperada de combates;
- parcela de EXP de quests, combate e conclusao de dungeon.

Distribuicao inicial recomendada depois da v0.04:

- 50-65% da progressao vem de quests principais;
- 20-30% vem de combate/objetivos obrigatorios;
- 10-20% vem de dungeon, boss ou marco final;
- side quests aceleram ou oferecem alternativas, mas nao sao obrigatorias para
  destravar a historia principal.

Regras:

- rewards permanecem fixos no catalogo e nao escalam pela EXP atual do jogador;
- uma quest normal deve conceder menos que uma quest posterior equivalente;
- quests de marco podem ter saltos maiores;
- calcular o orcamento pelo arco inteiro antes de dividir entre quests;
- validar o resultado com o minimo, esperado e maximo de EXP de combate;
- overlevel nao aumenta reward de quest;
- a curva global pode mudar no futuro sem exigir formulas especiais por quest:
  basta recalcular o orcamento do arco e seus valores data-driven.

## Datamoons

### Slimmoon

Status: `AJUSTAR`.

- inimigo level 1-3 na floresta leve;
- revisar stats e quantidade para o objetivo continuar legivel ao player level 7, apesar dos Slimmoon 1-3;
- finalizar animacoes, hit feedback, drops e versao aliada;
- `data_slimmoon_dna` existe no catalogo, mas nao precisa ter fonte na v0.04 se
  Slimmoon DataEgg estiver fora do beta.

### Nocmoon

Status: `AJUSTAR`.

- inimigo level 3-6 na floresta densa;
- inimigo level 7-8 na Moonlight Cavern;
- boss level 13;
- revisar stats, skills, drops, versao aliada e multiplicadores de boss;
- substituir `nocmoon_fang` por `data_nocmoon_dna`.

## Itens Ativos Na v0.04

### Equipamentos

`starter_bracelet`:

- manter;
- sem stats adicionais;
- habilita ataque do Datamoon.

`digital_bracelet`:

- renomear de `battle_bracelet`;
- gerar exatamente tres stats;
- pool: `ATK x2`, `CRIT x1`, `SKILL_DAMAGE x1`, `HP x2`, `MP x1`;
- alterar cap atual de MP de 2 para 1;
- manter curvas e chances de upgrade data-driven ate balanceamento posterior.

`unscan_digital_bracelet`:

- renomear de `unscan_battle_bracelet`;
- abrir uma vez;
- gerar `digital_bracelet` com tres stats autoritativos e persistidos;
- reward da Q6.

### Materiais

- `upgrade_chip`: manter; upgrade ate +5;
- `alternate_chip`: manter; troca um stat selecionado;
- `data_nocmoon_dna`: ID final aplicado; drop de 5% diretamente no boss, sem
  duplicacao na recompensa de conclusao;
- `data_slimmoon_dna`: renomear de `slimmoon_cell`; sem fonte obrigatoria nesta
  versao;
- `datacore_data`, `patch_data`, `glitch_data`: podem permanecer no catalogo,
  mas sem fonte/uso visivel enquanto Craft estiver desativado.

### Consumiveis Novos

`small_digital_energy_green`:

- `IMPLEMENTAR`;
- restaura 10% do HP maximo efetivo atual do Datamoon ativo, incluindo
  equipamentos;
- uso e quantidade restaurada validados no Server;
- bloquear se morto, HP cheio ou sem Datamoon valido;
- arredondar de forma deterministica e limitar a cura ao HP maximo efetivo.

`small_digital_energy_blue`:

- `IMPLEMENTAR`;
- restaura 10% do MP maximo efetivo atual do Datamoon ativo, incluindo
  equipamentos;
- uso e quantidade restaurada validados no Server;
- bloquear se MP cheio ou sem Datamoon valido;
- arredondar de forma deterministica e limitar a recuperacao ao MP maximo
  efetivo.

Ambos:

- stackaveis;
- usam uma operacao autoritativa compartilhada de recuperacao;
- Server resolve o percentual e o valor final; o Client nunca informa quanto
  recuperar;
- posse, quantidade, Datamoon ativo, morte e recurso atual sao validados antes
  do consumo;
- consumo e recuperacao pertencem a mesma operacao persistente, idempotente e
  auditada;
- feedback localizado;
- reward de 10 unidades cada na Q3.

## Itens Fora Do Conteudo v0.04

Nao apagar a mecanica nem os catalogos sem necessidade. Apenas remover fontes,
rewards e apresentacao ativa:

- `digital_hood`;
- `digital_shoes`;
- `digital_gloves`;
- `digital_shirt`;
- `digital_pants`;
- Unscan de todos eles;
- `starter_fishing_rod`;
- `small_fish_zip`;
- `small_fish`;
- `guild_deploy_drive`;
- `dataegg_null`;
- `dataegg_datacore`;
- `dataegg_patch`;
- `dataegg_glitch`;
- `dataegg_slimmoon`;
- `dataegg_nocmoon`;
- `attack_fish_skewer`.

Observacoes:

- Hood e Shoes existem hoje como `battle_hood` e `battle_shoes`; devem ficar sem
  fonte e fora da UI/rewards da v0.04.
- Gloves, Shirt e Pants ainda nao existem. Nao criar nesta versao.
- Os slots futuros exigirao mudancas de schema, equipamento, UI e recalculo de
  stats; nao antecipar isso no Beta.
- Fishing, Hatchery, Craft, Cooking e Guild continuam implementados, mas sem
  onboarding, NPC ou fonte de itens nesta versao.
- Fishing fica inacessivel porque a vara permanece desabilitada e sem fonte.

## NPCs Ativos

### Devmoon

Status: `MANTER E AJUSTAR`.

- unico NPC presente no Digital Center;
- oferece e conclui as seis quests;
- explica mundo, combate, mapa, portais e dungeon;
- dicas devem usar dialogo localizado e respeitar sessao/cancelamento atuais.

## NPCs Desativados Na v0.04

- Hatchery;
- Craft;
- Cooking;
- Equipment/Upgrade;
- Archive;
- Vendor.

Vendor ainda nao existe e nao deve ser implementado na v0.04.

Para os cinco sistemas existentes:

- manter codigo, cenas, APIs e contratos;
- usar apenas a flag generica `enabled: false`; nao criar `beta_enabled` nem
  acoplar disponibilidade a uma versao do beta;
- nao spawnar no Digital Center nem Moonlight Forest;
- manter validacao semantica capaz de ignorar conteudo desabilitado;
- reativar futuramente com NPCs baseados em Datamoons, nao terminais genericos.

Upgrade nao tera NPC na v0.04. Upgrade Chip e Alternate Chip podem ser obtidos e
guardados, mas nao usados. Esse estoque prepara a abertura do conteudo prevista
para a v0.05 ou v0.06 e nao e considerado um loop incompleto da v0.04.

Semantica de `enabled`:

- NPC, recipe, dungeon ou portal desabilitado nao aparece nem aceita operacoes;
- itens nao usam `enabled`; sua disponibilidade e controlada pelas fontes
  habilitadas, como quest, drop, recipe, NPC ou dungeon;
- Upgrade Chip e Alternate Chip permanecem rewards colecionaveis mesmo sem NPC;
- Fishing fica inacessivel porque a vara nao possui fonte na v0.04.

## O Que Modificar

- sistema de troca de cenas por `space_id`;
- mapas Digital Center e Moonlight Forest;
- portais azuis/vermelhos;
- spawns e levels dos inimigos;
- `moonlight_cavern` e o ID final aplicado;
- dungeon rewards, boss level e identidade;
- rewards/targets das seis quests;
- nomes/IDs/pools do Digital Bracelet e DNA;
- idiomas e assets relacionados;
- catalogos espelhados do Server e MySQL API;
- flags de conteudo/NPC ativo;
- handshake/catalog hash depois das renomeacoes.

## O Que Implementar

- duas cenas de mapa e registro de mapas;
- variantes visuais de portal;
- boss modifiers e HUD;
- duas pocoes de HP/MP;
- migracao controlada dos IDs persistidos;
- criterios de disponibilidade para conteudo fora do beta.

## O Que Remover Do Conteudo Ativo

- NPCs diferentes de Devmoon;
- fontes e rewards de itens fora da v0.04;
- Training Cavern e textos antigos;
- Hood/Shoes/Unscan correspondentes dos rewards e onboarding;
- pesca, eggs, cooking, guild e crafting do percurso inicial.

Nao remover:

- implementacoes de Fishing, Hatchery, Craft/Cooking, Guild, Archive e Equipment;
- auditorias, tabelas, rotas e protecoes ja prontas;
- itens historicos de personagens PBE sem migracao/backup.

## Known Issues E Bugs Da v0.04

Prioridade de correcao:

1. dano/numero flutuante antes do frame visual de impacto;
2. validar em jogo a ordenacao monotonicamente versionada de HP;
3. snap pequeno no inicio/fim de skill controlando o Datamoon;
4. skills sem contrato explicito de movimento durante `START`, `IMPACT` e
   `RECOVERY`;
5. input temporariamente preso apos handoff;
6. blur/pixel crisp em nomes, HUD, tiles e movimento;
7. colisao divergente entre mapa visual e autoridade do Server;
8. mensagens/loading durante troca de mapa e dungeon;
9. qualquer duplicacao de quest reward, dungeon reward ou item Unscan.

### Balanceamento PvE E Movimento De Skills

Nao aumentar globalmente `DEF` ou `def_inc` do jogador apenas para corrigir dano
de inimigos. Isso alteraria PvP, equipamentos, bosses e a curva futura. A forca
dos inimigos deve partir dos mesmos templates de especie e level, mas receber
um perfil PvE data-driven aplicado pelo Server:

```json
{
  "combat_profile": "wild_easy"
}
```

Perfis aprovados por funcao:

| Perfil | HP | Ataque | Defesa | Attack Speed |
| --- | ---: | ---: | ---: | ---: |
| `wild_easy` | 1.00 | 0.25 | 0.75 | 2.00 |
| `wild_normal` | 1.00 | 0.35 | 0.80 | 1.50 |
| `wild_hard` | 1.20 | 0.50 | 0.85 | 1.00 |
| `dungeon_easy` | 1.00 | 0.35 | 0.80 | 2.00 |
| `dungeon_normal` | 1.20 | 0.50 | 0.85 | 1.50 |
| `dungeon_hard` | 1.50 | 0.75 | 0.90 | 1.00 |

Os nomes descrevem funcao e dificuldade, nunca versao do jogo. Bosses nao
recebem automaticamente um perfil wild ou dungeon: calculam especie e level e
aplicam apenas os modificadores definidos no encontro. Isso evita multiplicar
duas vezes ataque, defesa ou HP.

`wild_easy` e o ponto inicial da v0.04. A formula defensiva compartilhada
permanece inalterada na primeira rodada. Se o combate ainda ficar curto ou
punitivo, ajustar primeiro perfis e stats das especies, medindo golpes para
matar/morrer, duracao e consumo de HP/MP com e sem equipamento.

O comportamento de spawn e a unica fonte de intencao da IA; nao existe flag
separada `hostile`:

- `aggressive`: detecta, avanca e ataca;
- `passive`: ignora e foge quando atacado;
- `defensive`: ignora e combate quando atacado;
- `flee`: detecta e foge, mas combate quando atacado.

Todos os inimigos comuns atuais usam `skill_slots: []` e
`skills_enabled: false`. O boss habilita explicitamente apenas o slot 2, junto
ao contrato de fase por HP, sem depender da lista automatica da especie.

Moonlight Cavern define mobs comuns por `enemy_areas`, usando o mesmo contrato
dos mapas: `spawn_pos`, `radius` e `max_mobs`. Cada instancia sorteia os spawns
dentro da area; apenas o boss usa um vetor fixo.

Bosses usam uma lista `skills`. Cada entrada define seu `slot`, limite de HP,
cooldown e se substitui o ataque basico daquele ciclo. Adicionar outra skill nao
exige mudar o runtime, apenas incluir uma nova entrada e manter
`skills_enabled: true`.

O runtime funcional da v0.04 ja replica `is_boss`, `boss_id`, `name_key`,
`hud_distance`, HP atual/maximo e `hp_version`. A conclusao depende da entidade
exata registrada pela instancia, nao escala pela Party e agenda o retorno por
10 segundos apos conceder as recompensas idempotentes. O Client ja preserva os
metadados para a HUD central; layout, animacao de entrada/saida e pixel crisp
permanecem na fase visual.

Cada skill deve declarar uma politica data-driven de movimento:

- `free`: movimento normal durante a acao;
- `reduced`: movimento permitido com multiplicador configurado;
- `locked`: movimento bloqueado apenas nas fases configuradas.

O Server continua validando movimento e acao, mas nao restaura a posicao antiga
do inicio do cast. O Client envia sequencia/tick de input e apresenta a politica
prevista imediatamente; correcoes usam a posicao autoritativa mais recente
aceita. Isso separa `START/IMPACT/RECOVERY` da formula de dano e reduz rollback
visual sem entregar autoridade ao Client.

### Contrato De Estados Pendente

Nao implementar `START/IMPACT/RECOVERY`, bloqueio de movimento ou correcao de
rollback antes de medir as animacoes finais. O formato a confirmar deve ser
data-driven e explicito em segundos:

```json
{
  "states": {
    "spawn": {
      "duration": 0.8,
      "locks_movement": true,
      "invulnerable": true
    },
    "death": {
      "duration": 1.2,
      "locks_movement": true
    },
    "basic_attack": {
      "start": 0.25,
      "impact": 0.10,
      "recovery": 0.35
    },
    "skills": {
      "2": {
        "start": 0.40,
        "impact": 0.15,
        "recovery": 0.55
      }
    }
  }
}
```

O Server deve ser autoridade sobre inicio, instante do impacto, dano e fim da
recuperacao. O Client apenas antecipa animacao e feedback. `spawn` impede alvo,
dano e input durante sua duracao; `death` mantem a entidade sem colisao/acao ate
o fim da animacao. Os valores so serao aprovados depois do teste visual.

O contrato de ataque e skill foi simplificado para frames em 12 FPS. Slimmoon
e a referencia inicial: ataque `total_frames: 6`, `impact_frame: 4` e janela de
um frame; Slime Spikes usa `9/6/1`. Server e Client aplicam as mesmas fases e
multiplicadores de movimento. `spawn` e `death` permanecem com duracao zero e
sem efeito novo no runtime ate a aprovacao visual. A correcao de rollback/snap
continua documentada e nao faz parte desta implementacao.

## Ordem De Implementacao

### Fase 1 - IDs E Catalogos

- confirmar IDs finais;
- criar aliases/migracao;
- adicionar pocoes;
- ajustar Bracelet/DNA;
- adicionar disponibilidade generica `enabled` a NPCs, recipes, portais e
  dungeons;
- sincronizar Server/API/Client.

### Fase 2 - Mapas E Portais

- criar Digital Center;
- criar Moonlight Forest;
- implementar map registry;
- adicionar portais azul/vermelho com listas data-driven de destinos e
  requisitos;
- validar loading, colisao e retorno.

### Fase 3 - Conteudo De Campo

- posicionar Devmoon;
- configurar Slimmoon 1-3;
- configurar Nocmoon 3-6;
- remover NPCs/estacoes do conteudo ativo.

### Fase 4 - Quests

- ajustar EXP/rewards;
- atualizar textos;
- integrar pocoes e Unscan;
- validar cadeia completa e level gates.

### Fase 5 - Moonlight Cavern

- renomear template;
- mobs 7-8;
- boss 13;
- rewards finais;
- HUD/modificadores do boss;
- retorno ao portal da floresta.

### Fase 6 - Polimento

- aplicar perfis PvE iniciais e validar dano recebido;
- adicionar politica de movimento por skill e remover rollback de cast;
- ordenar snapshots de HP por versao/tick;
- corrigir known issues;
- revisar pixel crisp;
- validar logs;
- executar fluxo manual solo e Party;
- validar reconnect e handoff;
- atualizar ambos os roadmaps.

## Escopo De Aplicacao Para Hoje

Objetivo: entregar a fundacao tecnica da v0.04 sem tentar finalizar mapas,
conteudo visual e todo o balanceamento no mesmo ciclo.

### Bloco 1 - Disponibilidade E Catalogos

- implementar somente a flag generica `enabled` em NPCs, recipes, portais e
  dungeons;
- manter sistemas existentes, mas rejeitar spawn, aquisicao, uso e acesso
  quando desabilitados;
- controlar itens pelas fontes de aquisicao habilitadas e manter
  Upgrade/Alternate Chips colecionaveis;
- criar as energias verde/azul com recuperacao autoritativa de 10%;
- remover compatibilidades de IDs antigos; o banco sera recriado antes do beta.

### Bloco 2 - Mapas E Portais

- criar o registro `space_id -> PackedScene`;
- preparar Digital Center e Moonlight Forest como cenas separadas;
- bloquear input e aguardar mapa pronto antes de aplicar snapshot;
- preservar HUD, camera e sessao;
- implementar uma cena compartilhada de portal com cor e lista de destinos
  data-driven;
- manter os dois mapas no worker overworld.

### Bloco 3 - Combate E Boss

- adicionar perfil PvE data-driven aos inimigos comuns;
- preservar a formula defensiva global nesta rodada;
- adicionar modificadores da instancia de boss e identidade autoritativa;
- replicar HP versionado e criar o contrato consumido pela futura HUD;
- documentar, mas adiar a politica de movimento por skill;
- adiar rollback do cast ate os testes de animacao;
- ordenar eventos/snapshots de HP por versao ou tick.

### Bloco 4 - Dungeon E Quests

- renomear `training_cavern` para `moonlight_cavern` simultaneamente no Server,
  API e dados compartilhados;
- ligar Q6 ao novo ID;
- reordenar Slimmoon antes de Nocmoon e aplicar a curva de EXP aprovada;
- manter conclusao e reward vinculados a uma unica operacao idempotente;
- nao limpar inventarios nem alterar auditorias historicas hoje.

### Encerramento Do Ciclo

- executar import/build e validacoes estaticas dos repos afetados;
- publicar commits separados por repositorio;
- atualizar a VM pelo deploy coordenado;
- validar manualmente login, troca de mapa, portal, combate, consumiveis,
  dungeon, reconnect e Party;
- registrar no roadmap qualquer ajuste de balanceamento observado, sem esconder
  valores diretamente no codigo.

## Checklist De Aceite

- [ ] Login cria/entra no Digital Center.
- [ ] Apenas Devmoon aparece no Digital Center.
- [ ] Portal azul troca para Moonlight Forest e carrega a cena correta.
- [ ] Slimmoon aparece somente na faixa 1-3 configurada.
- [ ] Nocmoon da floresta aparece na faixa 3-6.
- [ ] Portal vermelho abre/entra em Moonlight Cavern.
- [ ] Nocmoon da dungeon aparece na faixa 7-8.
- [ ] Boss Nocmoon level 13 possui HUD e stats de boss.
- [ ] Dungeon concede exatamente os rewards da v0.04 uma vez.
- [ ] As seis quests formam uma cadeia sem bloqueio acidental.
- [ ] Q3 concede Bracelet e 20 pocoes no total.
- [ ] Q6 concede Unscan Digital Bracelet.
- [ ] Datamoon termina a cadeia entre os levels 12 e 13.
- [ ] Itens e NPCs fora do escopo nao possuem fonte nem spawn.
- [ ] Sistemas futuros continuam compilando e preservados no codigo.
- [ ] Client, Server e API usam o mesmo catalog hash.
- [ ] Fluxo solo e Party passa na validacao manual.
- [ ] Known issues bloqueadores foram resolvidos ou explicitamente aceitos.

## Decisoes Ainda Abertas

- se reset/limpeza de inventarios PBE sera permitido antes da migracao de IDs;
- valores finais de `START`, `IMPACT`, `RECOVERY`, `spawn` e `death`;
- politica de movimento por skill e correcao de rollback;
- cenas, dimensoes, colisoes e pontos finais dos dois mapas;
- layout e animacao da HUD central do boss.
