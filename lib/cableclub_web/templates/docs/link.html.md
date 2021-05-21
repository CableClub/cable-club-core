# Pokemon Gen 1 Link Protocol

This document describes the trade protocol as I currently understand.
It may not be completley corerect. if you spot a discrepency, feel free to
PR a change. Anything technical will likely be expressed in C syntax,
but ocassionally Gameboy assembly may be required to explain concepts.
When Gameboy assembly is required, I will try to reference relevant source
in the [disassembled source code](https://github.com/pret/pokered).

## States

The trade protocol is a simple-ish state machine that can be expressed
as follows:

In Assembly:

```rgbds
; serial_constans.asm
LINK_STATE_NONE          EQU $00 ; not using link
LINK_STATE_IN_CABLE_CLUB EQU $01 ; in a cable club room (Colosseum or Trade Centre)
LINK_STATE_START_TRADE   EQU $02 ; pre-trade selection screen initialisation
LINK_STATE_START_BATTLE  EQU $03 ; pre-battle initialisation
LINK_STATE_BATTLING      EQU $04 ; in a link battle
LINK_STATE_RESET         EQU $05 ; reset game (unused)
LINK_STATE_TRADING       EQU $32 ; in a link trade
```

Or in C:

```c
typedef enum {
  LINK_STATE_NONE          = 0x00, /* not using link */
  LINK_STATE_IN_CABLE_CLUB = 0x01, /* in a cable club room (Colosseum or Trade Centre) */
  LINK_STATE_START_TRADE   = 0x02, /* pre-trade selection screen initialisation */
  LINK_STATE_START_BATTLE  = 0x03, /* pre-battle initialisation */
  LINK_STATE_BATTLING      = 0x04, /* in a link battle */
  LINK_STATE_RESET         = 0x05, /* reset game (unused) */
  LINK_STATE_TRADING       = 0x32  /* in a link trade */
} link_state_t; 
```

## Constant Values

The following values are important constant values to keep in mind:

```rgbds
; serial_constants.asm
ESTABLISH_CONNECTION_WITH_INTERNAL_CLOCK EQU $01
ESTABLISH_CONNECTION_WITH_EXTERNAL_CLOCK EQU $02

USING_EXTERNAL_CLOCK       EQU $01
USING_INTERNAL_CLOCK       EQU $02
CONNECTION_NOT_ESTABLISHED EQU $ff

; signals the start of an array of bytes transferred over the link cable
SERIAL_PREAMBLE_BYTE EQU $FD

; this byte is used when there is no data to send
SERIAL_NO_DATA_BYTE EQU $FE

; signals the end of one part of a patch list (there are two parts) for player/enemy party data
SERIAL_PATCH_LIST_PART_TERMINATOR EQU $FF
```

```c
#define ESTABLISH_CONNECTION_WITH_INTERNAL_CLOCK 0x01
#define ESTABLISH_CONNECTION_WITH_EXTERNAL_CLOCK 0x02
#define USING_EXTERNAL_CLOCK                     0x01
#define USING_INTERNAL_CLOCK                     0x02
#define CONNECTION_NOT_ESTABLISHED               0xff
#define SERIAL_PREAMBLE_BYTE                     0xFD /* signals the start of an array of bytes transferred over the link cable */
#define SERIAL_NO_DATA_BYTE                      0xFE /* this byte is used when there is no data to send */
#define SERIAL_PATCH_LIST_PART_TERMINATOR        0xFF /* signals the end of one part of a patch list (there are two parts) for player/enemy party data */
```
