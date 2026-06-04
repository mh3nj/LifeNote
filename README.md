# LIFE NOTE v2.0

**daily journaling, 1995 style. cyan on blue. beeps included. no internet required. ;)**

![PureBasic](https://img.shields.io/badge/PureBasic-6.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-blue)

<img width="100%" alt="banner" src="/assets/banner.png" />


---

## what is this? :|

a PureBasic console application that turns your terminal into a QBasic blue screen from 1995.

write one life note per day. pick a mood. hear beeps. see ASCII art. earn XP. read letters from your past self. grep your memories. track your streak. export your diary. burn the notes you need to let go of.

built for the kid who fell in love with `SCREEN 0`, `COLOR 11,1`, and `SOUND`. no bloat. no cloud. no login. just you, a blinking cursor, and your thoughts. :)

---

## features :D

### the basics
- deep blue background with cyan text, just like QBasic. four themes available: QBasic blue, amber, green phosphor, paper white
- one note per day. edit it any time before midnight if you change your mind
- mood picker: `:)` `:( ` `:D` `;(` `:|`; text emotes only, no unicode feelings here
- multi-line notes: type as many lines as you want, enter `.` alone on a line to finish (old SMTP style :D)
- beep sounds on save, level up, burn, unlock, and quit. real `Beep_()` calls, not fake ones
- startup melody on every launch, gorillas.bas tribute included

### writing tools
- **guided template mode**; press T at the mood screen to get three journal prompts: what made you smile, what drained you, one word for today
- **tags**; add `#work` `#family` `#dream` to any note and filter by them later
- **unsent letter mode**; write a letter to a person, read it with typewriter effect, then it's gone forever. just gone. cathartic :)
- **letter to future me**; seal a note until a date you choose. the app refuses to show it until that day arrives. when it unlocks, fanfare, special color, special message. this one is the best feature honestly

### reading and browsing
- **cozy reading mode**; press R from the main menu. reads your notes one at a time with typewriter effect, mood-colored text, wave borders, and P/N navigation. genuinely cozy
- **view history**; browse all past notes with color-coded mood indicators and tag display
- **GREP your memories**; search all notes by keyword. finds matches across text and tags. very satisfying :)
- **fill the gaps**; on startup the app checks your last 7 days for missed entries and gently asks if you want to write a late note

### stats and data
- **streak counter**; tracks how many days in a row you've written. shown on the main menu every time
- **mood graph**; last 60 days displayed as colored ASCII block characters. each mood has its own character. dots for empty days
- **ASCII calendar**; current month as a grid. colored squares for days with notes, grey for empty days, bright white for today
- **word frequency**; parses all your notes, strips common stopwords, shows your top 10 most-used words as bar charts. tells you what you actually think about
- **personal records**; longest note, shortest note, most common mood, total notes, best streak
- **achievement badges**; first note, 7-day streak, 30-day streak, 10 notes, 100 notes, crying week, happy week, all moods seen, burned a note, wrote a future letter, wrote 500+ chars, used grep, wrote after midnight. stored in a file, shown on the stats screen
- **XP system**; earn XP for writing. longer notes earn more. streak bonuses. level up from rookie diarist to wordsmith to life chronicler to memory keeper to soul scribe to legend. level-up screen with melody :D
- **annual review**; shows your whole year: total notes, mood breakdown, best streak, dominant mood, total XP. available any time from settings

### security and export
- **password lock**; set a password on startup. stored as a djb2 hash. wrong password = access denied with a sad beep
- **plain text export**; exports all notes to a readable dated .txt file. proper diary format
- **XOR encrypted export**; same export but XOR-ciphered with key `QBASIC1990`. retro and functional :)
- **auto-backup**; copies your notes file to a backup on every quit

### fun stuff
- **fortune cookie**; on exit, shows you a random line from one of your own past notes as wisdom. your own words back at you
- **cinematic screensaver**; starfield of `*` rain with your own notes scrolling across the screen. kicks in from the ASCII art menu
- **this day last year**; on startup, if you wrote a note exactly one year ago, it flashes on screen with typewriter effect and a little melody
- **ASCII art gallery**; random art on every launch. includes your two custom logos (the comet and the letter A) plus five classic QBasic drawings
- **multiple themes**; toggle between QBasic blue, amber (orange on black, hercules monitor style), green phosphor (VAX terminal style), and paper white

---

## file structure

```
LifeNote.exe              the program (Windows)
LifeNote                  the program (Linux/macOS)
LIFE_NOTES.TXT            your notes, plain text, one per entry
LIFE_NOTES_BACKUP.TXT     auto-backup created on every quit
ACHIEVEMENTS.TXT          your unlocked badges and dates
PLAYER.TXT                your XP, level, theme, password hash
DIARY_EXPORT_YYYYMMDD.TXT plain text export when you ask for it
DIARY_EXPORT_YYYYMMDD_ENC.TXT encrypted export
```

each note is stored as seven lines:

```
2026-06-04
:)
today i felt good because the code finally compiled without errors :D
#coding #win
normal
(empty - sealed date only used for future letters)
25
```

the XOR encrypted export uses key `QBASIC1990`. to decrypt it yourself: XOR every character with the repeating key. very simple, very retro

---
## screenshots

<table>
  <tr>
    <td>
      <img src="/screenshots/screenshot1.png" alt="first screenshot of lifenote app" width="100%" />
    </td>
    <td>
      <img src="/screenshots/screenshot2.png" alt="second screenshot of lifenote app" width="100%" />
    </td>
  </tr>
</table>

---

## how to use

1. run the program. console resizes to 83 columns. one of your two logos appears
2. if you set a password, enter it now
3. if you wrote a note one year ago today, it shows up as a time capsule
4. if any sealed future letters have unlocked, you get to read them now
5. ASCII art screen, then a daily quote in typewriter effect
6. if you missed any of the last 7 days, the app asks if you want to backfill them
7. main menu appears with your level, XP, and streak displayed at the top

main menu options:

```
  1 | write today's note
  2 | view past notes
  3 | grep your memories
  4 | statistics + achievements
  5 | mood graph
  6 | calendar view
  7 | word frequency
  8 | write to future me
  9 | unsent letter
  R | cozy reading mode
  A | ASCII art / screensaver
  B | burn a note
  S | settings
  Q | quit
```

---

## how to compile

PureBasic compiles to a single native binary with no runtime dependencies. one file, that's it :)

### windows

1. install [PureBasic](https://www.purebasic.com/) (version 6.0 or later recommended)
2. open `LIFENOTE.pb` in the PureBasic IDE
3. go to **Compiler > Compiler Options**, set subsystem to **Console**
4. press `F5` to run directly, or `Create Executable` from Compiler menu for compiling to `LifeNote.exe`
5. move `LifeNote.exe` wherever you want and run it. no install, no registry, no DLLs

to compile from command line:

```
pbcompiler LIFENOTE.pb /EXE LifeNote.exe /CONSOLE
```

### linux

PureBasic has a native Linux compiler. same single binary, no dependencies :)

1. install PureBasic for Linux from [purebasic.com](https://www.purebasic.com/)
2. the installer gives you `pbcompiler` (command-line) and `purebasic` (IDE)
3. open the IDE and follow the same steps as Windows, or use the command line:

```bash
pbcompiler LIFENOTE.pb --exe LifeNote --console
chmod +x LifeNote
./LifeNote
```

note: the `RunProgram("cmd.exe", ...)` call for console resizing is Windows-only. on Linux, replace that line with:

```purebasic
; Linux console resize
RunProgram("/bin/sh", "-c ""printf '\033[8;50;83t'""", "", #PB_Program_Wait)
```

or just delete it and resize your terminal manually to 83 cols before running

### macos

same as Linux. PureBasic compiles natively on macOS (Intel and Apple Silicon via Rosetta):

```bash
pbcompiler LIFENOTE.pb --exe LifeNote --console
chmod +x LifeNote
./LifeNote
```

for the console resize on macOS, replace the `cmd.exe` line with:

```purebasic
; macOS console resize (works in Terminal.app)
RunProgram("/bin/sh", "-c ""printf '\033[8;50;83t'""", "", #PB_Program_Wait)
```

### cross-platform summary

| platform | compiler flag | resize method | output |
|----------|--------------|---------------|--------|
| Windows  | `/CONSOLE`   | `mode con: cols=83 lines=50` | `LifeNote.exe` |
| Linux    | `--console`  | `printf '\033[8;50;83t'` | `LifeNote` |
| macOS    | `--console`  | `printf '\033[8;50;83t'` | `LifeNote` |

all three produce a standalone binary with zero runtime dependencies. copy it anywhere and run it. :)

---

## requirements

- PureBasic 6.0 or later (for compiling)
- a terminal that supports ANSI colors (every modern terminal does)
- 83 columns minimum window width
- Windows XP through 11, any modern Linux distro, macOS 10.13 or later
- no internet. ever. that's the point

---

## why this exists :|

Iran's internet shutdowns made me think. i don't need the cloud. i don't need a subscription. i don't need another app asking for my email address.

i need a blue screen, a blinking cursor, and a place to write down my life. exactly like i had in 1995, when i was a kid learning QBasic and nothing else mattered except getting that `SOUND` command to play a melody.

this is for that kid. and for anyone who has ever looked at a modern journaling app and thought: this is too much. i just want to write. :)

---

## license

MIT. do whatever you want with it. just keep the beeps alive. :)

---

## contributing

this is a personal time capsule. but if you want to fork it and make your own version, go for it. all i ask is that you keep the QBasic aesthetic. cyan on blue. no exceptions

---

## author

**Mohsen Jafari**.

- github: [mh3nj](https://github.com/mh3nj)
- Xing: [Mohsen Jafari's Xing Profile](https://www.xing.com/profile/Mohsen_Jafari093223/)
- logo design: [parsegan.com](https://parsegan.com)
- land surveying / portfolio: [dahgan.com](https://dahgan.com)

---

*made with `SOUND 1000, 10` and a lot of feelings*

*for 12 years old me, wherever he is right now, this is a gift for you for surviving and never giving up. :)*
