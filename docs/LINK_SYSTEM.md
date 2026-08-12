# LINK_SYSTEM.md

> Este documento define o contrato de Link. Status de implementacao, prioridade
> e pendencias vivem somente em `FIRST_BETA_ROADMAP.md`.

# Datamoons Online — Sistema de Link

## Visão Geral

O Link é a conexão digital formada entre um humano e um Datamoon.

Essa conexão representa a sincronização entre a consciência biológica do humano e a essência digital do Datamoon.

Todo Datamoon possui a capacidade de estabelecer um Link com um humano, mas a força dessa conexão varia de acordo com as experiências compartilhadas entre ambos.

O Link é um dos principais pilares de progressão de Datamoons Online e está diretamente ligado ao conceito de vínculo entre jogador e criatura.

---

# O Que é o Link

Quando um humano e um Datamoon estabelecem uma parceria, uma conexão digital é criada entre eles.

Essa conexão permite que informações, emoções, intenções e experiências sejam compartilhadas em diferentes níveis.

Quanto mais forte o Link, maior a capacidade de sincronização entre ambos.

O Link não representa apenas amizade ou confiança.

Ele representa uma ligação real entre dois seres de naturezas diferentes:

* Um ser biológico;
* Um ser híbrido biológico-digital.

---

# Filosofia do Sistema

O Link existe para reforçar o vínculo entre o jogador e seu Datamoon.

Ele não deve ser tratado apenas como mais um atributo numérico.

Seu objetivo é desbloquear novas possibilidades e fortalecer a relação entre humano e Datamoon.

O sistema deve priorizar:

* Vínculo;
* Progressão compartilhada;
* Escolhas significativas;
* Evolução da parceria;
* Recompensas por dedicação.

O sistema não deve existir apenas para aumentar números de dano, vida ou defesa.

---

# Funções do Link

Atualmente o Link influencia:

* Evoluções;
* Progressão de habilidades;
* Desbloqueio de conteúdo relacionado ao Datamoon;
* Compatibilidade entre humano e Datamoon.
* Eficiência dos bônus concedidos por equipamentos.

Novas funcionalidades poderão ser adicionadas futuramente.

---

# Sincronização com Equipamentos

Cada estrela de Link completa define quanto dos bônus brutos dos equipamentos o
Datamoon consegue sincronizar. Essa eficiência é individual para cada Datamoon:

| Estrelas completas | Bônus sincronizado |
| ---: | ---: |
| 0 | 0% |
| 1 | 10% |
| 2 | 20% |
| 3 | 30% |
| 4 | 40% |
| 5 | 50% |
| 6 | 60% |
| 7 | 70% |
| 8 | 80% |
| 9 | 90% |
| 10 | 100% |
| Link MAX | 150% |

A regra se aplica somente aos stats fornecidos pelos equipamentos. Stats-base
da espécie e do nível, buffs e modificadores de encontro não recebem esse
multiplicador. O Server calcula o valor efetivo e continua sendo a autoridade.

Exemplo: um conjunto que forneça 180 ATK concede 0 ATK com zero estrelas, 18 ATK
com uma estrela, 90 ATK com cinco, 180 ATK com dez e 270 ATK no Link MAX.

Essa progressão numérica complementa o Link, mas não substitui suas funções de
vínculo, evolução, habilidades e desbloqueios.

---

# Progressão de Habilidades

O Link permite que um Datamoon desenvolva melhor suas capacidades.

Em vez de simplesmente aumentar atributos, o Link deve expandir o potencial da criatura.

Exemplos de benefícios possíveis:

* Evolução de habilidades existentes;
* Desbloqueio de novas habilidades;
* Novas formas de utilização de habilidades;
* Melhor controle de determinadas técnicas;
* Habilidades exclusivas relacionadas ao vínculo.

O foco deve ser aumentar possibilidades de gameplay e não apenas aumentar números.

## Limite de Skill por Link

Skills comuns começam no nível 1. Link 0 e Link 1 mantêm esse nível-base;
dos Links 2 a 10, o nível de Link define o nível efetivo máximo da skill.

| Link | Nível efetivo máximo da skill |
| ---: | ---: |
| 0-1 | 1 |
| 2 | 2 |
| 3 | 3 |
| 4 | 4 |
| 5 | 5 |
| 6 | 6 |
| 7 | 7 |
| 8 | 8 |
| 9 | 9 |
| 10 | 10 |

Link MAX não cria um nível 11. Ele habilita a Mastery opcional definida pela
própria skill. O Server aplica essa regra e envia ao Client somente valores
resolvidos para apresentação.

```json
"link_max_mastery": {
  "damage_multiplier": 1.15,
  "buff_bonus_add": 0.0,
  "buff_duration_add": 2.0,
  "effect_chance_add": 0.1,
  "description_key": "SKILL_EXAMPLE_LINK_MAX_MASTERY"
}
```

Todos os campos são opcionais. Sem esse bloco, Link MAX não altera a skill.
Os bônus só ficam ativos para um Datamoon aliado com dez estrelas completas e
o marco persistente Link MAX desbloqueado.

---

# Evolução e Link

O Link é um dos fatores necessários para a evolução de um Datamoon.

Nenhuma evolução deve acontecer apenas por ganho de nível.

A evolução deve considerar:

* Link;
* Influências externas;
* Requisitos específicos da espécie.

Exemplos de influências:

* Itens;
* Anomalias;
* Eventos;
* Regiões específicas;
* Missões;
* Experiências únicas.

---

# Crescimento do Link

O Link aumenta através das experiências compartilhadas entre humano e Datamoon.

As fontes canônicas da v1 são combate, quests, dungeons e pesca. Exploração,
eventos, descobertas e momentos narrativos podem virar fontes futuras somente
quando forem observáveis e validados pelo Server.

O objetivo é incentivar o jogador a utilizar e desenvolver sua relação com o Datamoon ao longo da jornada.

---

# Compatibilidade

Cada Datamoon desenvolve seu próprio Link com o jogador.

O progresso obtido com um Datamoon não é automaticamente transferido para outro.

O vínculo é individual.

Isso incentiva a construção de relações únicas com diferentes Datamoons ao longo da aventura.

---

# Relação com o Mundo

O Link é um fenômeno natural do Mundo dos Datamoons.

Ele surgiu como consequência da interação entre seres biológicos e criaturas híbridas criadas a partir dos sonhos do Ser da Lua.

Por esse motivo, o Link é considerado um dos fenômenos mais importantes para a estabilidade entre os dois mundos.

---

# Futuras Expansões

O sistema foi projetado para permitir futuras expansões sem alterar sua filosofia principal.

Possíveis utilizações futuras:

* Eventos exclusivos;
* Interações especiais;
* Mecânicas de sincronização;
* Habilidades compartilhadas;
* Conteúdo narrativo avançado;
* Formas alternativas de evolução.

Essas funcionalidades devem sempre reforçar o conceito de vínculo e crescimento conjunto.

---

# Regras de Design

O Link deve sempre representar conexão e desenvolvimento conjunto.

O Link não deve:

* Ser apenas uma barra numérica;
* Servir apenas para aumentar dano;
* Substituir habilidade do jogador;
* Ser facilmente comprado ou ignorado.

O Link deve:

* Recompensar dedicação;
* Reforçar a identidade do Datamoon;
* Criar escolhas significativas;
* Apoiar evolução e progressão;
* Fortalecer a relação entre humano e Datamoon.

---

# Resumo

O Link é a conexão digital entre um humano e um Datamoon.

Ele representa o crescimento da parceria entre ambos e atua como um dos pilares centrais da progressão em Datamoons Online.

Seu propósito é fortalecer o vínculo entre jogador e criatura, desbloqueando novas possibilidades de evolução, habilidades e experiências ao longo da jornada.

---

# Contrato Técnico da Progressão por Estrelas

## Product Contract

- Link progression belongs to one persisted Datamoon instance.
- Link has ten stars. Partial progress never counts as a completed star.
- Every completed star synchronizes another 10% of equipment bonuses.
- Ten completed stars synchronize 100% of equipment bonuses.
- Link MAX is a separate permanent milestone and synchronizes 150% of equipment
  bonuses. It is not an eleventh star.
- Link multipliers affect equipment bonuses only. Base stats, flat buffs and
  multiplicative buffs keep their existing formulas.
- Progress is server authoritative and is persisted by the MySQL API.

## Star Curve

Star costs are individual, not cumulative:

| Star | Required Link EXP |
|---:|---:|
| 1 | 1,000 |
| 2 | 2,000 |
| 3 | 4,000 |
| 4 | 8,000 |
| 5 | 15,000 |
| 6 | 30,000 |
| 7 | 40,000 |
| 8 | 60,000 |
| 9 | 90,000 |
| 10 | 250,000 |

The total cap is 500,000 Link EXP.

## Sources

Canonical v1 source IDs are:

- `combat`
- `quest`
- `dungeon`
- `fishing`

The reward operation `source_type` is the source of truth. Unknown or missing
sources cannot grant Link EXP.

Stars may override their allowed sources per Datamoon family. The Nocmoon
family accepts every canonical source for stars 1-9 and only `combat` for star
10. Families without an override accept every canonical source.

## Segmented Grant Algorithm

Link EXP is applied one target star at a time while holding the Datamoon row
lock in the reward transaction:

1. Resolve the current target star and its partial progress.
2. Stop if the target star is above the Datamoon's unlocked star cap.
3. Stop if the operation source is not accepted by the target star.
4. Apply only the amount required to fill that star.
5. Continue with the remaining amount against the next star.

This means a quest reward may finish star 9 but cannot spill into Nocmoon's
combat-only star 10. EXP rejected by a cap or source rule is not banked.

The API response and audit metadata distinguish requested, applied and rejected
Link EXP and expose a stable rejection reason.

## Evolution Caps

The permanent unlocked progression stage controls the available star cap:

- Code/base form: 5 stars.
- Nex/intermediate form: 7 stars.
- Omega/advanced form: 10 stars.

The cap belongs to the Datamoon instance and does not decrease when an active
temporary form regresses. Evolution unlock code must promote the persisted cap;
temporary transformation state must not control it.

## Link MAX

- Completing star 10 makes the family-specific Link MAX quest available.
- The quest is bound to a specific `datamoon_id` when accepted.
- Completion atomically marks that Datamoon instance as Link MAX.
- A character owning multiple Datamoons of the same family must unlock Link MAX
  independently for each instance.
- Link MAX cannot be removed by regression, logout, death or archive changes.

The quest definitions and content are intentionally deferred. Persistence and
runtime contracts may be implemented before the first Link MAX quest exists.

## Client Payload

The server sends resolved data; the client never derives eligibility:

```json
{
  "link_total_exp": 1200,
  "link_level": 1,
  "link_star_cap": 5,
  "link_max_unlocked": false,
  "link_stars": [
    {
      "star": 1,
      "current_exp": 1000,
      "required_exp": 1000,
      "completed": true,
      "available": true,
      "allowed_sources": ["combat", "quest", "dungeon", "fishing"]
    },
    {
      "star": 2,
      "current_exp": 200,
      "required_exp": 2000,
      "completed": false,
      "available": true,
      "allowed_sources": ["combat", "quest", "dungeon", "fishing"]
    }
  ]
}
```

The reusable `link_stars.tscn` and `link_star.tscn` scenes consume this payload
in the Datamoon information and archive interfaces. Each star tooltip shows
status, individual progress, allowed sources, previous-Link and evolution
requirements, equipment synchronization and skill-level cap. The Link level
label summarizes active and next bonuses; Link 10 previews Link MAX, while Link
MAX has no next-bonus section.

## Runtime Stat Rules

Equipment synchronization is:

```text
completed_stars / 10.0
```

Link MAX overrides that value with `1.5`. HP and MP recalculation caused by a
Link transition must preserve the current resource percentage and must not act
as a free heal.
