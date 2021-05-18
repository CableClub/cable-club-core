# CableClub WebSocket TradeCenter Protocol

This document will lay out the protocol between the LinkCable device and the CableClub server.
Nothing has been implemented as of the writing of this document, so everything is subject to change
as the Gameboy Trade Center protocol is implemented.

## Highlevel Handshake

Below describes the series of events that shall be called the `handshake`.
Due to the LinkCable device being marked as the clock source, these events are fairly timing insensitive.

* User plugs in LinkCable
* User speaks with NPC in game
* LinkCable device assumes external clock (`ESTABLISH_CONNECTION_WITH_EXTERNAL_CLOCK`) position
* User sees `PLEASE WAIT!@` on screen
* LinkCable device establishes USB connection with User's PC
* PC establishes WebSocket connection with CableClub server
* The CableClub server will now act as a `broker` of sorts between both LinkCable devices

## Patch List Exchange

Once the handshake is complete, 418 bytes of data must be exchanged. See the [protocol docs](TradeCenterProtocol.md) for more
info.
