
import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1

import MuseScore 3.0

MuseScore

{

    menuPath: "Plugins.NegativeHarmonyGenerator"
    description: "Generates the negative harmony of the selected/ whole score"
    version: "1.0"
    pluginType: "dialog"
    width: 400
    height: 400
    property var fifths : ["C", "G", "D", "A","E","B", "F#", "C#", "G#", "D#", "A#", "F"];
    property var split1 : [];
    property var split2 : [];
    property var allnotes : [];
    property var allnumbers : [];
    property var notesbasic : ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    property var mainarraynotes : [];
    property var mainarraynumbers : [];
    property var selectedscale : "";
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
            console.log(split1[i]+" " + split2[i]+" ");
        }

    }

    function generatenegativeharmony(note)
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
                console.log(isinsplit1);
                if (isinsplit1 == true)
                    newnote = split2[split1.indexOf(curnote)];
                else
                    newnote = split1[split2.indexOf(curnote)];

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
                break;
            }
            if (mainarraynotes[j] == newnote)
            {
                console.log(j);
                newpitch = j;
                note.pitch = newpitch;
                break;
            }
            console.log("newp "+newpitch);

        }
        console.log("new = "+newpitch);
        note.pitch = newpitch;


    }
    function applyToNotesInSelection(func)
    {
        var fullScore = !curScore.selection.elements.length
        if (fullScore)
        {
            cmd("select-all")
            curScore.startCmd()
        }
        for (var i in curScore.selection.elements)
            if (curScore.selection.elements[i].pitch)
                func(curScore.selection.elements[i]);
        if (fullScore)
        {
            curScore.endCmd();
            cmd("escape");
        }
        Qt.quit();
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
                                applyToNotesInSelection(generatenegativeharmony)
                            }

                        }
                            Button {
                        id: quitbutton
                            text: qsTranslate("PrefsDialogBase", "Quit")
                            onClicked: {
                                Qt.quit()
                            }

                        }
                    }

                }
            }
        }




    }



}