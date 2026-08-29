# Auditoria De Portais, Nodes E Dungeons

## Contrato Atual

- `Node` organiza uma macro-regiao e associa mapas, sub-regioes, portais e
  templates de dungeon.
- `space_id` identifica o espaco autoritativo em runtime.
- Um portal pertence a um espaco de origem e aponta para destinos permitidos ou
  abre um seletor de templates.
- Um template de dungeon pertence a um Node, mas cada execucao usa um espaco
  isolado no formato `dungeon:<template_id>:<serial>`.
- Digital Center e um hub externo aos Nodes; Moonlight Forest e Moonlight
  Depths pertencem ao `NODE-01`.

## Fonte De Conteudo

`datamoon-online-server/utils/jsons/nodes.json` e a fonte do Server para:

- `space_id`, tipo e Node;
- cena estatica;
- escopo de worker (`zone` ou `instance`);
- `zone_id` ou `instance_group`.

O Client mantem somente o registro das cenas visuais que consegue apresentar.
Ele nao autoriza portal, mapa ou dungeon.

## Fluxos Implementados

1. O Client solicita interacao com um portal.
2. O Server valida existencia, espaco, distancia, combate, rate limit e quest.
3. Destinos multiplos usam uma sessao curta criada pelo Server.
4. A confirmacao revalida distancia, combate, unlock e destino atual do
   catalogo.
5. A troca de espaco reseta movimento, exige `space_ready` e sincroniza o novo
   snapshot.
6. Dungeons validam Party, nivel, limite diario e template antes do handoff ou
   da criacao da instancia local.
7. Timeout, conclusao, saida, desconexao e remocao da Party limpam a instancia
   e retornam o jogador por um ponto seguro.

## Persistencia De Localizacao

- `space_id` de mapas normais conhecidos e persistido no logout junto da
  posicao do personagem.
- Espacos com prefixo `dungeon:` nunca sao persistidos; o login retorna ao
  ponto seguro/retorno do mundo.
- Espacos de evento devem usar prefixo `event:` ou declarar
  `persist_character_location: false` no catalogo de espacos.
- O bloqueio de portal controla acesso ao mapa, nao apaga a ultima localizacao
  valida de um personagem que ja esta nele.

## Validacoes Aplicadas

- espacos precisam de cena existente, worker e escopo validos;
- Node precisa referenciar espacos, dungeons e portais existentes;
- espaco e dungeon precisam pertencer ao Node declarado;
- portais precisam ter origem, tipo, quest e destinos/templates validos;
- destinos precisam apontar para espacos existentes e Nodes coerentes;
- `_is_known_world_space()` usa o catalogo de espacos, nao apenas referencias de
  portais;
- a metadata de unlock do portal e replicada para a visibilidade do Client,
  enquanto a autoridade continua no Server.

## Compatibilidade E Pendencias

- O fallback `target_space` de `portal_config.gd` permanece como compatibilidade
  ate confirmar que nenhum catalogo antigo e consumido.
- `main_map.tscn` ainda preserva dados de TileMap usados pela compatibilidade de
  colisao/pesca; nao deve ser removido nesta etapa.
- Recuperacao de estado de dungeon apos reinicio de worker continua fora do
  escopo do beta.
- Multi-Node, mapa mundial com Nodes desbloqueados e catalogo visual gerado
  automaticamente ficam para a expansao posterior.
- `is_space_loaded()` e a pasta duplicada `datamoon-online-server` devem ser
  removidos somente apos uma verificacao de consumidores e origem.

## Validacao Manual Necessaria

- portal bloqueado e desbloqueado por quest;
- tentativa fora de alcance, em combate e com selecao expirada;
- destino adulterado no Client;
- troca de mapa com `space_ready` e snapshot inicial;
- duas Parties em instancias diferentes;
- reentrada na instancia da mesma Party;
- timeout, boss concluido, saida e desconexao;
- handoff entre workers e retorno ao portal de origem;
- erro de cena, Node, portal ou template impedindo readiness do Server.
