# Catalogos E Localizacao

## Fonte De Verdade

O catalogo autoritativo de gameplay fica no Server, em
`datamoon_online/datamoon-online-server/utils/jsons/`. Ele define itens,
receitas, Datamoons, evolucoes, Link e niveis usados pela simulacao.

A MySQL API espelha somente os dados necessarios para validar operacoes
persistentes, em `internal/catalog/data/`:

- `item_types.json`, `cooking_levels.json`, `datamoon_levels.json` e
  `link_levels.json`;
- `items/`, `recipes/`, `datamoons/` e `evolutions/`.

Mapas, Nodes, portais, dungeons, NPCs, spawns e IA permanecem exclusivos do
Server. Copiar esses arquivos para a API criaria uma segunda autoridade sem
beneficio para persistencia.

## Fluxo De Alteracao

1. Alterar e validar o JSON no Server.
2. Executar `scripts/sync-catalog.ps1` dentro do repositorio da MySQL API.
3. Executar `node ops/check_catalog_sync.cjs` no Agent.
4. Adicionar ou revisar as chaves em `utils/lang/en_us.json` e
   `utils/lang/pt_br.json` no Client.
5. Confirmar que o Client resolve nomes por `id`, `form_id` ou `skill_id` e que
   nao foi introduzido texto de apresentacao no catalogo autoritativo.

O gate compara semanticamente os campos de gameplay entre Server e API. Campos
de apresentacao, como `name`, `sprite` e `description`, podem ser diferentes
porque a apresentacao pertence ao Client.

## Idiomas

Todo texto visivel ao jogador deve usar uma chave nos JSONs de idioma. Isso
inclui nomes, descricoes, raridades, stats, estados, abas, mensagens de skill,
Node e sub-regiao. O Client possui helpers em `config.gd` para nomes de item,
receita, skill e Datamoon; novos consumidores devem usa-los em vez de montar
nomes diretamente.

As linguas oficiais atuais sao `en_us` e `pt_br`. Elas devem manter o mesmo
conjunto de chaves. Referencias `name_key`, `description_key` e
`link_max_mastery_description_key` dos catalogos tambem precisam existir nos
dois arquivos.

## Estado Auditado

- 38 itens, 9 receitas, 7 arquivos de Datamoon e 1 familia de evolucao estao
  sincronizados entre Server e API.
- As duas linguas possuem o mesmo conjunto de 866 chaves.
- As raridades seguem `common`, `uncommon`, `rare`, `epic`, `legendary`; `epic`
  possui cor propria no tooltip.
- O Client resolve nomes de catalogo por chave e mantem apelidos do jogador
  separados do nome oficial.
- `critical_damage` esta documentado para alguns equipamentos e possui chave
  de idioma, mas sua geracao no pool autoritativo ainda depende da definicao do
  contrato numerico. Nao ativar o stat apenas por existir no documento.

## Limites Da Auditoria

Chaves usadas por codigo dinamico nao podem ser descobertas apenas por busca
literal. Ao criar uma nova familia de efeitos, skills ou estados, adicionar as
chaves nos dois idiomas no mesmo change set e incluir uma verificacao de
catalogo/recurso quando o contrato estiver fechado.
