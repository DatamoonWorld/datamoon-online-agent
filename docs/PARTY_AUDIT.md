# Party - Auditoria De Fluxo

## Fluxo Atual

1. O Client envia convite, aceite, recusa, saida, expulsao, transferencia de
   lideranca ou mensagem pelo RPC explicito.
2. O Game Server valida a sessao, atualiza seu cache local e usa a MySQL API
   para as operacoes persistentes. O Client nunca decide membership ou cargo.
3. A MySQL API protege as alteracoes com transacao, ownership do personagem,
   limite de tres membros, versao da Party e convites com expiracao de 60s.
4. O Server distribui snapshots versionados aos membros locais. Alteracoes para
   outros workers usam os escopos de relay da Party e o snapshot persistido.
5. Presenca combina heartbeat persistido, cache local de status e TTL curto. A
   Party e mantida durante handoff; desconexao definitiva remove o membro depois
   da janela de 10s.

## Regras Funcionais Vigentes

- A Party tem no maximo tres personagens.
- Apenas o lider convida, expulsa ou transfere a lideranca.
- A saida do lider escolhe o membro mais antigo como novo lider; a remocao que
  deixa um unico membro encerra a Party.
- Itens e drops pertencem ao personagem que realizou o kill.
- XP compartilhado hoje e calculado para membros online da mesma Party no worker
  local; nao existe validacao de `space_id` ou distancia nessa regra.
- Progresso de quest `kill_enemy_type` usa regra mais restritiva: somente membros
  online no mesmo worker e no mesmo `space_id` recebem credito.
- `collect_item` e `talk_to_npc` nao sao compartilhados. `complete_dungeon`
  depende do evento de conclusao da instancia.
- Party dungeon reserva e handoff usam o `party_id` persistido e a versao da
  Party para evitar misturar grupos.

## Coesao E Seguranca

- As acoes mutaveis criticas tem ownership e transacao na API.
- Convites sao ligados ao alvo, party version e expiracao; aceite revalida o
  estado antes de inserir o membro.
- Snapshots usam versao e o Server e responsavel por rejeitar estado stale.
- O chat da Party passa pela sanitizacao e pelo mesmo rate limit do chat social.
- Nao foi encontrada funcao comprovadamente morta no fluxo usado pelo Server,
  Client ou dungeon.

## Candidata Legada

`/party/create` e `createOrJoinParty` ainda existem na MySQL API, mas nenhum
consumidor interno usa essa rota: o fluxo atual cria Party por convite e aceite.
Ela deve ser removida somente depois de confirmar que nenhuma ferramenta externa
ou ambiente antigo depende dela. A remocao exige apagar a rota, handler e
qualquer contrato publicado correspondente em um commit separado.

## Melhorias Recomendadas

### Antes De Crescer O MMO

- Decidir se XP compartilhado deve exigir o mesmo `space_id`, proximidade ou uma
  regra de instancia. A regra de quest ja e consistente e pode servir de base.
- Adicionar testes de concorrencia para dois aceites, convite expirado, kick e
  transferencia de lideranca simultaneos.
- Unificar a distribuicao de Party em um relay/event bus dedicado quando houver
  muitos workers; o relay via chat atual e adequado ao beta, mas mistura canais
  sociais e sincronizacao interna.

### Depois Do Beta

- Tornar tamanho maximo, regra de XP e distancia configuraveis por catalogo.
- Adicionar permissao explicita para iniciar dungeon, loot e futuras quests de
  Guild sem sobrecarregar o cargo de lider.
- Medir fan-out de snapshots, heartbeat e consultas de Party antes de aumentar
  frequencia ou quantidade de membros.
