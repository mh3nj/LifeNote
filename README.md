
# QBasic Blue Screen Life Note <3

**Daily journaling, 1995 style. Cyan on blue. Beeps included. No internet required. ;D**

![PureBasic](https://img.shields.io/badge/PureBasic-5.70+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-Windows-blue)

---

## :/ What is this?

A **PureBasic console application** that turns your terminal into a **QBasic blue screen** from 1995.  
Write one life note per day. Pick a mood. Hear beeps. See ASCII art. Get stats. Auto-backup on exit.

Built for the 12-year-old me who fell in love with `SCREEN 0`, `COLOR 11,1`, and `SOUND`.  
No bloat. No internet. Just you, a blinking cursor, and your thoughts. ;)

---

## :D Features

| Feature | Description |
|---------|-------------|
| **Blue Screen UI** | Deep blue background + cyan text. Just like QBasic. |
| **Mood Tracker** | `:)` `:(` `:D` `;(` `:\|` — classic text emotes only. |
| **Daily Notes** | One note per day. Edit if you change your mind. |
| **Beep Sounds** | `SOUND`-style beeps on save, error, and quit. |
| **ASCII Art** | Random QBasic nostalgia art on every launch. |
| **Daily Quotes** | Encouraging message to start your session. |
| **Scrollable History** | Browse all your past notes by date. |
| **Statistics** | See your most common mood and total notes. |
| **Auto-Backup** | Copies `LIFE_NOTES.TXT` to `LIFE_NOTES_BACKUP.TXT` on quit. |
| **Portable** | Single .exe + one .txt file. No install, no registry. |

---

## ;) Screenshot

```
╔══════════════════════════════════════╗
║          LIFE NOTE v1.0              ║
║     QBasic Blue Screen Edition        ║
║   For the 12-year-old me inside       ║
╚══════════════════════════════════════╝

LIFE NOTE - TODAY IS 2026-05-08
========================================

How do you feel?
  :)  Happy
  :(  Sad
  :D  Laughing
  ;(  Crying
  :|  Neutral

Choice > :)
```

---

## :3 Requirements

- **Windows** (XP through 11)
- **PureBasic** (if compiling from source) – or just download the `.exe`
- No internet connection required. Ever. :)

---

## ;/ Installation

### Option 1: Download pre-compiled .exe
1. Go to [Releases](../../releases)
2. Download `LifeNote.exe`
3. Double-click. That's it.

### Option 2: Compile from source
1. Install [PureBasic](https://www.purebasic.com/)
2. Copy the code from `LifeNote.pb`
3. Press `F5` to run or `F6` to compile

---

## :| How to use

1. Run the program. See ASCII art and a daily quote.
2. Choose your mood: `:)` `:(` `:D` `;(` `:|`
3. Type your life note (up to 200 characters)
4. Hear the **save beep** :D
5. Main menu options:
   - `1` – Write another note
   - `2` – View past notes (scrollable)
   - `3` – Show statistics
   - `4` – See ASCII art again
   - `5` – Quit (auto-backup)

---

## <3 File structure

```
LifeNote.exe          # The program
LIFE_NOTES.TXT        # Your precious notes (plain text)
LIFE_NOTES_BACKUP.TXT # Auto-backup created on quit
```

Each note is stored as:
```
2026-05-08
:)
Today I felt happy because the code finally worked.
```

---

## :/ Why I made this

> *"I was 12 years old when I first learned QBasic. In some ways, my childhood is marked by QBasic. ;D"*

Iran's internet shutdowns made me realize: I don't need the cloud. I need a **blue screen**, a **blinking cursor**, and a place to write down my life — just like I did in 1995.

This is for that kid. And for anyone who misses the simplicity of `SCREEN 0`.

---

## ;D License

MIT – do whatever you want with it. Just keep the beeps alive. <3

---

## :3 Contributing

No thanks. This is a personal time capsule.  
But if you want to make your own fork with more features, go for it ;)

---

## Author

**Mohsen Jafari** - Creator, Developer, Designer

- GitHub: [mh3nj](https://github.com/mh3nj)
- LinkedIn: [mh3nj](https://linkedin.com/in/mh3nj)
- Websites: [Parsegan.com](https://parsegan.com) (logo design), [Dahgan.com](https://dahgan.com) (land surveying/portfolio)

---

**Made with <3 and `SOUND 1000, 10`**  
*– For the 12-year-old me, wherever he is right now.*
