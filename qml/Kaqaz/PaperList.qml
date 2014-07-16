import QtQuick 2.0

Item {
    id: paper_list
    anchors.fill: parent

    property variant list: new Array

    onListChanged: p_list.refresh()

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        z: 10
    }

    ListView {
        id: p_list
        anchors.fill: parent
        anchors.topMargin: -statusBarHeight
        anchors.bottomMargin: -navigationBarHeight
        model: ListModel{}
        maximumFlickVelocity: flickVelocity
        clip: true

        property real itemHeight: 100*physicalPlatformScale

        header: Item{
            width: p_list.width
            height: (kaqaz.isAndroid()? 20 + statusBarHeight : title.height)
        }

        footer: Item{
            width: p_list.width
            height: navigationBarHeight
        }

        delegate: PaperListItem {
            id: item
            width: p_list.width
            height: p_list.itemHeight
            last: index == p_list.model.count-1
            z: index
            idx: index
            paperId: pid
        }

        function refresh() {
            for( var i=0; i<paper_list.list.length; i++ )
                model.append({"pid":paper_list.list[i]})
        }

        Component.onCompleted: refresh()
    }

    ScrollBar {
        scrollArea: p_list; height: p_list.height; width: 8
        anchors.right: p_list.right; anchors.top: p_list.top; color: "#000000"
    }

    function positionViewAtIndex( idx ) {
        var itemsPerPage = Math.floor(p_list.height/p_list.itemHeight)
        var pad = (itemsPerPage/2>2? 2 : 1)

        if( idx<pad )
            p_list.positionViewAtBeginning()
        else
            p_list.positionViewAtIndex( idx-pad, ListView.Beginning )
    }
}