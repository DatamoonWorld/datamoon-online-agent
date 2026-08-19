# Slimmoon Fighter Mode Design

> ID: `slimmoon_fm`.

## Identidade

- Tipo:         `Slimmoon FM`
- Sistema:      `DATACORE`
- Stage:        `CODE`
- Sprite:       `slimmoon_fm`
- Moonpedia:    `18`
- Descrição:    `Slimmoon FM é um Datamoon em seu primeiro estágio. Tímido e facilmente assustado, costuma evitar perigos sempre que pode. Porém, quando alguém importante está em risco, seu medo dá lugar a uma coragem surpreendente, revelando o grande coração escondido em seu pequeno corpo.`

## Stats e crescimento

- ATK Base:             `915`
    -- Crescimento:     `4.57`
- DEF Base:             `72`
    -- Crescimento:     `0.36`
- HP Base:              `6880`
    -- Crescimento:     `34.4`
- MP Base:              `1570`
    -- Crescimento:     `7.85`
- CT Base:              `0.05`
    -- Crescimento:     `0.001`
- AS Base:              `1` 
    -- Crescimento:     `0`

## Ataque basico e lifecycle

- Ataque basico:    ``
    -- Movimento:   ``
    -- FPS:         `12`
    -- Alcance:     ``
- Spawn:            ``
    -- Movimento:   `BLOQUEADO`
    -- FPS:         `12`
- Death:            ``
    -- Movimento:   `BLOQUEADO`
    -- FPS:         `12`

## Skills

- Skill 1
    -- ID:              `SkillDualBlade`
    -- Alcance:         ``
    -- Descrição:       `Slimmoon usa seu corpo adaptável e seu instinto defensivo para criar espinhos ao seu redor, causando {dano_multiplicado} de dano base aos inimigos próximos.`
    -- Cooldown:        `4s`
    -- Dano:            `2618 + 238 * L`
    -- Multiplicador:   `ATK * (1.0 + (0.1 * L + CT))`; 
    -- Mana:            `72 + 15 * L`
    -- FPS:             `12 FPS`
    -- Frames:          `` 
    -- Movimento:       ``
    -- Efeitos:         `Nenhum`
    -- Condições:       `Nenhuma`
    -- Master Link      `Multiplicador de ATK passa a ser 2.5 + CT no total`


## Link

- Familia:              `slimmoon`
- Caps CODE/NEX/OMEGA:  `5 / 7 / 10`
- Quest MAX:            `link_max_slimmoon`

## Evolucoes

- Forma CODE:           `Slimmoon`
- Forma NEX:            `Slimmoon FM`
    -- Requirement:     `Link 3; Sword Blueprint; lv 20`
- Forma OMEGA:          `Slimmoon WM`
    -- Requirement:     `Slimmoon FM liberado; Requer Link 6; Armor Blueprint; lv 60`

## Assets e cenas

- Cena:             `slimmoon_fm`
- Spritesheet       `slimmoon_fm_spritesheet`
- Portrait          `slimmoon_fm_portrait`
- Icon:             `slimmoon_fm_icon`
- Full Sprite:      `slimmoon_fm_sprite`
