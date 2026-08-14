# Regras De Codigo De Devmoon

Estas regras complementam `AGENTS.md`. Elas se aplicam a qualquer alteracao de
runtime e nao repetem os contratos especializados de banco, rede ou Godot.

## Antes De Alterar

1. Identificar o repositorio proprietario da responsabilidade.
2. Ler o fluxo atual e seus produtores/consumidores.
3. Definir autoridade, sincronizacao, persistencia e risco de abuso.
4. Verificar contratos de RPC, HTTP, JSON, cenas e banco afetados.
5. Planejar migracao e rollback quando houver mudanca persistente.

## Limites Dos Repositorios

- Client: input, prediction, replay, interpolacao, camera, UI e apresentacao.
- Server: simulacao, validacao, IA, combate, mundo e resultado de gameplay.
- Auth: credenciais e autenticacao.
- Gateway: entrada, compatibilidade e roteamento.
- MySQL API: operacoes persistentes, transacoes, idempotencia e auditoria.
- Web: portal publico, conta e suporte por APIs internas escopadas.
- Agent: contratos, roadmap e operacao; nunca gameplay runtime.

Nao mover responsabilidade apenas para evitar uma mudanca coordenada.

## Implementacao

- Preferir modulos pequenos com uma responsabilidade e interfaces explicitas.
- Nao criar abstracao sem pelo menos dois consumidores estaveis.
- Dados de conteudo ficam em JSON; composicao visual em cenas; regras e estado
  dinamico em codigo.
- Nao duplicar formulas ou validacoes criticas entre Client e Server. O Client
  pode espelhar dados para apresentar, nunca para autorizar.
- Operacoes multi-etapa recebem `operation_id`; mutacoes sensiveis sao
  idempotentes.
- Validar tipo, faixa, ownership, estado, escopo e rate antes de agir.
- Falhar fechado em autenticacao, ticket, catalogo incompatível e persistencia.
- Nao registrar segredo, senha, token, ticket ou conteudo normal do chat.

## Refatoracao E Legado

- Provar produtores e consumidores antes de remover um caminho.
- Migrar todos os leitores e escritores na mesma entrega quando o contrato muda.
- Nao manter fallback para dados de teste que serao recriados no PBE.
- Manter compatibilidade somente quando existir consumidor real e prazo de
  retirada documentado no roadmap.
- Remover codigo comentado, flags sem leitor, adapters sem produtor e nomes
  antigos depois da migracao.
- Nao misturar reorganizacao ampla com mudanca de regra sem necessidade.

## Performance

- Banco nunca participa de loop por frame, movimento ou ataque.
- Limitar trabalho por tick, por peer e por area de interesse.
- Evitar varredura global quando `space_id`, chunk ou indice resolvem a busca.
- Distribuir tarefas caras e medir antes de otimizar.
- Client nao processa UI ou polling quando o elemento esta inativo.
- Alocacao, trafego e logs de alta frequencia exigem justificativa.

## Validacao

- Executar formatadores, parsers, imports headless e gates existentes.
- Usar `git diff --check` e revisar o diff completo.
- Preservar o roteiro manual no Agent; nao adicionar suite automatizada sem
  decisao explicita.
- Informar claramente o que nao pode ser validado localmente.

## Referencias Especializadas

- `DATABASE_RULES.md`
- `NETWORK_RULES.md`
- `GODOT_STANDARDS.md`
- `SERVER_ARCHITECTURE.md`
- `DATAMOON_CREATION_RULES.md`
- `../docs/CODE_HEALTH.md`
