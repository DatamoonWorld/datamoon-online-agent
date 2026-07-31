# Character Creation

> This document defines the character-creation and appearance contract. Current
> implementation status and priorities live only in `FIRST_BETA_ROADMAP.md` and
> `FIRST_BETA_ROADMAP.md`.

## Goal

Replace the current single-sprite choice with a staged flow:

1. login;
2. customize and name the character;
3. choose the initial Datamoon;
4. atomically create both records;
5. join the game only after the API confirms the transaction.

The character is only a Client-side draft until the final confirmation. Closing
the Client, going back or disconnecting before choosing a Datamoon must leave no
character, inventory, Datamoon or hotbar record in the database.

## Selectable Appearance

The first version exposes:

- body: `male` or `female`;
- skin palette: one of three predefined palettes;
- hair style: one of the enabled styles;
- hair palette: one of three or four predefined palettes;
- eye style: one of the enabled styles;
- eye palette: one of three or four predefined palettes;
- outfit preset: `casual` or `urban`.

An outfit is selected as one preset during creation, not as independent pieces
in that screen. The catalog resolves and persists the preset as these individual
visual layers:

- head;
- shirt;
- pants;
- gloves;
- shoes.

The initial head layer may be empty. Initial outfit layers are cosmetic and have
no stats. The initial outfit has no bracelet visual. The bracelet layer appears
only after the player receives and equips the real gameplay `Bracelet` from the
quest. Equipment rewards and Datamoon stats remain governed by the
inventory/equipment system.

No initial appearance layer is an inventory item. Body, skin, hair, eyes, shirt,
pants, gloves, shoes and head exist only in the persisted appearance object. The
gameplay `Bracelet` and `Fishing Rod` are the only equipment items in this
initial model. The Rod remains without an acquisition source in v0.04.

Persisting the resolved parts is required even though creation selects a preset.
Future equipment can then replace one visual slot without replacing the whole
outfit. Runtime appearance resolution follows this priority for each slot:

1. visual supplied by a compatible currently equipped gameplay item, such as a
   Bracelet or Fishing Rod when that item has a world visual;
2. persisted initial outfit part;
3. safe empty/default layer.

A future equippable item that changes appearance declares its visual slot and
visual resource ID in the item catalog. It does not convert the initial outfit
part into an item. The Server resolves equipped item identity; the Client only
renders the resulting appearance. Unequipping an item restores the persisted
initial part for that slot.

## Data-Driven Catalog

Use one versioned appearance catalog shared by the creation flow. It defines:

- stable semantic IDs for bodies, styles, palettes and outfits;
- enabled state for each selectable option;
- compatible body types for each layer;
- texture or layer resource IDs consumed only by the Client;
- the piece mapping for each outfit preset;
- the enabled initial Datamoon choices;
- a catalog version/hash used during validation.

Never persist resource paths, arbitrary colors or values supplied directly by
the Client. Persist only validated IDs. Disabling an option must prevent new
selection without breaking characters that already use it; historical assets
therefore remain loadable even when they are no longer selectable.

Recommended persisted shape:

```json
{
  "version": 1,
  "body": "male",
  "skin_palette": "skin_02",
  "hair": "hair_03",
  "hair_palette": "hair_black_01",
  "eyes": "eyes_02",
  "eye_palette": "eyes_blue_01",
  "outfit_preset": "urban",
  "outfit_parts": {
    "head": "none",
    "shirt": "urban_shirt_01",
    "pants": "urban_pants_01",
    "gloves": "urban_gloves_01",
    "shoes": "urban_shoes_01"
  }
}
```

Store appearance as a bounded JSON object on `dm_characters`. The fields are not
search or ranking dimensions, so separate indexed columns would add schema cost
without a current query need. Remove the legacy single `sprite` authority after
all session, snapshot, HUD and selection paths consume `appearance`.

## Palette Shader

Do not create a complete spritesheet for every color combination. Each visual
layer uses:

- one indexed pixel-art texture per shape/style;
- transparent pixels through alpha;
- three or four exact source tone indexes;
- a shared CanvasItem shader;
- a predefined palette selected by semantic ID.

The shader maps each source tone index to a palette color. Source textures must
use nearest filtering, no mipmaps and exact index values so interpolation does
not create invalid colors. Palettes live in data/resources and are never chosen
as unrestricted RGB values by the player.

Every layer shares the same frame layout, direction, FPS and animation frame.
One character animator drives body, eyes, hair and outfit layers together. The
body type may change art, but must not change the authoritative collision shape
or movement rules.

For the initial small beta population, layered `Sprite2D` nodes with per-instance
shader parameters are acceptable. Keep materials and textures cached, update
uniforms only when appearance changes, and never rebuild layers every frame. If
measurements later show draw-call pressure, optimize remote players by appearance
signature/cache without changing the network or persistence contract.

## Authoritative Creation Flow

### Client draft

The Client owns only an in-memory draft containing name, appearance IDs and the
selected initial Datamoon. It renders the preview and validates completeness for
UX, but it is not authoritative.

### Server validation

The Server receives one final request and validates:

- authenticated account and character limit;
- normalized name and allowed characters;
- every appearance ID against the enabled catalog and compatibility rules;
- selected Datamoon against the enabled starter list;
- catalog version/hash;
- bounded payload shape and size.

### API transaction

The Server sends one internal operation to the MySQL API. In one transaction,
the API:

1. locks the account row;
2. enforces character limit and unique name;
3. creates `dm_characters` with the validated appearance;
4. creates the initial active Datamoon;
5. creates the default hotbar and other mandatory baseline rows;
6. commits all records together.

Any failure rolls back every insert. Include a unique creation `operation_id` so
a timeout/retry returns the original result instead of creating duplicates.
After success, refresh the character list and join using the returned character
identity. Do not optimistically enter the world before commit confirmation.

## Persistence And Networking

- Base appearance and resolved initial outfit parts belong to the character and
  survive login, logout and worker handoff.
- Equipped visual items are resolved on top of the persisted initial parts and
  are never copied into the base appearance object.
- Session/bootstrap responses include the validated appearance object.
- World spawn data includes compact appearance IDs and version/hash.
- Appearance is sent on spawn or change, never in movement ticks.
- Remote and local players use the same composition component.
- Character selection and HUD portraits use the same appearance data; they must
  not depend on a legacy combined sprite file.
- Unknown historical IDs use a safe visual fallback and emit one structured
  warning, without rejecting login.

## Initial Implementation Scope

Client:

- replace the combined character/Datamoon list with two explicit steps;
- add layered preview and palette selection;
- implement a reusable character appearance renderer for local, remote, preview
  and portrait contexts;
- send only one final creation request;
- localize labels, errors and confirmation states.

Server:

- replace `sprite` selection with validated appearance data;
- expose the enabled appearance and starter-Datamoon catalog;
- validate compatibility and operation identity;
- replicate appearance during selection, bootstrap, spawn and handoff.

MySQL API:

- add the final appearance shape directly to the clean baseline;
- make character plus Datamoon creation idempotent and atomic;
- return the existing result for a repeated `operation_id`;
- remove the legacy single-sprite dependency after consumers are migrated.

## Manual Acceptance

- every enabled body, palette, hair, eye and outfit combination renders with no
  gaps, bleeding or frame desynchronization;
- casual and urban resolve to the expected individual layers;
- a newly created character has no bracelet layer before equipping the quest
  Bracelet;
- equipping one visual item changes only its declared layer and unequipping it
  restores the initial outfit part;
- visual clothing grants no stats and does not satisfy combat equipment rules;
- initial appearance creates no inventory rows; only actual Bracelet/Rod items
  use the equipment and inventory systems;
- back, close and disconnect before final confirmation create no database rows;
- duplicate confirmation/retry creates exactly one character and one Datamoon;
- invalid or disabled IDs are rejected by the Server;
- local, remote, Party, reconnect and handoff views preserve the same appearance;
- character list, preview, HUD portrait and world sprite agree;
- four-character account limit and unique-name errors remain clear;
- a clean database creates the final schema without legacy conversion steps.
