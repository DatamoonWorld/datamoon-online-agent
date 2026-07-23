# Datamoons Online — Code Rules

## Stack Atual

Datamoons Online usa uma arquitetura distribuída com cinco aplicações principais:

1. **Client**

   * Godot 4.7
   * GDScript

2. **Game Server**

   * Godot 4.7
   * GDScript

3. **Auth Server**

   * Godot 4.7
   * GDScript

4. **Gateway**

   * Godot 4.7
   * GDScript

5. **MySQL API**

   * Go
   * Responsável por comunicação controlada com o banco MySQL

Banco de dados:

* MySQL

Multiplayer:

* ENet, ainda a confirmar.

Arquitetura interna:

* mistura de nodes tradicionais, services, singletons/autoloads e outros padrões, ainda a confirmar.

---

## Fluxo de Autenticação Atual

O fluxo esperado é:

1. Client conecta no Gateway.
2. Gateway conversa com Auth Server.
3. Auth Server valida dados via MySQL API.
4. MySQL API consulta o banco MySQL.
5. Após validação, Gateway/Auth gera ou repassa token.
6. Client recebe token.
7. Client usa token para se validar no Game Server.
8. Game Server também consulta a MySQL API quando precisa validar dados persistentes.

O agente deve preservar esse fluxo até que uma decisão formal altere a arquitetura.

---

## Regras de Autoridade

O servidor é a fonte da verdade para sistemas críticos.

O Client nunca deve decidir de forma final:

* login válido;
* identidade do jogador;
* posição final;
* dano;
* morte;
* captura;
* recompensa;
* drop;
* experiência;
* inventário;
* moeda;
* troca;
* evolução;
* dungeon state;
* estado persistente de Datamoons.

O Client pode:

* enviar intenção de ação;
* prever movimento local;
* tocar animações;
* mostrar feedback visual;
* carregar recursos;
* renderizar entidades recebidas por chunk.

---

## Separação de Responsabilidades

### Client

Responsável por:

* input;
* câmera;
* interface;
* animações;
* feedback visual;
* áudio;
* carregamento de mapa estático;
* entidades visuais por chunk;
* interpolação;
* predição quando necessário.

O Client não deve conter regras críticas de progressão, economia ou combate como fonte de verdade.

---

### Gateway

Responsável por:

* entrada inicial de conexão;
* roteamento;
* handshake;
* comunicação com Auth;
* entrega ou validação inicial de token;
* controle de fluxo entre Client, Auth e Game Server quando aplicável.

O Gateway não deve virar um “servidor de jogo escondido”.

---

### Auth Server

Responsável por:

* autenticação;
* validação de credenciais;
* emissão/validação de token;
* regras de sessão;
* integração com MySQL API para dados de conta.

O Auth Server não deve conter regras de gameplay.

---

### Game Server

Responsável por:

* estado online do mundo;
* players conectados;
* Datamoons ativos;
* chunks;
* combate;
* movimento validado;
* dungeons;
* spawns;
* captura;
* recompensas;
* sincronização;
* regras de gameplay.

O Game Server pode consultar a MySQL API para persistência, mas não deve depender do banco para cada evento de combate em tempo real.

---

### MySQL API

Responsável por:

* acesso ao MySQL;
* queries controladas;
* persistência;
* leitura e escrita de dados;
* isolamento do banco em relação aos servidores Godot.

A MySQL API deve evitar expor operações genéricas perigosas.

Ela deve oferecer endpoints/funções específicas para o jogo.

---

## Regras para Banco de Dados

O banco MySQL deve ser usado para dados persistentes, como:

* contas;
* personagens;
* Datamoons possuídos;
* inventário;
* progressão;
* moedas;
* quests;
* guildas;
* histórico relevante;
* configurações persistentes.

Não usar MySQL como fonte direta para estado de combate em tempo real.

Evitar:

* query por ataque;
* query por frame;
* query por movimento;
* dependência síncrona em ações rápidas;
* salvar estado volátil excessivamente.

Preferir:

* cache no Game Server;
* batch saves;
* checkpoints;
* salvamento por evento relevante;
* filas internas de persistência;
* logs auditáveis para sistemas sensíveis.

---

## Regras de Rede

O agente deve assumir rede multiplayer com ENet até confirmação contrária.

Toda implementação online deve considerar:

* latência;
* perda de pacotes;
* ordem de mensagens;
* autoridade do servidor;
* validação de input;
* rate limit;
* anti-spam;
* reconexão;
* duplicação de pacote;
* segurança contra manipulação do Client.

Mensagens de rede devem ser:

* pequenas;
* objetivas;
* versionáveis quando possível;
* separadas por responsabilidade;
* validadas no servidor.

---

## Regras para Chunks

O mundo é dividido em chunks.

O Game Server deve controlar:

* quais entidades existem em cada chunk;
* quais entidades cada player deve receber;
* entrada e saída de chunk;
* spawn e despawn;
* updates de entidades relevantes;
* transferência de interesse entre áreas.

O Client deve carregar:

* mapa estático;
* recursos visuais;
* entidades dinâmicas recebidas do servidor;
* transições entre partes do mapa.

O agente deve evitar soluções que exijam carregar todos os players, pets ou entidades do mundo no Client.

---

## Regras para Dungeons Instanciadas

Dungeons devem possuir estado isolado.

Cada instância pode conter:

* party;
* players;
* Datamoons;
* inimigos;
* objetivos;
* drops;
* timers;
* eventos;
* estado de progresso.

O agente deve evitar misturar estado de dungeon com estado global do mundo sem controle claro.

Cada dungeon precisa de:

* ID de instância;
* lista de participantes;
* regras de entrada;
* regras de saída;
* persistência quando necessário;
* limpeza de memória ao finalizar.

---

## Regras para Combate em Código

Combate deve ser tratado como sistema server-authoritative.

O Client envia intenção:

* mover;
* atacar;
* usar habilidade;
* trocar controle;
* mirar;
* interagir.

O Game Server valida:

* cooldown;
* alcance;
* direção;
* estado do player;
* estado do Datamoon;
* custo da habilidade;
* colisão/hitbox;
* alvo válido;
* dano final;
* aplicação de status.

O Client recebe resultado ou estado sincronizado.

---

## Regras para Alternância Player/Datamoon

A troca de controle entre player e Datamoon é mecânica central.

Implementações devem considerar:

* entidade atualmente controlada;
* entidade assistida por IA ou comportamento automático;
* validação no servidor;
* cooldown ou restrição de troca, se necessário;
* estado de input;
* câmera;
* habilidades disponíveis;
* riscos de exploração;
* sincronização para outros players.

O agente não deve tratar Datamoon como pet passivo por padrão.

---

## Regras para GDScript

Código GDScript deve priorizar:

* clareza;
* nomes explícitos;
* funções pequenas;
* baixo acoplamento;
* tipagem quando útil;
* sinais bem nomeados;
* separação entre lógica e visual;
* evitar scripts gigantes;
* evitar dependência excessiva de singletons globais.

Preferir:

```gdscript
func apply_damage(target_id: int, amount: int, source_id: int) -> void:
    ...
```

Evitar:

```gdscript
func do_stuff():
    ...
```

---

## Regras para Autoloads e Singletons

Autoloads devem ser usados com cuidado.

Aceitável para:

* configuração global;
* roteamento de rede;
* gerenciadores centrais bem definidos;
* registry de serviços;
* estado de sessão no Client.

Evitar usar Autoload como depósito de qualquer variável.

Se um singleton começar a ter responsabilidades demais, deve ser dividido.

---

## Regras para Services

Services devem ter responsabilidade clara.

Exemplos aceitáveis:

* `AuthService`
* `NetworkService`
* `ChunkService`
* `CombatService`
* `DatamoonService`
* `InventoryService`
* `DungeonService`

Cada service deve expor operações claras e evitar conhecer detalhes visuais do Client.

---

## Regras de Segurança

Nunca confiar no Client.

Validar no servidor:

* token;
* sessão;
* player ID;
* comandos;
* posição;
* velocidade;
* cooldown;
* dano;
* item usado;
* recompensa;
* troca;
* captura;
* evolução.

Qualquer sistema que possa gerar vantagem ao jogador deve ter validação server-side.

---

## Regras para Criação de Sistemas

Antes de implementar um sistema, o agente deve identificar:

1. Qual aplicação será alterada?
2. O sistema roda no Client, Game Server, Auth, Gateway ou MySQL API?
3. Há persistência?
4. Há sincronização de rede?
5. O sistema afeta combate, economia ou progressão?
6. Existe risco de exploit?
7. Precisa de logs?
8. Quais cenários manuais e eventos de log validam o comportamento?
9. Precisa alterar documentação?

Nenhum sistema grande deve ser implementado sem responder essas perguntas.

---

## Regras para Refatoração

Refatorações devem ser incrementais.

Evitar:

* reescrever sistemas inteiros sem necessidade;
* mudar protocolo sem compatibilidade;
* acoplar Client e Server;
* misturar visual com lógica;
* quebrar fluxo de autenticação;
* mudar banco sem migração clara.

Preferir:

* pequenas melhorias;
* interfaces claras;
* extração de serviços;
* documentação da alteração;
* validações manuais registradas e logs estruturados correlacionáveis.

---

## Regras para IA ao Programar

Quando o agente gerar código, deve informar:

* arquivos afetados;
* responsabilidade de cada alteração;
* impacto em Client/Server/API;
* riscos;
* como validar manualmente e quais logs observar;
* se precisa atualizar documentação.

O agente deve evitar código “mágico” sem explicar onde encaixa.

---

## Regra Final

Toda solução técnica deve respeitar três prioridades:

1. **Segurança multiplayer**
2. **Escalabilidade MMO**
3. **Manutenção de longo prazo**

Se uma solução for rápida mas comprometer qualquer uma dessas prioridades, o agente deve apontar o problema e sugerir alternativa melhor.
