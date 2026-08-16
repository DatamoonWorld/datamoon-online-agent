# Nocmoon Design

> ID: `nocmoon`.

## Identidade

- Tipo:         `Nocmoon`
- Sistema:      `GLITCH`
- Stage:        `CODE`
- Sprite:       `nocmoon`
- Moonpedia:    `5`
- Descrição:    `Nocmoon é um Datamoon em seu primeiro estágio. Agressivo e territorial, costuma reagir a invasores de forma coordenada, atacando em grupo quando necessário. Apesar de não possuir olhos, sua audição extremamente sensível permite que utilize ecolocalização para perceber tudo ao seu redor. Graças a essa habilidade, Nocmoon se torna um combatente eficiente mesmo em terrenos escuros ou de baixa visibilidade.`

## Stats e crescimento

- ATK Base:             `190`
    -- Crescimento:     `0.95`
- DEF Base:             `13`
    -- Crescimento:     `0.065`
- HP Base:              `520`
    -- Crescimento:     `2.6`
- MP Base:              `110`
    -- Crescimento:     `0.55`
- CT Base:              `0`
    -- Crescimento:     `0`
- AS Base:              `1` 
    -- Crescimento:     `0`

## Ataque basico e lifecycle

- Ataque basico:    ``
    -- Movimento:   ``
    -- FPS:         `12`
    -- Alcance:     ``
- Spawn:            ``
    -- Movimento:   ``
    -- FPS:         `12`
- Death:            ``
    -- Movimento:   ``
    -- FPS:         `12`

## Skills

- Skill 1
    -- ID:              `SkillFangStrike`
    -- Alcance:         ``
    -- Descrição:       `Nocmoon morde os inimigos em uma área, causando {dano} de dano e tendo {chance} de chance de aplicar BLEED. Caso o alvo já esteja sob efeito de BLEED, Nocmoon recupera {valor} do dano causado como vida.`
    -- Cooldown:        `4s`
    -- Dano:            `320 + 32 * L`
    -- Multiplicador:   `ATK * (1.0 + 0.1 * L)`;
    -- Mana:            `15 + 5 * L`
    -- FPS:             `12 FPS`
    -- Frames:          `` 
    -- Movimento:       ``
    -- Efeitos:         `1- 0.2 + 0.01 * L de chance de causar 5s de Bleed, máximo 5 stacks, dano 100 + 10 * L`; 
                        `2- Recupera 0.05 * 0.005 * L de dano causado caso o alvo esteja com BLEED`
    -- Condições:       `Nenhuma`
    -- Master Link      `Multiplicador de cura no BLEED passa a ser 0.2 no total`


## Link

- Familia:              `nocmoon`
- Caps CODE/NEX/OMEGA:  `5 / 7 / 10`
- Quest MAX:            `link_max_nocmoon`

## Evolucoes

- Forma CODE:           `Nocmoon`
- Forma NEX:            `Kainemoon`
    -- Requirement:     `Link 3; Corrupted Blood; lv 20`
- Forma OMEGA:          `Bathorymoon`
    -- Requirement:     `Kainemoon liberado; Requer Link 6; Glitched Crown; lv 60`

## Assets e cenas

- Cena:             `nocmoon`
- Spritesheet       `nocmoon_spritesheet`
- Portrait          `nocmoon_portrait`
- Icon:             `nocmoon_icon`
- Full Sprite:      `nocmoon_sprite`
