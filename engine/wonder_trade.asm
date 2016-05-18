WonderTrade::
	ld hl, DailyFlags2
	bit 3, [hl] ; ENGINE_DAILY_WONDER_TRADE
	jr nz, .already_traded

	ld hl, .Text_WonderTradeQuestion
	call PrintText
	call YesNoBox
	jr c, .canceled

	ld hl, .Text_WonderTradePrompt
	call PrintText

	ld b, 6
	callba SelectTradeOrDaycareMon
	jr c, .canceled

	ld hl, PartyMonNicknames
	ld bc, PKMN_NAME_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld de, StringBuffer1
	call CopyTradeName
	ld hl, .Text_WonderTradeConfirm
	call PrintText
	call YesNoBox
	jr c, .canceled

	ld hl, .Text_WonderTradeSetup
	call PrintText

	call DoWonderTrade

	ld hl, .Text_WonderTradeReady
	call PrintText

	call DisableSpriteUpdates
	predef TradeAnimation
	call ReturnToMapWithSpeechTextbox

	ld hl, DailyFlags2
	set 3, [hl] ; ENGINE_DAILY_WONDER_TRADE

	ld hl, .Text_WonderTradeComplete
	call PrintText

	call RestartMapMusic
.canceled
	ret

.already_traded
	ld hl, .Text_WonderTradeAlreadyDone
	call PrintText
	ret

.Text_WonderTradeQuestion:
	text_jump WonderTradeQuestionText
	db "@"

.Text_WonderTradePrompt:
	text_jump WonderTradePromptText
	db "@"

.Text_WonderTradeConfirm:
	text_jump WonderTradeConfirmText
	db "@"

.Text_WonderTradeSetup:
	text_jump WonderTradeSetupText
	db "@"

.Text_WonderTradeReady:
	text_jump WonderTradeReadyText
	db "@"

.Text_WonderTradeComplete:
	text_jump WonderTradeCompleteText
	start_asm
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	ld hl, .done
	ret
.done
	text_jump WonderTradeDoneFanfare
	db "@"

.Text_WonderTradeAlreadyDone:
	text_jump WonderTradeAlreadyDoneText
	db "@"

DoWonderTrade:
	ld a, [CurPartySpecies]
	ld [wPlayerTrademonSpecies], a

.random_trademon
	ld a, NUM_POKEMON
	call RandomRange
	inc a
	ld [wOTTrademonSpecies], a
	call CheckValidLevel
	and a
	jr nz, .random_trademon

	ld a, [wPlayerTrademonSpecies]
	ld de, wPlayerTrademonSpeciesName
	call GetTradeMonName
	call CopyTradeName

	ld a, [wOTTrademonSpecies]
	ld de, wOTTrademonSpeciesName
	call GetTradeMonName
	call CopyTradeName

	ld hl, PartyMonOT
	ld bc, NAME_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld de, wPlayerTrademonOTName
	call CopyTradeName

	ld hl, PlayerName
	ld de, wPlayerTrademonSenderName
	call CopyTradeName

	ld hl, PartyMon1ID
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld de, wPlayerTrademonID
	call Trade_CopyTwoBytes

	ld hl, PartyMon1DVs
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld de, wPlayerTrademonDVs
	call Trade_CopyTwoBytes

	ld hl, PartyMon1Species
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld b, h
	ld c, l
	callba GetCaughtGender
	ld a, c
	ld [wPlayerTrademonCaughtData], a

	; BUG: Caught data doesn't seem to be saved.
	ld a, 2
	ld [wOTTrademonCaughtData], a

	ld hl, PartyMon1Level
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld a, [hl]
	ld [CurPartyLevel], a
	ld a, [wOTTrademonSpecies]
	ld [CurPartySpecies], a
	xor a
	ld [MonType], a
	ld [wPokemonWithdrawDepositParameter], a
	callab RemoveMonFromPartyOrBox
	predef TryAddMonToParty

	ld b, RESET_FLAG
	callba SetGiftPartyMonCaughtData

	ld a, [wOTTrademonSpecies]
	ld de, wOTTrademonNickname
	call GetTradeMonName
	call CopyTradeName

	ld hl, PartyMonNicknames
	ld bc, PKMN_NAME_LENGTH
	call Trade_GetAttributeOfLastPartymon
	ld hl, wOTTrademonNickname
	call CopyTradeName

	; a = random byte
	; OT ID = (a ^ %10101010) << 8 | a
	call Random
	ld [Buffer1], a
	ld b, %10101010
	xor b
	ld [Buffer1 + 1], a
	ld hl, Buffer1
	ld de, wOTTrademonID
	call Trade_CopyTwoBytes

	ld hl, PartyMon1ID
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfLastPartymon
	ld hl, wOTTrademonID
	call Trade_CopyTwoBytes

	ld a, [wOTTrademonID]
	call GetWonderTradeOTName
	push hl
	ld de, wOTTrademonOTName
	call CopyTradeName
	pop hl
	ld de, wOTTrademonSenderName
	call CopyTradeName

	ld hl, PartyMonOT
	ld bc, NAME_LENGTH
	call Trade_GetAttributeOfLastPartymon
	ld hl, wOTTrademonOTName
	call CopyTradeName

	; Random DVs
	call Random
	ld [Buffer1], a
	call Random
	ld [Buffer1 + 1], a
	ld hl, Buffer1
	ld de, wOTTrademonDVs
	call Trade_CopyTwoBytes

	ld hl, PartyMon1DVs
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfLastPartymon
	ld hl, wOTTrademonDVs
	call Trade_CopyTwoBytes

	ld hl, PartyMon1Item
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfLastPartymon
	call GetWonderTradeHeldItem
	ld [de], a

	push af
	push bc
	push de
	push hl
	ld a, [CurPartyMon]
	push af
	ld a, [PartyCount]
	dec a
	ld [CurPartyMon], a
	callba ComputeNPCTrademonStats
	pop af
	ld [CurPartyMon], a
	pop hl
	pop de
	pop bc
	pop af
	ret


GetWonderTradeOTName:
; hl = .WonderTradeOTNameTable + a * PLAYER_NAME_LENGTH
	ld hl, .WonderTradeOTNameTable
	ld b, 0
	ld c, PLAYER_NAME_LENGTH
	call AddNTimes
	ret

; TODO: Associate each OT name with a correct gender (via wOTTrademonCaughtData?)
.WonderTradeOTNameTable:
	db "Nemo@@@@" ; 00
	db "Rangi@@@" ; 01
	db "Satoshi@" ; 02
	db "Tajiri@@" ; 03
	db "Satoru@@" ; 04
	db "Iwata@@@" ; 05
	db "Junichi@" ; 06
	db "Masuda@@" ; 07
	db "Imakuni@" ; 08
	db "Bryan@@@" ; 09
	db "Crystal@" ; 0A
	db "Mateo@@@" ; 0B
	db "Drayano@" ; 0C
	db "James@@@" ; 0D
	db "Marckus@" ; 0E
	db "Brock@@@" ; 0F
	db "Misty@@@" ; 10
	db "Surge@@@" ; 11
	db "Erika@@@" ; 12
	db "Janine@@" ; 13
	db "Sabrina@" ; 14
	db "Blaine@@" ; 15
	db "Blue@@@@" ; 16
	db "Lorelei@" ; 17
	db "Bruno@@@" ; 18
	db "Agatha@@" ; 19
	db "Lance@@@" ; 1A
	db "Falkner@" ; 1B
	db "Bugsy@@@" ; 1C
	db "Whitney@" ; 1D
	db "Morty@@@" ; 1E
	db "Chuck@@@" ; 1F
	db "Jasmine@" ; 20
	db "Pryce@@@" ; 21
	db "Clair@@@" ; 22
	db "Will@@@@" ; 23
	db "Koga@@@@" ; 24
	db "Karen@@@" ; 25
	db "Red@@@@@" ; 26
	db "Green@@@" ; 27
	db "Yellow@@" ; 28
	db "Gold@@@@" ; 29
	db "Silver@@" ; 2A
	db "Ruby@@@@" ; 2B
	db "Safire@@" ; 2C
	db "Emerald@" ; 2D
	db "Diamond@" ; 2E
	db "Pearl@@@" ; 2F
	db "Black@@@" ; 30
	db "White@@@" ; 31
	db "Ethan@@@" ; 32
	db "Lyra@@@@" ; 33
	db "Brendan@" ; 34
	db "May@@@@@" ; 35
	db "Wally@@@" ; 36
	db "Lucas@@@" ; 37
	db "Dawn@@@@" ; 38
	db "Barry@@@" ; 39
	db "Leaf@@@@" ; 3A
	db "Hilbert@" ; 3B
	db "Hilda@@@" ; 3C
	db "Cheren@@" ; 3D
	db "Bianca@@" ; 3E
	db "Nate@@@@" ; 3F
	db "Rosa@@@@" ; 40
	db "Hugh@@@@" ; 41
	db "Calem@@@" ; 42
	db "Serena@@" ; 43
	db "Shauna@@" ; 44
	db "Trevor@@" ; 45
	db "Tierno@@" ; 46
	db "Hibiki@@" ; 47
	db "Kotone@@" ; 48
	db "Yuuki@@@" ; 49
	db "Haruka@@" ; 4A
	db "Mitsuru@" ; 4B
	db "Kouki@@@" ; 4C
	db "Hikari@@" ; 4D
	db "Jun@@@@@" ; 4E
	db "Touya@@@" ; 4F
	db "Touko@@@" ; 50
	db "Bel@@@@@" ; 51
	db "Kyouhei@" ; 52
	db "Mei@@@@@" ; 53
	db "Oak@@@@@" ; 54
	db "Elm@@@@@" ; 55
	db "Birch@@@" ; 56
	db "Rowan@@@" ; 57
	db "Juniper@" ; 58
	db "Ivy@@@@@" ; 59
	db "Hala@@@@" ; 5A
	db "Kukui@@@" ; 5B
	db "Bill@@@@" ; 5C
	db "Lanette@" ; 5D
	db "Celio@@@" ; 5E
	db "Bebe@@@@" ; 5F
	db "Amanita@" ; 60
	db "Cassius@" ; 61
	db "Joey@@@@" ; 62
	db "AJ@@@@@@" ; 63
	db "Camila@@" ; 64
	db "Alice@@@" ; 65
	db "Leo@@@@@" ; 66
	db "Aoooo@@@" ; 67
	db "Jimmy@@@" ; 68
	db "Cly@@@@@" ; 69
	db "Revo@@@@" ; 6A
	db "Everyle@" ; 6B
	db "Zetsu@@@" ; 6C
	db "Alexis@@" ; 6D
	db "Hanson@@" ; 6E
	db "Sawyer@@" ; 6F
	db "Masuda@@" ; 70
	db "Nickel@@" ; 71
	db "Olson@@@" ; 72
	db "Wright@@" ; 73
	db "Bickett@" ; 74
	db "Saito@@@" ; 75
	db "Diaz@@@@" ; 76
	db "Hunter@@" ; 77
	db "Hill@@@@" ; 78
	db "Javier@@" ; 79
	db "Kaufman@" ; 7A
	db "O'Brien@" ; 7B
	db "Frost@@@" ; 7C
	db "Morse@@@" ; 7D
	db "Yufune@@" ; 7E
	db "Rajan@@@" ; 7F
	db "Stock@@@" ; 80
	db "Thurman@" ; 81
	db "Wagner@@" ; 82
	db "Yates@@@" ; 83
	db "Andrews@" ; 84
	db "Bahn@@@@" ; 85
	db "Mori@@@@" ; 86
	db "Buckman@" ; 87
	db "Cobb@@@@" ; 88
	db "Hughes@@" ; 89
	db "Arita@@@" ; 8A
	db "Easton@@" ; 8B
	db "Freeman@" ; 8C
	db "Giese@@@" ; 8D
	db "Hatcher@" ; 8E
	db "Jackson@" ; 8F
	db "Kahn@@@@" ; 90
	db "Leong@@@" ; 91
	db "Marino@@" ; 92
	db "Newman@@" ; 93
	db "Nguyen@@" ; 94
	db "Ogden@@@" ; 95
	db "Park@@@@" ; 96
	db "Raine@@@" ; 97
	db "Sells@@@" ; 98
	db "Turner@@" ; 99
	db "Walker@@" ; 9A
	db "Meyer@@@" ; 9B
	db "Johnson@" ; 9C
	db "Adams@@@" ; 9D
	db "Smith@@@" ; 9E
	db "Tajiri@@" ; 9F
	db "Baker@@@" ; A0
	db "Collins@" ; A1
	db "Smart@@@" ; A2
	db "Dykstra@" ; A3
	db "Eaton@@@" ; A4
	db "Wong@@@@" ; A5
	db "Nemo@@@@" ; A6
	db "Nemo@@@@" ; A7
	db "Nemo@@@@" ; A8
	db "Nemo@@@@" ; A9
	db "Nemo@@@@" ; AA
	db "Nemo@@@@" ; AB
	db "Nemo@@@@" ; AC
	db "Nemo@@@@" ; AD
	db "Nemo@@@@" ; AE
	db "Nemo@@@@" ; AF
	db "Nemo@@@@" ; B0
	db "Nemo@@@@" ; B1
	db "Nemo@@@@" ; B2
	db "Nemo@@@@" ; B3
	db "Nemo@@@@" ; B4
	db "Nemo@@@@" ; B5
	db "Nemo@@@@" ; B6
	db "Nemo@@@@" ; B7
	db "Nemo@@@@" ; B8
	db "Nemo@@@@" ; B9
	db "Nemo@@@@" ; BA
	db "Nemo@@@@" ; BB
	db "Nemo@@@@" ; BC
	db "Nemo@@@@" ; BD
	db "Nemo@@@@" ; BE
	db "Nemo@@@@" ; BF
	db "Nemo@@@@" ; C0
	db "Nemo@@@@" ; C1
	db "Nemo@@@@" ; C2
	db "Nemo@@@@" ; C3
	db "Nemo@@@@" ; C4
	db "Nemo@@@@" ; C5
	db "Nemo@@@@" ; C6
	db "Nemo@@@@" ; C7
	db "Nemo@@@@" ; C8
	db "Nemo@@@@" ; C9
	db "Nemo@@@@" ; CA
	db "Nemo@@@@" ; CB
	db "Nemo@@@@" ; CC
	db "Nemo@@@@" ; CD
	db "Nemo@@@@" ; CE
	db "Nemo@@@@" ; CF
	db "Nemo@@@@" ; D0
	db "Nemo@@@@" ; D1
	db "Nemo@@@@" ; D2
	db "Nemo@@@@" ; D3
	db "Nemo@@@@" ; D4
	db "Nemo@@@@" ; D5
	db "Nemo@@@@" ; D6
	db "Nemo@@@@" ; D7
	db "Nemo@@@@" ; D8
	db "Nemo@@@@" ; D9
	db "Nemo@@@@" ; DA
	db "Nemo@@@@" ; DB
	db "Nemo@@@@" ; DC
	db "Nemo@@@@" ; DD
	db "Nemo@@@@" ; DE
	db "Nemo@@@@" ; DF
	db "Nemo@@@@" ; E0
	db "Nemo@@@@" ; E1
	db "Nemo@@@@" ; E2
	db "Nemo@@@@" ; E3
	db "Nemo@@@@" ; E4
	db "Nemo@@@@" ; E5
	db "Nemo@@@@" ; E6
	db "Nemo@@@@" ; E7
	db "Nemo@@@@" ; E8
	db "Nemo@@@@" ; E9
	db "Nemo@@@@" ; EA
	db "Nemo@@@@" ; EB
	db "Nemo@@@@" ; EC
	db "Nemo@@@@" ; ED
	db "Nemo@@@@" ; EE
	db "Nemo@@@@" ; EF
	db "Nemo@@@@" ; F0
	db "Nemo@@@@" ; F1
	db "Nemo@@@@" ; F2
	db "Nemo@@@@" ; F3
	db "Nemo@@@@" ; F4
	db "Nemo@@@@" ; F5
	db "Nemo@@@@" ; F6
	db "Nemo@@@@" ; F7
	db "Nemo@@@@" ; F8
	db "Nemo@@@@" ; F9
	db "Nemo@@@@" ; FA
	db "Nemo@@@@" ; FB
	db "Nemo@@@@" ; FC
	db "Nemo@@@@" ; FD
	db "Nemo@@@@" ; FE
	db "Nemo@@@@" ; FF


GetWonderTradeHeldItem:
; Pick a random held item based on the bits of a random number.
; If bit 1 is set (50% chance), no held item.
; Otherwise, if bit 2 is set (25% chance), then Berry.
; And so on, with better items being more rare.
	call Random
	ld b, a
; TODO: factor out the repetition here with rept...endr and sla
	and a, %00000001
	jr z, .isbit2on
	ld a, 0
	jp .done
.isbit2on
	ld a, b
	and a, %00000010
	jr z, .isbit3on
	ld a, 1
	jp .done
.isbit3on
	ld a, b
	and a, %00000100
	jr z, .isbit4on
	ld a, 2
	jp .done
.isbit4on
	ld a, b
	and a, %00001000
	jr z, .isbit5on
	ld a, 3
	jp .done
.isbit5on
	ld a, b
	and a, %00010000
	jr z, .isbit6on
	ld a, 4
	jp .done
.isbit6on
	ld a, b
	and a, %00100000
	jr z, .isbit7on
	ld a, 5
	jp .done
.isbit7on
	ld a, b
	and a, %01000000
	jr z, .isbit8on
	ld a, 6
	jp .done
.isbit8on
	ld a, b
	and a, %10000000
	jr z, .allbitsoff
	ld a, 7
	jp .done
.allbitsoff
	ld a, 8
.done
	ld hl, .HeldItemsTable
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]
	ret

.HeldItemsTable:
	db NO_ITEM
	db BERRY
	db GOLD_BERRY
	db MYSTERYBERRY
	db QUICK_CLAW
	db SCOPE_LENS
	db KINGS_ROCK
	db LEFTOVERS
	db LUCKY_EGG

CheckValidLevel:
; Don't receive Pokémon outside a valid level range.
; Legendaries and other banned Pokémon have a "valid" range of 255 to 255.
	ld hl, PartyMon1Level
	ld bc, PARTYMON_STRUCT_LENGTH
	call Trade_GetAttributeOfCurrentPartymon
	ld a, [hl]
	ld d, a

	ld a, [wOTTrademonSpecies]
	ld hl, .ValidPokemonLevels
	ld b, 0
	ld c, a
	add hl, bc
	add hl, bc

	ld a, [hli]
	dec a
	cp d
	ret nc

	ld a, [hl]
	cp d
	ret c

	xor a
	ret

.ValidPokemonLevels
	;  min, max
	db 255, 255 ; ?????
	db   1,  15 ; Bulbasaur
	db  16,  31 ; Ivysaur
	db  32, 100 ; Venusaur
	db   1,  15 ; Charmander
	db  16,  35 ; Charmeleon
	db  36, 100 ; Charizard
	db   1,  15 ; Squirtle
	db  16,  35 ; Wartortle
	db  36, 100 ; Blastoise
	db   1,   6 ; Caterpie
	db   7,   9 ; Metapod
	db  10, 100 ; Butterfree
	db   1,   6 ; Weedle
	db   7,   9 ; Kakuna
	db  10, 100 ; Beedrill
	db   1,  17 ; Pidgey
	db  18,  35 ; Pidgeotto
	db  36, 100 ; Pidgeot
	db   1,  19 ; Rattata
	db  20, 100 ; Raticate
	db   1,  19 ; Spearow
	db  20, 100 ; Fearow
	db   1,  21 ; Ekans
	db  22, 100 ; Arbok
	db   1,  19 ; Pikachu
	db  20, 100 ; Raichu
	db   1,  21 ; Sandshrew
	db  22, 100 ; Sandslash
	db   1,  15 ; Nidoran♀
	db  16,  35 ; Nidorina
	db  36, 100 ; Nidoqueen
	db   1,  15 ; Nidoran♂
	db  16,  35 ; Nidorino
	db  36, 100 ; Nidoking
	db   5,  19 ; Clefairy
	db  20, 100 ; Clefable
	db   1,  19 ; Vulpix
	db  20, 100 ; Ninetales
	db   5,  19 ; Jigglypuff
	db  20, 100 ; Wigglytuff
	db   1,  21 ; Zubat
	db  22, 100 ; Golbat
	db   1,  20 ; Oddish
	db  21,  31 ; Gloom
	db  32, 100 ; Vileplume
	db   1,  23 ; Paras
	db  24, 100 ; Parasect
	db   1,  30 ; Venonat
	db  31, 100 ; Venomoth
	db   1,  25 ; Diglett
	db  26, 100 ; Dugtrio
	db   1,  27 ; Meowth
	db  28, 100 ; Persian
	db   1,  32 ; Psyduck
	db  33, 100 ; Golduck
	db   1,  27 ; Mankey
	db  28, 100 ; Primeape
	db   1,  19 ; Growlithe
	db  20, 100 ; Arcanine
	db   1,  24 ; Poliwag
	db  25,  35 ; Poliwhirl
	db  36, 100 ; Poliwrath
	db   1,  15 ; Abra
	db  16,  35 ; Kadabra
	db  36, 100 ; Alakazam
	db   1,  27 ; Machop
	db  28,  45 ; Machoke
	db  46, 100 ; Machamp
	db   1,  20 ; Bellsprout
	db  21,  31 ; Weepinbell
	db  32, 100 ; Victreebel
	db   1,  29 ; Tentacool
	db  30, 100 ; Tentacruel
	db   1,  24 ; Geodude
	db  25,  44 ; Graveler
	db  45, 100 ; Golem
	db   1,  39 ; Ponyta
	db  40, 100 ; Rapidash
	db   1,  36 ; Slowpoke
	db  37, 100 ; Slowbro
	db   1,  29 ; Magnemite
	db  30, 100 ; Magneton
	db   1, 100 ; Farfetch'd
	db   1,  30 ; Doduo
	db  31, 100 ; Dodrio
	db   1,  33 ; Seel
	db  34, 100 ; Dewgong
	db   1,  37 ; Grimer
	db  38, 100 ; Muk
	db   1,  33 ; Shellder
	db  34, 100 ; Cloyster
	db   1,  24 ; Gastly
	db  25,  44 ; Haunter
	db  45, 100 ; Gengar
	db   1, 100 ; Onix
	db   1,  25 ; Drowzee
	db  26, 100 ; Hypno
	db   1,  27 ; Krabby
	db  28, 100 ; Kingler
	db   1,  29 ; Voltorb
	db  30, 100 ; Electrode
	db   1,  29 ; Exeggcute
	db  30, 100 ; Exeggutor
	db   1,  27 ; Cubone
	db  28, 100 ; Marowak
	db  20, 100 ; Hitmonlee
	db  20, 100 ; Hitmonchan
	db   1, 100 ; Lickitung
	db   1,  34 ; Koffing
	db  35, 100 ; Weezing
	db   1,  41 ; Rhyhorn
	db  42,  54 ; Rhydon
	db   1, 100 ; Chansey
	db   1,  35 ; Tangela
	db   1, 100 ; Kangaskhan
	db   1,  31 ; Horsea
	db  32,  54 ; Seadra
	db   1,  32 ; Goldeen
	db  33, 100 ; Seaking
	db   1,  32 ; Staryu
	db  33, 100 ; Starmie
	db   1, 100 ; Mr.Mime
	db  10, 100 ; Scyther
	db  20, 100 ; Jynx
	db  20,  36 ; Electabuzz
	db  20,  36 ; Magmar
	db  10, 100 ; Pinsir
	db   1, 100 ; Tauros
	db   1,  19 ; Magikarp
	db  20, 100 ; Gyarados
	db  20, 100 ; Lapras
	db   1, 100 ; Ditto
	db   1,  19 ; Eevee
	db  20, 100 ; Vaporeon
	db  20, 100 ; Jolteon
	db  20, 100 ; Flareon
	db   1,  20 ; Porygon
	db  15,  39 ; Omanyte
	db  40, 100 ; Omastar
	db  15,  39 ; Kabuto
	db  40, 100 ; Kabutops
	db  15, 100 ; Aerodactyl
	db  20, 100 ; Snorlax
	db 255, 255 ; Articuno
	db 255, 255 ; Zapdos
	db 255, 255 ; Moltres
	db  20,  29 ; Dratini
	db  30,  54 ; Dragonair
	db  55, 100 ; Dragonite
	db 255, 255 ; Mewtwo
	db 255, 255 ; Mew
	db   1,  15 ; Chikorita
	db  16,  31 ; Bayleef
	db  32, 100 ; Meganium
	db   1,  13 ; Cyndaquil
	db  14,  35 ; Quilava
	db  36, 100 ; Typhlosion
	db   1,  17 ; Totodile
	db  18,  29 ; Croconaw
	db  30, 100 ; Feraligatr
	db   1,  14 ; Sentret
	db  15, 100 ; Furret
	db   1,  19 ; Hoothoot
	db  20, 100 ; Noctowl
	db   1,  17 ; Ledyba
	db  18, 100 ; Ledian
	db   1,  21 ; Spinarak
	db  22, 100 ; Ariados
	db  32, 100 ; Crobat
	db   1,  26 ; Chinchou
	db  27, 100 ; Lanturn
	db   1,  19 ; Pichu
	db   1,  19 ; Cleffa
	db   1,  19 ; Igglybuff
	db   1,  19 ; Togepi
	db  20, 100 ; Togetic
	db   1,  24 ; Natu
	db  25, 100 ; Xatu
	db   1,  14 ; Mareep
	db  15,  29 ; Flaaffy
	db  30, 100 ; Ampharos
	db  32, 100 ; Bellossom
	db   1,  17 ; Marill
	db  18, 100 ; Azumarill
	db   1, 100 ; Sudowoodo
	db  36, 100 ; Politoed
	db   1,  17 ; Hoppip
	db  18,  26 ; Skiploom
	db  27, 100 ; Jumpluff
	db   1, 100 ; Aipom
	db   1,  19 ; Sunkern
	db  20, 100 ; Sunflora
	db   1, 100 ; Yanma
	db   1,  19 ; Wooper
	db  20, 100 ; Quagsire
	db  20, 100 ; Espeon
	db  20, 100 ; Umbreon
	db   1, 100 ; Murkrow
	db  37, 100 ; Slowking
	db   1, 100 ; Misdreavus
	db   1, 100 ; Unown
	db   1, 100 ; Wobbuffet
	db   1, 100 ; Girafarig
	db   1,  30 ; Pineco
	db  31, 100 ; Forretress
	db   1, 100 ; Dunsparce
	db   1, 100 ; Gligar
	db  20, 100 ; Steelix
	db   1,  22 ; Snubbull
	db  23, 100 ; Granbull
	db   1, 100 ; Qwilfish
	db  20, 100 ; Scizor
	db   1, 100 ; Shuckle
	db   1, 100 ; Heracross
	db   1, 100 ; Sneasel
	db   1,  29 ; Teddiursa
	db  30, 100 ; Ursaring
	db   1,  37 ; Slugma
	db  38, 100 ; Magcargo
	db   1,  32 ; Swinub
	db  33, 100 ; Piloswine
	db   1, 100 ; Corsola
	db   1,  24 ; Remoraid
	db  25, 100 ; Octillery
	db   1, 100 ; Delibird
	db   1, 100 ; Mantine
	db   1, 100 ; Skarmory
	db   1,  23 ; Houndour
	db  24, 100 ; Houndoom
	db  55, 100 ; Kingdra
	db   1,  24 ; Phanpy
	db  25, 100 ; Donphan
	db  20, 100 ; Porygon2
	db   1, 100 ; Stantler
	db   1, 100 ; Smeargle
	db   1,  19 ; Tyrogue
	db  20, 100 ; Hitmontop
	db   1,  19 ; Smoochum
	db   1,  19 ; Elekid
	db   1,  19 ; Magby
	db   1,  19 ; Miltank
	db  20, 100 ; Blissey
	db 255, 255 ; Raikou
	db 255, 255 ; Entei
	db 255, 255 ; Suicune
	db   1,  29 ; Larvitar
	db  30,  54 ; Pupitar
	db  55, 100 ; Tyranitar
	db 255, 255 ; Lugia
	db 255, 255 ; Ho-Oh
	db 255, 255 ; Celebi
	db 255, 255 ; ?????
	db 255, 255 ; ?????
	db 255, 255 ; Egg
	db 255, 255 ; ?????
