
import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.2

import MuseScore 3.0

MuseScore

{

    menuPath: "Plugins.NegativeHarmonyGenerator"
    description: "Generates the negative harmony of the selected/ whole score"
    version: "1.2"
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


    function makethelargearrays() {
        for (var i = 0; i < 128; i++) {
            mainarraynumbers[i] = i;
        }
        for (var i = 0; i < 128; i++) {
            mainarraynotes[i] = notesbasic[i % notesbasic.length];
        }
    }

    function assignscaleclick(scale) {
        console.log("Selected scale: " + scale);
        makethelargearrays(); // Assuming this needs to be called here as before
        selectedscale = scale;

        // Mapping scales to their respective TPC arrays
        var scaleToTPC = {
            "C": tpcc,
            "C#": tpccsharp,
            "D": tpcd,
            "D#": tpcdsharp,
            "E": tpce,
            "F": tpcf,
            "F#": tpcfsharp,
            "G": tpcg,
            "G#": tpcgsharp,
            "A": tpca,
            "A#": tpcasharp,
            "B": tpcb
        };

        tpcarray1 = scaleToTPC[scale].slice();
        for (var i = 0; i < 128; i++) {
            tpcarrayfull[i] = tpcarray1[i % tpcarray1.length];
        }
        // Split the cycle of fifths based on the selected scale
        var splitIndex = fifths.indexOf(scale) + 1;
        split1 = fifths.slice(splitIndex, splitIndex + 6);
        split2 = fifths.slice(0, splitIndex).reverse();

        // Fill in remaining slots if not enough elements
        if (split1.length < 6) {
            split1 = split1.concat(fifths.slice(0, 6 - split1.length));
        }
        if (split2.length < 6) {
            split2 = split2.concat(fifths.slice(-6 + split2.length).reverse());
        }

        console.log("TPC Full: ", tpcarrayfull.join(", "));
        console.log("Split 1: ", split1.join(", "));
        console.log("Split 2: ", split2.join(", "));
    }

    function generatenegativeharmony(note, oldpitch)
    {
        console.log("Original pitch: " + note.pitch);

        var curnote = mainarraynotes[note.pitch];
        var split1Map = split1.reduce(function(result, note, index) {
            result[note] = split2[index];
            return result;
        }, {});

        var split2Map = split2.reduce(function(result, note, index) {
            result[note] = split1[index];
            return result;
        }, {});
        var newnote = split1Map[curnote] || split2Map[curnote];

        console.log("Current note: " + curnote + ", New note: " + newnote);

        var newpitch = 0;
        for( var i = note.pitch, j = note.pitch;i<128 && j >=0 ; j--, i++)
        {

            if( mainarraynotes[i] == newnote)
            {
                console.log(i);
                newpitch = i;
                note.pitch = newpitch;
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

        }
        console.log("new = "+newpitch);
        console.log("old = "+oldpitch);
        while (newpitch > oldpitch) 
            newpitch -= 12;
        
        note.pitch = newpitch;
        return newpitch;

    }

    // function generatenegativeharmony(note) {
    //     console.log("Original pitch: " + note.pitch);
    //    
    //     
    //     var curnote = mainarraynotes[note.pitch];

    //     
    //     var split1Map = split1.reduce(function(result, note, index) {
    //         result[note] = split2[index];
    //         return result;
    //     }, {});

    //     var split2Map = split2.reduce(function(result, note, index) {
    //         result[note] = split1[index];
    //         return result;
    //     }, {});



    //     
    //     var newnote = split1Map[curnote] || split2Map[curnote];

    //     console.log("Current note: " + curnote + ", New note: " + newnote);

    //     
    //     var newpitch = getPitchFromNoteName(newnote); // Implement this function based on your note to pitch mapping.

    //     // Adjust pitch if necessary.
    //     while (newpitch > note.pitch) {
    //         newpitch -= 12;
    //     }

    //     console.log("New pitch: " + newpitch);
    //     note.pitch = newpitch;

    //     return newpitch;
    // }

    // 
    // function getPitchFromNoteName(noteName) {
    //     
    //     return mainarraynotes.indexOf(noteName);
    // }

    
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
