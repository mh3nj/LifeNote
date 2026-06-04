# LIFE NOTE; software development timeline

**project:** LIFE NOTE, a personal journaling application  
**developer:** Mohsen Jafari  
**initial release:** may 10, 2026 (v1.0)  
**current version:** v2.0, june 2026  
**language:** PureBasic  
**platform:** Windows, Linux, macOS  
**repository:** [github.com/mh3nj](https://github.com/mh3nj)

---

## overview

LIFE NOTE is a console-based daily journaling application written in PureBasic. it presents a retro terminal interface inspired by QBasic from the mid-1990s, and runs entirely offline with no external dependencies, no installation, no registry entries, and no internet connection required at any point.

the project began as a personal response to internet disruptions in Iran. when the internet is unreliable, cloud-based tools become unreliable too. the answer was to build something that lives entirely on the local machine, is portable enough to run from a USB drive, and feels personal enough to actually use every day.

v1.0 was completed in five days in may 2026. v2.0 followed in june 2026 with twenty-five additional features, a full data architecture redesign, and cross-platform support. this document covers both phases in full.

---

## phase one: v1.0 (may 6 – may 10, 2026)

### day 1; may 6, 2026

the first day was about turning an idea into something real as fast as possible.

context: an internet shutdown was in progress. mohsen remembered learning QBasic as a twelve-year-old, and how that environment; cyan text on a deep blue background, simple INPUT prompts, SOUND commands that beeped through the PC speaker; felt like a safe and creative space. the goal was to recreate that feeling as a daily journaling tool.

PureBasic was chosen because it compiles to a single native binary with zero runtime dependencies, its syntax is close to classic BASIC, and it runs on modern Windows without any framework or installer.

work completed:

- project folder created, repository initialized on GitHub
- console configured with cyan text on deep blue background
- note saving to `LIFE_NOTES.TXT` with `YYYY-MM-DD` date stamps
- date detection so the application always knows the current day
- mood picker with five text emotes: `:)` `:(` `:D` `;(` `:|`
- QBasic-style beep sounds using `Beep_(frequency, duration)`
- wait-for-keypress functionality modeled on old BASIC `INPUT` behavior
- first working build: open the app, pick a mood, write a note, save, exit

**hours this day:** approximately 6  
**result:** a working prototype

---

### day 2; may 7, 2026

day two focused on making the application feel alive rather than just functional.

work completed:

- daily quote generator with ten original quotes about writing, memory, and coding
- random ASCII art on startup: five hand-drawn pieces; a DOS stick figure, an old computer terminal, a smiley face, a QBasic logo recreation, and a love note to the language
- `CenterText(y, text$)` procedure for horizontal text positioning
- `DrawLine(y, char$)` for full-width separator lines
- scrollable history view: browse all past notes with date and mood
- statistics dashboard: mood counts and most common mood
- custom `ClsScreen()` procedure to clear the console without flickering
- auto-backup: on every quit, notes file is copied to `LIFE_NOTES_BACKUP.TXT`
- main menu with five options: write, view history, statistics, ASCII art, quit
- today detection: if a note exists for today, asks whether to edit it

**hours this day:** approximately 8  
**result:** eight complete features, the application had genuine character

---

### day 3; may 8, 2026

day three was entirely debugging and hardening.

work completed:

- resolved naming conflict: `Screen` clashed with a PureBasic library keyword, renamed throughout
- resolved structure naming collision: `Note` renamed to `NoteData`
- resolved multiple additional variable conflicts with PureBasic standard library
- tested on Windows 10 and Windows 11
- edge case handling: empty input, first run with no file, entries at the character limit
- beep system refined: save uses high tone, errors use low tone, quit uses a three-tone farewell
- note length capped at 200 characters to prevent console overflow
- first stable build with no known bugs

**hours this day:** approximately 7  
**result:** first stable build

---

### day 4; may 9, 2026

working software without documentation is unfinished. day four was documentation only.

work completed:

- `README.md` with full feature list, installation guide, usage instructions, and project background
- `BUILD.md` with step-by-step compilation instructions for building from source
- v1.0 release notes
- development timeline document

**hours this day:** approximately 6  
**result:** complete documentation package

---

### day 5; may 10, 2026

final review and publication.

work completed:

- complete code review, all features confirmed working
- tagged as v1.0 on GitHub
- all files pushed to repository
- release page created (source code only, internet restrictions affected large file uploads)
- shared with friends

**hours this day:** approximately 3  
**result:** v1.0 live :)

---

### v1.0 by the numbers

| metric | value |
|--------|-------|
| total development days | 5 |
| total hours | approximately 30 |
| lines of code | approximately 450 |
| features shipped | 8 |
| ASCII art pieces | 5 |
| daily quotes | 10 |
| beep types | 3 |
| platforms tested | Windows 10, Windows 11 |
| external dependencies | zero |
| internet required to run | no |

```
day 1 (may 6):   ████████████ 6 hrs      idea and prototype
day 2 (may 7):   ████████████████ 8 hrs  features and soul
day 3 (may 8):   ██████████████ 7 hrs    debugging and polish
day 4 (may 9):   ████████████ 6 hrs      documentation
day 5 (may 10):  ██████ 3 hrs            release
                 ──────────────────────────────────────
total:           30 hours
```

---

## phase two: v2.0 (june 2026)

after v1.0 was published and used daily, a major expansion was planned. v2.0 is not a patch; it is a full rearchitecture of the data layer combined with twenty-five new features, bringing the total to thirty-three.

---

### data architecture redesign

the original format stored three fields per entry: date, mood, text. v2.0 redesigned this to seven:

```
date
mood
text           (multi-line, internal lines joined by Chr(10))
tags
note type      (normal / future / opened)
sealed-until   (unlock date for future letters, empty otherwise)
xp earned      (experience points awarded for this entry)
```

new data files added:

| file | purpose |
|------|---------|
| `LIFE_NOTES.TXT` | all journal entries |
| `LIFE_NOTES_BACKUP.TXT` | auto-backup on every quit |
| `ACHIEVEMENTS.TXT` | unlocked badges with dates |
| `PLAYER.TXT` | XP, level, theme preference, password hash |
| `DIARY_EXPORT_YYYYMMDD.TXT` | readable plain text export |
| `DIARY_EXPORT_YYYYMMDD_ENC.TXT` | XOR-encrypted export |

---

### new features in v2.0

#### writing

**multi-line notes**; v1.0 accepted one line per entry. v2.0 implements a small interactive editor: type freely across as many lines as needed, enter a period alone to finish. borrowed from 1980s SMTP mail client convention.

**guided template mode**; pressing T at the mood screen switches to three structured prompts: what made you smile today, what drained you, one word for today. for days when starting from nothing feels hard.

**tags**; hashtag-style labels added to any note (`#work` `#family` `#dream`), stored separately, usable for filtering history.

**unsent letter mode**; write a letter to a named person. displayed once with typewriter effect. never saved anywhere. exists purely as an emotional outlet.

**letter to future me**; write a note sealed with a future unlock date. the app stores it and refuses to show it until that date. when it unlocks, a special screen appears with a melody and the original writing date.

#### reading and browsing

**cozy reading mode**; press R from the main menu. one note at a time, typewriter rendering, wave-border decoration, mood-colored text, P and N navigation. designed for comfortable re-reading.

**color-coded history**; mood indicators rendered in distinct colors: green for happy, red for sad, yellow for laughing, blue for crying, grey for neutral.

**GREP search**; full-text search across all notes and tags. results show date, mood, and text excerpt.

**fill the gaps**; on startup, checks the previous seven days for missing entries and offers to write backdated notes for any missed day.

#### statistics and visualization

**streak counter**; consecutive days with entries, calculated by walking backwards through the notes file. displayed on the main menu every time the app opens.

**mood graph**; last sixty days as two rows of colored ASCII block characters. each mood maps to a distinct Unicode symbol. empty days show as dots.

**ASCII calendar**; current month as a Monday-to-Sunday grid. days with notes colored by mood, empty days greyed, today in bright white.

**word frequency analyzer**; reads all note text, removes common stopwords, counts and sorts remaining words, displays top ten as ASCII bar charts. shows what a person actually writes about most.

**personal records**; longest note, shortest note, most common mood, total entry count.

**annual review**; total notes for the year, mood breakdown, best streak, dominant mood, total XP. available from settings at any time.

#### progression and motivation

**XP system**; writing earns experience points. longer notes earn more. streak bonuses apply. accumulates across all sessions in `PLAYER.TXT`.

**level progression**; six levels: Rookie Diarist, Wordsmith, Life Chronicler, Memory Keeper, Soul Scribe, Legend. leveling up triggers a celebration screen with melody.

**achievement system**; thirteen badges unlocking on real behavior: first note, 7-day streak, 30-day streak, 10 notes, 100 notes, seven consecutive sad days, seven consecutive happy days, all five moods used, a note deleted, a future letter written, a note over 500 characters, the search feature used, a note written after midnight. each stored with unlock date.

#### security and privacy

**password lock**; optional password stored as a djb2 hash integer. plaintext never stored. wrong password denies access.

**burn mode**; permanent note deletion after typing YES to confirm. descending-frequency beep sequence on delete.

**plain text diary export**; all normal notes in a cleanly formatted `.TXT` file readable by any text editor.

**XOR encrypted export**; same export encrypted with repeating XOR cipher, key `QBASIC1990`. a deliberate nod to 1980s hobbyist encryption.

#### atmosphere

**four visual themes**; QBasic Blue (default), Amber (orange on black, Hercules monitor), Green Phosphor (green on black, VAX terminal), Paper White (grey on black). saved in `PLAYER.TXT`.

**this day last year**; on startup, if a note exists from one year prior, it displays automatically with typewriter effect and a melody. a built-in time capsule requiring no user effort.

**fortune cookie on exit**; on quit, a random line from the user's own past notes is displayed as a closing thought.

**cinematic screensaver**; asterisk starfield with the user's own note excerpts drifting across the screen. accessible from the art menu.

**startup logo system**; two custom ASCII logos designed by the developer, stored as DataSection data inside the compiled binary (the same technique GORILLAS.BAS used for sprites in 1991). randomly alternates on each launch with gradient color. one is a comet shape, one is a large letter A.

---

### v2.0 technical challenges and solutions

| challenge | solution |
|-----------|----------|
| `DayOfWeek` conflicts with PureBasic Date library | renamed to `CalcDayOfWeek()` |
| `RepeatString` does not exist in PureBasic | wrote custom `RepeatStr(char$, count)` procedure |
| `SetConsoleSize` does not exist in PureBasic | replaced with `RunProgram("cmd.exe", "/c mode con: cols=83 lines=50", ...)` |
| console background appearing black before color applied | `ConsoleColor()` + `ClearConsole()` + `Delay(150)` before any drawing |
| ASCII logos wrapping across screen lines | measured true content width per logo, recalculated left-padding for 83-column centering, removed all trailing spaces from data lines |
| mood graph showing empty for today | date array filled in reverse order placed today at index 0 instead of index 59. loop direction corrected |
| multi-line text in a line-based flat file | lines joined with `Chr(10)` as internal separator on write, reconstructed on read |
| password storage without storing plaintext | djb2 hash of password stored as integer |
| console resize on Linux and macOS | terminal escape sequence `\033[8;50;83t` replaces the Windows `mode con` call |

---

### v2.0 by the numbers

| metric | value |
|--------|-------|
| new features in v2.0 | 25 |
| total features across both versions | 33 |
| lines of code | approximately 2,500 |
| data files | 6 |
| achievement badges | 13 |
| XP levels | 6 |
| visual themes | 4 |
| ASCII art pieces | 7 |
| platforms supported | Windows, Linux, macOS |
| external dependencies | zero |
| internet required to run | no |

---

## what this project demonstrates

this project was conceived, designed, built, debugged, documented, and shipped by one person working alone, during active internet restrictions, using a language with no mainstream community support. there were no frameworks, no package managers, and no readily available answers to most of the technical problems encountered.

v1.0 was a working, documented, released product in five days. v2.0 more than tripled the feature set while maintaining full backward compatibility with existing note files from v1.0. both versions shipped with complete documentation.

the application is not a proof of concept or a portfolio piece written for show. it is in daily personal use. it stores real memories. it has been running without data loss since may 2026.

the skills demonstrated include independent project scoping and delivery, systematic debugging under real constraints, iterative development with a stable release before expansion, data format design for long-term compatibility, user experience thinking in a constrained medium, and the ability to finish what was started.

---

## author

**Mohsen Jafari**; developer, designer, creator

- github: [github.com/mh3nj](https://github.com/mh3nj)
- linkedin: [linkedin.com/in/mh3nj](https://linkedin.com/in/mh3nj)
- logo design studio: [parsegan.com](https://parsegan.com)
- land surveying and portfolio: [dahgan.com](https://dahgan.com)

---

*this document covers the complete development history of LIFE NOTE from may 6, 2026 through june 2026.*  
*all work described was performed independently by mohsen jafari.*
