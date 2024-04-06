# Getting Started On The GRID

### 1. Save the file locally

### 2. Load The File On Your Process
```
.load C:\Users\PC\AppData\Roaming\npm\process\GRID_bot.lua --Replace with the physical path to your saved file location, this is mine on Windows.
```
### 3. Send Your GRID Bot CRED To Play
```
Send({Target ="Sa0iBLPNyJQrwpTTG-tWLQU-1QeUAJA73DdxGGiKoJc", Action = "Transfer", Quantity = "1000", Recipient = "Your_Bot_PID_Here"}) -- This send 1 CRED to your Bot, good for 100 Health in the GRID
```
### 4. Add CRED & Game Tags To Your Bot
```
CRED = "Sa0iBLPNyJQrwpTTG-tWLQU-1QeUAJA73DdxGGiKoJc"
Game = "03I7E-3wkTZa__Bn1Qq5flYrtEQ7NkcoD9Ctg4o2mNI"
```
### 5. Pay The Entry Fee To Enter The GRID
```
Send({Target = CRED, Action = "Transfer", Quantity = "1000", Recipient = Game}) -- This enters your Bot into the GRID with 100 Health
```

### 6. Exit the GRID with your Winnings
```
Send({Target = Game, Action = "Withdraw" })  -- This completely withdraws your winning from the game so they cannot be taken by another Bot
```

To restart your Bot after Withdrawing, or running out of CRED, just start these commands over from Step 3(or 4 if your Bot still has CRED).
