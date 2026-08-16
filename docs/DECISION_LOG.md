# Registro De Decisoes Vigentes

Este arquivo registra somente decisoes transversais que ainda orientam mais de
um repositorio. Detalhes pertencem aos contratos tematicos; tarefas e status
pertencem a `FIRST_BETA_ROADMAP.md`.

## Plataforma E Entrega

- Godot 4.7 e a referencia do Client e dos runtimes Godot.
- Cada pasta do workspace possui repositorio e release independentes.
- `pbe` e o ambiente de integracao; `main` representa a linha publicada de
  cada repositorio conforme seu fluxo.
- O deploy da VM e coordenado por `ops/update_vm.sh`, com gates estaticos,
  rollback do release e units systemd.
- O roteiro de validacao do jogo e manual. Nao criar suites automatizadas nos
  projetos sem nova decisao explicita.

## Autoridade E Servicos

- Game Server e autoridade de movimento aceito, combate, IA, Party, dungeons e
  estado runtime.
- MySQL API e a unica porta para persistencia e operacoes economicas; o Server
  nao escreve diretamente no banco.
- Auth controla credenciais e emissao de sessao.
- Gateway valida o acesso e seleciona a rota; nao possui logica de gameplay.
- Client cuida de input, prediction, replay de comandos, interpolacao, UI,
  animacao e feedback, sem decidir resultados persistentes.
- Web usa APIs internas escopadas para conta, suporte e apresentacao publica.

## Rede E Mundo

- A conexao publica usa transporte seguro e tickets de sessao de uso limitado.
- Movimento local usa prediction, acknowledgements monotonicamente ordenados e
  reconciliation suave; hard snap e reservado para erro grande ou troca de
  autoridade.
- Snapshots antigos nao podem sobrescrever estado mais novo de posicao ou HP.
- `space_id` identifica cada espaco autoritativo. Digital Center e Moonlight
  Forest permanecem no worker Overworld; dungeons usam instancias reservadas.
- Mapas visuais sao cenas do Client. Geometria, spawns, portais e navegacao que
  afetam autoridade possuem representacao equivalente no Server.
- Handoff preserva Party e sessao; desconexao curta pode retomar no mesmo
  worker quando o lease ainda for valido.

## Gameplay E Conteudo

- Combate e deterministico fora do critico e usa impacto autoritativo alinhado
  ao timing configurado da animacao.
- Ataque basico inicia cooldown somente depois do fim da acao.
- Alcances do catalogo orientam IA e futuro Auto Combate. No controle manual,
  iniciar ataque ou skill livre nao e bloqueado por distancia; hitbox, area ou
  projetil autoritativo determinam o acerto.
- Efeitos usam consultas semanticas centralizadas para movimento, ataque e
  skills; modificadores percentuais respeitam os limites do contrato de combate.
- IA usa `behavior` como autoridade, NavigationAgent2D em areas navegaveis,
  repath distribuido, leash suave, estado de evade e snap apenas emergencial.
- Conteudo e data-driven. IDs em JSON, cenas e API devem ser validados entre os
  catalogos antes de deploy.
- Equipamentos gerados persistem stats no item; progresso sensivel e rewards
  usam operacoes idempotentes e auditoria.
- Link representa o vinculo com o Datamoon e controla a porcentagem dos stats
  de equipamento e o nivel efetivo de skills.
- Evolucao segue `Code -> Nex -> Omega`, separando Unlock persistente de
  Transform/Regress. A forma Omega identifica a linha evolutiva. Forma ativa e
  cooldown de transformacao existem apenas na sessao; login sempre retorna a
  Code e nao exige coluna de banco.
- `Datapedia` e o nome oficial do catalogo de especies no jogo e na Web.

## Conta, Web E Operacao

- Mute e slow mode sao persistentes; antispam bloqueia a quinta mensagem em
  dois segundos. Nao existe chat-ban e o conteudo normal do chat nao e logado.
- Logs estruturados vao para stdout/journald; arquivos JSONL duplicados ficam
  desativados. INFO registra transicoes, bloqueios e erros, nao cada movimento.
- Auditorias persistentes cobrem economia e operacoes administrativas; retencao
  padrao e 180 dias.
- Contas exigem verificacao de e-mail. Reset e alteracoes de credenciais usam
  desafios de uso unico, expiram e invalidam sessoes conforme o contrato.
- Suporte e first-party, com tickets persistentes e notificacao transacional.
- O Beta nao possui compras. Termos e privacidade versionados sao aceitos na Web
  e o Client deve respeitar o estado legal retornado no login.

## Como Registrar Uma Nova Decisao

Inclua data, decisao, motivo, consequencias e documentos afetados somente se a
decisao alterar varios dominios. Atualize ou remova a entrada quando ela deixar
de valer; Git preserva o historico antigo.
