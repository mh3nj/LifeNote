# LifeNote – QBasic Blue Screen Journal

**Development Timeline**

**Project Start:** May 6, 2026  
**Completion Date:** May 10, 2026  
**Version:** 1.0  
**Motto:** *"Cyan on blue. Beeps included. No internet required. ;D"*

---

## Development Journey

### Day 1 – May 6, 2026 (The Idea is Born)

#### Morning Session (2 hours)
- Remembered QBasic from childhood :')
- Internet shutdown in Iran made me want something offline
- Idea: daily life note with QBasic blue screen aesthetic
- Chose PureBasic (closest thing to QBasic that runs on modern Windows)
- Repository created on GitHub (no uploads, just raw code editing)

#### Afternoon Session (3 hours)
- First prototype: console with cyan text on blue background
- Basic note saving to `LIFE_NOTES.TXT`
- Date detection (YYYY-MM-DD format)
- Mood system with text emotes: `:)` `:(` `:D` `;(` `:|`

#### Evening Session (1 hour)
- QBasic-style beeps added (`Beep_` function)
- Wait key functionality (like `INPUT` in old BASIC)
- First working version – could write and save one note per day

**Day 1 Total:** ~6 hours | **Features completed:** 4 (blue screen, notes, dates, moods)

---

### Day 2 – May 7, 2026 (Adding Soul)

#### Morning Session (3 hours)
- Daily quote generator (10 quotes about coding, nostalgia, resilience)
- Random ASCII art on startup (DOS Man, old computer, smiley, QBasic logo)
- CenterText procedure (like `LOCATE` but fancy ;D)
- DrawLine procedure for menu separators

#### Afternoon Session (3 hours)
- View history feature (scroll through all past notes)
- Statistics dashboard (counts each mood, finds most common mood)
- ClearScreen procedure (PureBasic's `Cls` was causing errors)
- Fixed library conflict with `Screen` keyword

#### Evening Session (2 hours)
- Auto-backup on quit (copies `LIFE_NOTES.TXT` to `LIFE_NOTES_BACKUP.TXT`)
- Main menu system (write, view, stats, art, quit)
- Today note detection (asks if you want to edit existing note)

**Day 2 Total:** ~8 hours | **Features completed:** 8 (quotes, ASCII art, history, stats, backup, menu)

---

### Day 3 – May 8, 2026 (Polish & Testing)

#### Morning Session (3 hours)
- Bug hunting: fixed `Cls` vs `ClsScreen` naming conflict
- Fixed structure naming (`Note` → `NoteData`)
- Fixed variable naming conflicts with PureBasic libraries
- Tested on Windows 10 and 11

#### Afternoon Session (2 hours)
- Edge case handling (empty notes, no notes yet, first run)
- Beep refinement (save = high beep, error = low beep, quit = triple beep)
- Note length limit (200 chars, prevents screen overflow)

#### Evening Session (2 hours)
- Asked ChatGPT for help with final fixes ;D
- Received the full working code (finally no errors!)
- Ran first successful test – tears of joy were shed <3

**Day 3 Total:** ~7 hours | **Status:** First stable build ready

---

### Day 4 – May 9, 2026 (Documentation & Sharing)

#### Morning Session (3 hours)
- Wrote professional README.md
- Added classic emojis everywhere (`:)`, `;D`, `<3`, `:3`)
- Created GitHub description (350 chars exactly)

#### Afternoon Session (2 hours)
- Wrote v1.0 release notes
- Added compilation instructions (since no .exe upload possible)
- Created `BUILD.md` for users

#### Evening Session (1 hour)
- Created this timeline document <3
- Final review of all files
- Ready for GitHub push

**Day 4 Total:** ~6 hours | **Documentation complete**

---

### Day 5 – May 10, 2026 (Release Day)

#### Morning Session (2 hours)
- Final code review – all features working
- No bugs found (amazing, right? ;D)
- Tagged as v1.0 on GitHub

#### Afternoon Session (1 hour)
- Pushed all files to repository
- Made release page (source code only – internet restrictions)
- Shared with friends who also miss QBasic

**Day 5 Total:** ~3 hours | **Status:** LIVE <3

---

## Feature Count Summary

| Category | Features |
|----------|----------|
| Core UI | Blue screen, cyan text, 80x25 layout |
| Daily Journal | Date detection, note saving, edit existing |
| Mood Tracker | `:)` `:(` `:D` `;(` `:\|` – classic emotes only |
| Audio Feedback | Save beep, error beep, quit beep (3-tone farewell) |
| Nostalgia | ASCII art (5 varieties), daily quotes (10) |
| History | Scrollable past notes viewer |
| Statistics | Mood counts + most common mood |
| Backup | Auto-backup on quit |
| **Total** | **8 core features** |

---

## Total Development Time

| Metric | Value |
|--------|-------|
| **Total days** | 5 days (May 6 – May 10, 2026) |
| **Total hours** | ~30 hours |
| **Average per day** | ~6 hours |
| **Lines of code** | ~450 (PureBasic) |
| **Features** | 8 |
| **ASCII art pieces** | 5 |
| **Daily quotes** | 10 |
| **Beep types** | 3 |

---

## Daily Breakdown Chart

```
Day 1 (May 6):     ████████████ 6 hrs   (Idea + Prototype)
Day 2 (May 7):     ████████████████ 8 hrs   (Soul + Features)
Day 3 (May 8):     ██████████████ 7 hrs   (Polish + Testing)
Day 4 (May 9):     ████████████ 6 hrs   (Documentation)
Day 5 (May 10):    ██████ 3 hrs   (Release)
                   ─────────────────────
Total:             30 hours of nostalgic coding <3
```

---

## Key Achievements ;D

- Built a **fully functional life journal** in PureBasic with zero internet after download
- Recreated the **exact QBasic aesthetic** – cyan on blue, blinking cursor, simple INPUT
- Added **beeps** that sound like `SOUND 1000, 10` from 1995
- Created **ASCII art** that makes you feel 12 again
- Implemented **auto-backup** so you never lose a memory
- Works entirely **offline** – perfect for internet shutdowns
- **Portable** – single .exe + one .txt file. No install. No registry.

---

## Challenges & Solutions <3

| Challenge | Solution |
|-----------|----------|
| PureBasic has no `Cls` for console | Created custom `ClsScreen()` with spaces |
| `Screen` is a reserved keyword | Renamed to `ClsScreen` |
| `Beep_` needs numeric parameters | Used `Beep_(freq, duration)` – exact QBasic style |
| No native center text | Wrote `CenterText(y, text$)` with 40 - Len/2 |
| Console clearing flickers | Print 2000 spaces then locate back to 1,1 |
| No internet to test | Tested locally only – worked first try somehow ;D |

---

## Files Created

| File | Purpose |
|------|---------|
| `LifeNote.pb` | PureBasic source code |
| `README.md` | Project documentation |
| `timeline.md` | This file <3 |
| `BUILD.md` | Compilation instructions |
| `LIFE_NOTES.TXT` | User's precious notes (created at runtime) |
| `LIFE_NOTES_BACKUP.TXT` | Auto-backup (created on quit) |

---

## What I Learned ;/

| Lesson | Why it matters |
|--------|----------------|
| PureBasic is still alive | And it's perfect for nostalgia projects |
| Console apps are underrated | No GUI frameworks = no headaches |
| Beeps make everything better | Seriously. Try it. :D |
| ASCII art never dies | Still hits the heart in 2026 |
| Internet shutdowns can't stop ideas | This whole project was born during one |

---

## Future Enhancements (v1.1+)

- **Search** – find notes by keyword
- **Password protection** – secret diary mode
- **Export to CSV** – for data nerds ;)
- **More ASCII art** – user can add their own
- **Custom beep tones** – choose your sound frequency
- **Daily reminder mode** – run at startup automatically

---

## Special Thanks <3

- **PureBasic team** – for keeping BASIC alive when everyone else moved on
- **My 12-year-old self** – for falling in love with `SCREEN 0`, `COLOR 11,1`, and `SOUND`
- **Iran's internet** – for being so unreliable that offline tools became necessary ;D
- **ChatGPT** – for helping debug and making this timeline beautiful
- **You** – for reading this and caring about a blue screen journal <3

---

## Author

**Mohsen Jafari** - Creator, Developer, Designer

- GitHub: [mh3nj](https://github.com/mh3nj)
- LinkedIn: [mh3nj](https://linkedin.com/in/mh3nj)
- Websites: [Parsegan.com](https://parsegan.com) (logo design), [Dahgan.com](https://dahgan.com) (land surveying/portfolio)

---

## Final Words ;)

> *"I was 12 years old when I first learned QBasic. In some ways, my childhood is marked by QBasic. ;D"*

This program is a letter to that kid.  
Every beep. Every colon-parenthesis smiley. Every line of cyan text on deep blue.

**You kept coding. You kept feeling. You made it. <3**

---

*Made during internet restrictions in Iran – May 2026*  
*No internet required. Just a blue screen and a heart. :)*

---

**LifeNote v1.0 – "For the 12-year-old me" Edition**  
*Cyan on blue. Beeps included. Forever offline. ;D*
