# Slimmoon Design

> ID: `slimmoon`.

## Identidade

- Tipo:         `Slimmoon`
- Sistema:      `DATACORE`
- Stage:        `CODE`
- Sprite:       `slimmoon`
- Moonpedia:    `17`
- Descrição:    `Slimmoon é um Datamoon em seu primeiro estágio. Tímido e facilmente assustado, costuma evitar perigos sempre que pode. Porém, quando alguém importante está em risco, seu medo dá lugar a uma coragem surpreendente, revelando o grande coração escondido em seu pequeno corpo.`

## Stats e crescimento

- ATK Base:             `120`
    -- Crescimento:     `0.6`
- DEF Base:             `18`
    -- Crescimento:     `0.09`
- HP Base:              `730`
    -- Crescimento:     `3.65`
- MP Base:              `130`
    -- Crescimento:     `0.65`
- CT Base:              `0`
    -- Crescimento:     `0`
- AS Base:              `2` 
    -- Crescimento:     `0`

## Ataque basico e lifecycle

- Ataque basico:    `8 frames; impacto nos frames 5-8; mesma hitbox`
    -- Movimento:   `START: livre 100%; IMPACT: BLOQUEADO; RECOVERY: BLOQUEADO`
    -- FPS:         `12`
    -- Alcance:     `10`
- Move:             `6 frames`
    -- FPS:         `12`
    -- Ao parar:    `interrompe imediatamente e entra em Idle`
- Spawn:            `8 frames`
    -- Movimento:   `BLOQUEADO`
    -- FPS:         `12`
- Death:            `14 frames; frame 8 dura 166ms; demais frames duram 83ms`
    -- Movimento:   `BLOQUEADO`
    -- FPS:         `12`

## Skills

- Skill 1
    -- ID:              `SkillSlimeSpikes`
    -- Alcance:         `12`
    -- Descrição:       `Slimmoon usa seu corpo adaptável e seu instinto defensivo para criar espinhos ao seu redor, causando {dano_multiplicado} de dano base aos inimigos próximos.`
    -- Cooldown:        `3s`
    -- Dano:            `280 + 28 * L`
    -- Multiplicador:   `ATK * (0.8 + 0.08 * L)`; `HP * (0.1 + 0.005 * L)` 
    -- Mana:            `18 + 6 * L`
    -- FPS:             `12 FPS`
    -- Frames:          `7 frames; impacto no frame 3; janela de impacto de 2 frames` 
    -- Movimento:       `START: reduzido 50%; IMPACT: bloqueado; RECOVERY: BLOQUEADO`
    -- Efeitos:         `Nenhum`
    -- Condições:       `Nenhuma`
    -- Master Link      `Multiplicador de HP passa a ser 0,2 no total`


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

- Cena:             `slimmoon`
- Spritesheet       `slimmoon_spritesheet`
- Portrait          `slimmoon_portrait`
- Icon:             `slimmoon_icon`
- Full Sprite:      `slimmoon_sprite`
