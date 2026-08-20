# Padrao Das Fichas De Datamoon

Cada arquivo em `docs/species/` descreve o Datamoon canônico, suas formas,
stats, skills e dependencias visuais. `docs/species/slimmoon.md` e a primeira
referencia oficial de estrutura.

## Limite Da Ficha

A ficha pertence a especie jogavel, nao a uma aparicao no mundo. Nao incluir:

- mapa, area, ponto ou quantidade de spawn;
- nivel de inimigo;
- behavior, aggro, wander, leash ou velocidade do inimigo;
- combat profile de criatura selvagem;
- EXP, Link EXP, Bits ou drops;
- modificadores, skills ou HUD de boss;
- composicao e rewards de dungeon.

Esses dados pertencem aos documentos e JSONs do mapa ou dungeon em que a
criatura aparece. A cena inimiga apenas adapta a forma canônica ao contrato
autoritativo de IA; ela nao redefine a especie.

## Estrutura Obrigatoria

### Identidade

- ID canonico em `snake_case`;
- nome exibido;
- sistema `Datacore`, `Patch` ou `Glitch`;
- estagio `Code`, `Nex` ou `Omega`;
- ID do sprite;
- numero e disponibilidade na Moonpedia;
- descricao oficial.

### Stats E Crescimento

Registrar valor base e crescimento por nivel para:

- ATK;
- DEF;
- HP;
- MP;
- Critical, quando houver crescimento;
- Attack Speed.

Outros stats entram somente quando a forma realmente os possuir. Os valores da
ficha devem corresponder ao JSON autoritativo do Server.

### Ataque Basico E Lifecycle

Registrar:

- FPS;
- total de frames;
- frame e janela de impacto;
- alcance;
- movimento em `START`, `IMPACT` e `RECOVERY`;
- frames de Spawn e Death;
- bloqueio de movimento durante Spawn e Death.

Attack Speed representa o intervalo iniciado depois do fim do ataque. O tempo
entre inicios e `duracao da animacao + attack_speed`.

O alcance do ataque basico informa quando a IA, e futuramente o Auto Combate,
pode iniciar a acao. Controle manual nao e rejeitado por esse valor: o acerto
depende da hitbox autoritativa, ou do projetil quando aplicavel.

### Skills

Cada skill declara:

- slot;
- ID runtime e nome exibido;
- dano base e crescimento por nivel de skill;
- formula e crescimento de cada multiplicador;
- mana base e crescimento;
- cooldown e alcance;
- FPS, frames, impacto e movimento por fase;
- projectile, efeitos e condicoes;
- Mastery de Link MAX, quando existir.

O alcance da skill orienta IA e futuro Auto Combate. Skills livres usadas por
um jogador controlando diretamente o Datamoon nao sofrem validacao previa por
distancia; hitbox, area ou projetil determinam o acerto. Uma futura skill com
alvo ou ponto escolhido deve declarar separadamente seu limite de selecao.

Nas formulas, `L` e o nivel efetivo da skill e começa em `1`. Se o runtime usa
`base + incremento * L`, a ficha deve escrever exatamente essa expressao; nao
converter silenciosamente para `L - 1`.

### Link

Registrar familia, caps de `Code/Nex/Omega` e ID da quest de Link MAX. Regras
globais, percentuais e Mastery pertencem a `LINK_SYSTEM.md`.

### Evolucoes

Registrar as formas `Code`, `Nex` e `Omega`, seus IDs runtime e requisitos de
Unlock. A linha usa a forma Omega como `line_id`. Ramificacoes recebem blocos
separados e nao compartilham um identificador arbitrario.

### Assets E Cenas

Registrar os IDs documentais convencionais de:

- cena-base;
- spritesheet;
- portrait;
- icon;
- cenas de formas evoluidas quando existirem.

Esses campos nao obrigam a existencia do asset. O Client resolve recursos por
convencao a partir do ID/sprite da forma, por exemplo `{sprite}_portrait`, e usa
o recurso somente quando ele existe. Ausencia de icon, portrait, full sprite ou
spritesheet opcional nao invalida a especie nem deve causar erro de runtime.

## Autoridade

- A ficha explica o design aprovado.
- JSON do Server executa stats, timing, formulas e evolucao.
- MySQL API espelha catalogos persistentes e valida operacoes.
- Client possui cenas, assets, animacao, localizacao e apresentacao.
- Documentos de mapa/dungeon definem apenas a aparicao daquela especie naquele
  conteudo.

Uma divergencia entre ficha e runtime deve ser resolvida explicitamente; nunca
escolher um dos valores por suposicao.

## Checklist

- IDs e nomes correspondem aos catalogos atuais?
- Stats, crescimento e formulas correspondem ao Server?
- Frames correspondem a animacao real do Client?
- Movimento por fase usa `free`, `reduced` ou `locked` corretamente?
- Mastery substitui ou soma exatamente os campos descritos?
- Evolucoes usam a forma Omega como linha?
- Assets informados realmente existem?
- A ficha permaneceu livre de spawn, IA, drops e balanceamento de mapa?
