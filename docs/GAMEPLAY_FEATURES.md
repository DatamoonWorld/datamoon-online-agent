# Datamoons Online - Funcionalidades Do Jogo

Este documento concentra o desenho funcional das mecanicas de Datamoons
Online. Ele descreve o objetivo de cada sistema e o que o projeto oferece hoje,
sem classificar prioridade, maturidade ou versao de entrega.

Status, pendencias e ordem de implementacao pertencem exclusivamente a
`FIRST_BETA_ROADMAP.md`. Ao expandir uma mecanica, primeiro completar seu desenho
aqui e depois transformar as partes aprovadas em tarefas no roadmap.

## Archive

### Definicao

Armazenamento e retirada dos Datamoons pertencentes ao jogador. O Archive nao
deve concentrar treino, evolucao, incubacao ou melhoria de stats.

### O Que Existe Hoje

- listagem dos Datamoons do personagem;
- armazenamento e ativacao do Datamoon selecionado;
- persistencia da selecao ativa;
- recálculo seguro de HP, MP, Link e equipamentos durante a troca;
- bloqueio da interacao durante combate;
- rollback quando a persistencia da troca falha;
- janela e NPC preservados, mas sem fonte ativa na v0.04.

## Hatchery

### Definicao

Forma de obter novos Datamoons por incubacao de DataEggs durante um tempo
persistido. Fechar o Client ou reiniciar os servicos nao reinicia o tempo.

### O Que Existe Hoje

- slots de incubacao persistentes;
- inicio autoritativo da incubacao;
- duracao definida pelo DataEgg;
- consulta de estado e tempo restante;
- claim idempotente do Datamoon resultante;
- validacao de posse e consumo do Egg;
- protecao contra repeticao de claim;
- DataEggs de Slimmoon e Nocmoon catalogados;
- janela e NPC preservados, mas sem fonte ativa na v0.04.

## Craft

### Definicao

Fabricacao data-driven de tudo que precise ser produzido por receitas, incluindo
Eggs, equipamentos, materiais e itens futuros.

### O Que Existe Hoje

- catalogo de receitas em JSON;
- validacao autoritativa de ingredientes, quantidades e inventario;
- consumo e concessao dentro de operacao transacional e idempotente;
- motor de receitas compartilhado com Cooking;
- suporte a resultados com metadata;
- auditoria das mudancas de inventario;
- janela e NPC preservados, mas sem receitas acessiveis na v0.04.

## Cooking

### Definicao

Cozimento de peixes e outros ingredientes para produzir alimentos, buffs e
outros consumiveis relacionados a preparacao do jogador.

### O Que Existe Hoje

- receitas de Cooking separadas por profissao no catalogo compartilhado;
- validacao e processamento autoritativos;
- Cooking EXP e nivel de Cooking persistentes;
- consumo e producao transacionais;
- alimentos que aplicam buffs temporarios;
- tooltips de receita e resultado;
- janela e NPC preservados, mas sem fonte ativa na v0.04.

## Equipment NPC

### Definicao

NPC dedicado a Upgrade, Alternate e futuras formas de melhoria de equipamentos.

### O Que Existe Hoje

- janela com abas Upgrade e Alternate;
- slots separados para equipamento e material;
- selecao visual sem mover o item do inventario;
- soma visual de todos os stacks do material selecionado;
- exigencia de equipamento desequipado;
- Upgrade ate +5 com chances definidas por dados;
- Alternate de um stat selecionado respeitando pool e limites;
- consumo, resultado, retry e auditoria autoritativos;
- NPC preservado, mas desativado no conteudo da v0.04.

## Fishing

### Definicao

Pesca com conteudo e resultados influenciados pelos stats da Fishing Rod e por
futuros dados do local de pesca.

### O Que Existe Hoje

- Fishing Rod como slot de equipamento;
- sessao autoritativa com identificador unico;
- validacao de timing e protecao contra replay;
- Fishing EXP e nivel persistentes;
- rewards processados pelo backend;
- suporte a dados de raridade da Rod sem confiar no Client;
- cancelamento quando o personagem entra em estado incompatível;
- inacessivel na v0.04 porque nao existe fonte para obter a Rod.

## Guild

### Definicao

Grupo social persistente para reunir amigos. Nao inclui dominio territorial,
politica de faccoes ou economia propria neste desenho.

### O Que Existe Hoje

- criacao por `guild_deploy_drive`;
- convite, aceite, recusa e saida;
- expulsao e transferencia de lideranca;
- papeis e permissoes basicas;
- mensagem da Guild;
- canal de Chat da Guild;
- operacoes e eventos administrativos auditados;
- sistema preservado, mas sem fonte ativa do item de criacao na v0.04.

## Equipamentos

### Definicao

Itens persistentes com stats que auxiliam a progressao de todo Datamoon ativo do
personagem. Equipamentos tambem poderao substituir camadas visuais especificas
do personagem.

### O Que Existe Hoje

- slots Bracelet, Hood, Shirt, Gloves, Pants, Shoes e Fishing Rod;
- Starter Bracelet habilitando ataque sem stats aleatorios;
- equipamentos gerados com tres entradas de stats;
- pools, limites, pesos e curvas por item;
- Unscan autoritativo com metadata persistente;
- equipar e desequipar fora de combate;
- recalculo imediato de stats, HP e MP;
- bonus escalado pelo Link do Datamoon ativo;
- Upgrade e Alternate;
- Bracelet ativo na v0.04 e demais equipamentos preservados sem fonte.

## Evolucao

### Definicao

Progressao de formas `Code -> Nex -> Omega`. Unlock permanente e Transform
temporario sao conceitos diferentes. Familias podem possuir linhas ramificadas.

### O Que Existe Hoje

- catalogo de familia e linhas de evolucao;
- Slimmoon, Slimmoon Fighter Mode e Slimmoon Warrior Mode registrados;
- Unlock persistente por instancia de Datamoon;
- requisitos de level, Link, item e forma anterior;
- consumo atomico do material de Unlock;
- auditoria e promocao do cap de Link;
- replicacao de todas as linhas registradas;
- selecao interna deterministica de linha no Client;
- slots e tooltips de requisitos na janela de stats;
- Transform e Regress autoritativos com nove atalhos `ALT+1` a `ALT+9`;
- bloqueio de dois segundos, cooldown compartilhado de tres segundos e
  recuperacao total de HP/MP depois do recalculo de equipamentos;
- forma ativa temporaria por sessao, retorno a Code no login e regressao
  automatica na morte;
- hotbar reidratada pelas skills da forma ativa;
- troca visual completa depende das cenas runtime de cada forma. Enquanto o
  Slimmoon Fighter Mode nao possui essas cenas, ele usa fallback visual Code.

## Passe De Batalha

### Definicao

Passe com niveis. O jogador completa requisitos para obter progresso e recebe
recompensas ao atingir cada nivel.

### O Que Existe Hoje

- somente a direcao de produto;
- nenhuma temporada, trilha, progresso, reward ou compra esta ativa;
- duracao, quantidade de niveis, requisitos, trilha gratuita/premium, catch-up,
  expiracao, monetizacao e protecao contra abuso ainda nao foram definidos.

## Link

### Definicao

Representa a amizade e sincronia entre humano e Datamoon. Deve influenciar
progressao, equipamentos, skills e outras mecanicas que reforcem essa relacao.

### O Que Existe Hoje

- dez Link Levels com custos individuais;
- Link EXP concedida apenas por fontes autorizadas;
- caps persistentes de 5, 7 e 10 ligados a evolucao;
- 10% a 100% dos stats de equipamentos conforme o Link Level;
- skill level associado ao Link Level;
- tooltips de estrelas, progresso, bonus atual e proximo bonus;
- suporte persistente ao marco Link MAX;
- contrato de Link MAX com 150% dos equipamentos e Mastery opcional de skill;
- quest definitiva de Link MAX ainda nao existe.

## Anomalias

### Definicao

Anomalias Glitch aparecem em areas delimitadas do mapa, alterando temporariamente
o ecossistema. Elas trazem Datamoons mais agressivos e oportunidades maiores de
drop, sempre por regras autoritativas e limitadas.

### O Que Existe Hoje

- contrato geral de eventos mundiais autoritativos;
- suporte arquitetural a spawns, combat profiles, drops, chunks e `space_id`;
- nenhuma agenda, area, tabela de rewards ou interface de Anomalia implementada;
- participacao, limites por jogador, anti-alt e restauracao da zona ainda
  precisam de desenho final.

## Trade Entre Jogadores

### Definicao

Transacoes diretas e seguras de itens e valores entre jogadores, com revisao da
oferta e confirmacao das duas partes.

### O Que Existe Hoje

- inventario, moedas, operacoes idempotentes e auditoria economica reutilizaveis;
- nenhuma sessao, janela ou endpoint de Trade;
- contrato preliminar exige confirmacao bilateral versionada, lock de posse,
  capacidade de inventario, commit atomico e cancelamento sem mover valor;
- itens negociaveis, limites, taxas e restricoes ainda precisam ser definidos.

## Rarity

### Definicao

Raridade classificara itens e equipamentos sem ser confundida com upgrade,
qualidade, quantidade de stats ou poder pago.

### O Que Existe Hoje

- equipamentos atuais nao possuem raridade ou qualidade;
- pesos de stats e chance de drop existem, mas nao representam tier de raridade;
- tiers, cores, impacto em drops, equipamentos, Craft, Trade e economia ainda
  precisam ser definidos.

## NPCs Vendedores

### Definicao

NPCs distribuidos pelos mapas que vendem itens de utilidade e criam sinks de
Bits para auxiliar jogadores e controlar inflacao.

### O Que Existe Hoje

- Bits, inventario, catalogo de itens e operacoes economicas autoritativas;
- estrutura data-driven de NPCs e servicos;
- nenhum fluxo de compra, estoque ou preco implementado;
- catalogo de venda, recompra, limites, variacao de estoque e regras por mapa
  ainda precisam ser definidos.

## Datapedia

### Definicao

Enciclopedia que apresenta Datamoons ja liberados e formas ainda a liberar,
preservando misterio quando uma entrada nao deve revelar todos os dados.

### O Que Existe Hoje

- catalogo publico Web chamado temporariamente de Moonpedia;
- listagem numerada e pagina individual por Datamoon;
- identidade, sistema, stage, stats, crescimento, skills e formulas;
- assets e animacoes apresentados pela Web;
- nenhuma integracao com progresso individual de descoberta/unlock;
- rota, textos e codigo ainda usam o nome Moonpedia;
- versao dentro do Client ainda nao existe.

## Party

### Definicao

Grupo temporario para jogar com amigos em mapas e dungeons.

### O Que Existe Hoje

- convite e membership;
- propagacao versionada entre workers;
- reserva integral para dungeon;
- preservacao durante handoff;
- HUD remota acinzentada sem texto `OFFLINE`;
- remocao depois de offline definitivo;
- rollback quando a transferencia falha.

## Chat E Moderacao

### Definicao

Comunicacao por escopo com protecoes contra abuso. Punicao deste modulo afeta o
Chat, nao o acesso completo a conta.

### O Que Existe Hoje

- canais World, Private, Party e Guild;
- mute/unmute administrativo persistente;
- slow/normal mode persistente por canal;
- quinta mensagem em dois segundos bloqueada com timeout de 2.000 ms;
- feedback de tempo restante;
- administradores definidos por conta;
- conteudo das mensagens nao e gravado nos logs de auditoria.

## Quests

### Definicao

Estrutura de objetivos e recompensas que conduz historia, tutorial, progressao e
desbloqueio de sistemas.

### O Que Existe Hoje

- quests data-driven com requisitos e dependencias;
- objetivos de conversa, derrota e conclusao de dungeon;
- progresso persistente;
- turn-in e rewards idempotentes;
- sete quests iniciais ligadas ao Devmoon;
- rewards de EXP, itens e desbloqueios;
- suporte futuro a quests de Guild, evento, Link MAX e interacao com sistemas.

## Dungeons E Bosses

### Definicao

Conteudo instanciado para jogador ou Party, com requisitos, limite de recompensa,
boss autoritativo e retorno seguro ao mundo.

### O Que Existe Hoje

- selecao por portal e reserva de Party;
- worker separado de instancia;
- handoff e retorno ao portal de origem;
- limite diario com reset configurado;
- mobs e boss definidos por dados;
- conclusao vinculada a entidade exata do boss;
- rewards idempotentes e auditados;
- saida automatica depois da conclusao;
- HUD final do boss, Fang Strike e mapa final ainda nao estao completos.

## Criacao De Personagem

### Definicao

Fluxo `Login -> Criacao -> Escolha de Datamoon -> Join Game`. Nome, aparencia e
Datamoon inicial so devem persistir juntos na confirmacao final.

### O Que Existe Hoje

- contrato de aparencia em camadas e paletas predefinidas;
- body masculino/feminino, pele, cabelo, olhos e roupa como escolhas aprovadas;
- presets Casual e Urbano persistindo suas partes separadamente;
- personagem inicial sem Bracelet visual;
- servidor preparado para validar IDs em vez de RGB arbitrario;
- operacao atomica final, UI e assets em camadas ainda nao estao completos.

## Buffs, Debuffs E Consumiveis

### Definicao

Efeitos temporarios de combate ou preparacao, aplicados por skills, alimentos,
itens e outros sistemas autorizados.

### O Que Existe Hoje

- efeitos centrais de stats, dano periodico, controle e permissao de acoes;
- Attack, Defense, Crit, Skill, cooldown e attack speed positivos/negativos;
- shield, damage reduction, vulnerable, marked, slow, root, silence, disarm e
  weakened;
- Bleed, Poison e Burn com dano capturado;
- limites percentuais para efeitos sensiveis;
- buffs e debuffs separados no HUD, com timer e tooltip de origem;
- consumiveis autoritativos de HP/MP e alimentos com buffs.

## Eventos Mundiais

### Definicao

Eventos temporarios por zona ou shard que mudam comportamento, atividade e
recompensas sem carregar o mundo inteiro nem ignorar interest management.

### O Que Existe Hoje

- contrato de autoridade, escopo, participacao, rewards e antiabuso;
- categorias planejadas para ondas, corrupcao, recursos, portais, elites,
  preparacao de dungeon e progresso comunitario;
- Anomalias definidas como primeiro formato planejado;
- nenhum scheduler ou evento ativo.

## Aparencia E Cosmeticos

### Definicao

Composicao visual do personagem por camadas, permitindo que roupas e futuros
cosmeticos substituam partes sem trocar o sprite inteiro.

### O Que Existe Hoje

- slots visuais head, shirt, pants, gloves, shoes e bracelet aprovados;
- body, hair e eyes separados;
- palette swap com cores predefinidas;
- roupas iniciais nao sao itens;
- equipamentos futuros podem declarar a camada visual correspondente;
- assets finais e integracao runtime ainda nao estao completos;
- compras e cosmeticos pagos permanecem fora do beta.
