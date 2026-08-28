# Auditoria Transversal - Datamoons Online

Data da auditoria: 2026-08-28

## Escopo

Esta auditoria revisa os repositorios ativos do jogo e os contratos entre
Client, Server, Gateway, Auth, MySQL API e Agent. Tambem verifica o projeto Web
quando ele participa de um fluxo de conta ou suporte. O objetivo e confirmar
que o nucleo esta jogavel, coerente e preparado para crescer sem apagar
conteudo ou compatibilidade apenas por heuristica.

## Resultado Executivo

O nucleo operacional esta positivo para o Beta: conexao, autenticacao,
roteamento, autoridade do Server, persistencia controlada, catalogos,
localizacao, portais, quests, social, inventario, combate e UI possuem contratos
coerentes e gates executaveis. Isso representa a meta de pelo menos 90% para os
fluxos centrais, mas nao substitui os testes manuais com jogadores nem a
validacao de conteudo visual.

Nao foi encontrado codigo de gameplay que possa ser removido com seguranca por
estar inequivocamente morto. Scripts Godot podem ser carregados por cenas,
autoloads ou nomes dinamicos; por isso a ausencia de uma referencia textual nao
e prova suficiente para excluir um script.

## Contratos Verificados

- Client e Server usam Godot 4.7.1, ENet e autoridade do Server para combate,
  recompensas, inventario, evolucao e estado persistente.
- Gateway coordena a entrada e o roteamento; Auth valida credenciais e sessoes;
  a API MySQL executa somente operacoes de persistencia autorizadas.
- Mapas e workers usam o catalogo de Nodes/spaces do Server. O Client carrega
  a cena visual ativa, sem transformar a base de dados em autoridade de
  movimento ou combate.
- Catalogos de itens, receitas e Datamoons mantem paridade semantica entre
  Server e API. Campos apenas visuais podem divergir.
- Os idiomas oficiais do Client sao `en_us.json` e `pt_br.json`; textos novos
  devem entrar nesses arquivos, nao em strings espalhadas pelo codigo.
- Quests suportam ciclo principal, secundaria, daily e weekly; o reset daily
  segue o mesmo ciclo operacional definido para dungeons.
- Chat, Party, Friends e Guild usam canais e operacoes explicitas, com limites,
  rate limit, ownership e auditoria na API.

## Qualidade e Desempenho

- Nao ha persistencia por frame ou por tick; o Server permanece como autoridade
  de runtime e a API e usada para checkpoints e operacoes sensiveis.
- Repath de IA e distribuido/limitado; mapas sao carregados no worker conforme
  o contrato atual, mantendo a estrategia de escala documentada.
- O chat usa polling controlado para o Beta. Fanout/event bus continua sendo
  uma evolucao de escala, nao uma correcao necessaria para o nucleo atual.
- Scenes ficam responsaveis pela hierarquia e apresentacao; scripts controlam
  estado e comportamento; JSON controla catalogo e conteudo ajustavel.

## Limpeza Aplicada

- Removido o arquivo da copia isolada `datamoon-online-server/utils/jsons/recipes/`
  na raiz antiga do workspace. A receita oficial permanece em
  `datamoon_online/datamoon-online-server` e na MySQL API.
- Mantidas migrations, normalizadores e nomes `legacy` que existem para
  migracao de dados ou compatibilidade historica. Eles nao sao lixo: remover
  esses arquivos quebraria bancos que ainda precisam ser atualizados.
- Mantidos logs estruturados de transicoes, falhas de contrato, seguranca,
  economia, roteamento e deploy. Conteudo normal de Chat nao entra nos logs
  operacionais.

## Pendencias Deliberadas

Estas pendencias formam a margem de configuracao futura e nao indicam quebra do
nucleo:

- preencher e validar sprites, colisao, navigation e animacoes dos mapas finais;
- validar o balanceamento de `critical_damage` em combate; o stat ja esta
  presente nos pools oficiais de equipamentos, nos payloads e no calculo
  autoritativo como bonus aditivo sobre o multiplicador base de 1.50x;
- aprovar os custos provisorios de BIT e os niveis de Craft antes de habilitar
  qualquer receita; os campos ja estao sincronizados nos catalogos, mas Craft
  ainda nao possui progressao persistida nem enforcement de nivel;
- executar testes de carga do Beta com jogadores, snapshots, projeteis,
  latencia, perda de pacotes, CPU, memoria, tick time e p95/p99 da API;
- validar visualmente todas as animacoes de Datamoons e o fluxo de quests com
  personagem inicial;
- executar backup externo e restauracao perto do Beta;
- implementar sistemas futuros: Trade, Rarity expandida, Vendors, Battle Pass,
  Anomalies e Guild expandida.

## Gates Executados

- `check_catalog_sync.cjs`
- `check_localization.cjs`
- `check_movement_contract.cjs`
- `gofmt`, `go test ./...`
- importacao headless do Client e Server no Godot 4.7.1
- `python -m unittest discover -s tests -q` no DevmoonAI local
- sintaxe Node e `git diff --check`

Os gates confirmam contratos estaticos e importacao. A aprovacao final de
jogabilidade continua sendo feita no Client conectado ao ambiente de teste.
