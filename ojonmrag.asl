// Oh Jeez, Oh No, My Rabbits Are Gone!!!
// Autosplitter by duncathan_salt

state("MyRabbitsAreGone", "1.3.1.2") {
    double roomId : 0x004DBA74, 0x2C, 0x10, 0x654, 0x250;

    double normalEnd : 0x004DBA74, 0x2C, 0x10, 0x654, 0x270;
    double trueEnd : 0x004DBA74, 0x2C, 0x10, 0x654, 0x260;

    double magnetX : 0x004DBA74, 0x2C, 0x10, 0x654, 0x230;
    double magnetY : 0x004DBA74, 0x2C, 0x10, 0x654, 0x220;

    double playerState : 0x004DBA74, 0x2C, 0x10, 0x654, 0x1D0;
    double playerX : 0x004DBA74, 0x2C, 0x10, 0x654, 0x200;
    double playerY : 0x004DBA74, 0x2C, 0x10, 0x654, 0x1F0;
}

state("MyRabbitsAreGone", "1.3.1.3") {
    double roomId : 0x003829c, 0x7c, 0xac, 0x24, 0xd80;

    double normalEnd : 0x003829c, 0x7c, 0xac, 0x24, 0xda0;
    double trueEnd : 0x003829c, 0x7c, 0xac, 0x24, 0xd90;

    double magnetX : 0x003829c, 0x7c, 0xac, 0x24, 0xd60;
    double magnetY : 0x003829c, 0x7c, 0xac, 0x24, 0xd50;

    double playerState : 0x003829c, 0x7c, 0xac, 0x24, 0xd00;
    double playerX : 0x003829c, 0x7c, 0xac, 0x24, 0xd30;
    double playerY : 0x003829c, 0x7c, 0xac, 0x24, 0xd20;   
}

startup {
    refreshRate = 60;

    settings.Add("StartGameDoor", true, "Start Game When Entering House Door");
    settings.Add("StartGameFile", false, "Start Game When Entering New File");

    settings.Add("SplitExit", true, "Split When Exiting");
    settings.Add("SplitPlateauExit", true, "Exit Plateau", "SplitExit");
    settings.Add("SplitCaveExit", true, "Exit Cave", "SplitExit");
    settings.Add("SplitForestExit", true, "Exit Forest", "SplitExit");
    settings.Add("SplitLakeExit", true, "Exit Lake", "SplitExit");
    settings.Add("SplitNightTransExit", true, "Exit Night Transition", "SplitExit");
    settings.Add("SplitNightLakeExit", true, "Exit Night Lake", "SplitExit");
    settings.Add("SplitNightForestExit", true, "Exit Night Forest", "SplitExit");
    settings.Add("SplitNightCaveExit", true, "Exit Night Cave", "SplitExit");
    settings.Add("SplitNightPlateauExit", true, "Exit Night Plateau", "SplitExit");
    
    settings.Add("SplitEnter", false, "Split When Entering");
    settings.Add("SplitPlateau", true, "Enter Cave Transition", "SplitEnter");
    settings.Add("SplitCave", true, "Enter Forest Transition", "SplitEnter");
    settings.Add("SplitForest", true, "Enter Lake Transition", "SplitEnter");
    settings.Add("SplitLake", true, "Enter Night Transition", "SplitEnter");
    settings.Add("SplitNightTrans", true, "Enter Night Lake", "SplitEnter");
    settings.Add("SplitNightLake", true, "Enter Night Forest", "SplitEnter");
    settings.Add("SplitNightForest", true, "Enter Night Cave", "SplitEnter");
    settings.Add("SplitNightCave", true, "Enter Night Plateau 1", "SplitEnter");
    settings.Add("SplitNightPlateau", true, "Enter Night Plateau 2", "SplitEnter");

    settings.Add("SplitEndings", true, "Split For Endings");
    settings.Add("SplitNormalEnd", true, "Normal Ending", "SplitEndings");
    settings.Add("SplitTrueEnd", false, "True Ending", "SplitEndings");
}

init {
    string MD5Hash;
    using (var md5 = System.Security.Cryptography.MD5.Create())
        using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
            MD5Hash = md5.ComputeHash(s).Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
    switch (MD5Hash)
    {
        case "E5CEDC05FAD16B9954499167623C4501": // steam
        case "3001F1AC3947DEB328280891CB79DB8B": // itch
            version = "1.3.1.3";
            break;
        default:
            version = "1.3.1.2";
            break;
    }

    print("Connecting...");

    vars.triggeredSplits = new List<string>();
    vars.PrevPhase = null;
    
    Func<string, bool> trySplit = (split) => {
        print("Attempting split: " + split);
        if (!settings[split]) { print("Failure (settings)"); return false; }
        if (!vars.triggeredSplits.Contains(split)) {
            vars.triggeredSplits.Add(split);
            print("Success");
            return true;
        }
        print("Failure (already split)");
        return false;
    };
    vars.trySplit = trySplit;
    
    Func<dynamic, double, double, bool> checkMagnet = (_current, x, y) => {
        print("Checking magnet: " + x.ToString() + "," + y.ToString());
        return _current.playerState == vars.states["state_player_cutscene"] && _current.magnetX == x && _current.magnetY == y;
    };
    vars.checkMagnet = checkMagnet;

    Func<dynamic, string, dynamic, string, bool> mapTransition = (_old, oldmap, _current, newmap) => {
        print("Checking map transition: " + oldmap + " -> " + newmap);
        return _current.roomId == vars.rooms[newmap] && _old.roomId == vars.rooms[oldmap];
    };
    vars.mapTransition = mapTransition;
    
    // states
    vars.states = new Dictionary<string, double>();
    vars.states["state_player_cutscene"] = 41;
    vars.states["state_player_entering"] = 53;
    vars.states["state_player_jump"] = 44;

    // rooms
    vars.rooms = new Dictionary<string, double>();
    vars.rooms["rm_house"] = 34;
    vars.rooms["rm_intro"] = 35;
    vars.rooms["rm_mainmenu"] = 3;

    vars.rooms["rm_g1"] = 5;
    vars.rooms["rm_c1"] = 6;
    vars.rooms["rm_f1"] = 15;
    vars.rooms["rm_l1"] = 19;
    
    vars.rooms["rm_cavetransition"] = 9;
    vars.rooms["rm_foresttransition"] = 17;
    vars.rooms["rm_laketransition"] = 18;
    vars.rooms["rm_nighttransition"] = 21;

    vars.rooms["rm_n1"] = 22;
    vars.rooms["rm_n2"] = 23;
    vars.rooms["rm_n3"] = 24;
    vars.rooms["rm_n4"] = 25;
    vars.rooms["rm_n4_2"] = 26;
    vars.rooms["rm_n5"] = 27;
}

update {
    if (timer.CurrentPhase != vars.PrevPhase) {
        vars.PrevPhase = timer.CurrentPhase;

        if (timer.CurrentPhase == TimerPhase.NotRunning) {
            vars.triggeredSplits.Clear();
        }
    }
}

start {
    if (settings["StartGameDoor"]) {
        return current.roomId == vars.rooms["rm_house"] && vars.checkMagnet(current, 202, 143) && current.playerX > 128;
    }
    if (settings["StartGameFile"]) {
        return vars.mapTransition(old, "rm_mainmenu", current, "rm_intro");
    }
}

split {
    bool toSplit = false;

    // exits
    if (settings["SplitExit"]) {
        if (current.roomId == vars.rooms["rm_g1"] && vars.checkMagnet(current, 3696, 688)) {
            // interact with plateau exit door
            toSplit |= vars.trySplit("SplitPlateauExit");
        }
        if (current.roomId == vars.rooms["rm_c1"] && vars.checkMagnet(current, 2256, 1664)) {
            // interact with cave exit door
            toSplit |= vars.trySplit("SplitCaveExit");
        }
        if (current.roomId == vars.rooms["rm_f1"] && current.playerX >= 3808 && current.playerY >= 688) {
            // touch forest exit trigger
            toSplit |= vars.trySplit("SplitForestExit");
        }
        if (current.roomId == vars.rooms["rm_l1"] && current.playerX <= 16 && current.playerY >= 880) {
            // touch lake exit trigger
            toSplit |= vars.trySplit("SplitLakeExit");
        }
        if (current.roomId == vars.rooms["rm_nighttransition"] && old.roomId == current.roomId && current.playerX <= 80 && current.playerY >= 176) {
            // touch night transition exit trigger
            toSplit |= vars.trySplit("SplitNightTransExit");
        }
        if (current.roomId == vars.rooms["rm_n1"] && current.playerState == vars.states["state_player_cutscene"] && current.playerY <= 256 && current.playerX >= 672 && current.playerX <= 768 ) {
            // land on night lake exit minecart
            toSplit |= vars.trySplit("SplitNightLakeExit");
        }
        if (old.roomId == vars.rooms["rm_n2"] && current.roomId == old.roomId && current.playerState == vars.states["state_player_entering"]) {
            // interact with night forest exit door
            toSplit |= vars.trySplit("SplitNightForestExit");
        }
        if (old.roomId == vars.rooms["rm_n3"] && current.roomId == old.roomId && current.playerState == vars.states["state_player_entering"]) {
            // interact with night cave exit door
            toSplit |= vars.trySplit("SplitNightCaveExit");
        }
        if (current.roomId == vars.rooms["rm_n4"] && current.playerX >= 3824) {
            // touch night plateau 1 exit trigger
            toSplit |= vars.trySplit("SplitNightPlateauExit");
        }
    }

    // entrances
    if (settings["SplitEnter"]) {
        if (vars.mapTransition(old, "rm_g1", current, "rm_cavetransition")) {
            toSplit |= vars.trySplit("SplitPlateau");
        }
        if (vars.mapTransition(old, "rm_c1", current, "rm_foresttransition")) {
            toSplit |= vars.trySplit("SplitCave");
        }
        if (vars.mapTransition(old, "rm_f1", current, "rm_laketransition")) {
            toSplit |= vars.trySplit("SplitForest");
        }
        if (vars.mapTransition(old, "rm_l1", current, "rm_nighttransition")) {
            toSplit |= vars.trySplit("SplitLake");
        }
        if (vars.mapTransition(old, "rm_nighttransition", current, "rm_n1")) {
            toSplit |= vars.trySplit("SplitNightTrans");
        }
        if (vars.mapTransition(old, "rm_n1", current, "rm_n2")) {
            toSplit |= vars.trySplit("SplitNightLake");
        }
        if (vars.mapTransition(old, "rm_n2", current, "rm_n3")) {
            toSplit |= vars.trySplit("SplitNightForest");
        }
        if (vars.mapTransition(old, "rm_n3", current, "rm_n4")) {
            toSplit |= vars.trySplit("SplitNightCave");
        }
        if (vars.mapTransition(old, "rm_n4", current, "rm_n4_2")) {
            toSplit |= vars.trySplit("SplitNightPlateau");
        }
    }
    
    // endings
    if (current.normalEnd == 1) {
        toSplit |= vars.trySplit("SplitNormalEnd");
    }
    if (current.trueEnd == 1) {
        toSplit |= vars.trySplit("SplitTrueEnd");
    }

    return toSplit;
}
