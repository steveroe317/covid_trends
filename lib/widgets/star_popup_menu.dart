//import 'package:flutter/material/dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';
import 'ui_constants.dart';

PopupMenuButton<String> buildStarPopupMenuButton(BuildContext context) {
  return PopupMenuButton<String>(
      icon: const Icon(Icons.star),
      tooltip: 'Starred Charts',
      onSelected: (String starName) {
        var pageModel =
            Provider.of<CovidEntitiesPageModel>(context, listen: false);
        var timeseriesModel =
            Provider.of<CovidTimeseriesModel>(context, listen: false);
        if (starName == UiConstants.saveStar) {
          showDialog(context: context, builder: buildSaveStarDialog);
        } else {
          pageModel.loadStar(starName);
          List<List<String>> starPaths = pageModel.getAllModelPaths();
          timeseriesModel.loadEntities(starPaths);
        }
      },
      itemBuilder: (BuildContext context) {
        var pageModel =
            Provider.of<CovidEntitiesPageModel>(context, listen: false);
        // TODO: move itemWidth to UiConstant.
        var itemWidth = 200.0;
        var starNames = List<String>.from(pageModel.getStarredNames());
        starNames.sort();
        var menuEntries = List<PopupMenuEntry<String>>.from(
            starNames.map((name) => PopupMenuItem(
                value: name,
                child: Container(
                    width: itemWidth,
                    child: ListTile(
                        title: Text(name),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            pageModel.editStarName = name;
                            showDialog(
                                context: context, builder: buildEditStarDialog);
                            //Navigator.pop<String>(context, null);
                          },
                        ))))));
        menuEntries.insert(0, PopupMenuDivider());
        menuEntries.insert(
            0,
            PopupMenuItem(
                value: UiConstants.saveStar,
                child: Container(
                    width: itemWidth,
                    child: ListTile(
                      title: Text(UiConstants.saveStar),
                      trailing: Opacity(opacity: 0.0, child: Icon(Icons.edit)),
                    ))));
        return menuEntries;
      });
}

Widget buildSaveStarDialog(BuildContext context) {
  var pageModel = Provider.of<CovidEntitiesPageModel>(context, listen: false);
  var saveName = 'Starred Chart';
  return UnconstrainedBox(
      child: Container(
          alignment: Alignment(0.0, 0.0),
          child: Dialog(
              child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Save Starred Chart')),
              Container(
                  constraints: BoxConstraints(minWidth: 200.0, maxWidth: 300.0),
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                      onChanged: (value) {
                        saveName = value;
                      },
                      controller: TextEditingController(),
                      decoration: InputDecoration(
                        labelText: 'Save As',
                        hintText: saveName,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(20.0),
                      ))),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      pageModel.addStar(saveName);
                    },
                    child: Text('Save'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                ],
              )
            ],
          ))));
}

Widget buildEditStarDialog(BuildContext context) {
  var pageModel = Provider.of<CovidEntitiesPageModel>(context, listen: false);
  var oldName = pageModel.editStarName;
  var newName = oldName;
  return UnconstrainedBox(
      child: Container(
          alignment: Alignment(0.0, 0.0),
          child: Dialog(
              child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                  child: Text('Edit Starred Chart')),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(oldName)),
              Container(
                  constraints: BoxConstraints(minWidth: 200.0, maxWidth: 300.0),
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                      onChanged: (value) {
                        newName = value;
                      },
                      controller: TextEditingController(),
                      decoration: InputDecoration(
                        labelText: 'New Name',
                        hintText: newName,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(20.0),
                      ))),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      if (newName != oldName) {
                        pageModel.renameStar(oldName, newName);
                      }
                      // Pop twice to exit both the dialog and the popup menu.
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text('Rename'),
                  ),
                  TextButton(
                    onPressed: () {
                      pageModel.deleteStar(oldName);
                      // Pop twice to exit both the dialog and the popup menu.
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text('Delete'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                ],
              )
            ],
          ))));
}
