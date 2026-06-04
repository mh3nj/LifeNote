; ==========================================
;          LIFE NOTE v2.0
;    QBasic Blue Screen Edition - GOD TIER
;  For the 14-year-old me who loved
;  SCREEN 0, COLOR 11,1, and SOUND
;  Now with: streaks, moods, letters,
;  ciphers, ASCII calendars, and more
; ==========================================

OpenConsole()
ConsoleTitle("QBasic Life Note v2.0 - GOD TIER EDITION")
; Resize console to 84x50 so logos render correctly, then wait for OS to repaint
RunProgram("cmd.exe", "/c mode con: cols=83 lines=50", "", #PB_Program_Wait)
Delay(300)

; ==========================================
;  GLOBAL THEME SYSTEM
; ==========================================
; Themes: 0=QBasic Blue, 1=Amber, 2=Green Phosphor, 3=Paper
Global gTheme = 0

Structure ThemeData
  fg.i       ; foreground (normal text)
  hi.i       ; highlight color
  bg.i       ; background
  name$
EndStructure

Global Dim Themes.ThemeData(3)
Themes(0)\fg = 11 : Themes(0)\hi = 14 : Themes(0)\bg = 1  : Themes(0)\name$ = "QBasic Blue"
Themes(1)\fg = 6  : Themes(1)\hi = 14 : Themes(1)\bg = 0  : Themes(1)\name$ = "Amber"
Themes(2)\fg = 2  : Themes(2)\hi = 10 : Themes(2)\bg = 0  : Themes(2)\name$ = "Green Phosphor"
Themes(3)\fg = 7  : Themes(3)\hi = 15 : Themes(3)\bg = 0  : Themes(3)\name$ = "Paper White"

Procedure SetNormal()
  ConsoleColor(Themes(gTheme)\fg, Themes(gTheme)\bg)
EndProcedure

Procedure SetHighlight()
  ConsoleColor(Themes(gTheme)\hi, Themes(gTheme)\bg)
EndProcedure

Procedure SetColor(fg, bg = -1)
  If bg = -1 : bg = Themes(gTheme)\bg : EndIf
  ConsoleColor(fg, bg)
EndProcedure

; ==========================================
;  DATA STRUCTURES
; ==========================================
Structure NoteData
  date$
  mood$
  text$        ; lines joined by Chr(10)
  tags$        ; space-separated #tags
  noteType$    ; "normal", "letter", "future"
  sealedUntil$ ; date for future letters
  xp.i
EndStructure

Structure AchievementData
  id$
  unlocked.i
  unlockedDate$
EndStructure

Structure PlayerData
  xp.i
  level.i
  passwordHash.i
  hasPassword.i
  theme.i
EndStructure

Global NewList Notes.NoteData()
Global NewList Achievements.AchievementData()
Global Player.PlayerData

Global NotesFile$       = "LIFE_NOTES.TXT"
Global AchievFile$      = "ACHIEVEMENTS.TXT"
Global PlayerFile$      = "PLAYER.TXT"
Global BackupFile$      = "LIFE_NOTES_BACKUP.TXT"
Global EncryptedFile$   = "LIFE_NOTES_ENCRYPTED.TXT"

; ==========================================
;  SCREEN / CONSOLE HELPERS
; ==========================================
Procedure ClsScreen()
  ClearConsole()
  ConsoleLocate(0, 0)
EndProcedure

Procedure QBeep(freq, duration)
  Beep_(freq, duration)
EndProcedure

Procedure WaitKey()
  SetColor(7)
  PrintN("")
  PrintN("  Press any key to continue...")
  SetNormal()
  Input()
EndProcedure

Procedure CenterText(y, text$)
  ConsoleLocate(0, y)
  padding = (78 - Len(text$)) / 2
  If padding < 0 : padding = 0 : EndIf
  PrintN(Space(padding) + text$)
EndProcedure

Procedure DrawLine(y, char$)
  ConsoleLocate(0, y)
  s$ = ""
  For i = 1 To 78
    s$ + char$
  Next i
  PrintN(s$)
EndProcedure

Procedure PrintMenuItem(y, key$, label$)
  ConsoleLocate(0, y)
  PrintN("  " + key$ + " | " + label$)
EndProcedure

; Build a repeated character string (PureBasic has no RepeatString built-in)
Procedure.s RepeatStr(char$, count)
  s$ = ""
  For i = 1 To count
    s$ + char$
  Next i
  ProcedureReturn s$
EndProcedure

; Typewriter effect - print one char at a time
Procedure TypeWriter(text$, delayMs = 30)
  For i = 1 To Len(text$)
    Print(Mid(text$, i, 1))
    Delay(delayMs)
  Next i
  PrintN("")
EndProcedure

; ==========================================
;  STARTUP MELODY (GORILLAS.BAS TRIBUTE)
; ==========================================
Procedure PlayStartupMelody()
  QBeep(523, 120)  ; C5
  QBeep(659, 120)  ; E5
  QBeep(784, 120)  ; G5
  QBeep(1047, 200) ; C6
  Delay(80)
  QBeep(784, 120)  ; G5
  QBeep(1047, 300) ; C6
  Delay(100)
  QBeep(880, 120)  ; A5
  QBeep(1047, 120) ; C6
  QBeep(988, 200)  ; B5
EndProcedure

Procedure PlaySadMelody()
  QBeep(440, 200)
  QBeep(392, 200)
  QBeep(349, 200)
  QBeep(330, 400)
EndProcedure

Procedure PlayBurnMelody()
  QBeep(800, 100)
  QBeep(600, 100)
  QBeep(400, 100)
  QBeep(200, 300)
  QBeep(100, 500)
EndProcedure

Procedure PlayLevelUpMelody()
  QBeep(523, 100)
  QBeep(659, 100)
  QBeep(784, 100)
  QBeep(1047, 100)
  QBeep(1319, 200)
  QBeep(1047, 100)
  QBeep(1319, 300)
EndProcedure

Procedure PlayUnlockMelody()
  QBeep(784, 150)
  QBeep(988, 150)
  QBeep(1175, 150)
  QBeep(1568, 300)
  Delay(100)
  QBeep(1568, 150)
  QBeep(1760, 400)
EndProcedure

; ==========================================
;  HASH (simple djb2 for password)
; ==========================================
Procedure.i SimpleHash(s$)
  h = 5381
  For i = 1 To Len(s$)
    h = ((h << 5) + h) + Asc(Mid(s$, i, 1))
  Next i
  ProcedureReturn h & $7FFFFFFF
EndProcedure

; ==========================================
;  XOR ENCRYPT / DECRYPT
; ==========================================
Procedure.s XorCipher(text$, key$ = "QBASIC1990")
  result$ = ""
  kLen = Len(key$)
  For i = 1 To Len(text$)
    kChar = Asc(Mid(key$, ((i-1) % kLen) + 1, 1))
    result$ + Chr(Asc(Mid(text$, i, 1)) ! kChar)
  Next i
  ProcedureReturn result$
EndProcedure

; ==========================================
;  DATE HELPERS
; ==========================================
Procedure.s TodayDate()
  ProcedureReturn FormatDate("%yyyy-%mm-%dd", Date())
EndProcedure

Procedure.s LastYearDate()
  ProcedureReturn FormatDate("%yyyy-%mm-%dd", Date() - 365 * 24 * 3600)
EndProcedure

Procedure.i DateToInt(d$)
  ; returns YYYYMMDD as integer for comparison
  ProcedureReturn Val(ReplaceString(d$, "-", ""))
EndProcedure

Procedure.i DaysBetween(d1$, d2$)
  ; very rough: just compare YYYYMMDD difference in days
  ; parse manually
  y1 = Val(Left(d1$, 4)) : m1 = Val(Mid(d1$, 6, 2)) : day1 = Val(Right(d1$, 2))
  y2 = Val(Left(d2$, 4)) : m2 = Val(Mid(d2$, 6, 2)) : day2 = Val(Right(d2$, 2))
  ; convert to julian-style day count (simplified)
  jd1 = y1 * 365 + m1 * 30 + day1
  jd2 = y2 * 365 + m2 * 30 + day2
  ProcedureReturn Abs(jd2 - jd1)
EndProcedure

Procedure.s PreviousDay(d$)
  ; subtract one day
  y = Val(Left(d$, 4)) : m = Val(Mid(d$, 6, 2)) : day = Val(Right(d$, 2))
  day - 1
  If day < 1
    m - 1
    If m < 1 : m = 12 : y - 1 : EndIf
    Select m
      Case 1,3,5,7,8,10,12 : day = 31
      Case 4,6,9,11         : day = 30
      Case 2                : day = 28
    EndSelect
  EndIf
  ProcedureReturn RSet(Str(y),4,"0") + "-" + RSet(Str(m),2,"0") + "-" + RSet(Str(day),2,"0")
EndProcedure

Procedure.s MonthName(m)
  Select m
    Case 1:ProcedureReturn "January"   : Case 2:ProcedureReturn "February"
    Case 3:ProcedureReturn "March"     : Case 4:ProcedureReturn "April"
    Case 5:ProcedureReturn "May"       : Case 6:ProcedureReturn "June"
    Case 7:ProcedureReturn "July"      : Case 8:ProcedureReturn "August"
    Case 9:ProcedureReturn "September" : Case 10:ProcedureReturn "October"
    Case 11:ProcedureReturn "November" : Case 12:ProcedureReturn "December"
  EndSelect
  ProcedureReturn ""
EndProcedure

; Day of week (0=Mon..6=Sun) - Zeller's congruence
Procedure.i CalcDayOfWeek(y, m, d)
  If m < 3 : m + 12 : y - 1 : EndIf
  k = y % 100 : j = y / 100
  h = (d + (13*(m+1))/5 + k + k/4 + j/4 + 5*j) % 7
  ProcedureReturn (h + 6) % 7  ; 0=Mon..6=Sun
EndProcedure

; Days in month
Procedure.i DaysInMonth(y, m)
  Select m
    Case 1,3,5,7,8,10,12 : ProcedureReturn 31
    Case 4,6,9,11         : ProcedureReturn 30
    Case 2
      If (y % 4 = 0 And y % 100 <> 0) Or (y % 400 = 0)
        ProcedureReturn 29
      Else
        ProcedureReturn 28
      EndIf
  EndSelect
  ProcedureReturn 30
EndProcedure

; ==========================================
;  PLAYER / XP SYSTEM
; ==========================================
Procedure.s LevelName(lvl)
  Select lvl
    Case 0 : ProcedureReturn "ROOKIE DIARIST"
    Case 1 : ProcedureReturn "WORDSMITH"
    Case 2 : ProcedureReturn "LIFE CHRONICLER"
    Case 3 : ProcedureReturn "MEMORY KEEPER"
    Case 4 : ProcedureReturn "SOUL SCRIBE"
    Case 5 : ProcedureReturn "LEGEND"
    Default : ProcedureReturn "LEGEND"
  EndSelect
EndProcedure

Procedure.i XpForLevel(lvl)
  Select lvl
    Case 0 : ProcedureReturn 0
    Case 1 : ProcedureReturn 100
    Case 2 : ProcedureReturn 300
    Case 3 : ProcedureReturn 700
    Case 4 : ProcedureReturn 1500
    Case 5 : ProcedureReturn 3000
    Default : ProcedureReturn 99999
  EndSelect
EndProcedure

Procedure UpdateLevel()
  For lvl = 5 To 0 Step -1
    If Player\xp >= XpForLevel(lvl)
      If Player\level < lvl
        Player\level = lvl
        ; celebrate!
        ClsScreen()
        SetHighlight()
        DrawLine(5, "*")
        CenterText(8,  "*** LEVEL UP! ***")
        CenterText(10, "You are now: " + LevelName(lvl))
        CenterText(12, "XP: " + Str(Player\xp))
        DrawLine(14, "*")
        SetNormal()
        PlayLevelUpMelody()
        WaitKey()
      EndIf
      Break
    EndIf
  Next lvl
EndProcedure

Procedure AddXP(amount)
  Player\xp + amount
  UpdateLevel()
EndProcedure

; ==========================================
;  ACHIEVEMENT SYSTEM
; ==========================================
Procedure InitAchievements()
  ClearList(Achievements())
  
  Restore AchievList
  Repeat
    Read.s id$
    If id$ = "END" : Break : EndIf
    AddElement(Achievements())
    Achievements()\id$ = id$
    Achievements()\unlocked = 0
    Achievements()\unlockedDate$ = ""
  ForEver
  
  DataSection
    AchievList:
    Data.s "FIRST_NOTE", "STREAK_7", "STREAK_30", "NOTES_10", "NOTES_100"
    Data.s "CRYING_WEEK", "HAPPY_WEEK", "ALL_MOODS", "BURNED_NOTE"
    Data.s "FUTURE_LETTER", "WROTE_LONG", "GREP_USED", "NIGHT_OWL", "END"
  EndDataSection
EndProcedure

Procedure.s AchievName(id$)
  Select id$
    Case "FIRST_NOTE"    : ProcedureReturn "[* FIRST NOTE] You wrote your first entry!"
    Case "STREAK_7"      : ProcedureReturn "[FIRE 7-DAY STREAK] A whole week of memories!"
    Case "STREAK_30"     : ProcedureReturn "[FIRE 30-DAY STREAK] A month of dedication!"
    Case "NOTES_10"      : ProcedureReturn "[10 NOTES] Getting into the habit!"
    Case "NOTES_100"     : ProcedureReturn "[100 NOTES] You are a true chronicler!"
    Case "CRYING_WEEK"   : ProcedureReturn "[RAIN CRYING WEEK] Seven sad days... you survived."
    Case "HAPPY_WEEK"    : ProcedureReturn "[SUN HAPPY WEEK] Seven days of smiling!"
    Case "ALL_MOODS"     : ProcedureReturn "[RAINBOW ALL MOODS] You felt everything."
    Case "BURNED_NOTE"   : ProcedureReturn "[ASH BURNED NOTE] Some memories are ash."
    Case "FUTURE_LETTER" : ProcedureReturn "[CLOCK FUTURE LETTER] You wrote to future-you!"
    Case "WROTE_LONG"    : ProcedureReturn "[SCROLL LONG NOTE] 500+ chars in one entry!"
    Case "GREP_USED"     : ProcedureReturn "[LENS GREP MASTER] You searched your memories."
    Case "NIGHT_OWL"     : ProcedureReturn "[OWL NIGHT OWL] Writing after midnight!"
    Default              : ProcedureReturn "[? Unknown]"
  EndSelect
EndProcedure

Procedure UnlockAchievement(id$)
  ForEach Achievements()
    If Achievements()\id$ = id$ And Achievements()\unlocked = 0
      Achievements()\unlocked = 1
      Achievements()\unlockedDate$ = TodayDate()
      ; Flash notification
      SetColor(14)
      ConsoleLocate(0, 23)
      Print("  ACHIEVEMENT UNLOCKED: " + AchievName(id$))
      SetNormal()
      QBeep(1000, 80) : QBeep(1200, 80) : QBeep(1500, 150)
      Delay(2000)
      Break
    EndIf
  Next
EndProcedure

Procedure CheckAchievements()
  total = ListSize(Notes())
  
  If total >= 1     : UnlockAchievement("FIRST_NOTE") : EndIf
  If total >= 10    : UnlockAchievement("NOTES_10")   : EndIf
  If total >= 100   : UnlockAchievement("NOTES_100")  : EndIf
  
  ; Check moods
  Dim moodSeen$(5)
  ForEach Notes()
    moodSeen$(0) = moodSeen$(0) + Notes()\mood$
  Next
  If FindString(moodSeen$(0), ":)") And FindString(moodSeen$(0), ":(") And
     FindString(moodSeen$(0), ":D") And FindString(moodSeen$(0), ";(") And
     FindString(moodSeen$(0), ":|")
    UnlockAchievement("ALL_MOODS")
  EndIf
  
  ; Night owl: check if current hour >= 0 and < 4
  h = Val(FormatDate("%hh", Date()))
  If h >= 0 And h < 4
    UnlockAchievement("NIGHT_OWL")
  EndIf
EndProcedure

; ==========================================
;  STREAK COUNTER
; ==========================================
Procedure.i CalculateStreak()
  If ListSize(Notes()) = 0 : ProcedureReturn 0 : EndIf
  
  streak = 0
  checkDate$ = TodayDate()
  
  Repeat
    found = 0
    ForEach Notes()
      If Notes()\date$ = checkDate$ And Notes()\noteType$ = "normal"
        found = 1
        Break
      EndIf
    Next
    If found
      streak + 1
      checkDate$ = PreviousDay(checkDate$)
    Else
      Break
    EndIf
    If streak > 3650 : Break : EndIf  ; safety cap
  ForEver
  
  ProcedureReturn streak
EndProcedure

; ==========================================
;  FILE I/O
; ==========================================
Procedure LoadNotes()
  ClearList(Notes())
  If ReadFile(0, NotesFile$)
    While Not Eof(0)
      line$ = ReadString(0)
      If line$ = "" And Eof(0) : Break : EndIf
      AddElement(Notes())
      Notes()\date$        = line$
      Notes()\mood$        = ReadString(0)
      Notes()\text$        = ReadString(0)
      Notes()\tags$        = ReadString(0)
      Notes()\noteType$    = ReadString(0)
      Notes()\sealedUntil$ = ReadString(0)
      Notes()\xp           = Val(ReadString(0))
    Wend
    CloseFile(0)
  EndIf
EndProcedure

Procedure SaveNotes()
  If CreateFile(0, NotesFile$)
    ForEach Notes()
      WriteStringN(0, Notes()\date$)
      WriteStringN(0, Notes()\mood$)
      WriteStringN(0, Notes()\text$)
      WriteStringN(0, Notes()\tags$)
      WriteStringN(0, Notes()\noteType$)
      WriteStringN(0, Notes()\sealedUntil$)
      WriteStringN(0, Str(Notes()\xp))
    Next
    CloseFile(0)
  EndIf
  QBeep(800, 150) : QBeep(1000, 100)
EndProcedure

Procedure LoadAchievements()
  InitAchievements()
  If ReadFile(0, AchievFile$)
    While Not Eof(0)
      id$ = ReadString(0)
      If id$ = "" And Eof(0) : Break : EndIf
      unl = Val(ReadString(0))
      uDate$ = ReadString(0)
      ForEach Achievements()
        If Achievements()\id$ = id$
          Achievements()\unlocked = unl
          Achievements()\unlockedDate$ = uDate$
          Break
        EndIf
      Next
    Wend
    CloseFile(0)
  EndIf
EndProcedure

Procedure SaveAchievements()
  If CreateFile(0, AchievFile$)
    ForEach Achievements()
      WriteStringN(0, Achievements()\id$)
      WriteStringN(0, Str(Achievements()\unlocked))
      WriteStringN(0, Achievements()\unlockedDate$)
    Next
    CloseFile(0)
  EndIf
EndProcedure

Procedure LoadPlayer()
  Player\xp = 0 : Player\level = 0 : Player\hasPassword = 0 : Player\theme = 0
  If ReadFile(0, PlayerFile$)
    Player\xp          = Val(ReadString(0))
    Player\level       = Val(ReadString(0))
    Player\hasPassword = Val(ReadString(0))
    Player\passwordHash = Val(ReadString(0))
    Player\theme       = Val(ReadString(0))
    CloseFile(0)
  EndIf
  gTheme = Player\theme
EndProcedure

Procedure SavePlayer()
  If CreateFile(0, PlayerFile$)
    WriteStringN(0, Str(Player\xp))
    WriteStringN(0, Str(Player\level))
    WriteStringN(0, Str(Player\hasPassword))
    WriteStringN(0, Str(Player\passwordHash))
    WriteStringN(0, Str(Player\theme))
    CloseFile(0)
  EndIf
EndProcedure

; ==========================================
;  PASSWORD SYSTEM
; ==========================================
Procedure.i CheckPassword()
  If Player\hasPassword = 0 : ProcedureReturn 1 : EndIf
  ClsScreen()
  SetHighlight()
  CenterText(8, "*** LIFE NOTE IS LOCKED ***")
  SetNormal()
  CenterText(10, "Enter password:")
  ConsoleLocate(35, 12) : Print("> ")
  pass$ = Input()
  If SimpleHash(pass$) = Player\passwordHash
    QBeep(1000, 100) : QBeep(1200, 100)
    ProcedureReturn 1
  Else
    SetColor(12)
    CenterText(14, "WRONG PASSWORD! Access denied.")
    QBeep(200, 500)
    Delay(1500)
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure SetPassword()
  ClsScreen()
  SetHighlight()
  CenterText(5, "=== SET PASSWORD ===")
  SetNormal()
  CenterText(8, "Enter new password (blank to remove):")
  ConsoleLocate(30, 10) : Print("> ")
  pass$ = Input()
  If pass$ = ""
    Player\hasPassword = 0
    Player\passwordHash = 0
    CenterText(12, "Password removed.")
  Else
    CenterText(11, "Confirm password:")
    ConsoleLocate(30, 13) : Print("> ")
    pass2$ = Input()
    If pass$ = pass2$
      Player\hasPassword = 1
      Player\passwordHash = SimpleHash(pass$)
      CenterText(15, "Password set! Don't forget it.")
      QBeep(1000, 100)
    Else
      SetColor(12)
      CenterText(15, "Passwords don't match! Not changed.")
    EndIf
  EndIf
  SavePlayer()
  WaitKey()
EndProcedure

; ==========================================
;  MULTI-LINE NOTE EDITOR
; ==========================================
Procedure.s MultiLineInput(prompt$, startRow)
  SetHighlight()
  ConsoleLocate(2, startRow)
  PrintN(prompt$)
  SetNormal()
  ConsoleLocate(2, startRow + 1)
  PrintN("(Type lines, enter . alone to finish)")
  PrintN("")
  
  fullText$ = ""
  row = startRow + 3
  lineNum = 1
  
  Repeat
    ConsoleLocate(2, row)
    Print(Str(lineNum) + "> ")
    line$ = Input()
    If line$ = "."
      Break
    EndIf
    If fullText$ <> "" : fullText$ + Chr(10) : EndIf
    fullText$ + line$
    row + 1
    lineNum + 1
    If row > 22
      WaitKey()
      ClsScreen()
      row = 3
    EndIf
  ForEver
  
  ProcedureReturn fullText$
EndProcedure

; ==========================================
;  FIND TODAY'S NOTE
; ==========================================
Procedure FindNoteByDate(date$)
  i = 0
  ForEach Notes()
    If Notes()\date$ = date$ And Notes()\noteType$ = "normal"
      ProcedureReturn i
    EndIf
    i + 1
  Next
  ProcedureReturn -1
EndProcedure

; ==========================================
;  MOOD COLOR
; ==========================================
Procedure SetMoodColor(mood$)
  Select mood$
    Case ":)"  : SetColor(10)   ; bright green  = happy
    Case ":("  : SetColor(12)   ; bright red    = sad
    Case ":D"  : SetColor(14)   ; yellow        = laughing
    Case ";("  : SetColor(9)    ; blue           = crying
    Case ":|"  : SetColor(7)    ; grey           = neutral
    Default    : SetNormal()
  EndSelect
EndProcedure

Procedure.s MoodBar(mood$)
  Select mood$
    Case ":)"  : ProcedureReturn Chr($2588)  ; full block green
    Case ":("  : ProcedureReturn Chr($2591)  ; light shade red
    Case ":D"  : ProcedureReturn Chr($2593)  ; dark shade yellow
    Case ";("  : ProcedureReturn Chr($2592)  ; medium shade blue
    Case ":|"  : ProcedureReturn "-"
    Default    : ProcedureReturn "?"
  EndSelect
EndProcedure

; ==========================================
;  DAILY QUOTE
; ==========================================
Procedure.s DailyQuote()
  RandomSeed(ElapsedMilliseconds())
  q = Random(13)
  Select q
    Case 0  : ProcedureReturn "Code is poetry that runs."
    Case 1  : ProcedureReturn "One note = one memory saved."
    Case 2  : ProcedureReturn "Your 14-year-old self is smiling."
    Case 3  : ProcedureReturn "Blue screen = safe place."
    Case 4  : ProcedureReturn "Beep beep! You're doing great."
    Case 5  : ProcedureReturn "Print 'Hello World' to yourself today."
    Case 6  : ProcedureReturn "Every day deserves a line of text."
    Case 7  : ProcedureReturn "No internet needed for this feeling."
    Case 8  : ProcedureReturn "QBasic taught us: we can create."
    Case 9  : ProcedureReturn "This note is a gift to future you."
    Case 10 : ProcedureReturn "The screen glows because you do."
    Case 11 : ProcedureReturn "Your story compiles without errors."
    Case 12 : ProcedureReturn "Even GOTO was a step forward."
    Case 13 : ProcedureReturn "10 PRINT 'you matter' : 20 GOTO 10"
  EndSelect
EndProcedure

; ==========================================
;  ASCII ART
; ==========================================
; ==========================================
;  LOGO DISPLAY FROM DATA
; ==========================================
Procedure ShowLogoFromData(labelStr$, color1, color2)
  ; labelStr$ tells us which Restore label to use
  ; We use a global flag to pick the right DataSection
  ClsScreen()
  row = 0
  Repeat
    Read.s line$
    If line$ = "END" : Break : EndIf
    ConsoleLocate(0, row)
    ; Alternate two colors for depth
    If row % 2 = 0
      SetColor(color1)
    Else
      SetColor(color2)
    EndIf
    Print(line$)
    row + 1
    If row > 23 : Break : EndIf
  ForEver
  SetNormal()
EndProcedure

Procedure ShowLogoComet()
  ClearConsole()
  Restore LogoComet
  row = 0
  Repeat
    Read.s line$
    If line$ = "END" : Break : EndIf
    ConsoleLocate(0, row)
    If row < 12
      SetColor(14)   ; yellow - comet tail
    ElseIf row < 28
      SetColor(11)   ; cyan   - body
    Else
      SetColor(9)    ; blue   - base
    EndIf
    PrintN(line$)
    row + 1
    If row > 42 : Break : EndIf
  ForEver
  SetNormal()
EndProcedure

Procedure ShowLogoLetterA()
  ClearConsole()
  Restore LogoLetterA
  row = 0
  Repeat
    Read.s line$
    If line$ = "END" : Break : EndIf
    ConsoleLocate(0, row)
    If row < 6
      SetColor(14)   ; yellow tip
    ElseIf row < 20
      SetColor(11)   ; cyan middle
    Else
      SetColor(10)   ; green base
    EndIf
    PrintN(line$)
    row + 1
    If row > 46 : Break : EndIf
  ForEver
  SetNormal()
EndProcedure

Procedure ShowASCIIArt()
  RandomSeed(ElapsedMilliseconds())
  artNum = Random(6)   ; 0-1 = your logos, 2-6 = classic art
  Select artNum
    Case 0
      ShowLogoComet()
      ConsoleLocate(0, 24)
      SetHighlight()
      CenterText(23, "- LIFE NOTE  ~  Your Digital Soul  -")
      SetNormal()
    Case 1
      ShowLogoLetterA()
      ConsoleLocate(0, 24)
      SetHighlight()
      CenterText(23, "- LIFE NOTE  ~  Always Writing  -")
      SetNormal()
    Case 2
      ClsScreen()
      SetHighlight() : CenterText(2, "=== REMEMBER THIS? ===") : SetNormal()
      PrintN("") : PrintN("         _______")
      PrintN("        /       \")
      PrintN("       |  :-)    |")
      PrintN("        \_______/")
      PrintN("            |")
      PrintN("            |")
      PrintN("          --+--")
      PrintN("            |")
      PrintN("           / \")
      CenterText(20, "- DOS QBasic Man -")
    Case 3
      ClsScreen()
      SetHighlight() : CenterText(2, "=== REMEMBER THIS? ===") : SetNormal()
      PrintN("") : PrintN("        ________________")
      PrintN("       |                |")
      PrintN("       |   [=====]      |")
      PrintN("       |   (o o)        |")
      PrintN("       |    ---         |")
      PrintN("       |   QBasic!      |")
      PrintN("       |________________|")
      CenterText(20, "- Old Computer -")
    Case 4
      ClsScreen()
      SetHighlight() : CenterText(2, "=== REMEMBER THIS? ===") : SetNormal()
      PrintN("") : PrintN("          *****")
      PrintN("        **     **")
      PrintN("      **  :D    **")
      PrintN("      **         **")
      PrintN("        **     **")
      PrintN("          *****")
      CenterText(20, "- Smiley Face -")
    Case 5
      ClsScreen()
      SetHighlight() : CenterText(2, "=== REMEMBER THIS? ===") : SetNormal()
      PrintN("") : PrintN("        +-----------+")
      PrintN("        |  SCREEN 0 |")
      PrintN("        |  COLOR 11 |")
      PrintN("        |  SOUND    |")
      PrintN("        |  INPUT    |")
      PrintN("        +-----------+")
      CenterText(20, "- My QBasic Setup -")
    Case 6
      ClsScreen()
      SetHighlight() : CenterText(2, "=== REMEMBER THIS? ===") : SetNormal()
      PrintN("") : PrintN("            ______")
      PrintN("         .-'      '-.")
      PrintN("        /   LOVE    \")
      PrintN("       |     :)      |")
      PrintN("        \   QBASIC  /")
      PrintN("         '-._____.-'")
      CenterText(20, "- For my 14-year-old self -")
  EndSelect
  PrintN("") : CenterText(25, "Press any key...")
  Input()
EndProcedure

; ==========================================
;  LOGO DATA SECTIONS
; ==========================================
DataSection
  LogoComet:
  Data.s ""
  Data.s "                                                                *****************"
  Data.s "                                                               ******************"
  Data.s "     *                                                        *******************"
  Data.s "     **                                                      *******************"
  Data.s "     ***                                                    ********************"
  Data.s "     ****                                                  *********************"
  Data.s "     ******                                              **********************"
  Data.s "     ********                                           **********************"
  Data.s "     **********                                      *************************"
  Data.s "     *************                                ***************************"
  Data.s "     *****************                        ******************************"
  Data.s "     *******************                   ********************************"
  Data.s "     *******************                   ******************************"
  Data.s "     *******************                   *****************************"
  Data.s "     *******************                   ***************************"
  Data.s "     *******************                   *************************"
  Data.s "     *******************                   ***********************"
  Data.s "     *******************                   *********************"
  Data.s "     *******************                   *****************"
  Data.s "     *******************                   *************"
  Data.s "     *******************                   *******"
  Data.s "     *******************"
  Data.s "     *******************"
  Data.s "     *******************"
  Data.s "     *******************"
  Data.s "     *******************"
  Data.s "     *******************"
  Data.s "     *******************"
  Data.s "     ********************"
  Data.s "     *********************"
  Data.s "     ************************"
  Data.s "     *********************************************************"
  Data.s "     *********************************************************"
  Data.s "     *********************************************************"
  Data.s "      ********************************************************"
  Data.s "      ********************************************************"
  Data.s "       *******************************************************"
  Data.s "         *****************************************************"
  Data.s "          ****************************************************"
  Data.s "            **************************************************"
  Data.s "               ***********************************************"
  Data.s "                   *******************************************"
  Data.s "END"

  LogoLetterA:
  Data.s ""
  Data.s ""
  Data.s ""
  Data.s "                             *****************"
  Data.s "                         ************************"
  Data.s "                       *****************************"
  Data.s "      **************************************************************************"
  Data.s "      **************************************************************************"
  Data.s "      **************************************************************************"
  Data.s "      **************************************************************************"
  Data.s "      **************************************************************************"
  Data.s "      **************************************************************************"
  Data.s "      **************************************************************************"
  Data.s "      **************************************************           *************"
  Data.s "      **************************************************           *************"
  Data.s "      ************* ***********************************            *************"
  Data.s "      *************  *********************************             *************"
  Data.s "      *************    *****************************              **************"
  Data.s "      *************      *************************               ***************"
  Data.s "      *************         *******************                 ****************"
  Data.s "      *************            ************                    *****************"
  Data.s "      *************            ************                   ******************"
  Data.s "      *************            ************                 ********************"
  Data.s "      *************            ************               **********************"
  Data.s "      *************            ************             ************************"
  Data.s "      *************            ************         ****************************"
  Data.s "      *************            ************ ************************************"
  Data.s "      *************            *************************************************"
  Data.s "      *************            *************************************************"
  Data.s "      *************            *************************************************"
  Data.s "      *************            *************************************************"
  Data.s "      *************             ************************************************"
  Data.s "      *************              ***********************************************"
  Data.s "      *************                                    *************************"
  Data.s "      *************                                    *************************"
  Data.s "      *************                                    *************************"
  Data.s "      **************                                   *************************"
  Data.s "      ***************                                  *************************"
  Data.s "      *****************                                *************************"
  Data.s "      ********************                             *************************"
  Data.s "      *************************************************************************"
  Data.s "       ************************************************************************"
  Data.s "        **********************************************************************"
  Data.s "         ********************************************************************"
  Data.s "          ******************************************************************"
  Data.s "             ************************************************************"
  Data.s "                ******************************************************"
  Data.s "END"
EndDataSection

; ==========================================
;  VIEW HISTORY (color-coded moods)
; ==========================================
Procedure ViewHistory()
  ClsScreen()
  SetHighlight()
  CenterText(2, "=== YOUR PAST NOTES ===")
  SetNormal()
  
  If ListSize(Notes()) = 0
    CenterText(5, "No notes yet.")
    WaitKey()
    ProcedureReturn
  EndIf
  
  row = 4
  ForEach Notes()
    If Notes()\noteType$ <> "normal" : Continue : EndIf
    ConsoleLocate(2, row)
    SetHighlight()
    Print(Notes()\date$ + " ")
    SetMoodColor(Notes()\mood$)
    Print("[" + Notes()\mood$ + "] ")
    SetNormal()
    excerpt$ = ReplaceString(Notes()\text$, Chr(10), " ")
    If Len(excerpt$) > 45 : excerpt$ = Left(excerpt$, 42) + "..." : EndIf
    Print(excerpt$)
    If Notes()\tags$ <> ""
      SetColor(13)
      Print("  " + Notes()\tags$)
    EndIf
    SetNormal()
    row + 1
    If row > 22
      WaitKey()
      row = 4
      ClsScreen()
      SetHighlight()
      CenterText(2, "=== YOUR PAST NOTES (cont.) ===")
      SetNormal()
    EndIf
  Next
  WaitKey()
EndProcedure

; ==========================================
;  VIEW HISTORY WITH BURN MODE
; ==========================================
Procedure ViewHistoryBurn()
  ClsScreen()
  SetHighlight()
  CenterText(2, "=== NOTES (B to burn a note) ===")
  SetNormal()
  
  If ListSize(Notes()) = 0
    CenterText(5, "No notes yet.")
    WaitKey()
    ProcedureReturn
  EndIf
  
  ; build index list for display
  Global Dim noteIdx(1000)
  count = 0
  ForEach Notes()
    If Notes()\noteType$ = "normal"
      noteIdx(count) = ListIndex(Notes())
      count + 1
    EndIf
  Next
  
  row = 4
  num = 0
  ForEach Notes()
    If Notes()\noteType$ <> "normal" : Continue : EndIf
    ConsoleLocate(2, row)
    SetHighlight()
    Print(Str(num+1) + ". " + Notes()\date$ + " ")
    SetMoodColor(Notes()\mood$)
    Print("[" + Notes()\mood$ + "] ")
    SetNormal()
    excerpt$ = ReplaceString(Notes()\text$, Chr(10), " ")
    If Len(excerpt$) > 40 : excerpt$ = Left(excerpt$, 37) + "..." : EndIf
    Print(excerpt$)
    row + 1 : num + 1
    If row > 21
      ConsoleLocate(2, 23)
      SetNormal()
      Print("More... number to burn, ENTER=next, Q=quit > ")
      ch$ = Input()
      If UCase(ch$) = "Q" : ProcedureReturn : EndIf
      If Val(ch$) > 0
        burnNum = Val(ch$) - 1
        ; find and delete
        i = 0
        ForEach Notes()
          If Notes()\noteType$ = "normal"
            If i = burnNum
              ClsScreen()
              SetColor(12)
              CenterText(8, "*** BURN THIS MEMORY? ***")
              SetNormal()
              excerpt2$ = ReplaceString(Notes()\text$, Chr(10), " ")
              CenterText(10, Left(excerpt2$, 60))
              CenterText(12, "Type YES to confirm:")
              ConsoleLocate(35, 14) : Print("> ")
              confirm$ = Input()
              If UCase(confirm$) = "YES"
                DeleteElement(Notes())
                SaveNotes()
                PlayBurnMelody()
                UnlockAchievement("BURNED_NOTE")
                SetColor(12)
                CenterText(16, "This memory has been released.")
                Delay(2000)
              EndIf
              Break
            EndIf
            i + 1
          EndIf
        Next
        ProcedureReturn
      EndIf
      row = 4
      ClsScreen()
      SetHighlight()
      CenterText(2, "=== NOTES (cont.) ===")
      SetNormal()
    EndIf
  Next
  WaitKey()
EndProcedure

; ==========================================
;  GREP YOUR MEMORIES
; ==========================================
Procedure GrepMemories()
  ClsScreen()
  SetHighlight()
  CenterText(2, "=== GREP YOUR MEMORIES ===")
  SetNormal()
  CenterText(5, "Enter search term:")
  ConsoleLocate(30, 7) : Print("> ")
  term$ = Input()
  If term$ = "" : ProcedureReturn : EndIf
  
  UnlockAchievement("GREP_USED")
  
  ClsScreen()
  SetHighlight()
  CenterText(2, "=== RESULTS FOR: " + term$ + " ===")
  SetNormal()
  
  found = 0
  row = 4
  ForEach Notes()
    searchIn$ = LCase(Notes()\text$ + " " + Notes()\tags$)
    If FindString(searchIn$, LCase(term$))
      ConsoleLocate(2, row)
      SetHighlight()
      Print(Notes()\date$ + " ")
      SetMoodColor(Notes()\mood$)
      Print("[" + Notes()\mood$ + "] ")
      SetNormal()
      excerpt$ = ReplaceString(Notes()\text$, Chr(10), " ")
      If Len(excerpt$) > 45 : excerpt$ = Left(excerpt$, 42) + "..." : EndIf
      Print(excerpt$)
      found + 1
      row + 1
      If row > 22
        WaitKey()
        row = 4
        ClsScreen()
        SetHighlight()
        CenterText(2, "=== RESULTS (cont.) ===")
        SetNormal()
      EndIf
    EndIf
  Next
  
  If found = 0
    CenterText(5, "No notes found for: " + term$)
  Else
    ConsoleLocate(2, row + 1)
    SetColor(10)
    PrintN("  Found: " + Str(found) + " note(s).")
    SetNormal()
  EndIf
  WaitKey()
EndProcedure

; ==========================================
;  STATISTICS + RECORDS
; ==========================================
Procedure ShowStats()
  ClsScreen()
  SetHighlight()
  CenterText(2, "=== YOUR STATISTICS ===")
  SetNormal()
  
  If ListSize(Notes()) = 0
    CenterText(5, "No notes yet. Write your life first!")
    WaitKey()
    ProcedureReturn
  EndIf
  
  happy = 0 : sad = 0 : laugh = 0 : cry = 0 : neutral = 0
  totalNormal = 0
  longestLen = 0 : shortestLen = 999999
  longestDate$ = "" : shortestDate$ = ""
  
  ForEach Notes()
    If Notes()\noteType$ <> "normal" : Continue : EndIf
    totalNormal + 1
    Select Notes()\mood$
      Case ":)"  : happy   + 1
      Case ":("  : sad     + 1
      Case ":D"  : laugh   + 1
      Case ";("  : cry     + 1
      Case ":|"  : neutral + 1
    EndSelect
    tLen = Len(Notes()\text$)
    If tLen > longestLen  : longestLen  = tLen  : longestDate$  = Notes()\date$ : EndIf
    If tLen < shortestLen : shortestLen = tLen  : shortestDate$ = Notes()\date$ : EndIf
  Next
  
  streak = CalculateStreak()
  
  ConsoleLocate(5, 4)  : Print("Total notes:       " + Str(totalNormal))
  ConsoleLocate(5, 5)  : Print("Current streak:    " + Str(streak) + " day(s)")
  ConsoleLocate(5, 6)  : Print("Your XP:           " + Str(Player\xp))
  ConsoleLocate(5, 7)  : Print("Your level:        " + LevelName(Player\level))
  ConsoleLocate(5, 9)  
  SetColor(10)  : Print("Happy  :) : " + Str(happy))
  ConsoleLocate(5, 10) 
  SetColor(12)  : Print("Sad    :( : " + Str(sad))
  ConsoleLocate(5, 11) 
  SetColor(14)  : Print("Laugh  :D : " + Str(laugh))
  ConsoleLocate(5, 12) 
  SetColor(9)   : Print("Cry    ;( : " + Str(cry))
  ConsoleLocate(5, 13) 
  SetColor(7)   : Print("Neutral:| : " + Str(neutral))
  SetNormal()
  
  ConsoleLocate(5, 15) : Print("Longest note:  " + longestDate$ + " (" + Str(longestLen) + " chars)")
  ConsoleLocate(5, 16) : Print("Shortest note: " + shortestDate$ + " (" + Str(shortestLen) + " chars)")
  
  ; most common mood
  maxCount = happy : bestMood$ = ":)"
  If sad     > maxCount : maxCount = sad     : bestMood$ = ":(" : EndIf
  If laugh   > maxCount : maxCount = laugh   : bestMood$ = ":D" : EndIf
  If cry     > maxCount : maxCount = cry     : bestMood$ = ";(" : EndIf
  If neutral > maxCount : maxCount = neutral : bestMood$ = ":|" : EndIf
  
  ConsoleLocate(5, 18) : Print("Most common mood: " + bestMood$)
  
  WaitKey()
  
  ; Show achievements
  ClsScreen()
  SetHighlight()
  CenterText(2, "=== ACHIEVEMENTS ===")
  SetNormal()
  row = 4
  ForEach Achievements()
    ConsoleLocate(2, row)
    If Achievements()\unlocked
      SetColor(14)
      Print("[UNLOCKED " + Achievements()\unlockedDate$ + "] ")
      SetColor(10)
    Else
      SetColor(8)
      Print("[LOCKED]              ")
    EndIf
    Print(AchievName(Achievements()\id$))
    SetNormal()
    row + 1
    If row > 22
      WaitKey()
      row = 4
      ClsScreen()
      SetHighlight()
      CenterText(2, "=== ACHIEVEMENTS (cont.) ===")
      SetNormal()
    EndIf
  Next
  WaitKey()
EndProcedure

; ==========================================
;  MOOD GRAPH (ASCII bar chart)
; ==========================================
Procedure ShowMoodGraph()
  ClsScreen()
  SetHighlight()
  CenterText(2, "=== MOOD GRAPH - LAST 60 DAYS ===")
  SetNormal()
  
  If ListSize(Notes()) = 0
    CenterText(5, "No notes yet!")
    WaitKey()
    ProcedureReturn
  EndIf
  
  ; Build a 60-day timeline
  today$ = TodayDate()
  
  ; For each of last 60 days, find mood
  Dim dayMood$(60)
  Dim dayDate$(60)
  
  ; Fill from today (index 59 = newest/right) backwards
  checkDate$ = today$
  For i = 59 To 0 Step -1
    dayDate$(i) = checkDate$
    dayMood$(i) = ""
    ForEach Notes()
      If Notes()\date$ = checkDate$ And Notes()\noteType$ = "normal"
        dayMood$(i) = Notes()\mood$
        Break
      EndIf
    Next
    If i > 0
      checkDate$ = PreviousDay(checkDate$)
    EndIf
  Next i
  
  ; Print 2 rows of 30 days each
  SetHighlight()
  ConsoleLocate(2, 4)
  PrintN("Last 60 days (newest at right):")
  SetNormal()
  
  ; Row 1: days 0-29 (oldest 30)
  ConsoleLocate(2, 6)
  For i = 0 To 29
    If dayMood$(i) = ""
      SetColor(8)
      Print(".")
    Else
      SetMoodColor(dayMood$(i))
      Print(MoodBar(dayMood$(i)))
    EndIf
  Next i
  SetNormal()
  
  ; Row 2: days 30-59 (newest 30)
  ConsoleLocate(2, 7)
  For i = 30 To 59
    If dayMood$(i) = ""
      SetColor(8)
      Print(".")
    Else
      SetMoodColor(dayMood$(i))
      Print(MoodBar(dayMood$(i)))
    EndIf
  Next i
  SetNormal()
  
  ConsoleLocate(2, 9)
  SetColor(10) : Print(Chr($2588) + "=happy  ")
  SetColor(12) : Print(Chr($2591) + "=sad  ")
  SetColor(14) : Print(Chr($2593) + "=laugh  ")
  SetColor(9)  : Print(Chr($2592) + "=cry  ")
  SetColor(7)  : Print("-=neutral  ")
  SetColor(8)  : Print(".=no entry")
  SetNormal()
  
  WaitKey()
EndProcedure

; ==========================================
;  ASCII CALENDAR
; ==========================================
Procedure ShowCalendar()
  ClsScreen()
  SetHighlight()
  
  y = Val(FormatDate("%yyyy", Date()))
  m = Val(FormatDate("%mm", Date()))
  
  CenterText(2, "=== " + UCase(MonthName(m)) + " " + Str(y) + " ===")
  SetNormal()
  
  ; Build set of dates with notes
  Dim hasNote$(31)
  Dim noteMood$(31)
  ForEach Notes()
    noteY = Val(Left(Notes()\date$, 4))
    noteM = Val(Mid(Notes()\date$, 6, 2))
    noteD = Val(Right(Notes()\date$, 2))
    If noteY = y And noteM = m And Notes()\noteType$ = "normal"
      hasNote$(noteD) = "1"
      noteMood$(noteD) = Notes()\mood$
    EndIf
  Next
  
  ; Print header
  ConsoleLocate(10, 4)
  SetHighlight()
  Print("Mo  Tu  We  Th  Fr  Sa  Su")
  SetNormal()
  
  startDow = CalcDayOfWeek(y, m, 1)  ; 0=Mon
  daysInM = DaysInMonth(y, m)
  
  row = 5
  col = 10 + startDow * 4
  
  ConsoleLocate(col, row)
  todayD = Val(FormatDate("%dd", Date()))
  
  For d = 1 To daysInM
    If col >= 10 + 7 * 4
      col = 10
      row + 1
    EndIf
    ConsoleLocate(col, row)
    If d = todayD
      SetColor(15)  ; bright white for today
    ElseIf hasNote$(d) = "1"
      SetMoodColor(noteMood$(d))
    Else
      SetColor(8)   ; dark grey for no entry
    EndIf
    s$ = Str(d)
    If Len(s$) = 1 : s$ = " " + s$ : EndIf
    Print(s$)
    SetNormal()
    col + 4
  Next d
  
  ConsoleLocate(10, row + 2)
  SetColor(15) : Print("## = today  ")
  SetColor(10) : Print("colored = has note  ")
  SetColor(8)  : Print("grey = no entry")
  SetNormal()
  
  WaitKey()
EndProcedure

; ==========================================
;  WORD FREQUENCY
; ==========================================
Procedure ShowWordFrequency()
  ClsScreen()
  SetHighlight()
  CenterText(2, "=== TOP WORDS IN YOUR LIFE ===")
  SetNormal()
  
  ; Stopwords
  stopwords$ = " i the a an and or but is was are were be been being have has had do does did will would could should may might shall to of in on at by for with from that this it its not no my me we us he she they them their our you your "
  
  ; Collect all words
  Dim wordList$(2000)
  Dim wordCount(2000)
  wordTotal = 0
  
  ForEach Notes()
    If Notes()\noteType$ <> "normal" : Continue : EndIf
    text$ = LCase(ReplaceString(Notes()\text$, Chr(10), " "))
    ; strip punctuation
    text$ = ReplaceString(text$, ".", " ")
    text$ = ReplaceString(text$, ",", " ")
    text$ = ReplaceString(text$, "!", " ")
    text$ = ReplaceString(text$, "?", " ")
    text$ = ReplaceString(text$, "'", " ")
    text$ = ReplaceString(text$, Chr(34), " ")
    
    ; split by spaces
    Repeat
      spacePos = FindString(text$, " ")
      If spacePos = 0
        word$ = Trim(text$)
        text$ = ""
      Else
        word$ = Trim(Left(text$, spacePos - 1))
        text$ = Mid(text$, spacePos + 1)
      EndIf
      If Len(word$) < 3 : Continue : EndIf
      If FindString(stopwords$, " " + word$ + " ") : Continue : EndIf
      
      ; check if already in list
      found = 0
      For i = 0 To wordTotal - 1
        If wordList$(i) = word$
          wordCount(i) + 1
          found = 1
          Break
        EndIf
      Next i
      If Not found And wordTotal < 2000
        wordList$(wordTotal) = word$
        wordCount(wordTotal) = 1
        wordTotal + 1
      EndIf
    Until text$ = "" Or spacePos = 0 And word$ = ""
  Next
  
  ; Bubble sort top 10
  For i = 0 To wordTotal - 2
    For j = 0 To wordTotal - 2 - i
      If wordCount(j) < wordCount(j+1)
        tmpC = wordCount(j) : wordCount(j) = wordCount(j+1) : wordCount(j+1) = tmpC
        tmpS$ = wordList$(j) : wordList$(j) = wordList$(j+1) : wordList$(j+1) = tmpS$
      EndIf
    Next j
  Next i
  
  If wordTotal = 0
    CenterText(6, "Not enough words yet!")
    WaitKey()
    ProcedureReturn
  EndIf
  
  limit = 10
  If wordTotal < limit : limit = wordTotal : EndIf
  
  ConsoleLocate(15, 4)
  SetHighlight()
  PrintN("Your top " + Str(limit) + " most used words:")
  SetNormal()
  
  For i = 0 To limit - 1
    ConsoleLocate(15, 6 + i)
    bar$ = ""
    barLen = wordCount(i)
    If barLen > 30 : barLen = 30 : EndIf
    For b = 1 To barLen : bar$ + Chr($2588) : Next b
    SetColor(14)
    Print(RSet(Str(i+1), 2) + ". ")
    SetColor(11)
    Print(LSet(wordList$(i), 15))
    SetColor(10)
    Print(bar$ + " " + Str(wordCount(i)))
    SetNormal()
  Next i
  
  WaitKey()
EndProcedure

; ==========================================
;  THIS DAY LAST YEAR
; ==========================================
Procedure CheckLastYear()
  lastYear$ = LastYearDate()
  ForEach Notes()
    If Notes()\date$ = lastYear$ And Notes()\noteType$ = "normal"
      ClsScreen()
      SetColor(13)
      DrawLine(3, "*")
      CenterText(5, "*** A MESSAGE FROM PAST YOU ***")
      CenterText(6, "One year ago today (" + lastYear$ + "), you wrote:")
      DrawLine(8, "-")
      SetMoodColor(Notes()\mood$)
      CenterText(10, "Mood: " + Notes()\mood$)
      SetNormal()
      ; typewriter display
      lines$ = Notes()\text$
      ConsoleLocate(5, 12)
      TypeWriter(Left(lines$, 70), 40)
      DrawLine(15, "*")
      SetColor(13)
      CenterText(17, "Remember that day? You made it.")
      SetNormal()
      PlayUnlockMelody()
      WaitKey()
      Break
    EndIf
  Next
EndProcedure

; ==========================================
;  NOTE TEMPLATES
; ==========================================
Procedure.s TemplatePrompt()
  ClsScreen()
  SetHighlight()
  CenterText(2, "=== GUIDED JOURNAL ===")
  SetNormal()
  CenterText(4, "Answer these three questions:")
  
  ConsoleLocate(5, 6) : Print("1. What made you smile today?")
  ConsoleLocate(8, 7) : Print("> ")
  ans1$ = Input()
  
  ConsoleLocate(5, 9) : Print("2. What drained you?")
  ConsoleLocate(8, 10) : Print("> ")
  ans2$ = Input()
  
  ConsoleLocate(5, 12) : Print("3. One word that describes today:")
  ConsoleLocate(8, 13) : Print("> ")
  ans3$ = Input()
  
  ProcedureReturn "Smile: " + ans1$ + Chr(10) + "Drained: " + ans2$ + Chr(10) + "Word: " + ans3$
EndProcedure

; ==========================================
;  UNSENT LETTER MODE
; ==========================================
Procedure UnsentLetter()
  ClsScreen()
  SetHighlight()
  CenterText(2, "=== UNSENT LETTER ===")
  SetColor(13)
  CenterText(4, "This letter will never be saved.")
  CenterText(5, "Write it. Read it. Then it's gone.")
  SetNormal()
  
  ConsoleLocate(5, 7) : Print("To: ")
  toName$ = Input()
  
  ClsScreen()
  SetHighlight()
  CenterText(2, "Write your letter to " + toName$)
  SetNormal()
  CenterText(4, "(Enter . alone to finish)")
  PrintN("")
  
  letter$ = ""
  row = 6
  Repeat
    ConsoleLocate(5, row)
    Print("> ")
    line$ = Input()
    If line$ = "." : Break : EndIf
    letter$ + line$ + Chr(10)
    row + 1
    If row > 22 : row = 6 : ClsScreen() : EndIf
  ForEver
  
  ; Display with typewriter
  ClsScreen()
  SetColor(13)
  CenterText(2, "Dear " + toName$ + ",")
  SetNormal()
  ConsoleLocate(5, 4)
  
  lines$ = letter$
  lineRow = 4
  Repeat
    nlPos = FindString(lines$, Chr(10))
    If nlPos = 0
      thisLine$ = lines$
      lines$ = ""
    Else
      thisLine$ = Left(lines$, nlPos - 1)
      lines$ = Mid(lines$, nlPos + 1)
    EndIf
    ConsoleLocate(5, lineRow)
    TypeWriter(thisLine$, 35)
    lineRow + 1
  Until lines$ = "" And nlPos = 0
  
  PrintN("")
  SetColor(13)
  CenterText(lineRow + 2, "This letter belongs to the universe now.")
  SetNormal()
  
  PlaySadMelody()
  WaitKey()
EndProcedure

; ==========================================
;  LETTER TO FUTURE ME
; ==========================================
Procedure WriteFutureLetter()
  ClsScreen()
  SetHighlight()
  CenterText(2, "=== LETTER TO FUTURE ME ===")
  SetNormal()
  CenterText(4, "This letter will be SEALED until a date you choose.")
  CenterText(5, "You cannot read it until then.")
  
  ConsoleLocate(5, 7) : Print("Unlock date (YYYY-MM-DD): ")
  unlockDate$ = Input()
  
  ; Basic validation
  If Len(unlockDate$) <> 10
    CenterText(9, "Invalid date. Returning.")
    Delay(1500) : ProcedureReturn
  EndIf
  
  If DateToInt(unlockDate$) <= DateToInt(TodayDate())
    CenterText(9, "Date must be in the future!")
    Delay(1500) : ProcedureReturn
  EndIf
  
  ClsScreen()
  SetHighlight()
  CenterText(2, "Write your letter (. to finish)")
  SetNormal()
  CenterText(4, "It will be sealed until: " + unlockDate$)
  PrintN("")
  
  letter$ = ""
  row = 6
  Repeat
    ConsoleLocate(5, row)
    Print("> ")
    line$ = Input()
    If line$ = "." : Break : EndIf
    If letter$ <> "" : letter$ + Chr(10) : EndIf
    letter$ + line$
    row + 1
    If row > 22 : row = 6 : ClsScreen() : EndIf
  ForEver
  
  AddElement(Notes())
  Notes()\date$        = TodayDate()
  Notes()\mood$        = ":|"
  Notes()\text$        = letter$
  Notes()\tags$        = "#future"
  Notes()\noteType$    = "future"
  Notes()\sealedUntil$ = unlockDate$
  Notes()\xp           = 50
  AddXP(50)
  SaveNotes()
  
  UnlockAchievement("FUTURE_LETTER")
  
  ClsScreen()
  SetColor(13)
  CenterText(8, "Your letter is SEALED.")
  CenterText(10, "It will open on: " + unlockDate$)
  CenterText(12, "Past-you is waiting for you there.")
  PlayUnlockMelody()
  WaitKey()
EndProcedure

Procedure CheckFutureLetters()
  today$ = TodayDate()
  ForEach Notes()
    If Notes()\noteType$ = "future" And Notes()\sealedUntil$ <= today$
      ClsScreen()
      SetColor(14)
      DrawLine(2, "*")
      CenterText(4, "*** A SEALED LETTER HAS OPENED ***")
      CenterText(6, "Past-you wrote this on " + Notes()\date$)
      CenterText(7, "It was sealed for you until today.")
      DrawLine(9, "*")
      SetColor(13)
      CenterText(11, "Are you ready to read it? (Y/N)")
      ConsoleLocate(38, 13) : Print("> ")
      ans$ = Input()
      If UCase(ans$) = "Y"
        ClsScreen()
        SetColor(14)
        CenterText(2, "Dear Future Me,")
        SetNormal()
        ConsoleLocate(5, 4)
        lines$ = Notes()\text$
        lineRow = 4
        Repeat
          nlPos = FindString(lines$, Chr(10))
          If nlPos = 0
            thisLine$ = lines$
            lines$ = ""
          Else
            thisLine$ = Left(lines$, nlPos - 1)
            lines$ = Mid(lines$, nlPos + 1)
          EndIf
          ConsoleLocate(5, lineRow)
          TypeWriter(thisLine$, 40)
          lineRow + 1
        Until lines$ = "" And nlPos = 0
        SetColor(14)
        CenterText(lineRow + 2, "- Your past self, " + Notes()\date$)
        PlayUnlockMelody()
        WaitKey()
        ; Convert to normal note so it doesn't trigger again
        Notes()\noteType$ = "opened"
        SaveNotes()
      EndIf
    EndIf
  Next
EndProcedure

; ==========================================
;  FILL THE GAPS
; ==========================================
Procedure FillTheGaps()
  If ListSize(Notes()) = 0 : ProcedureReturn : EndIf
  
  today$ = TodayDate()
  checkDate$ = PreviousDay(today$)
  gapsFound = 0
  
  ; Check last 7 days
  For d = 1 To 7
    found = 0
    ForEach Notes()
      If Notes()\date$ = checkDate$ And Notes()\noteType$ = "normal"
        found = 1 : Break
      EndIf
    Next
    If Not found
      ClsScreen()
      SetHighlight()
      CenterText(5, "=== MISSED DAY DETECTED ===")
      SetNormal()
      CenterText(7, "You missed: " + checkDate$)
      CenterText(9, "Want to write a late entry? (Y/N)")
      ConsoleLocate(38, 11) : Print("> ")
      ans$ = Input()
      If UCase(ans$) = "Y"
        ClsScreen()
        SetHighlight()
        CenterText(2, "LATE ENTRY FOR " + checkDate$)
        SetNormal()
        CenterText(4, "Mood?  :)  :(  :D  ;(  :|")
        ConsoleLocate(38, 6) : Print("> ")
        mood$ = Input()
        Select mood$
          Case ":)", ":(", ":D", ";(", ":|" : ; valid
          Default : mood$ = ":|"
        EndSelect
        
        noteText$ = MultiLineInput("Your note for " + checkDate$, 8)
        If noteText$ = "" : noteText$ = "(late entry, silent day)" : EndIf
        
        AddElement(Notes())
        Notes()\date$     = checkDate$
        Notes()\mood$     = mood$
        Notes()\text$     = noteText$
        Notes()\tags$     = "#lateentry"
        Notes()\noteType$ = "normal"
        Notes()\xp        = 5
        AddXP(5)
        SaveNotes()
        gapsFound + 1
      EndIf
    EndIf
    checkDate$ = PreviousDay(checkDate$)
  Next d
  
  If gapsFound = 0
    ; silently continue
  EndIf
EndProcedure

; ==========================================
;  ANNUAL REVIEW (Dec 31 special)
; ==========================================
Procedure AnnualReview()
  year$ = FormatDate("%yyyy", Date())
  month$ = FormatDate("%mm", Date())
  
  ; Show anytime if December, not just 31
  ; (Or force with menu)
  ClsScreen()
  SetHighlight()
  DrawLine(1, "=")
  CenterText(3, "*** ANNUAL REVIEW " + year$ + " ***")
  DrawLine(5, "=")
  SetNormal()
  
  totalYear = 0 : happy = 0 : sad = 0 : laugh = 0 : cry = 0 : neutral = 0
  bestStreak = 0 : currentS = 0
  prevDate$ = ""
  
  ForEach Notes()
    If Left(Notes()\date$, 4) <> year$ : Continue : EndIf
    If Notes()\noteType$ <> "normal"   : Continue : EndIf
    totalYear + 1
    Select Notes()\mood$
      Case ":)"  : happy   + 1
      Case ":("  : sad     + 1
      Case ":D"  : laugh   + 1
      Case ";("  : cry     + 1
      Case ":|"  : neutral + 1
    EndSelect
  Next
  
  bestStreak = CalculateStreak()
  
  ConsoleLocate(5, 7)  : Print("Notes written in " + year$ + ": " + Str(totalYear))
  ConsoleLocate(5, 8)  : SetColor(10) : Print("Happy days  :) : " + Str(happy))   : SetNormal()
  ConsoleLocate(5, 9)  : SetColor(12) : Print("Sad days    :( : " + Str(sad))     : SetNormal()
  ConsoleLocate(5, 10) : SetColor(14) : Print("Laughing    :D : " + Str(laugh))   : SetNormal()
  ConsoleLocate(5, 11) : SetColor(9)  : Print("Crying days ;( : " + Str(cry))     : SetNormal()
  ConsoleLocate(5, 12) : SetColor(7)  : Print("Neutral     :| : " + Str(neutral)) : SetNormal()
  ConsoleLocate(5, 14) : Print("Best streak: " + Str(bestStreak) + " days")
  ConsoleLocate(5, 15) : Print("Total XP:    " + Str(Player\xp))
  ConsoleLocate(5, 16) : Print("Level:       " + LevelName(Player\level))
  
  If totalYear > 0
    ; Dominant mood
    ConsoleLocate(5, 18)
    maxC = happy : bestM$ = ":) Happy"
    If sad > maxC     : maxC = sad     : bestM$ = ":( Sad"     : EndIf
    If laugh > maxC   : maxC = laugh   : bestM$ = ":D Laughing" : EndIf
    If cry > maxC     : maxC = cry     : bestM$ = ";( Crying"  : EndIf
    If neutral > maxC : maxC = neutral : bestM$ = ":| Neutral" : EndIf
    Print("Your " + year$ + " in one mood: " + bestM$)
  EndIf
  
  WaitKey()
EndProcedure

; ==========================================
;  EXPORT DIARY
; ==========================================
Procedure ExportDiary()
  ClsScreen()
  SetHighlight()
  CenterText(2, "=== EXPORT YOUR DIARY ===")
  SetNormal()
  CenterText(4, "1. Plain readable .TXT")
  CenterText(5, "2. XOR encrypted backup (retro security!)")
  CenterText(6, "3. Both")
  ConsoleLocate(38, 8) : Print("> ")
  ch$ = Input()
  
  exportFile$ = "DIARY_EXPORT_" + ReplaceString(TodayDate(), "-", "") + ".TXT"
  encFile$    = "DIARY_EXPORT_" + ReplaceString(TodayDate(), "-", "") + "_ENC.TXT"
  
  If ch$ = "1" Or ch$ = "3"
    If CreateFile(0, exportFile$)
      WriteStringN(0, "========================================")
      WriteStringN(0, "  LIFE NOTE - DIARY EXPORT")
      WriteStringN(0, "  Exported: " + TodayDate())
      WriteStringN(0, "  Total notes: " + Str(ListSize(Notes())))
      WriteStringN(0, "========================================")
      WriteStringN(0, "")
      ForEach Notes()
        If Notes()\noteType$ <> "normal" : Continue : EndIf
        WriteStringN(0, "DATE: " + Notes()\date$)
        WriteStringN(0, "MOOD: " + Notes()\mood$)
        If Notes()\tags$ <> "" : WriteStringN(0, "TAGS: " + Notes()\tags$) : EndIf
        WriteStringN(0, "---")
        ; write text lines
        lines$ = Notes()\text$
        Repeat
          nlPos = FindString(lines$, Chr(10))
          If nlPos = 0
            WriteStringN(0, lines$)
            lines$ = ""
          Else
            WriteStringN(0, Left(lines$, nlPos - 1))
            lines$ = Mid(lines$, nlPos + 1)
          EndIf
        Until lines$ = "" And nlPos = 0
        WriteStringN(0, "")
        WriteStringN(0, "========================================")
        WriteStringN(0, "")
      Next
      CloseFile(0)
    EndIf
  EndIf
  
  If ch$ = "2" Or ch$ = "3"
    ; Read the plain export and XOR it, or build from scratch
    If CreateFile(0, encFile$)
      WriteStringN(0, "LIFENOTE_ENCRYPTED_V2")
      ForEach Notes()
        If Notes()\noteType$ <> "normal" : Continue : EndIf
        WriteStringN(0, XorCipher(Notes()\date$))
        WriteStringN(0, XorCipher(Notes()\mood$))
        WriteStringN(0, XorCipher(Notes()\text$))
        WriteStringN(0, XorCipher(Notes()\tags$))
      Next
      CloseFile(0)
    EndIf
  EndIf
  
  ClsScreen()
  SetColor(10)
  CenterText(8, "Export complete!")
  SetNormal()
  If ch$ = "1" Or ch$ = "3"
    CenterText(10, "Plain: " + exportFile$)
  EndIf
  If ch$ = "2" Or ch$ = "3"
    CenterText(11, "Encrypted: " + encFile$)
    CenterText(12, "(XOR cipher key: QBASIC1990)")
  EndIf
  QBeep(1000, 100) : QBeep(1200, 150)
  WaitKey()
EndProcedure

; ==========================================
;  THEME SELECTOR
; ==========================================
Procedure SelectTheme()
  ClsScreen()
  SetHighlight()
  CenterText(2, "=== SELECT YOUR THEME ===")
  SetNormal()
  
  For i = 0 To 3
    ConsoleLocate(20, 5 + i)
    If i = gTheme : SetColor(14) : Else : SetNormal() : EndIf
    Print(Str(i+1) + ". " + Themes(i)\name$)
    SetNormal()
  Next i
  
  ConsoleLocate(35, 11) : Print("Choice > ")
  ch$ = Input()
  c = Val(ch$) - 1
  If c >= 0 And c <= 3
    gTheme = c
    Player\theme = c
    SavePlayer()
    ConsoleColor(Themes(gTheme)\fg, Themes(gTheme)\bg)
    CenterText(13, "Theme set to: " + Themes(gTheme)\name$)
    Delay(1000)
  EndIf
EndProcedure

; ==========================================
;  CINEMATIC SCREENSAVER
; ==========================================
Procedure Screensaver()
  If ListSize(Notes()) = 0 : ProcedureReturn : EndIf
  
  ClsScreen()
  ConsoleColor(8, 0)  ; dark on black for starfield
  
  ; Build note snippets
  Dim snippets$(100)
  sCount = 0
  ForEach Notes()
    If Notes()\noteType$ = "normal" And Len(Notes()\text$) > 5
      snippet$ = Notes()\date$ + ": " + Left(ReplaceString(Notes()\text$, Chr(10), " "), 50)
      snippets$(sCount) = snippet$
      sCount + 1
      If sCount >= 100 : Break : EndIf
    EndIf
  Next
  
  If sCount = 0 : ProcedureReturn : EndIf
  
  RandomSeed(ElapsedMilliseconds())
  
  PrintN("  Press any key to exit screensaver...")
  
  row = 2
  For frame = 1 To 60
    ; Star rain
    For s = 1 To 5
      ConsoleLocate(Random(79), Random(22) + 1)
      ConsoleColor(8, 0)
      Print("*")
    Next s
    
    ; Scroll a note snippet
    If frame % 8 = 0
      idx = Random(sCount - 1)
      ConsoleLocate(2, row)
      ConsoleColor(11, 0)
      Print(snippets$(idx))
      row + 1
      If row > 22 : row = 2 : ClsScreen() : ConsoleLocate(0,0) : Print("  Press any key...") : EndIf
    EndIf
    
    Delay(300)
    
    ; Check for keypress (non-blocking via Inkey)
    k$ = Inkey()
    If k$ <> "" : Break : EndIf
  Next frame
  
  SetNormal()
  ClsScreen()
EndProcedure

; ==========================================
;  FORTUNE COOKIE FROM YOUR OWN NOTES
; ==========================================
Procedure FortuneCookie()
  If ListSize(Notes()) = 0 : ProcedureReturn : EndIf
  
  ; Collect short lines from notes
  Dim fortunes$(500)
  fCount = 0
  
  ForEach Notes()
    If Notes()\noteType$ <> "normal" : Continue : EndIf
    lines$ = Notes()\text$
    Repeat
      nlPos = FindString(lines$, Chr(10))
      If nlPos = 0
        thisLine$ = Trim(lines$)
        lines$ = ""
      Else
        thisLine$ = Trim(Left(lines$, nlPos - 1))
        lines$ = Mid(lines$, nlPos + 1)
      EndIf
      If Len(thisLine$) >= 15 And Len(thisLine$) <= 80
        fortunes$(fCount) = thisLine$
        fCount + 1
        If fCount >= 500 : Break : EndIf
      EndIf
    Until lines$ = "" And nlPos = 0
    If fCount >= 500 : Break : EndIf
  Next
  
  If fCount = 0 : ProcedureReturn : EndIf
  
  RandomSeed(ElapsedMilliseconds())
  idx = Random(fCount - 1)
  
  ClsScreen()
  SetColor(14)
  CenterText(7, "*** YOUR FORTUNE COOKIE ***")
  CenterText(9, "(from your own past words)")
  DrawLine(11, "-")
  SetColor(13)
  CenterText(13, Chr(34) + fortunes$(idx) + Chr(34))
  SetColor(14)
  DrawLine(15, "-")
  SetNormal()
  CenterText(17, "- Your past self -")
  QBeep(800, 100) : QBeep(1000, 150)
  WaitKey()
EndProcedure

; ==========================================
;  SETTINGS MENU
; ==========================================
Procedure SettingsMenu()
  Repeat
    ClsScreen()
    SetHighlight()
    CenterText(2, "=== SETTINGS ===")
    SetNormal()
    CenterText(5,  "1. Change theme  (current: " + Themes(gTheme)\name$ + ")")
    CenterText(6,  "2. Set / change password")
    CenterText(7,  "3. Export diary")
    CenterText(8,  "4. Annual review")
    CenterText(9,  "5. Return to main menu")
    ConsoleLocate(38, 11) : Print("> ")
    ch$ = Input()
    Select ch$
      Case "1" : SelectTheme()
      Case "2" : SetPassword()
      Case "3" : ExportDiary()
      Case "4" : AnnualReview()
      Case "5" : Break
    EndSelect
  ForEver
EndProcedure

; ==========================================
;  WRITE NOTE (main flow)
; ==========================================
Procedure WriteNote(dateOverride$ = "")
  targetDate$ = dateOverride$
  If targetDate$ = "" : targetDate$ = TodayDate() : EndIf
  
  ClsScreen()
  SetHighlight()
  CenterText(2, "WRITE YOUR LIFE NOTE")
  DrawLine(4, "-")
  SetNormal()
  
  CenterText(6, "How do you feel?")
  ConsoleLocate(30, 7) : SetColor(10)  : Print(":)  Happy")
  ConsoleLocate(30, 8) : SetColor(12)  : Print(":(  Sad")
  ConsoleLocate(30, 9) : SetColor(14)  : Print(":D  Laughing")
  ConsoleLocate(30, 10): SetColor(9)   : Print(";(  Crying")
  ConsoleLocate(30, 11): SetColor(7)   : Print(":|  Neutral")
  SetNormal()
  
  CenterText(12, "Or press T for guided template")
  ConsoleLocate(38, 13) : Print("Choice > ")
  mood$ = Input()
  
  If UCase(mood$) = "T"
    noteText$ = TemplatePrompt()
    mood$ = ":|"
  Else
    Select mood$
      Case ":)", ":(", ":D", ";(", ":|" : ; valid
      Default : mood$ = ":|"
    EndSelect
    
    ClsScreen()
    SetHighlight()
    CenterText(2, "YOUR NOTE FOR " + targetDate$)
    DrawLine(4, "-")
    SetNormal()
    CenterText(6, "Type your note. Enter . alone to finish.")
    
    noteText$ = MultiLineInput("", 7)
  EndIf
  
  If noteText$ = ""
    noteText$ = "(silent day, but still here)"
    QBeep(300, 500)
  Else
    QBeep(1000, 150)
  EndIf
  
  ; Tags
  ClsScreen()
  SetHighlight()
  CenterText(5, "Add tags? (e.g. #work #family #dream)")
  SetNormal()
  CenterText(7, "(press ENTER to skip)")
  ConsoleLocate(20, 9) : Print("Tags > ")
  tags$ = Input()
  
  ; XP calculation
  xpEarned = 10
  xpEarned + Len(noteText$) / 20
  streak = CalculateStreak()
  If streak >= 7 : xpEarned + 20 : EndIf
  If Len(noteText$) >= 500 : xpEarned + 30 : UnlockAchievement("WROTE_LONG") : EndIf
  
  ; Save
  todayIdx = FindNoteByDate(targetDate$)
  If todayIdx >= 0
    SelectElement(Notes(), todayIdx)
    Notes()\mood$  = mood$
    Notes()\text$  = noteText$
    Notes()\tags$  = tags$
    Notes()\xp     + xpEarned
  Else
    AddElement(Notes())
    Notes()\date$     = targetDate$
    Notes()\mood$     = mood$
    Notes()\text$     = noteText$
    Notes()\tags$     = tags$
    Notes()\noteType$ = "normal"
    Notes()\sealedUntil$ = ""
    Notes()\xp        = xpEarned
  EndIf
  
  SaveNotes()
  AddXP(xpEarned)
  CheckAchievements()
  SaveAchievements()
  
  ClsScreen()
  SetColor(10)
  CenterText(8,  "NOTE SAVED!")
  SetNormal()
  CenterText(10, "Mood: " + mood$)
  CenterText(11, Left(ReplaceString(noteText$, Chr(10), " "), 70))
  SetColor(14)
  CenterText(13, "+" + Str(xpEarned) + " XP earned!  Total: " + Str(Player\xp) + " XP")
  SetNormal()
  
  streak = CalculateStreak()
  If streak >= 2
    CenterText(15, "Streak: " + Str(streak) + " days in a row! Keep going!")
    If streak = 7  : UnlockAchievement("STREAK_7")  : EndIf
    If streak = 30 : UnlockAchievement("STREAK_30") : EndIf
  EndIf
  
  SaveAchievements()
  QBeep(1200, 200)
  WaitKey()
EndProcedure

; ==========================================
;  COZY READING MODE
; ==========================================
Procedure CozyReadingMode()
  If ListSize(Notes()) = 0
    ClsScreen()
    ConsoleLocate(0, 8)
    PrintN("")
    PrintN("  No notes yet. Write your first one!")
    PrintN("")
    PrintN("  Press any key...")
    Input()
    ProcedureReturn
  EndIf

  ; Build normal-note index
  Dim readIdx(2000)
  readCount = 0
  ForEach Notes()
    If Notes()\noteType$ = "normal"
      readIdx(readCount) = ListIndex(Notes())
      readCount + 1
    EndIf
  Next

  If readCount = 0 : ProcedureReturn : EndIf

  curNote = readCount - 1  ; start at most recent

  Repeat
    SelectElement(Notes(), readIdx(curNote))

    ClsScreen()

    ; Top border
    ConsoleLocate(0, 0)
    SetHighlight()
    PrintN("  " + RepeatStr("~", 74))

    ; Date + mood centered
    ConsoleLocate(0, 1)
    moodLabel$ = ""
    Select Notes()\mood$
      Case ":)" : moodLabel$ = "Happy :)"
      Case ":(" : moodLabel$ = "Sad :("
      Case ":D" : moodLabel$ = "Laughing :D"
      Case ";(" : moodLabel$ = "Crying ;("
      Case ":|" : moodLabel$ = "Neutral :|"
      Default   : moodLabel$ = Notes()\mood$
    EndSelect
    headerLine$ = "  " + Notes()\date$ + "   " + moodLabel$
    If Notes()\tags$ <> ""
      headerLine$ + "   " + Notes()\tags$
    EndIf
    PrintN(headerLine$)

    ConsoleLocate(0, 2)
    PrintN("  " + RepeatStr("~", 74))
    SetNormal()

    ; Note body — typewriter line by line
    lines$ = Notes()\text$
    lineRow = 4
    Repeat
      nlPos = FindString(lines$, Chr(10))
      If nlPos = 0
        thisLine$ = lines$
        lines$ = ""
      Else
        thisLine$ = Left(lines$, nlPos - 1)
        lines$ = Mid(lines$, nlPos + 1)
      EndIf
      If Trim(thisLine$) <> "" Or nlPos > 0
        ConsoleLocate(0, lineRow)
        SetMoodColor(Notes()\mood$)
        TypeWriter("    " + thisLine$, 18)
        SetNormal()
        lineRow + 1
      EndIf
      If lineRow > 19 : Break : EndIf
    Until lines$ = "" And nlPos = 0

    ; XP badge
    ConsoleLocate(0, 20)
    SetColor(8)
    PrintN("  XP earned on this day: " + Str(Notes()\xp))

    ; Bottom border + nav
    ConsoleLocate(0, 21)
    SetHighlight()
    PrintN("  " + RepeatStr("~", 74))
    ConsoleLocate(0, 22)
    SetNormal()
    noteNum$ = "  Note " + Str(curNote + 1) + " of " + Str(readCount)
    PrintN(noteNum$)
    ConsoleLocate(0, 23)
    SetColor(7)
    PrintN("  [ P ] Prev   [ N ] Next   [ Q ] Back to menu")
    SetNormal()
    ConsoleLocate(0, 24)
    Print("  > ")

    nav$ = UCase(Input())

    Select nav$
      Case "N"
        curNote + 1
        If curNote >= readCount : curNote = 0 : EndIf
      Case "P"
        curNote - 1
        If curNote < 0 : curNote = readCount - 1 : EndIf
      Case "Q"
        Break
    EndSelect
  ForEver
EndProcedure

; ==========================================
;  MAIN MENU
; ==========================================
Procedure ShowMainMenu()
  ClsScreen()
  SetHighlight()
  ConsoleLocate(0, 0) : PrintN("  " + RepeatStr("=", 74))
  ConsoleLocate(0, 1) : PrintN("      LIFE NOTE v2.0   ~   " + TodayDate() + "   ~   GOD TIER EDITION")
  ConsoleLocate(0, 2) : PrintN("  " + RepeatStr("=", 74))
  SetNormal()

  streak = CalculateStreak()
  xpNext = XpForLevel(Player\level + 1)

  ConsoleLocate(0, 3)
  SetColor(14) : Print("  Level : " + LevelName(Player\level))
  SetNormal()  : Print("    XP : " + Str(Player\xp))
  If Player\level < 5
    Print("  (next : " + Str(xpNext) + " XP)")
  EndIf
  ConsoleLocate(0, 4)
  If streak > 0
    SetColor(10) : PrintN("  Streak: " + Str(streak) + " day(s) in a row! Keep going!")
  Else
    SetColor(8)  : PrintN("  No streak yet - write today!")
  EndIf
  SetNormal()

  ConsoleLocate(0, 5) : PrintN("  " + RepeatStr("-", 74))

  ConsoleLocate(0, 6)  : PrintN("")
  PrintMenuItem(7,  "1", "Write today's note")
  PrintMenuItem(8,  "2", "View past notes")
  PrintMenuItem(9,  "3", "GREP your memories")
  PrintMenuItem(10, "4", "Statistics + Achievements")
  PrintMenuItem(11, "5", "Mood graph")
  PrintMenuItem(12, "6", "Calendar view")
  PrintMenuItem(13, "7", "Word frequency")
  PrintMenuItem(14, "8", "Write to future me")
  PrintMenuItem(15, "9", "Unsent letter")
  PrintMenuItem(16, "R", "Cozy reading mode")
  PrintMenuItem(17, "A", "ASCII art / screensaver")
  PrintMenuItem(18, "B", "Burn a note")
  PrintMenuItem(19, "S", "Settings")
  PrintMenuItem(20, "Q", "Quit")

  ConsoleLocate(0, 21) : PrintN("  " + RepeatStr("=", 74))
  ConsoleLocate(0, 22) : Print("  > ")
EndProcedure

; ==========================================
;  STARTUP SPLASH
; ==========================================
LoadPlayer()
LoadNotes()
LoadAchievements()
ConsoleColor(Themes(gTheme)\fg, Themes(gTheme)\bg)

If Not CheckPassword()
  CloseConsole()
  End
EndIf

; Set theme colors BEFORE drawing anything so background is correct
ConsoleColor(Themes(gTheme)\fg, Themes(gTheme)\bg)
ClearConsole()
Delay(150)  ; let the OS repaint the background fully

; Show logo — randomly alternate between the two real logos
RandomSeed(ElapsedMilliseconds())
If Random(1) = 0
  ShowLogoComet()
Else
  ShowLogoLetterA()
EndIf

; Title bar at bottom of logo
ConsoleLocate(0, 44)
SetHighlight()
PrintN(Space(4) + "LIFE NOTE v2.0   ~   GOD TIER EDITION   ~   " + TodayDate())
SetNormal()
ConsoleLocate(0, 45)
PrintN(Space(4) + "Loading memories...")
PlayStartupMelody()
Delay(600)

; Check for opened future letters
CheckFutureLetters()

; Check for "this day last year"
CheckLastYear()

; Show ASCII art
ShowASCIIArt()

; Daily quote (typewriter effect)
ClsScreen()
SetHighlight()
CenterText(10, DailyQuote())
SetNormal()
WaitKey()

; Fill the gaps prompt
FillTheGaps()

; ==========================================
;  MAIN LOOP
; ==========================================
running = 1
Repeat
  ShowMainMenu()
  choice$ = Input()
  
  Select UCase(choice$)
    Case "1"
      ; Check if note exists today
      todayIdx = FindNoteByDate(TodayDate())
      If todayIdx >= 0
        SelectElement(Notes(), todayIdx)
        ClsScreen()
        SetColor(10)
        CenterText(5, "[You already wrote today:]")
        SetMoodColor(Notes()\mood$)
        CenterText(7, "Mood: " + Notes()\mood$)
        SetNormal()
        excerpt$ = Left(ReplaceString(Notes()\text$, Chr(10), " "), 70)
        CenterText(8, excerpt$)
        SetHighlight()
        CenterText(10, "Change it? (Y/N)")
        SetNormal()
        ConsoleLocate(38, 12) : Print("> ")
        ch$ = Input()
        If UCase(ch$) = "Y"
          WriteNote()
        EndIf
      Else
        WriteNote()
      EndIf
      
    Case "2" : ViewHistory()
    Case "3" : GrepMemories()
    Case "4" : ShowStats()
    Case "5" : ShowMoodGraph()
    Case "6" : ShowCalendar()
    Case "7" : ShowWordFrequency()
    Case "8" : WriteFutureLetter()
    Case "9" : UnsentLetter()
    Case "R" : CozyReadingMode()
    Case "A"
      ClsScreen()
      SetHighlight()
      CenterText(5, "1. ASCII Art")
      CenterText(6, "2. Cinematic Screensaver")
      SetNormal()
      ConsoleLocate(38, 8) : Print("> ")
      sc$ = Input()
      If sc$ = "1" : ShowASCIIArt()
      ElseIf sc$ = "2" : Screensaver()
      EndIf
    Case "B" : ViewHistoryBurn()
    Case "S" : SettingsMenu()
    Case "Q" : running = 0
  EndSelect
  
Until running = 0

; ==========================================
;  GOODBYE + FORTUNE COOKIE
; ==========================================
FortuneCookie()

ClsScreen()
SetHighlight()
CenterText(5, "Backing up your soul...")
SetNormal()
SaveNotes()
SaveAchievements()
SavePlayer()
CopyFile(NotesFile$, BackupFile$)
QBeep(400, 300) : QBeep(600, 300) : QBeep(800, 400)

ClsScreen()
SetHighlight()
CenterText(7,  "Goodbye, little me.")
CenterText(8,  "Keep coding. Keep feeling.")
CenterText(10, "You made it.")
SetNormal()
streak = CalculateStreak()
If streak > 0
  SetColor(10)
  CenterText(12, "Current streak: " + Str(streak) + " days. Don't break it!")
  SetNormal()
EndIf
CenterText(14, "Press any key to exit.")
Input()
CloseConsole()
End

; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 1
; FirstLine = 1
; Folding = ---
; EnableXP
; DPIAware
; Executable = LifeNote.exe
