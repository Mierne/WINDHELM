MODE con: cols=120 lines=28
REM Combat Engine Pre-Alpha Version 0.8.0
REM Extra Build Information: wce-250113.PA8.GU0 - "Abyssal"

:EBS
MODE con: cols=120 lines=28
IF %enemy.health% LEQ 0 GOTO :VICTORY_STATS_TRACK
IF %player.health% LEQ 0 GOTO :DEFEAT_SCREEN
TITLE (WINDHELM) - COMBAT ENGINE ^| %player.name% the %player.class% vs %curEn% & SET enAT=%enATb%
CLS
ECHO.
TYPE "%winLoc%\data\assets\enemies\Iridescent Forest\%currentEnemy%.txt"
ECHO.
ECHO +-------------------------------------------------------------------------------------------------------+
ECHO ^| %currentEnemy% HP: %enemy.health% ^| ATK %enemy.damage%
ECHO ^| %displayMessage% ^| %player.message%
ECHO +-------------------------------------------------------------------------------------------------------+
ECHO ^| HP: %player.health% ^| XP: %player.xp%/%player.xp_required% ^| LUNIS: %player.coins% ^| AT: %player.damage% ^| AM: %player.armor% ^| ST: %player.stamina% ^| MG: %player.magicka%
ECHO +-------------------------------------------------------------------------------------------------------+
ECHO ^| [A / ATTACK ] ^| [I / ITEMS ] ^| [R / RECOVER ] ^| [Q / FLEE ]
ECHO +-------------------------------------------------------------------------------------------------------+
CHOICE /C AIRQ /N /M ">"
IF ERRORLEVEL 4 GOTO :PLAYER_FLEE
IF ERRORLEVEL 3 GOTO :PLAYER_RECOVER
IF ERRORLEVEL 2 GOTO :PLAYER_ITEMS
IF ERRORLEVEL 1 GOTO :PLAYER_ATTACK_SC

:PLAYER_ATTACK_SC
IF %player.stamina% LSS %player.attack_stamina% (
    SET player.message=Not enough stamina^!
    GOTO :EBS
) ELSE (
    GOTO :PLAYER_ATTACK
)

:PLAYER_ATTACK
SET /A PA=%RANDOM% %%50
IF %PA% LEQ 15 (
    SET player.message=Critical hit^!
    SET /A enemy.health=!enemy.health! -%player.damage%*2
    GOTO  :PLAYER_ARMOR_CALCULATION
) ELSE IF %PA% GEQ 35 (
    SET player.message=Critical hit^!
    SET /A enemy.health=!enemy.health! -%player.damage*2
    GOTO :PLAYER_ARMOR_CALCULATION
) ELSE IF %PA% GEQ 20 (
    SET player.message=Normal attack placeholder
    SET /A enemy.health=!enemy.health! -%player.damage%
) ELSE (
    SET player.message=You missed^!
    GOTO :PLAYER_ARMOR_CALCULATION
)

:PLAYER_ARMOR_CALCULATION
SET enemy.damage=%enemy.damage_base%
IF %player.armor_prot% LEQ 0 ( 
    GOTO :ENEMY_ATTACK_CALCULATION
) ELSE (
    SET /A enemy.damage=!enemy.damage! -%player.armor_prot%
    GOTO :ENEMY_ATTACK_CALCULATION
)

:ENEMY_ATTACK_CALCULATION
REM Check if this is a boss fight.
IF %ce.boss_active% EQU 1 (
    REM A boss fight is active, goto the boss label.
) ELSE (
    SET /A EAC=%RANDOM% %%40
        IF %EAC% GTR 30 (
            SET displayMessage=The enemy got a critical hit^!
            SET /A player.health=!player.health! -%enemy.damage%*2
            GOTO :EBS
        ) ELSE IF %EAC% GTR 20 (
            SET displayMessage=You were unable to dodge the %curEn%'s swift attack^!
            SET /A player.health=!player.health! -%enemy.damage%
            GOTO :EBS
        ) ELSE IF %EAC% GTR 12 (
            SET displayMessage=The enemy lands a glancing blow, a weak hit^!
            SET /A player.health=!player.health! -%enemy.damage%
            SET /A player.health=!player.health! +8
            GOTO :EBS
        ) ELSE (
            SET displayMessage=You see the attack coming from miles away and move out of the way before it connects.
            GOTO :EBS
        )
)

:EAC_BOSS
REM BOSS FIGHT MECHANICS

:PLAYER_INVENTORY
REM REDESIGN PLAYER INVENTORY ACCESS

:ERROR_HANDLER
CALL "%cd%\data\functions\Error Handler.bat"
CLS
ECHO.
ECHO An error has occured in Combat Engine. It is not recommended that you continue.
ECHO Save your game and exit?
CHOICE /C YN /N /M "Y/N"
IF ERRORLEVEL 2 GOTO :EH_WARN
IF ERRORLEVEL 1 GOTO :EH_CS

:EH_WARN
ECHO You have been warned.
PAUSE
GOTO :EBS

:EH_CS
SET SLOPr=SAVE
CALL "%winLoc%\data\functions\SLOP.bat"
EXIT

:VICTORY_STATS_TRACK
IF %currentEnemy% == "Bandit" (
    SET /A player.bandits_slain=!player.bandits_slain! +1
    GOTO :VICTORY_REWARDS
) ELSE (
    GOTO :VICTORY_REWARDS
)

:VICTORY_REWARDS
REM REWORK VICTORY REWARDS

:VICTORY_SCREEN
REM REDESIGN VICTORY SCREEN

:LOOT
REM REWORK ceLOOT

:DEFEAT_SCREEN
SET /A player.total_deaths=!player.total_deaths! +1
REM REDESIGN DEFEAT SCREEN

:EXIT
SET player.armor_calculated=1
SET enemy.attack=%enemy.attack_normal%
GOTO :EOF