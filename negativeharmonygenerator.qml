
import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.2

import MuseScore 4.0

MuseScore

{

    menuPath: "Plugins.NegativeHarmonyGenerator"
    description: "Generates the negative harmony of the selected/ whole score"
    version: "1.0"
    pluginType: "dialog"
    width: 400
    height: 400
	id: 'pluginId'
    property var fifths : ["C", "G", "D", "A","E","B", "F#", "C#", "G#", "D#", "A#", "F"];
    property var split1 : [];
    property var split2 : [];
    property var allnotes : [];
    property var allnumbers : [];
    property var notesbasic : ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    property var mainarraynotes : [];
    property var mainarraynumbers : [];
    property var selectedscale : "";
    property var tpcc : [14,9,16,11,18,13,8,15,10,17,12,19];
    property var tpccsharp : [14,9,16,11,18,13,8,15,10,17,12,19];
    property var tpcd : [14,21,16,23,18,13,20,15,22,17,24,19];
    property var tpcdsharp : [14,9,16,11,18,13,8,15,10,17,12,19];
    property var tpce : [14,21,16,23,18,13,20,15,22,17,24,19];
    property var tpcf : [14,9,16,11,18,13,8,15,10,17,12,19];
    property var tpcfsharp : [7,9,16,11,18,13,8,15,10,17,12,19];
    property var tpcg : [14,21,16,23,18,13,20,15,22,17,24,19];
    property var tpcgsharp : [14,9,16,11,18,13,8,15,10,17,12,19];
    property var tpca : [14,21,16,23,18,13,20,15,22,17,24,19];
    property var tpcasharp : [14,9,16,11,18,13,8,15,10,17,12,19];
    property var tpcb : [14,21,16,23,18,13,20,15,22,17,24,19];
    property var tpcarray1: [];
    property var tpcarrayfull : [];

    function elementObject(track, pitches, tpcs, dur, tupdur, ratio,harmony) {
        this.track = track;
        this.pitches = pitches;
        this.tpcs = tpcs;
        this.dur = dur;
        this.tupdur = tupdur;
        this.ratio = ratio;
        this.harmony = harmony;
    }

    function activeTracks() {
        var tracks = [];
        for(var i = 0; i < curScore.selection.elements.length; i++) {
            var e = curScore.selection.elements[i];
            if(i == 0) {
                tracks.push(e.track);
                var previousTrack = e.track;
            }
            if(i > 0) {
                if(e.track != previousTrack) {
                    tracks.push(e.track);
                    previousTrack = e.track;
                }
            }
        }
        return tracks;
    }

    function doNegHarm() {
        // initialize tick variables
        var startTick;
        var endTick;

        // initialize loop object variables
        var pitches = [];
        var tpcs = [];
        var dur = [];
        var tupdur = [];
        var ratio = [];
        //var harmony = [];
        var harmony;
        var thisElement = []; // the container for chord/note/rest data
        var theRetrograde = []; // the container for the full selection

        // initialize cursor
        var cursor = curScore.newCursor();

        // check if a selection exists
        cursor.rewind(1); // rewind cursor to beginning of selection to avoid last measure bug
        if(!cursor.segment) {
            console.log("Nothing Selected");
            Qt.quit; // if nothing selected, quit
        }

        // get selection start and end ticks
        startTick = cursor.tick; // get tick at beginning of selection
        cursor.rewind(2); // go to end of selection
        endTick = cursor.tick; // get tick at end of selection
        if(endTick === 0) { // if last measure selected,
            endTick = curScore.lastSegment.tick; // get last tick of score instead
        }

        // get active tracks
        var tracks = activeTracks();

        cursor.rewind(1); // go to beginning of selection before starting the loop

        // go through the selection and copy all elements to an object
        for(var trackNum in tracks) {
             if(cursor.tick == 0 && trackNum < tracks.length) {
                    cursor.rewind(1); // rewind to get additional voices
                }
            cursor.track = tracks[trackNum]; // set staff index
            console.log ("cursor.track = ", cursor.track)
            // begin loop
            while(cursor.segment && cursor.tick < endTick) {
                var e = cursor.element; // current chord, note, or rest at cursor
                
                // get pitch and tpc data
                if(e.type == Element.CHORD) {
                    var notes = e.notes; // get all notes in the chord
                    var newpitch = 128;
                    for(var noteLoop = 0; noteLoop < notes.length; noteLoop++) {
                        var note = notes[noteLoop];
                        curScore.startCmd();
                        newpitch = generatenegativeharmony(note, newpitch)
                        curScore.endCmd();
                    }
                }
                cursor.next(); // advance the cursor (unless you want to get stuck in a while loop)
            }
            if(cursor.tick == endTick && trackNum < tracks.length) {
                cursor.rewind(1); // rewind to get additional voices
            }
        }
        
    }


    function makethelargearrays()
    {
        for (var i   = 0 ; i< 128; i ++)
        {
            mainarraynumbers[i] = i;
        }
        var k = 0;
        for(var i = 0; i < 128; i ++)
        {
            mainarraynotes[i] = notesbasic[k];
            if ( k ==12)
            {
                k = 0;
                mainarraynotes[i]=notesbasic[k];
            }
            k++;
        }
        for (var i = 0; i<128; i++)
        {
            console.log(mainarraynotes[i]+" "+mainarraynumbers[i]);
        }
    }
    function assignscaleclick(scale)
    {
        console.log("2");
        makethelargearrays();
        selectedscale = scale;
        if (scale == "C")
        {
            for (var p = 0 ; p <12 ; p++)
                tpcarray1[p] = tpcc[p];
        }
        if (scale == "C#")
        {
            for (var p = 0 ; p <12 ; p++)
                tpcarray1[p] = tpccsharp[p];
        }
        if (scale == "D")
        {
            for (var p = 0 ; p <12 ; p++)
                tpcarray1[p] = tpcd[p];
        }
        if (scale == "D#")
        {
            for (var p = 0 ; p <12 ; p++)
                tpcarray1[p] = tpcdsharp[p];
        }
        if (scale == "E")
        {
            for (var p = 0 ; p <12 ; p++)
                tpcarray1[p] = tpce[p];
        }
        if (scale == "F")
        {
            for (var p = 0 ; p <12 ; p++)
                tpcarray1[p] = tpcf[p];
        }
        if (scale == "F#")
        {
            for (var p = 0 ; p <12 ; p++)
                tpcarray1[p] = tpcfsharp[p];
        }
        if (scale == "G")
        {
            for (var p = 0 ; p <12 ; p++)
                tpcarray1[p] = tpcg[p];
        }
        if (scale == "G#")
        {
            for (var p = 0 ; p <12 ; p++)
                tpcarray1[p] = tpcgsharp[p];
        }
        if (scale == "A")
        {
            for (var p = 0 ; p <12 ; p++)
                tpcarray1[p] = tpca[p];
        }
        if (scale == "A#")
        {
            for (var p = 0 ; p <12 ; p++)
                tpcarray1[p] = tpcasharp[p];
        }
        if (scale == "B")
        {
            for ( var p = 0; p < 12; p++)
                tpcarray1[p] = tpcb[p];
        }
        var k = 0;
        for ( var i = 0; i<128; i ++)
        {
            tpcarrayfull[i] = tpcarray1[k];

            if (k ===12)
            {
                k = 0;
                tpcarrayfull[i] = tpcarray1[k];

            }

            k++;
        }
        for( var i = 0; i < 128; i++)
        {
            console.log("tpcfull = "+tpcarrayfull[i]);
        }

        for (var j = fifths.indexOf(scale)+1, k = 0;k<6;j ++, k++)
        {
            if (j == 12)
                j = 0;
            console.log(fifths[j]);
            split1[k] = fifths[j];
        }
        var k = 0;
        while (k < 6)
        {
            if ( j == 12)
                j = 0;
            split2[k] = fifths[j];
            k++;
            j++;
        }
        split2 = split2.reverse();
        for (var i = 0 ; i <6; i++)
        {
            //console.log(split1[i]+" " + split2[i]+" ");
        }

    }

    function generatenegativeharmony(note, oldpitch)
    {
        var curnote = "", newnote = "";
        var noteindex;
        console.log("pitch = "+note.pitch);
        for ( var i = 0; i < 128; i++)
        {
            if (note.pitch == i)
            {
                console.log("pitch = "+note.pitch);
                curnote = mainarraynotes[i];
                console.log("curnote = "+curnote);
                var isinsplit1 = false;
                for (var p = 0 ;p< 6;p++)
                {
                    if (split1[p] == curnote)
                    {
                        isinsplit1 = true;
                        break;
                    }

                }
                //console.log("isinsplit1");
                if (isinsplit1 == true){
                    console.log("isinsplit1");
                    newnote = split2[split1.indexOf(curnote)];
                }
                else {
                    console.log("isinsplit2");
                    newnote = split1[split2.indexOf(curnote)];
                }

            }

        }
        console.log("newnote = "+newnote);
        var newpitch = 0;
        for( var i = note.pitch, j = note.pitch;i<128 && j >=0 ; j--, i++)
        {

            if( mainarraynotes[i] == newnote)
            {
                console.log(i);
                newpitch = i;
                note.pitch = newpitch;
                //note.tpc2 = tpcarrayfull[i];
                note.tpc1 = tpcarrayfull[i];
                note.tpc2 = tpcarrayfull[i];
                break;
            }
            if (mainarraynotes[j] == newnote)
            {
                console.log(j);
                newpitch = j;
                note.pitch = newpitch;
                note.tpc2 = tpcarrayfull[j];
                note.tpc1 = tpcarrayfull[j];
                break;
            }
            //console.log("newp "+newpitch);

        }
        console.log("new = "+newpitch);
        console.log("old = "+oldpitch);
        while (newpitch > oldpitch) newpitch -= 12;
        
        note.pitch = newpitch;
        return newpitch;

    }
    

    Rectangle
    {
        color: "lightgrey"
        anchors.fill: parent
        GridLayout
        {
            columns: 2
            anchors.fill: parent
            anchors.margins: 10
            GroupBox
            {
                title: "Select Scale"
                ColumnLayout
                {
                    ExclusiveGroup {id: availablescales}
                    RadioButton{
                        id: c_scale_button
                        text: "C"
                        checked: true
                        exclusiveGroup: availablescales
                        onClicked: {assignscaleclick(notesbasic[0])}
                    }
                    RadioButton{
                        id: csharp_scale_button
                        text: "C#"
                        exclusiveGroup: availablescales
                        onClicked: { assignscaleclick(notesbasic[1])}

                    }
                    RadioButton{
                        id: d_scale_button
                        text: "D"
                        exclusiveGroup: availablescales
                        onClicked: { assignscaleclick(notesbasic[2])}

                    }
                    RadioButton{
                        id: dsharp_scale_button
                        text: "D#"
                        exclusiveGroup: availablescales
                        onClicked: { assignscaleclick(notesbasic[3])}

                    }
                    RadioButton{
                        id: e_scale_button
                        text: "E"
                        exclusiveGroup: availablescales
                        onClicked: { assignscaleclick(notesbasic[4])}

                    }
                    RadioButton{
                        id: f_scale_button
                        text: "F"
                        exclusiveGroup: availablescales
                        onClicked: { assignscaleclick(notesbasic[5])}

                    }
                    RadioButton{
                        id: fsharp_scale_button
                        text: "F#"
                        exclusiveGroup: availablescales
                        onClicked: { assignscaleclick(notesbasic[6])}

                    }
                    RadioButton{
                        id: g_scale_button
                        text: "G"
                        exclusiveGroup: availablescales
                        onClicked: { assignscaleclick(notesbasic[7])}

                    }
                    RadioButton{
                        id: gsharp_scale_button
                        text: "G#"
                        exclusiveGroup: availablescales
                        onClicked: { assignscaleclick(notesbasic[8])}

                    }
                    RadioButton{
                        id: a_scale_button
                        text: "A"
                        exclusiveGroup: availablescales
                        onClicked: { assignscaleclick(notesbasic[9])}

                    }
                    RadioButton{
                        id: asharp_scale_button
                        text: "A#"
                        exclusiveGroup: availablescales
                        onClicked: { assignscaleclick(notesbasic[10])}

                    }
                    RadioButton{
                        id: b_scale_button
                        text: "B"
                        exclusiveGroup: availablescales
                        onClicked: { assignscaleclick(notesbasic[11])}

                    }



                }
            }
            ColumnLayout
            {



                GroupBox
                {
                    title: "Apply Changes/ Quit"
                    RowLayout
                    {
                        Button {
                            id: applyButton
                            text: qsTranslate("PrefsDialogBase", "Apply")
                            onClicked: {
                                var fullScore = !curScore.selection.elements.length
                                if (fullScore)
                                {
                                    cmd("select-all")
                                }
                                if (selectedscale === "")
                                    assignscaleclick("C");
                                doNegHarm();
                                if (fullScore)
                                {
                                    cmd("escape");
                                }
								pluginId.parent.Window.window.close();
                            }

                        }
                            Button {
                        id: quitbutton
                            text: qsTranslate("PrefsDialogBase", "Quit")
                            onClicked: {
                                pluginId.parent.Window.window.close();
                            }

                        }
                    }

                }
            }
        }




    }



}
