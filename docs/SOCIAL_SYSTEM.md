# Social System

Este documento define o contrato social atual do jogo. A autoridade e o Server;
a API persiste amizades, convites e memberships; o Client apresenta janelas e
acoes contextuais.

## Friends

- cada personagem pode ter no maximo 20 amizades;
- convite e persistido mesmo quando o alvo esta offline;
- o alvo aceita ou recusa na janela Friends;
- ao aceitar, a amizade e criada para os dois personagens;
- a lista mostra nome e presenca `Online` ou `Offline`;
- remover amizade atualiza os dois lados quando estiverem conectados;
- convite para jogador conectado em outro worker e entregue pelo relay social;
- convites duplicados, auto-convites, listas cheias e ownership invalido sao
  rejeitados pela API dentro de transacao;
- o Client nao decide o resultado e nao persiste a lista localmente.

## Party

- party so e formada por convite aceito;
- convite pode partir da lista Friends, lista Guild ou nome clicavel no Chat;
- convite para personagem offline nao e persistido nem enviado;
- itens de um abate pertencem ao jogador que realizou o abate;
- progresso de quest de matar pode ser compartilhado por membros no mesmo
  contexto de mapa/worker, conforme o contrato de quests;
- dungeon usa completude da instancia, salvo quando a quest pedir explicitamente
  o boss;
- acoes sociais continuam disponiveis por UI, nao por comandos sociais digitados.

## Guild

- convite de Guild para personagem offline nao e persistido nem enviado;
- Guilds tem no maximo 30 membros;
- a criacao exige o consumo atomico de um `guild_deploy_drive`; o futuro NPC
  apenas apresentara o popup e chamara este mesmo contrato, sem regra paralela;
- nomes de Guild tem de 3 a 10 caracteres, usam letras ASCII, numeros, espaco,
  `_` ou `-`, sao unicos e nao podem conter termos proibidos;
- a lista de membros fornece o `character_id` necessario para acoes contextuais;
- permissoes, convite, aceite, papeis e membership continuam autoritativos no
  Server/API.
- aceitacao, recusa e saida entram no audit junto com criacao, convite,
  expulsao, cargos, lideranca e MOTD;
- snapshots de Guild incluem presenca baseada no heartbeat da API e sao
  atualizados nos demais workers por relay interno de refresh;

## Chat

- mensagens sem prefixo usam o canal `Local`, limitado ao `space_id` atual;
- o canal `World` existe para leitura, mas nao aceita envio manual; um item de
  mensagem mundial podera liberar esse envio no futuro;
- os unicos comandos de conversa sao `/w Nome mensagem`, `/p mensagem` e
  `/g mensagem`;
- aliases de whisper e comandos administrativos nao fazem parte do parser do
  Chat. Moderacao continua em rotas protegidas para uma futura ferramenta de
  administracao;
- as abas do Client sao `All`, `Guild`, `Local`, `World`, `Party`, `Whisper` e
  `System`. `All` agrega todos os canais e mensagens de sistema;
- o nome do remetente carrega `sender_character_id` para abrir `Invite Friend`,
  `Invite to Party`, `Invite to Guild` ou `Whisper`;
- o corpo da mensagem nao recebe conteudo adicional nem segredo;
- o limite unico de mensagem e 240 caracteres. O Server sanitiza, autoriza e
  persiste antes do fan-out;
- mensagens privadas sao persistidas por 168 horas por padrao, inclusive quando
  o destinatario esta offline, e sao entregues quando ele reconecta. A entrega
  e at-least-once no relay e o Client remove duplicatas por `message_id`;
- mensagens Local, Party e Guild tambem sao persistidas antes da entrega direta;
  o `message_id` permite deduplicacao no Client;
- o relay entre workers transporta nome, `sender_character_id` e `message_id`.
- com `Ctrl` + clique direito em um item do Inventario ou equipamento equipado,
  o jogador insere o nome visivel e anexa um vinculo ao rascunho da mensagem;
  cada mensagem aceita no maximo dois itens. O vinculo acompanha edicoes no
  texto e e removido se o nome inserido for alterado ou apagado;
- o Server valida a posse atual pelo `inventory_item_id` e substitui a referencia
  por um snapshot publico contendo item, nome, descricao, raridade, sprite,
  upgrade e stats. Tipos de catalogo como `material_craft` sao normalizados
  para o tipo publico `material`;
- o snapshot e persistido junto da mensagem e continua disponivel durante a
  retencao mesmo que o item seja alterado ou removido depois;
- no Client, `Ctrl` + clique no nome vinculado abre o mesmo tooltip do
  Inventario em modo somente leitura, incluindo descricao e stats publicos.
  Dono, slot, quantidade, id do inventario e metadata privada nunca sao
  enviados ao Chat.

### Retencao e logs

- mensagens normais ficam apenas em `dm_game_chat_messages`, sujeitas a
  `DATAMOON_CHAT_RETENTION_HOURS`, e nao entram no journald como conteudo;
- o banco armazena o remetente resolvido pelo `sender_character_id`; o Server
  nunca confia no nome enviado pelo Client;
- moderacao, bloqueios antispam e falhas de entrega geram eventos sem texto da
  mensagem. Conteudo de Chat nunca deve ser colocado em log operacional;
- o polling atual considera apenas escopos ativos, processa no maximo 64 por
  ciclo em ordem rotativa e usa indice por tipo, canal, escopo e id. Em escala
  maior, deve ser substituido por fan-out/event bus.

Convites e atualizacoes de amizade usam escopos internos de relay, separados do
Chat exibido ao jogador. O payload transporta somente o identificador do
convite ou um pedido de sincronizacao; o Server reconsulta a API antes de
atualizar a janela Friends.

## UI

- `F` abre a janela Friends;
- a janela mostra Friends e Invites, com contador `0/20`;
- `Accept` e `Decline` operam convites recebidos;
- `Remove` exclui uma amizade;
- `Invite to Party` fica desabilitado para amigos offline;
- HUD de outros jogadores e uma extensao futura, nao requisito do primeiro
  fluxo social.
